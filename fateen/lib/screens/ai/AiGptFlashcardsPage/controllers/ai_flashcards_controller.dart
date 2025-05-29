// ai_flashcards_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:http/http.dart' as http;

import '../../../../models/generated_flashcard_model.dart';
import '../constants/ai_flashcards_strings.dart';
import '../components/ai_flashcards_result_dialog_component.dart';
import '../services/ai_flashcards_api_service.dart';
import '../services/ai_flashcards_file_service.dart';

class AiFlashcardsController extends ChangeNotifier {
  // Animation controllers injected from parent
  final TickerProvider vsync;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late AnimationController loadingController;

  // Text controllers
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController flashcardsCountController =
      TextEditingController(text: "5");
  final TextEditingController manualInputController = TextEditingController();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State variables
  bool _isLoading = false;
  bool _showAnswer = false;
  String? _fileContent;
  String _selectedFileName = "";
  int _currentFlashcardIndex = 0;
  List<GeneratedFlashcardModel> _flashcards = [];
  int _requestCounter = 0;
  final math.Random _random = math.Random();
  List<String> _previousFlashcardTexts = [];
  int _generatedFlashcardsCount = 0;
  int _totalFlashcardsToGenerate = 0;
  bool _isTestMode = false;
  String _selectedLanguage = 'auto';

  // Getters
  bool get isLoading => _isLoading;
  bool get showAnswer => _showAnswer;
  String get selectedFileName => _selectedFileName;
  int get currentFlashcardIndex => _currentFlashcardIndex;
  List<GeneratedFlashcardModel> get flashcards => _flashcards;
  int get generatedFlashcardsCount => _generatedFlashcardsCount;
  int get totalFlashcardsToGenerate => _totalFlashcardsToGenerate;
  bool get isTestMode => _isTestMode;
  String get selectedLanguage => _selectedLanguage;

  // Constructor
  AiFlashcardsController({required this.vsync});

  // دالة فارغة للحفاظ على التوافق
  void showApiKeyDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("مفتاح API مضمن في الخادم، لا حاجة لإدخاله"),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // استعادة مفتاح API المحفوظ - دالة فارغة للتوافق
  Future<void> loadSavedApiKey() async {
    // لا نفعل شيئًا لأننا لم نعد نستخدم مفتاح API المحفوظ
  }

  // طريقة لتغيير اللغة المختارة
  void setSelectedLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Initialize animations
  void initializeAnimations() {
    // إعداد متحكم الرسوم المتحركة للتنقل بين البطاقات
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 350),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // إعداد متحكم الرسوم المتحركة لمؤشر التحميل
    loadingController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    );

    // تشغيل الرسوم المتحركة عند بدء التطبيق
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    loadingController.dispose();
    apiKeyController.dispose();
    flashcardsCountController.dispose();
    manualInputController.dispose();
    super.dispose();
  }

  // التقاط ملف (نصي أو PDF) وقراءته
  Future<void> pickFileAndReadContent(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await AiFlashcardsFileService.pickAndReadFile();

      if (result['success']) {
        _selectedFileName = result['fileName'];
        _fileContent = result['content'];

        // التحقق من أن المحتوى ليس فارغًا
        if (_fileContent == null || _fileContent!.trim().isEmpty) {
          _showErrorSnackBar(
              context, "الملف فارغ أو لا يحتوي على نص قابل للاستخراج");
          _fileContent = null;
          _selectedFileName = "";
        } else {
          // عند اختيار ملف جديد، نمسح البطاقات السابقة ونعيد ضبط الحالة
          resetContent(fullReset: true);

          // عرض رسالة نجاح
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("تم تحميل الملف بنجاح: $_selectedFileName"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        _showErrorSnackBar(
            context, result['error'] ?? "حدث خطأ أثناء قراءة الملف");
      }
    } catch (e) {
      debugPrint("خطأ أثناء اختيار الملف: $e");
      _showErrorSnackBar(context, "${AiFlashcardsStrings.filePickError}$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // استدعاء خدمة AI لإنشاء البطاقات التعليمية
  Future<void> generateFlashcards(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // التحقق من وضع الاختبار
    if (_isTestMode) {
      _generateDummyFlashcards();
      return;
    }

    // الآن نستخدم محتوى الملف فقط بدلاً من النص اليدوي
    String textToUse = "";
    if (_fileContent != null && _fileContent!.isNotEmpty) {
      textToUse = _fileContent!;
    } else {
      _showErrorSnackBar(
          context, "لم يتم اختيار ملف أو الملف فارغ. الرجاء اختيار ملف نصي.");
      return;
    }

    // التحقق من عدد البطاقات
    int flashcardsCount = int.tryParse(flashcardsCountController.text) ?? 1;
    if (flashcardsCount < 1) {
      _showErrorSnackBar(
          context, AiFlashcardsStrings.invalidFlashcardsCountError);
      return;
    }

    // بدء حالة التحميل
    _isLoading = true;
    _flashcards = [];
    _showAnswer = false;
    _currentFlashcardIndex = 0;
    _requestCounter += 100;
    _generatedFlashcardsCount = 0;
    _totalFlashcardsToGenerate = flashcardsCount;
    notifyListeners();

    loadingController.repeat();

    try {
      // استدعاء خدمة توليد البطاقات التعليمية
      _flashcards = await AiFlashcardsApiService.generateFlashcards(
        text: textToUse,
        flashcardCount: flashcardsCount,
        apiKey: "", // المفتاح غير مطلوب، سيتم استخدام المفتاح المضمن في الخادم
        language: "auto", // دائماً استخدام الكشف التلقائي للغة
        clearHistory: true,
      );

      animationController.reset();
      animationController.forward();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AiFlashcardsStrings.generationSuccessText
              .replaceFirst('%d', _flashcards.length.toString())),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("استثناء أثناء توليد البطاقات: $e");

      // عرض معلومات مفصلة عن الخطأ للمستخدم
      String errorDetails = e.toString();
      if (e is SocketException) {
        errorDetails = "لا يمكن الاتصال بالخادم. تأكد من اتصالك بالإنترنت.";
      } else if (e is TimeoutException) {
        errorDetails =
            "استغرق الاتصال وقتًا طويلًا. قد تكون هناك مشكلة في الخدمة.";
      } else if (e is FormatException) {
        errorDetails = "خطأ في تنسيق البيانات المستلمة من الخادم.";
      }

      _showErrorSnackBar(context, "خطأ: $errorDetails");

      // استخدام بطاقات تجريبية كحل احتياطي إذا فشلت كل المحاولات
      _generateDummyFlashcards();
    } finally {
      loadingController.stop();
      _isLoading = false;
      _generatedFlashcardsCount = 0;
      notifyListeners();
    }
  }

  // توليد بطاقات تعليمية أساسية في حالة فشل كل الطرق
  List<GeneratedFlashcardModel> _generateBasicFlashcards() {
    return [
      GeneratedFlashcardModel(
        front: "المشتري",
        back:
            "أكبر كوكب في المجموعة الشمسية، يتميز بالحجم الهائل والأقمار العديدة.",
      ),
      GeneratedFlashcardModel(
        front: "غابرييل غارسيا ماركيز",
        back:
            "كاتب كولومبي حائز على جائزة نوبل للآداب، واشتهر بروايته (مائة عام من العزلة).",
      ),
      GeneratedFlashcardModel(
        front: "باريس",
        back: "عاصمة فرنسا، وتعرف بأنها مدينة النور والثقافة والفنون.",
      ),
      GeneratedFlashcardModel(
        front: "آسيا",
        back:
            "أكبر قارة في العالم من حيث المساحة والسكان، وتضم بلداناً مثل الصين والهند واليابان.",
      ),
      GeneratedFlashcardModel(
        front: "الأكسجين",
        back:
            "عنصر كيميائي رمزه O، ضروري للتنفس ويشكل حوالي 21% من الغلاف الجوي للأرض.",
      ),
    ];
  }

  // عرض رسالة خطأ بشكل موحد
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 5), // وقت أطول لقراءة الخطأ
        action: SnackBarAction(
          label: 'وضع الاختبار',
          textColor: Colors.white,
          onPressed: () {
            // تفعيل وضع الاختبار واستخدام بطاقات وهمية
            _isTestMode = true;
            _generateDummyFlashcards();
          },
        ),
      ),
    );
  }

  // إنشاء بطاقات تجريبية للاختبار (بدلاً من الاتصال بالخادم)
  void _generateDummyFlashcards() {
    _isLoading = true;
    notifyListeners();

    // محاكاة وقت التحميل
    Future.delayed(const Duration(seconds: 1), () {
      _flashcards = _generateBasicFlashcards();

      _isLoading = false;
      _currentFlashcardIndex = 0;
      _showAnswer = false;

      animationController.reset();
      animationController.forward();
      notifyListeners();
    });
  }

  // عرض الإجابة أو إخفاؤها
  void toggleAnswer() {
    _showAnswer = !_showAnswer;
    notifyListeners();
  }

  // انتقال للبطاقة التالية مع رسوم متحركة
  void nextFlashcard() {
    if (_currentFlashcardIndex < _flashcards.length - 1) {
      // تشغيل رسوم متحركة للخروج
      animationController.reverse().then((_) {
        _currentFlashcardIndex++;
        _showAnswer = false; // إخفاء الإجابة عند الانتقال
        notifyListeners();
        // تشغيل رسوم متحركة للدخول
        animationController.forward();
      });
    }
  }

  // انتقال للبطاقة السابقة مع رسوم متحركة
  void previousFlashcard() {
    if (_currentFlashcardIndex > 0) {
      // تشغيل رسوم متحركة للخروج
      animationController.reverse().then((_) {
        _currentFlashcardIndex--;
        _showAnswer = false; // إخفاء الإجابة عند الانتقال
        notifyListeners();
        // تشغيل رسوم متحركة للدخول
        animationController.forward();
      });
    }
  }

  // تعليم البطاقة كمعروفة أو غير معروفة
  void markFlashcard(bool known) {
    _flashcards[_currentFlashcardIndex].isKnown = known;
    notifyListeners();

    // الانتقال للبطاقة التالية بعد التمييز
    if (_currentFlashcardIndex < _flashcards.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        nextFlashcard();
      });
    }
  }

  // إعادة تعيين المحتوى لإنشاء بطاقات جديدة
  void resetContent({bool fullReset = false}) {
    _flashcards = [];
    _showAnswer = false;
    _currentFlashcardIndex = 0;

    // زيادة العداد بقيمة كبيرة لإجبار GPT على إعطاء بطاقات جديدة تماماً
    _requestCounter += 1000 + _random.nextInt(1000);

    if (fullReset) {
      // إعادة تعيين كاملة تشمل مسح قائمة البطاقات السابقة
      _previousFlashcardTexts = [];
    }

    // إضافة عشوائية بسيطة للنص إذا كان هناك نص مدخل
    if (manualInputController.text.isNotEmpty) {
      // إضافة مسافة عشوائية في نهاية النص لخداع الخوارزمية
      String originalText = manualInputController.text.trim();
      if (originalText.isNotEmpty) {
        if (_random.nextBool()) {
          // نضيف فقط تغييرات غير مرئية لتجنب إزعاج المستخدم مع نفس النص الأصلي
          manualInputController.text = "$originalText ";
        } else {
          manualInputController.text = " $originalText";
        }
      }
    }

    notifyListeners();
  }

  // تفعيل/تعطيل وضع الاختبار
  void toggleTestMode() {
    _isTestMode = !_isTestMode;
    notifyListeners();
  }
}
