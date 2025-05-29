import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../models/language_model.dart';
import '../../../../models/translation_result.dart';
import '../constants/api_constants.dart';

class DeeplTranslationService {
  // مفتاح تخزين API
  static const String _apiKeyPreference = 'deepl_api_key';

  // الحصول على مفتاح API المخزن
  Future<String?> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_apiKeyPreference);
    } catch (e) {
      debugPrint('خطأ في الحصول على مفتاح API: $e');
      return null;
    }
  }

  // حفظ مفتاح API
  Future<bool> saveApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_apiKeyPreference, apiKey);
    } catch (e) {
      debugPrint('خطأ في حفظ مفتاح API: $e');
      return false;
    }
  }

  // تحويل رمز اللغة إلى الصيغة التي يتوقعها DeepL
  String _formatLanguageCode(String code) {
    // تنسيق رمز اللغة إلى الصيغة التي يتوقعها DeepL
    final formattedCode = code.toUpperCase();

    // أمثلة على رموز اللغات المدعومة في DeepL
    switch (formattedCode) {
      case 'AR':
        return 'AR'; // العربية
      case 'EN':
        return 'EN'; // الإنجليزية
      case 'FR':
        return 'FR'; // الفرنسية
      case 'DE':
        return 'DE'; // الألمانية
      case 'IT':
        return 'IT'; // الإيطالية
      case 'ES':
        return 'ES'; // الإسبانية
      case 'JA':
        return 'JA'; // اليابانية
      case 'ZH':
        return 'ZH'; // الصينية
      case 'RU':
        return 'RU'; // الروسية
      case 'PT':
        return 'PT'; // البرتغالية
      // إضافة المزيد من اللغات حسب الحاجة
      default:
        return formattedCode;
    }
  }

  // ترجمة نص باستخدام DeepL API
  Future<TranslationResult> translateText({
    required String text,
    required LanguageModel sourceLanguage,
    required LanguageModel targetLanguage,
  }) async {
    // التقاط كل الأخطاء المحتملة
    try {
      // التحقق من وجود نص للترجمة
      if (text.isEmpty) {
        return TranslationResult.error(
          originalText: text,
          errorMessage: 'النص فارغ. يرجى إدخال نص للترجمة.',
        );
      }

      // الحصول على مفتاح API
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        return TranslationResult.error(
          originalText: text,
          errorMessage:
              'مفتاح API غير موجود. يرجى إضافة مفتاح DeepL API في الإعدادات.',
        );
      }

      // تحضير رموز اللغات بالصيغة الصحيحة
      final sourceLang = _formatLanguageCode(sourceLanguage.code);
      final targetLang = _formatLanguageCode(targetLanguage.code);

      // معلومات تشخيصية
      debugPrint('ترجمة من $sourceLang إلى $targetLang');
      debugPrint('طول النص: ${text.length} حرف');

      // تحديد ما إذا كان يستخدم API المجاني أو الاحترافي
      final isProAccount = !apiKey.endsWith(':fx');
      final baseUrl = isProAccount
          ? 'https://api.deepl.com/v2'
          : 'https://api-free.deepl.com/v2';

      // إنشاء طلب الترجمة
      final url = Uri.parse('$baseUrl/translate');

      // إعداد معلمات الطلب
      final Map<String, dynamic> requestBody = {
        'text': [text],
        'target_lang': targetLang,
      };

      // إضافة لغة المصدر إذا لم تكن تلقائية
      if (sourceLang != 'AUTO') {
        requestBody['source_lang'] = sourceLang;
      }

      // إجراء طلب الترجمة مع مراقبة الأخطاء
      final response = await http
          .post(
        url,
        headers: {
          'Authorization': 'DeepL-Auth-Key $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 30), // مهلة زمنية للطلب
        onTimeout: () {
          return http.Response(
            jsonEncode({'error': 'انتهت مهلة الاتصال بالخادم'}),
            408, // Request Timeout
          );
        },
      );

      // طباعة معلومات للتشخيص
      debugPrint('رمز استجابة API: ${response.statusCode}');

      // معالجة الاستجابة حسب رمز الحالة
      switch (response.statusCode) {
        case 200:
          // نجاح الطلب - معالجة الاستجابة
          try {
            final decodedResponse = jsonDecode(response.body);

            // محاولة طباعة نص الاستجابة للتشخيص
            debugPrint(
                'استلام استجابة: ${response.body.substring(0, math.min(100, response.body.length))}...');

            // استخراج النص المترجم
            final translations = decodedResponse['translations'] as List;
            if (translations.isNotEmpty) {
              final translatedText = translations[0]['text'] as String;

              // نجاح الترجمة
              return TranslationResult.success(
                originalText: text,
                translatedText: translatedText,
              );
            } else {
              // لا توجد ترجمات في الاستجابة
              return TranslationResult.error(
                originalText: text,
                errorMessage: 'لم يتم العثور على ترجمات في استجابة API',
              );
            }
          } catch (e) {
            // خطأ في معالجة استجابة API
            debugPrint('خطأ في معالجة استجابة API: $e');
            return TranslationResult.error(
              originalText: text,
              errorMessage: 'خطأ في معالجة استجابة API: $e',
            );
          }

        case 400:
          // طلب غير صالح
          String errorDetails = '';
          try {
            final error = jsonDecode(response.body);
            errorDetails = error['message'] ?? 'تفاصيل الخطأ غير متوفرة';
          } catch (_) {
            errorDetails = response.body;
          }

          return TranslationResult.error(
            originalText: text,
            errorMessage: 'طلب غير صالح: $errorDetails',
          );

        case 401:
        case 403:
          // مشكلة في المصادقة أو الوصول
          return TranslationResult.error(
            originalText: text,
            errorMessage:
                'خطأ في المصادقة: مفتاح API غير صالح أو منتهي الصلاحية.',
          );

        case 404:
          // المورد غير موجود
          return TranslationResult.error(
            originalText: text,
            errorMessage:
                'عنوان API غير موجود. تأكد من استخدام النسخة الصحيحة من API.',
          );

        case 413:
          // حجم الطلب كبير جدًا
          return TranslationResult.error(
            originalText: text,
            errorMessage: 'النص كبير جدًا للترجمة. يرجى تقسيمه إلى أجزاء أصغر.',
          );

        case 429:
          // تجاوز حد الاستخدام
          return TranslationResult.error(
            originalText: text,
            errorMessage:
                'تم تجاوز حد استخدام API. يرجى المحاولة لاحقًا أو الترقية إلى خطة أعلى.',
          );

        case 456:
          // حد استخدام الحساب
          return TranslationResult.error(
            originalText: text,
            errorMessage: 'تم الوصول إلى حد ترجمة الحساب الشهري.',
          );

        case 500:
        case 503:
          // خطأ داخلي في الخادم
          return TranslationResult.error(
            originalText: text,
            errorMessage: 'خطأ في خادم DeepL. يرجى المحاولة لاحقًا.',
          );

        case 408:
          // انتهاء مهلة الطلب
          return TranslationResult.error(
            originalText: text,
            errorMessage:
                'انتهت مهلة الاتصال بخادم DeepL. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
          );

        default:
          // خطأ غير معروف
          return TranslationResult.error(
            originalText: text,
            errorMessage:
                'فشل في التحقق من حالة الترجمة: ${response.statusCode}',
          );
      }
    } catch (e) {
      // التقاط أي استثناء غير متوقع
      debugPrint('خطأ غير متوقع في ترجمة النص: $e');

      String errorMessage = 'حدث خطأ غير متوقع: $e';

      // معالجة أنواع معينة من الأخطاء
      if (e is SocketException) {
        errorMessage = 'تعذر الاتصال بخادم DeepL. تحقق من اتصالك بالإنترنت.';
      } else if (e is FormatException) {
        errorMessage = 'خطأ في تنسيق البيانات: $e';
      } else if (e is TimeoutException) {
        errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
      }

      return TranslationResult.error(
        originalText: text,
        errorMessage: errorMessage,
      );
    }
  }

  // ترجمة مستند باستخدام DeepL API
  Future<TranslationResult> translateDocument({
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
    required LanguageModel sourceLanguage,
    required LanguageModel targetLanguage,
  }) async {
    try {
      // التحقق من وجود مفتاح API
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        return TranslationResult.error(
          originalText: 'مستند',
          errorMessage:
              'مفتاح API غير موجود. يرجى إضافة مفتاح DeepL API في الإعدادات.',
        );
      }

      // التحقق من توافق الملف
      final fileExtension = path.extension(fileName).toLowerCase();
      if (!ApiConstants.supportedFileExtensions
          .contains(fileExtension.replaceFirst('.', ''))) {
        return TranslationResult.error(
          originalText: 'مستند',
          errorMessage:
              'نوع الملف غير مدعوم: $fileExtension. الأنواع المدعومة: '
              '${ApiConstants.supportedFileExtensions.join(", ")}',
        );
      }

      // التحقق من حجم الملف (الحد الأقصى 20 ميجابايت لـ DeepL)
      final fileSizeInMB = fileBytes.length / (1024 * 1024);
      if (fileSizeInMB > 20) {
        return TranslationResult.error(
          originalText: 'مستند',
          errorMessage:
              'حجم الملف (${fileSizeInMB.toStringAsFixed(2)} ميجابايت) أكبر من الحد المسموح به (20 ميجابايت).',
        );
      }

      // تحضير رموز اللغات بالصيغة الصحيحة
      final sourceLang = _formatLanguageCode(sourceLanguage.code);
      final targetLang = _formatLanguageCode(targetLanguage.code);

      debugPrint('ترجمة مستند من $sourceLang إلى $targetLang');
      debugPrint(
          'اسم الملف: $fileName، حجم الملف: ${(fileBytes.length / 1024).toStringAsFixed(2)} كيلوبايت');

      // تحديد ما إذا كان يستخدم API المجاني أو الاحترافي
      final isProAccount = !apiKey.endsWith(':fx');
      final baseUrl = isProAccount
          ? 'https://api.deepl.com/v2'
          : 'https://api-free.deepl.com/v2';

      // تحضير عنوان API
      final url = Uri.parse('$baseUrl/document');

      // إنشاء طلب متعدد الأجزاء
      final request = http.MultipartRequest('POST', url);

      // إضافة ترويسة المصادقة
      request.headers['Authorization'] = 'DeepL-Auth-Key $apiKey';

      // إضافة معلمات اللغة
      request.fields['target_lang'] = targetLang;
      if (sourceLang != 'AUTO') {
        request.fields['source_lang'] = sourceLang;
      }

      // إضافة ملف المستند
      final fileTypeInfo = mimeType.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: MediaType(fileTypeInfo[0], fileTypeInfo[1]),
        ),
      );

      // إرسال الطلب مع مراقبة الأخطاء
      debugPrint('جاري إرسال المستند للترجمة...');
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2), // وقت طويل للملفات الكبيرة
        onTimeout: () {
          throw TimeoutException('انتهت مهلة رفع المستند');
        },
      );

      // تحويل استجابة التدفق إلى استجابة عادية
      final response = await http.Response.fromStream(streamedResponse);

      // طباعة معلومات للتشخيص
      debugPrint('رمز استجابة API للمستند: ${response.statusCode}');
      debugPrint('محتوى الاستجابة: ${response.body}');

      // معالجة الاستجابة حسب رمز الحالة
      if (response.statusCode == 200) {
        // نجاح - الحصول على معرف المستند ومفتاح المستند
        try {
          Map<String, dynamic> documentInfo = jsonDecode(response.body);

          // التحقق من وجود المعلومات المطلوبة
          if (!documentInfo.containsKey('document_id') ||
              !documentInfo.containsKey('document_key')) {
            debugPrint(
                'خطأ: الاستجابة لا تحتوي على document_id أو document_key: ${response.body}');
            return TranslationResult.error(
              originalText: 'مستند',
              errorMessage:
                  'استجابة API غير صالحة: مفقود document_id أو document_key. الرجاء التحقق من صحة مفتاح API.',
            );
          }

          String documentId = documentInfo['document_id'];
          String documentKey = documentInfo['document_key'];

          // مزيد من التشخيص
          debugPrint('تم استلام document_id: $documentId');
          debugPrint('تم استلام document_key: $documentKey');

          // انتظار اكتمال الترجمة
          return await _waitForDocumentTranslation(
            documentId: documentId,
            documentKey: documentKey,
            apiKey: apiKey,
            fileName: fileName,
            baseUrl: baseUrl,
          );
        } catch (e) {
          debugPrint('خطأ في معالجة استجابة بدء ترجمة المستند: $e');
          return TranslationResult.error(
            originalText: 'مستند',
            errorMessage:
                'خطأ في بدء ترجمة المستند: $e. محتوى الاستجابة: ${response.body}',
          );
        }
      } else {
        // معالجة حالات الخطأ
        String errorDetails = '';
        try {
          final error = jsonDecode(response.body);
          errorDetails = error['message'] ?? 'تفاصيل الخطأ غير متوفرة';
        } catch (_) {
          errorDetails = response.body;
        }

        // رسائل خطأ مخصصة حسب رمز الحالة
        switch (response.statusCode) {
          case 400:
            return TranslationResult.error(
              originalText: 'مستند',
              errorMessage: 'طلب غير صالح: $errorDetails',
            );
          case 401:
          case 403:
            return TranslationResult.error(
              originalText: 'مستند',
              errorMessage:
                  'خطأ في المصادقة: مفتاح API غير صالح أو منتهي الصلاحية.',
            );
          case 404:
            return TranslationResult.error(
              originalText: 'مستند',
              errorMessage:
                  'عنوان API غير موجود. تأكد من استخدام النسخة الصحيحة من API.',
            );
          case 413:
            return TranslationResult.error(
              originalText: 'مستند',
              errorMessage: 'حجم المستند كبير جدًا للترجمة.',
            );
          case 429:
            return TranslationResult.error(
              originalText: 'مستند',
              errorMessage: 'تم تجاوز حد استخدام API. يرجى المحاولة لاحقًا.',
            );
          case 456:
            return TranslationResult.error(
              originalText: 'مستند',
              errorMessage: 'تم الوصول إلى حد ترجمة الحساب الشهري.',
            );
          default:
            return TranslationResult.error(
              originalText: 'مستند',
              errorMessage:
                  'فشل في ترجمة المستند: ${response.statusCode} - $errorDetails',
            );
        }
      }
    } catch (e) {
      // التقاط أي استثناء غير متوقع
      debugPrint('خطأ غير متوقع في ترجمة المستند: $e');

      String errorMessage = 'حدث خطأ غير متوقع: $e';

      // معالجة أنواع معينة من الأخطاء
      if (e is SocketException) {
        errorMessage = 'تعذر الاتصال بخادم DeepL. تحقق من اتصالك بالإنترنت.';
      } else if (e is FormatException) {
        errorMessage = 'خطأ في تنسيق البيانات: $e';
      } else if (e is TimeoutException) {
        errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
      }

      return TranslationResult.error(
        originalText: 'مستند',
        errorMessage: errorMessage,
      );
    }
  }

  // انتظار اكتمال ترجمة المستند
  Future<TranslationResult> _waitForDocumentTranslation({
    required String documentId,
    required String documentKey,
    required String apiKey,
    required String fileName,
    required String baseUrl,
  }) async {
    try {
      debugPrint(
          'بدء انتظار اكتمال ترجمة المستند: $documentId مع document_key: $documentKey');

      // عنوان للتحقق من حالة الترجمة
      final statusUrl = Uri.parse('$baseUrl/document/$documentId');

      // عدد محاولات التحقق من الحالة
      int attemptsCount = 0;
      const maxAttempts = 60; // تحقق لمدة ~5 دقائق

      // التحقق من حالة الترجمة بشكل متكرر
      while (attemptsCount < maxAttempts) {
        attemptsCount++;

        // انتظار 5 ثوانٍ بين كل محاولة تحقق
        if (attemptsCount > 1) {
          await Future.delayed(const Duration(seconds: 5));
        }

        debugPrint(
            'محاولة التحقق #$attemptsCount من حالة المستند: $documentId');

        // إجراء طلب التحقق مع إرسال document_key
        final statusResponse = await http
            .post(
          statusUrl,
          headers: {
            'Authorization': 'DeepL-Auth-Key $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'document_key': documentKey,
          }),
        )
            .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            return http.Response(
              jsonEncode({'error': 'انتهت مهلة التحقق من الحالة'}),
              408,
            );
          },
        );

        debugPrint('رمز استجابة حالة المستند: ${statusResponse.statusCode}');
        debugPrint('محتوى استجابة الحالة: ${statusResponse.body}');

        // التحقق من الاستجابة
        if (statusResponse.statusCode == 200) {
          try {
            final statusInfo = jsonDecode(statusResponse.body);
            final status = statusInfo['status'] as String? ?? '';

            debugPrint('حالة المستند: $status');

            if (status.toLowerCase() == 'done') {
              // تم الانتهاء من الترجمة - تنزيل الملف المترجم
              debugPrint('تم الانتهاء من ترجمة المستند، جاري التنزيل...');
              return await _downloadTranslatedDocument(
                documentId: documentId,
                documentKey: documentKey,
                apiKey: apiKey,
                originalFileName: fileName,
                baseUrl: baseUrl,
              );
            } else if (status.toLowerCase() == 'error') {
              // حدث خطأ أثناء الترجمة
              final errorMessage = statusInfo['error_message'] as String? ??
                  'خطأ غير معروف في ترجمة المستند';
              return TranslationResult.error(
                originalText: 'مستند',
                errorMessage: 'فشلت ترجمة المستند: $errorMessage',
              );
            }
            // استمر في الانتظار والتحقق مرة أخرى
          } catch (e) {
            debugPrint('خطأ في معالجة استجابة حالة المستند: $e');
            // استمر في المحاولة رغم الخطأ
          }
        } else if (statusResponse.statusCode == 400) {
          // خطأ في الطلب - قد يكون مفقود document_key
          String errorDetails = '';
          try {
            final error = jsonDecode(statusResponse.body);
            errorDetails = error['message'] ?? 'تفاصيل الخطأ غير متوفرة';
          } catch (_) {
            errorDetails = statusResponse.body;
          }

          debugPrint('خطأ 400 أثناء التحقق من حالة المستند: $errorDetails');

          // إذا كان الخطأ يتعلق بـ document_key، نعيد رسالة خطأ مفصلة
          if (errorDetails.toLowerCase().contains('document_key')) {
            return TranslationResult.error(
              originalText: 'مستند',
              errorMessage:
                  'Missing - 400: فشل في التحقق من حالة الترجمة: document_key',
            );
          }

          // الاستمرار في المحاولة رغم الخطأ للمحاولات الأولى
          if (attemptsCount >= 3) {
            return TranslationResult.error(
              originalText: 'مستند',
              errorMessage:
                  'فشل متكرر في التحقق من حالة الترجمة: $errorDetails',
            );
          }
        } else if (statusResponse.statusCode >= 401 &&
            statusResponse.statusCode < 500) {
          // أخطاء المصادقة والتصريح - لا فائدة من إعادة المحاولة
          String errorDetails = '';
          try {
            final error = jsonDecode(statusResponse.body);
            errorDetails = error['message'] ?? 'تفاصيل الخطأ غير متوفرة';
          } catch (_) {
            errorDetails = statusResponse.body;
          }

          return TranslationResult.error(
            originalText: 'مستند',
            errorMessage:
                'فشل في التحقق من حالة الترجمة: ${statusResponse.statusCode} - $errorDetails',
          );
        }
        // في حالة أخطاء أخرى (مثل أخطاء الخادم 5xx)، نستمر في المحاولة
      }

      // تجاوز الحد الأقصى لعدد المحاولات
      return TranslationResult.error(
        originalText: 'مستند',
        errorMessage: 'انتهت مهلة انتظار ترجمة المستند. يرجى المحاولة لاحقًا.',
      );
    } catch (e) {
      debugPrint('خطأ أثناء انتظار ترجمة المستند: $e');
      return TranslationResult.error(
        originalText: 'مستند',
        errorMessage: 'حدث خطأ أثناء انتظار ترجمة المستند: $e',
      );
    }
  }

  // تنزيل المستند المترجم
  Future<TranslationResult> _downloadTranslatedDocument({
    required String documentId,
    required String documentKey,
    required String apiKey,
    required String originalFileName,
    required String baseUrl,
  }) async {
    try {
      debugPrint('بدء تنزيل المستند المترجم: $documentId');

      // عنوان تنزيل المستند المترجم
      final downloadUrl = Uri.parse('$baseUrl/document/$documentId/result');

      // إجراء طلب التنزيل مع إرسال document_key
      final downloadResponse = await http
          .post(
        downloadUrl,
        headers: {
          'Authorization': 'DeepL-Auth-Key $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'document_key': documentKey,
        }),
      )
          .timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response(
            jsonEncode({'error': 'انتهت مهلة تنزيل المستند المترجم'}),
            408,
          );
        },
      );

      debugPrint('رمز استجابة تنزيل المستند: ${downloadResponse.statusCode}');
      debugPrint(
          'حجم استجابة التنزيل: ${downloadResponse.bodyBytes.length} بايت');

      // التحقق من الاستجابة
      if (downloadResponse.statusCode == 200) {
        // تنزيل ناجح - حفظ الملف
        try {
          // الحصول على اسم الملف المترجم
          String fileName = originalFileName;

          // استخراج امتداد الملف والاسم الأساسي
          final fileExtension = path.extension(fileName);
          final fileNameWithoutExtension =
              path.basenameWithoutExtension(fileName);

          // إنشاء اسم ملف جديد بإضافة "translated"
          fileName = '${fileNameWithoutExtension}_translated$fileExtension';

          // حفظ الملف
          String? filePath;
          if (kIsWeb) {
            // على الويب، نعيد البيانات مباشرة دون حفظها
            return TranslationResult.success(
              originalText: 'مستند',
              translatedText: 'تمت ترجمة المستند بنجاح. يمكنك تنزيله الآن.',
              fileBytes: downloadResponse.bodyBytes,
            );
          } else {
            // على الأجهزة، نحفظ الملف
            filePath = await _saveFile(
              fileBytes: downloadResponse.bodyBytes,
              fileName: fileName,
            );

            if (filePath == null) {
              throw Exception('فشل في حفظ الملف المترجم');
            }

            debugPrint('تم حفظ المستند المترجم في: $filePath');

            return TranslationResult.success(
              originalText: 'مستند',
              translatedText: 'تمت ترجمة المستند بنجاح وحفظه في $filePath',
              filePath: filePath,
            );
          }
        } catch (e) {
          debugPrint('خطأ في معالجة المستند المترجم المنزل: $e');
          return TranslationResult.error(
            originalText: 'مستند',
            errorMessage:
                'تم تنزيل المستند المترجم، لكن حدث خطأ أثناء معالجته: $e',
          );
        }
      } else if (downloadResponse.statusCode == 400) {
        // خطأ في الطلب - قد يكون مفقود document_key
        String errorDetails = '';
        try {
          final error = jsonDecode(downloadResponse.body);
          errorDetails = error['message'] ?? 'تفاصيل الخطأ غير متوفرة';
        } catch (_) {
          errorDetails = downloadResponse.body;
        }

        if (errorDetails.toLowerCase().contains('document_key')) {
          return TranslationResult.error(
            originalText: 'مستند',
            errorMessage:
                'Missing - 400: فشل في التحقق من حالة الترجمة: document_key',
          );
        }

        return TranslationResult.error(
          originalText: 'مستند',
          errorMessage:
              'فشل في تنزيل المستند المترجم: طلب غير صالح - $errorDetails',
        );
      } else {
        // فشل التنزيل لأسباب أخرى
        String errorDetails = '';
        try {
          final error = jsonDecode(downloadResponse.body);
          errorDetails = error['message'] ?? 'تفاصيل الخطأ غير متوفرة';
        } catch (_) {
          errorDetails = downloadResponse.body;
        }

        return TranslationResult.error(
          originalText: 'مستند',
          errorMessage:
              'فشل في تنزيل المستند المترجم: ${downloadResponse.statusCode} - $errorDetails',
        );
      }
    } catch (e) {
      debugPrint('خطأ أثناء تنزيل المستند المترجم: $e');
      return TranslationResult.error(
        originalText: 'مستند',
        errorMessage: 'حدث خطأ أثناء تنزيل المستند المترجم: $e',
      );
    }
  }

  // حفظ الملف على الجهاز
  Future<String?> _saveFile({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      // التحقق من كون التطبيق على الويب
      if (kIsWeb) {
        // على الويب، لا يمكننا حفظ الملفات بهذه الطريقة
        throw UnimplementedError('حفظ الملفات غير مدعوم على الويب');
      }

      // الحصول على دليل التنزيلات أو المستندات
      String basePath;
      if (Platform.isAndroid) {
        // أندرويد: حفظ في دليل التنزيلات أو المستندات العامة
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('لم يتم العثور على دليل تخزين خارجي');
        }

        // محاولة انشاء المسار إلى دليل التنزيلات
        final downloadDir = Directory('${directory.path}/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        basePath = downloadDir.path;
      } else if (Platform.isIOS) {
        // iOS: حفظ في دليل المستندات
        final directory = await getApplicationDocumentsDirectory();
        basePath = directory.path;
      } else {
        // أنظمة أخرى (macOS, Linux, Windows)
        final directory = await getApplicationDocumentsDirectory();
        basePath = directory.path;
      }

      // إنشاء المسار الكامل للملف
      final filePath = path.join(basePath, fileName);

      // التحقق من وجود الملف مسبقًا وإضافة رقم إذا لزم الأمر
      File file = File(filePath);
      int counter = 1;

      while (await file.exists()) {
        final fileNameWithoutExtension =
            path.basenameWithoutExtension(fileName);
        final fileExtension = path.extension(fileName);

        final newFileName =
            '${fileNameWithoutExtension}_$counter$fileExtension';
        file = File(path.join(basePath, newFileName));
        counter++;
      }

      // كتابة الملف
      await file.writeAsBytes(fileBytes);

      // إرجاع المسار
      return file.path;
    } catch (e) {
      debugPrint('خطأ في حفظ الملف: $e');
      return null;
    }
  }
}
