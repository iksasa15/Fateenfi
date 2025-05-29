import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../../../../models/language_model.dart';
import '../../../../models/translation_result.dart';
import '../constants/translation_strings.dart';
import '../services/file_service.dart';
import '../services/notification_service.dart';
import '../constants/api_constants.dart';

class TranslationController extends ChangeNotifier {
  // الخدمات
  final FileService _fileService = FileService();
  final NotificationService _notificationService = NotificationService();

  // حالة التحميل
  bool _isLoading = false;
  double _progressValue = 0.0;
  String _progressMessage = '';

  // النص الأصلي والمترجم
  String _originalText = '';
  String _translatedText = TranslationStrings.noFileLoaded;
  String? _fileName;
  String? _translatedFilePath;
  bool _isTranslationSuccessful = false;

  // الملف المحدد للترجمة
  PlatformFile? _selectedFile;

  // قاموس للأسماء الشائعة
  final Map<String, Map<String, String>> _commonNames = {
    'EN': {
      'ahmed': 'أحمد',
      'mohamed': 'محمد',
      'ali': 'علي',
      'ibrahim': 'إبراهيم',
      'omar': 'عمر',
      'abdullah': 'عبدالله',
      'khalid': 'خالد',
      'hassan': 'حسن',
      'hussein': 'حسين',
      'fatima': 'فاطمة',
      'aisha': 'عائشة',
      'sara': 'سارة',
      'mariam': 'مريم',
      'mohammed': 'محمد',
      'ahmad': 'أحمد',
      'john': 'جون',
      'david': 'ديفيد',
      'michael': 'مايكل',
      'james': 'جيمس',
      'robert': 'روبرت',
    },
    'AR': {
      'أحمد': 'Ahmed',
      'محمد': 'Mohamed',
      'علي': 'Ali',
      'إبراهيم': 'Ibrahim',
      'عمر': 'Omar',
      'عبدالله': 'Abdullah',
      'خالد': 'Khalid',
      'حسن': 'Hassan',
      'حسين': 'Hussein',
      'فاطمة': 'Fatima',
      'عائشة': 'Aisha',
      'سارة': 'Sara',
      'مريم': 'Mariam',
      'جون': 'John',
      'ديفيد': 'David',
      'مايكل': 'Michael',
      'جيمس': 'James',
      'روبرت': 'Robert',
    }
  };

  // الوصول إلى الحالة
  bool get isLoading => _isLoading;
  double get progressValue => _progressValue;
  String get progressMessage => _progressMessage;
  String get originalText => _originalText;
  String get translatedText => _translatedText;
  String? get fileName => _fileName;
  String? get translatedFilePath => _translatedFilePath;
  bool get isTranslationSuccessful => _isTranslationSuccessful;
  bool get hasSourceText => _originalText.isNotEmpty;
  PlatformFile? get selectedFile => _selectedFile;
  TranslationResult? get translationResult => _translationResult;
  bool get hasTranslationResult => _translationResult != null;

  // نتيجة الترجمة للتوافق مع الواجهة
  TranslationResult? _translationResult;

  // النص المدخل في وضع الترجمة النصية
  final TextEditingController textController = TextEditingController();

  // تهيئة المتحكم
  TranslationController() {
    _notificationService.initialize();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // دالة للتحقق من الأسماء المعروفة
  String? _checkCommonName(String text, String fromLang, String toLang) {
    // تحويل النص إلى أحرف صغيرة للبحث
    final normalizedText = text.trim().toLowerCase();

    // تنظيف أكواد اللغة
    final fromCode = fromLang.toUpperCase().substring(0, 2);
    final toCode = toLang.toUpperCase().substring(0, 2);

    // البحث في قاموس الأسماء المعروفة
    if (_commonNames.containsKey(fromCode) &&
        _commonNames[fromCode]!.containsKey(normalizedText)) {
      if (toCode == 'AR') {
        return _commonNames[fromCode]![normalizedText];
      } else if (toCode == 'EN' && _commonNames.containsKey('AR')) {
        // البحث عن الترجمة العكسية
        final arabicName = _commonNames[fromCode]![normalizedText];
        if (arabicName != null && _commonNames['AR']!.containsKey(arabicName)) {
          return _commonNames['AR']![arabicName];
        }
      }
    }

    return null;
  }

  // إعادة تعيين نتائج الترجمة
  void _resetTranslationResults() {
    _translationResult = null;
    _originalText = '';
    _translatedText = TranslationStrings.noFileLoaded;
    _isTranslationSuccessful = false;
  }

  // معالجة النص المترجم وإصلاح مشكلات الترميز
  String _processTranslatedText(String text) {
    try {
      // إذا كان النص يحتوي على رموز الترميز غير الصحيح
      if (text.contains('Ø') || text.contains('£') || text.contains('ØÙ')) {
        try {
          return utf8.decode(latin1.encode(text));
        } catch (e) {
          try {
            return utf8.decode(text.codeUnits);
          } catch (_) {
            return text;
          }
        }
      }
      return text;
    } catch (e) {
      debugPrint('خطأ في معالجة النص: $e');
      return text;
    }
  }

  // تعيين رسالة التقدم
  void _setProgress(double value, String message) {
    _progressValue = value;
    _progressMessage = message;
    notifyListeners();
  }

  // إعادة تعيين الحالة
  void reset() {
    _isLoading = false;
    _progressValue = 0.0;
    _progressMessage = '';
    _originalText = '';
    _translatedText = TranslationStrings.noFileLoaded;
    _fileName = null;
    _translatedFilePath = null;
    _isTranslationSuccessful = false;
    _translationResult = null;
    textController.clear();
    notifyListeners();
  }

  // تعيين الملف المحدد
  void setSelectedFile(PlatformFile file) {
    _selectedFile = file;
    _fileName = file.name;
    _resetTranslationResults();
    notifyListeners();
  }

  // مسح الملف المحدد
  void clearSelectedFile() {
    _selectedFile = null;
    _fileName = null;
    _resetTranslationResults();
    notifyListeners();
  }

  // مسح نتيجة الترجمة
  void clearTranslationResult() {
    _resetTranslationResults();
    notifyListeners();
  }

  // حل احتياطي باستخدام واجهة برمجة جوجل
  Future<String?> _fallbackTranslationForShortTexts(
    String text,
    String sourceLanguageCode,
    String targetLanguageCode,
  ) async {
    // التحقق من الأسماء الشائعة أولاً
    if (text.split(" ").length == 1 && text.length < 30) {
      final nameTranslation =
          _checkCommonName(text, sourceLanguageCode, targetLanguageCode);

      if (nameTranslation != null) {
        debugPrint('اسم معروف: $text -> $nameTranslation');
        return nameTranslation;
      }
    }

    try {
      // تحويل أكواد اللغة إلى الصيغة المناسبة
      final sourceCode = sourceLanguageCode.toLowerCase() == 'auto'
          ? 'auto'
          : sourceLanguageCode.substring(0, 2).toLowerCase();

      final targetCode = targetLanguageCode.toLowerCase() == 'auto'
          ? 'en'
          : targetLanguageCode.substring(0, 2).toLowerCase();

      // استخدام واجهة برمجة جوجل غير الرسمية
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx'
        '&sl=$sourceCode&tl=$targetCode&dt=t&q=${Uri.encodeComponent(text)}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String translatedText = '';

        if (jsonResponse[0] != null) {
          for (var item in jsonResponse[0]) {
            if (item[0] != null) {
              translatedText += item[0];
            }
          }
        }

        return translatedText.isNotEmpty ? translatedText : null;
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في الترجمة الاحتياطية: $e');
      return null;
    }
  }

  // تحويل رمز اللغة إلى نوع TranslateLanguage
  TranslateLanguage _getMLKitLanguage(String code) {
    final normalizedCode = code.toUpperCase().substring(0, 2);

    switch (normalizedCode) {
      case 'AR':
        return TranslateLanguage.arabic;
      case 'EN':
        return TranslateLanguage.english;
      case 'FR':
        return TranslateLanguage.french;
      case 'ES':
        return TranslateLanguage.spanish;
      case 'DE':
        return TranslateLanguage.german;
      case 'IT':
        return TranslateLanguage.italian;
      case 'PT':
        return TranslateLanguage.portuguese;
      case 'RU':
        return TranslateLanguage.russian;
      case 'ZH':
        return TranslateLanguage.chinese;
      case 'JA':
        return TranslateLanguage.japanese;
      case 'KO':
        return TranslateLanguage.korean;
      case 'HI':
        return TranslateLanguage.hindi;
      default:
        return TranslateLanguage.english;
    }
  }

  // تأكد من تنزيل نماذج اللغة
  Future<void> _ensureLanguageModelsDownloaded(
    TranslateLanguage sourceLanguage,
    TranslateLanguage targetLanguage,
  ) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();

      if (!await modelManager.isModelDownloaded(sourceLanguage as String)) {
        _setProgress(0.3, 'تنزيل نموذج اللغة المصدر...');
        await modelManager.downloadModel(sourceLanguage as String);
      }

      if (!await modelManager.isModelDownloaded(targetLanguage as String)) {
        _setProgress(0.35, 'تنزيل نموذج اللغة الهدف...');
        await modelManager.downloadModel(targetLanguage as String);
      }
    } catch (e) {
      debugPrint('تحذير: فشل في تنزيل نماذج اللغة: $e');
    }
  }

  // ترجمة النص باستخدام ML Kit
  Future<TranslationResult> _translateWithMlKit(
    String text,
    LanguageModel sourceLanguage,
    LanguageModel targetLanguage,
  ) async {
    try {
      // التحقق من الأسماء الشائعة أولاً
      if (text.split(" ").length == 1 && text.length < 30) {
        final nameTranslation =
            _checkCommonName(text, sourceLanguage.code, targetLanguage.code);

        if (nameTranslation != null) {
          return TranslationResult.success(
            originalText: text,
            translatedText: nameTranslation,
            fileBytes: Uint8List(0),
          );
        }
      }

      // تحضير اللغات
      final sourceLang = _getMLKitLanguage(sourceLanguage.code);
      final targetLang = _getMLKitLanguage(targetLanguage.code);

      // إنشاء مترجم محلي
      final onDeviceTranslator = OnDeviceTranslator(
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );

      String translatedText;

      try {
        translatedText = await onDeviceTranslator.translateText(text);
      } catch (e) {
        debugPrint('خطأ في ML Kit: $e');

        // محاولة الحل الاحتياطي
        final fallbackTranslation = await _fallbackTranslationForShortTexts(
          text,
          sourceLanguage.code,
          targetLanguage.code,
        );

        // إغلاق المترجم
        onDeviceTranslator.close();

        if (fallbackTranslation != null && fallbackTranslation.isNotEmpty) {
          return TranslationResult.success(
            originalText: text,
            translatedText: fallbackTranslation,
            fileBytes: Uint8List(0),
          );
        }

        // للنصوص القصيرة، أعد النص الأصلي بدلاً من فشل العملية
        if (text.length < 50) {
          return TranslationResult.success(
            originalText: text,
            translatedText: text,
            fileBytes: Uint8List(0),
          );
        }

        throw e;
      }

      // إغلاق المترجم
      onDeviceTranslator.close();

      // إذا كانت الترجمة هي نفس النص الأصلي أو فارغة
      if (translatedText.trim().isEmpty || translatedText == text) {
        // محاولة الحل الاحتياطي
        final fallbackTranslation = await _fallbackTranslationForShortTexts(
          text,
          sourceLanguage.code,
          targetLanguage.code,
        );

        if (fallbackTranslation != null && fallbackTranslation.isNotEmpty) {
          return TranslationResult.success(
            originalText: text,
            translatedText: fallbackTranslation,
            fileBytes: Uint8List(0),
          );
        }
      }

      // معالجة النص المترجم
      String processedText = _processTranslatedText(translatedText);

      return TranslationResult.success(
        originalText: text,
        translatedText: processedText,
        fileBytes: Uint8List(0),
      );
    } catch (e) {
      debugPrint('خطأ في الترجمة: $e');

      // محاولة أخيرة باستخدام الحل الاحتياطي
      try {
        final fallbackTranslation = await _fallbackTranslationForShortTexts(
          text.length > 1000 ? text.substring(0, 1000) : text,
          sourceLanguage.code,
          targetLanguage.code,
        );

        if (fallbackTranslation != null && fallbackTranslation.isNotEmpty) {
          return TranslationResult.success(
            originalText: text,
            translatedText: fallbackTranslation,
            fileBytes: Uint8List(0),
          );
        }
      } catch (_) {}

      // للنصوص القصيرة جداً، نعيد النص الأصلي بدلاً من فشل العملية
      if (text.length < 50) {
        return TranslationResult.success(
          originalText: text,
          translatedText: text,
          fileBytes: Uint8List(0),
        );
      }

      return TranslationResult.error(
        originalText: text,
        errorMessage: '${TranslationStrings.translateError} $e',
      );
    }
  }

  // ترجمة النص المدخل مع تحسين معالجة الأخطاء
  Future<bool> translateInputText({
    required LanguageModel sourceLanguage,
    required LanguageModel targetLanguage,
  }) async {
    final textToTranslate = textController.text.trim();

    if (textToTranslate.isEmpty) {
      throw Exception(TranslationStrings.enterTextError);
    }

    try {
      // بدء الترجمة
      _isLoading = true;
      _setProgress(0.3, TranslationStrings.translating);
      _originalText = textToTranslate;
      _isTranslationSuccessful = false;

      // التحقق من الأسماء الشائعة أولاً للنصوص القصيرة
      if (textToTranslate.split(" ").length == 1 &&
          textToTranslate.length < 30) {
        final nameTranslation = _checkCommonName(
            textToTranslate, sourceLanguage.code, targetLanguage.code);

        if (nameTranslation != null) {
          _translatedText = nameTranslation;
          _isTranslationSuccessful = true;
          _translationResult = TranslationResult.success(
            originalText: textToTranslate,
            translatedText: nameTranslation,
          );
          _isLoading = false;
          _progressValue = 1.0;
          notifyListeners();
          return true;
        }
      }

      // التأكد من تنزيل نماذج اللغة
      try {
        final sourceLang = _getMLKitLanguage(sourceLanguage.code);
        final targetLang = _getMLKitLanguage(targetLanguage.code);
        await _ensureLanguageModelsDownloaded(sourceLang, targetLang);
      } catch (e) {
        debugPrint('تحذير: فشل في تحميل نماذج اللغة: $e');
      }

      // ترجمة النص
      TranslationResult translation = await _translateWithMlKit(
        textToTranslate,
        sourceLanguage,
        targetLanguage,
      );

      // تحديث الحالة بناءً على نتيجة الترجمة
      if (translation.isSuccessful ?? false) {
        _translatedText = translation.translatedText;
        _isTranslationSuccessful = true;
        _translationResult = translation;
        _isLoading = false;
        _progressValue = 1.0;
        notifyListeners();
        return true;
      } else {
        // محاولة الحل الاحتياطي
        final fallbackTranslation = await _fallbackTranslationForShortTexts(
          textToTranslate,
          sourceLanguage.code,
          targetLanguage.code,
        );

        if (fallbackTranslation != null && fallbackTranslation.isNotEmpty) {
          _translatedText = fallbackTranslation;
          _isTranslationSuccessful = true;
          _translationResult = TranslationResult.success(
            originalText: textToTranslate,
            translatedText: fallbackTranslation,
          );
          _isLoading = false;
          _progressValue = 1.0;
          notifyListeners();
          return true;
        }

        // فشل الترجمة
        _translatedText =
            translation.errorMessage ?? TranslationStrings.translateError;
        _isLoading = false;
        _progressValue = 0.0;
        notifyListeners();
        throw Exception(_translatedText);
      }
    } catch (e) {
      _isLoading = false;
      _progressValue = 0.0;

      // للنصوص القصيرة جداً، نعيد النص الأصلي بدلاً من فشل العملية
      if (textToTranslate.length < 30 &&
          textToTranslate.split(' ').length <= 3) {
        final fallbackTranslation = await _fallbackTranslationForShortTexts(
          textToTranslate,
          sourceLanguage.code,
          targetLanguage.code,
        );

        if (fallbackTranslation != null && fallbackTranslation.isNotEmpty) {
          _translatedText = fallbackTranslation;
        } else {
          _translatedText = textToTranslate;
        }

        _isTranslationSuccessful = true;
        _translationResult = TranslationResult.success(
          originalText: textToTranslate,
          translatedText: _translatedText,
        );
        notifyListeners();
        return true;
      }

      _translatedText = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // تحسين طلب الأذونات والتحقق منها
  Future<bool> checkAndRequestPermissions(BuildContext context) async {
    if (kIsWeb) return true;

    bool hasPermission = true;

    if (Platform.isAndroid) {
      final storage = await Permission.storage.status;
      if (!storage.isGranted) {
        final status = await Permission.storage.request();
        hasPermission = status.isGranted;
      }
    } else if (Platform.isIOS) {
      final photos = await Permission.photos.status;
      if (!photos.isGranted) {
        final status = await Permission.photos.request();
        hasPermission = status.isGranted;
      }
    }

    if (!hasPermission && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'يجب منح الأذونات للوصول إلى الملفات',
            style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'الإعدادات',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }

    return hasPermission;
  }

  // دالة لعرض حوار استخدام OCR
  Future<bool> _showUseOCRDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تعذر استخراج النص', textAlign: TextAlign.right),
            content: const Text(
              'تعذر استخراج النص من ملف PDF بالطريقة المباشرة. قد يكون الملف محمياً أو يحتوي على صور فقط.\n\n'
              'هل تريد استخدام تقنية OCR للتعرف على النص في الصور؟\n\n'
              'ملحوظة: هذه العملية قد تستغرق بعض الوقت وقد لا تكون النتيجة مثالية.',
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('استخدام OCR'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // اختيار وترجمة ملف
  Future<bool> pickAndTranslateFile({
    required LanguageModel sourceLanguage,
    required LanguageModel targetLanguage,
    required bool useDeeplFormatting,
    bool useOCR = false, // معامل جديد للتحكم في استخدام OCR
    BuildContext? context,
  }) async {
    try {
      // التحقق من الأذونات
      if (!kIsWeb && context != null) {
        _setProgress(0.05, 'جاري التحقق من الأذونات...');
        bool hasPermission = await checkAndRequestPermissions(context);
        if (!hasPermission) {
          _isLoading = false;
          throw Exception(TranslationStrings.permissionsRequired);
        }
      }

      // بدء العملية
      _isLoading = true;
      _setProgress(0.1, TranslationStrings.loadingFile);
      _originalText = '';
      _isTranslationSuccessful = false;

      // اختيار الملف إذا لم يتم اختياره مسبقاً
      if (_selectedFile == null) {
        try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ApiConstants.supportedFileExtensions,
            withReadStream: true,
          );

          if (result == null) {
            _isLoading = false;
            throw Exception(TranslationStrings.noFileSelected);
          }

          _selectedFile = result.files.single;
          _fileName = _selectedFile!.name;
        } catch (e) {
          _isLoading = false;
          throw Exception('حدث خطأ أثناء اختيار الملف: ${e.toString()}');
        }
      }

      // قراءة الملف
      String content = '';
      _setProgress(0.2, TranslationStrings.loadingFile);

      if (kIsWeb) {
        // معالجة الملف على الويب
        final fileBytes = _selectedFile!.bytes;
        if (fileBytes == null) {
          _isLoading = false;
          throw Exception(TranslationStrings.readingError);
        }

        if (_fileName!.toLowerCase().endsWith('.pdf')) {
          _isLoading = false;
          throw Exception(
              "عذراً، لا يمكن معالجة ملفات PDF على الويب حالياً. يرجى استخدام التطبيق على الجهاز أو تحويل المستند إلى نص.");
        } else {
          content = String.fromCharCodes(fileBytes);
        }
      } else {
        // معالجة الملف على الجهاز
        final filePath = _selectedFile!.path;
        if (filePath == null) {
          _isLoading = false;
          throw Exception(TranslationStrings.invalidFilePath);
        }

        File file = File(filePath);
        if (!await file.exists()) {
          _isLoading = false;
          throw Exception(TranslationStrings.fileNotFound);
        }

        if (filePath.toLowerCase().endsWith('.pdf')) {
          _setProgress(0.3, 'جاري استخراج النص من ملف PDF...');

          // استخدام OCR إذا تم تحديد ذلك
          if (useOCR) {
            try {
              content = await _fileService.extractTextFromPdfWithOCR(
                  file, sourceLanguage);
            } catch (e) {
              _isLoading = false;
              throw Exception(
                  'فشل استخراج النص من الملف باستخدام OCR: $e\n\nحاول استخدام ملف PDF آخر يحتوي على نص قابل للقراءة.');
            }
          } else {
            // محاولة الاستخراج المباشر أولاً
            try {
              content =
                  await _fileService.extractTextFromPdf(file, sourceLanguage);

              // إذا كان النص فارغاً، اقترح استخدام OCR
              if (content.isEmpty && context != null && context.mounted) {
                final shouldUseOcr = await _showUseOCRDialog(context);
                if (shouldUseOcr) {
                  _setProgress(0.35, 'جاري استخراج النص باستخدام OCR...');
                  content = await _fileService.extractTextFromPdfWithOCR(
                      file, sourceLanguage);
                } else {
                  _isLoading = false;
                  throw Exception('تعذر استخراج النص من ملف PDF.\n\n'
                      'اقتراحات للحل:\n'
                      '1. استخدم ملفاً آخر يحتوي على نص قابل للنسخ\n'
                      '2. استخدم وضع الترجمة النصية بدلاً من وضع الملفات\n'
                      '3. جرب تحويل PDF إلى نص باستخدام أداة خارجية');
                }
              }
            } catch (e) {
              _isLoading = false;
              throw Exception('فشل استخراج النص من الملف: $e\n\n'
                  'اقتراحات للحل:\n'
                  '1. تأكد من أن الملف غير محمي وقابل للقراءة\n'
                  '2. جرب استخدام خيار "استخراج النص باستخدام OCR"\n'
                  '3. استخدم ملفاً آخر بتنسيق نصي بسيط');
            }
          }
        } else {
          // قراءة ملف نصي
          content = await _fileService.readTextFile(file);
        }
      }

      if (content.isEmpty) {
        _isLoading = false;
        throw Exception(TranslationStrings.emptyFile);
      }

      // حفظ النص الأصلي
      _originalText = content;

      // بدء الترجمة
      _setProgress(0.5, TranslationStrings.translating);

      // تحضير اللغات
      final sourceLang = _getMLKitLanguage(sourceLanguage.code);
      final targetLang = _getMLKitLanguage(targetLanguage.code);

      // ترجمة النص
      TranslationResult translation = await _translateWithMlKit(
        content,
        sourceLanguage,
        targetLanguage,
      );

      // معالجة نتيجة الترجمة
      if (translation.isSuccessful ?? false) {
        String processedText =
            _processTranslatedText(translation.translatedText);

        // حفظ النص المترجم في ملف
        String? savedFilePath;
        if (!kIsWeb) {
          _setProgress(0.8, 'جاري حفظ الترجمة...');
          savedFilePath = await _fileService.saveTranslatedText(
            processedText,
            _fileName ?? 'translated',
          );
        }

        // تحديث الحالة
        _translatedText = processedText;
        _translatedFilePath = savedFilePath;
        _isTranslationSuccessful = true;
        _translationResult = translation;

        // إظهار إشعار
        if (!kIsWeb && savedFilePath != null) {
          _notificationService
              .showNotification(
                title: TranslationStrings.notificationTitle,
                body: TranslationStrings.notificationBody,
              )
              .catchError((e) => debugPrint('خطأ في الإشعار: $e'));
        }

        _isLoading = false;
        _progressValue = 1.0;
        notifyListeners();
        return true;
      } else {
        // محاولة الحل الاحتياطي
        final fallbackTranslation = await _fallbackTranslationForShortTexts(
          content.length > 1000 ? content.substring(0, 1000) : content,
          sourceLanguage.code,
          targetLanguage.code,
        );

        if (fallbackTranslation != null && fallbackTranslation.isNotEmpty) {
          _translatedText = fallbackTranslation;
          _isTranslationSuccessful = true;
          _translationResult = TranslationResult.success(
            originalText: content,
            translatedText: fallbackTranslation,
          );
          _isLoading = false;
          _progressValue = 1.0;
          notifyListeners();
          return true;
        }

        // فشل الترجمة
        _translatedText =
            translation.errorMessage ?? TranslationStrings.translateError;
        _isLoading = false;
        _progressValue = 0.0;
        notifyListeners();
        throw Exception(_translatedText);
      }
    } catch (e) {
      _isLoading = false;
      _progressValue = 0.0;
      _translatedText = e is Exception
          ? 'خطأ: ${e.toString()}'
          : 'حدث خطأ غير متوقع: ${e.toString()}';
      notifyListeners();
      throw e;
    }
  }

  // نسخ النص المترجم
  Future<void> copyTranslatedText() async {
    if (_translatedText.isNotEmpty && _isTranslationSuccessful) {
      await _fileService.copyToClipboard(_translatedText);
    }
  }

  // مشاركة النص المترجم
  Future<void> shareTranslatedText() async {
    if (_isTranslationSuccessful) {
      if (_translatedFilePath != null && !kIsWeb) {
        final file = File(_translatedFilePath!);
        if (await file.exists()) {
          await _fileService.shareFile(_translatedFilePath!,
              text: 'هذا هو النص المترجم');
        } else {
          await _fileService.shareFile('', text: _translatedText);
        }
      } else {
        await _fileService.shareFile('', text: _translatedText);
      }
    } else {
      throw Exception('لا توجد ترجمة ناجحة للمشاركة');
    }
  }

  // تنزيل الملف المترجم
  Future<void> downloadTranslatedFile() async {
    if (_translatedFilePath == null || kIsWeb) {
      throw Exception(TranslationStrings.noFileToDownload);
    }

    final file = File(_translatedFilePath!);
    if (!await file.exists()) {
      throw Exception(
          '${TranslationStrings.fileNotAccessible}$_translatedFilePath');
    }

    await _fileService.shareFile(_translatedFilePath!,
        text: 'فتح الملف المترجم');

    await _notificationService.showNotification(
      title: TranslationStrings.downloadNotificationTitle,
      body: 'الملف المترجم متاح في: $_translatedFilePath',
    );
  }
}
