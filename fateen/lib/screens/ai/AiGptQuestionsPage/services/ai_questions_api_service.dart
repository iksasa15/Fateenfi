import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../models/generated_question_model.dart';

class AiQuestionsApiService {
  // عنوان الخادم - تأكد من وجود البروتوكول (https://)
  static String _serverAddress = "https://apii-1-kjff.onrender.com";

  // آخر رسالة من الخادم
  static String lastServerMessage = "";

  // حالة الاتصال بالخادم
  static bool _isServerAvailable = false;
  static bool get isServerAvailable => _isServerAvailable;

  // تعيين عنوان الخادم - مع التأكد من وجود البروتوكول
  static void setServerAddress(String address) {
    // التأكد من أن العنوان يحتوي على بروتوكول http:// أو https://
    if (!address.startsWith('http://') && !address.startsWith('https://')) {
      address = 'https://$address';
    }
    _serverAddress = address;
  }

  // الحصول على عنوان الخادم الحالي
  static String get serverInfo => _serverAddress;

  // تعديل عنوان الخدمة
  static String get apiEndpoint {
    // تأكد من أن الخادم لديه بروتوكول
    if (!_serverAddress.startsWith('http://') &&
        !_serverAddress.startsWith('https://')) {
      return "https://$_serverAddress/generate-questions";
    }
    return "$_serverAddress/generate-questions";
  }

  // نقطة نهاية لاختبار الاتصال
  static String get testApiEndpoint {
    // تأكد من أن الخادم لديه بروتوكول
    if (!_serverAddress.startsWith('http://') &&
        !_serverAddress.startsWith('https://')) {
      return "https://$_serverAddress/test-api";
    }
    return "$_serverAddress/test-api";
  }

  /// دالة إيقاظ الخدمة - تُستخدم لإيقاظ الخدمة من وضع السكون
  static Future<bool> wakeUpService() async {
    try {
      // تأكد من أن العنوان يحتوي على بروتوكول
      String serverUrl = _serverAddress;
      if (!serverUrl.startsWith('http://') &&
          !serverUrl.startsWith('https://')) {
        serverUrl = 'https://$serverUrl';
      }

      // استدعاء الصفحة الرئيسية للخدمة لإيقاظها
      final response = await http
          .get(Uri.parse(serverUrl))
          .timeout(const Duration(seconds: 15));

      // ملاحظة: حتى لو كان الرد 404، فإن الخدمة استيقظت
      return true;
    } catch (e) {
      debugPrint("خطأ أثناء محاولة إيقاظ الخدمة: $e");
      return false;
    }
  }

  /// اختبار الاتصال بالخادم
  static Future<bool> testConnection() async {
    try {
      // تأكد من أن عنوان الاختبار يحتوي على بروتوكول
      String testUrl = testApiEndpoint;

      // محاولة إيقاظ الخدمة أولاً
      await wakeUpService();

      // محاولة الاتصال بنقطة نهاية الاختبار
      final response = await http
          .get(Uri.parse(testUrl))
          .timeout(const Duration(seconds: 20));

      // تحليل الاستجابة إذا كانت ناجحة
      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
          // حفظ الرسالة من الخادم
          lastServerMessage = jsonResponse['message'] ?? "";
          // التحقق من حقل "status" في الاستجابة
          _isServerAvailable = jsonResponse['status'] == 'working';
          return _isServerAvailable;
        } catch (e) {
          // إذا فشل تحليل JSON، نعتمد على كود الاستجابة فقط
          debugPrint("خطأ في تحليل استجابة JSON: $e");
          lastServerMessage = "";
          _isServerAvailable = true;
          return true;
        }
      }

      _isServerAvailable = false;
      lastServerMessage = "";
      return false;
    } catch (e) {
      debugPrint("خطأ في اختبار الاتصال بالخادم: $e");
      _isServerAvailable = false;
      lastServerMessage = "";
      return false;
    }
  }

  /// استدعاء خدمة API لإنشاء الأسئلة
  static Future<List<GeneratedQuestionModel>> generateQuestions({
    required String text,
    required int questionCount,
    String? apiKey,
    required String language,
    bool clearHistory = false,
    Function()? fallbackToTestMode,
  }) async {
    try {
      // تأكد من أن عنوان API يحتوي على بروتوكول
      String apiUrl = apiEndpoint;

      // محاولة إيقاظ الخدمة أولاً
      await wakeUpService();

      debugPrint("استدعاء API على العنوان: $apiUrl");

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "text": text,
              "num_questions": questionCount,
              "clear_history": clearHistory,
              "language": language,
            }),
          )
          .timeout(const Duration(seconds: 120)); // زيادة المهلة إلى دقيقتين

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> questionsJson = responseJson['questions'];

        List<GeneratedQuestionModel> questions = [];
        for (var questionData in questionsJson) {
          questions.add(GeneratedQuestionModel.fromJson(questionData));
        }

        return questions;
      } else {
        // تحديث حالة الخادم
        _isServerAvailable = false;

        final errorMessage =
            jsonDecode(utf8.decode(response.bodyBytes))['detail'] ??
                "حدث خطأ غير معروف (رمز الاستجابة: ${response.statusCode})";

        // التبديل إلى وضع الاختبار إذا تم تمرير الدالة المرجعية
        if (fallbackToTestMode != null) {
          fallbackToTestMode();
        }

        throw Exception("فشل إنشاء الأسئلة: $errorMessage");
      }
    } catch (e) {
      debugPrint("استثناء أثناء استدعاء خدمة API: $e");

      // تحديث حالة الخادم
      _isServerAvailable = false;

      // التبديل إلى وضع الاختبار إذا تم تمرير الدالة المرجعية
      if (fallbackToTestMode != null) {
        fallbackToTestMode();
      }

      throw Exception("خطأ أثناء الاتصال بخدمة توليد الأسئلة: $e");
    }
  }

  /// استرجاع العنوان الصحيح - دالة مساعدة لإضافة البروتوكول
  static String getValidUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }
}
