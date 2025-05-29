import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:http/http.dart' as http;

import '../../../../models/generated_question_model.dart';
import '../constants/ai_questions_strings.dart';
import '../components/ai_questions_result_dialog_component.dart';
import '../services/ai_questions_api_service.dart';
import '../services/ai_questions_file_service.dart';

class AiQuestionsController extends ChangeNotifier {
  // Animation controllers injected from parent
  final TickerProvider vsync;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late AnimationController loadingController;

  // Text controllers
  final TextEditingController apiKeyController =
      TextEditingController(); // مازلنا نستخدمه للتوافق
  final TextEditingController questionsCountController =
      TextEditingController(text: "5");
  final TextEditingController manualInputController = TextEditingController();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State variables
  bool _isLoading = false;
  bool _showAnswers = false;
  String? _fileContent;
  String _selectedFileName = "";
  int _currentQuestionIndex = 0;
  List<GeneratedQuestionModel> _questions = [];
  int _requestCounter = 0;
  final math.Random _random = math.Random();
  List<String> _previousQuestionTexts = [];
  int _generatedQuestionsCount = 0;
  int _totalQuestionsToGenerate = 0;
  bool _isTestMode = false; // وضع الاختبار
  String _selectedLanguage = 'auto'; // تلقائي

  // Getters
  bool get isLoading => _isLoading;
  bool get showAnswers => _showAnswers;
  String get selectedFileName => _selectedFileName;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<GeneratedQuestionModel> get questions => _questions;
  int get generatedQuestionsCount => _generatedQuestionsCount;
  int get totalQuestionsToGenerate => _totalQuestionsToGenerate;
  bool get isTestMode => _isTestMode;
  String get selectedLanguage => _selectedLanguage;

  // Constructor
  AiQuestionsController({required this.vsync}) {
    // التأكد من استخدام العنوان الصحيح للخادم منذ البداية
    updateServerAddress("https://apii-1-kjff.onrender.com");
  }

  // التحقق من حالة الخادم عند بدء التطبيق
  Future<void> checkServerStatus() async {
    try {
      // محاولة التحقق من حالة الخادم
      bool isConnected = await AiQuestionsApiService.testConnection();
      if (!isConnected) {
        // إذا فشل الاتصال، قم بتفعيل وضع الاختبار تلقائياً
        _isTestMode = true;
        debugPrint("تم تفعيل وضع الاختبار تلقائياً لأن الخادم غير متوفر");
      } else {
        // إذا نجح الاتصال، قم بتعطيل وضع الاختبار
        _isTestMode = false;
        debugPrint(
            "تم الاتصال بالخادم بنجاح: ${AiQuestionsApiService.serverInfo}");
      }
    } catch (e) {
      debugPrint("خطأ أثناء التحقق من حالة الخادم: $e");
      // تفعيل وضع الاختبار عند حدوث خطأ
      _isTestMode = true;
    }
    notifyListeners();
  }

  // إضافة هذه الدالة للسماح بتغيير عنوان الخادم من واجهة المستخدم
  void updateServerAddress(String newAddress) {
    try {
      if (newAddress.isEmpty) {
        // إذا كان العنوان فارغاً، استخدم العنوان الافتراضي
        AiQuestionsApiService.setServerAddress(
            "https://apii-1-kjff.onrender.com");
      } else {
        // قم بتحديث عنوان الخادم
        AiQuestionsApiService.setServerAddress(newAddress);
      }
      // اطبع العنوان الجديد للتشخيص
      debugPrint(
          "تم تحديث عنوان الخادم إلى: ${AiQuestionsApiService.serverInfo}");
    } catch (e) {
      debugPrint("خطأ أثناء تحديث عنوان الخادم: $e");
    }
  }

  // دالة فارغة للحفاظ على التوافق
  void showApiKeyDialog(BuildContext context) {
    // لا نفعل شيئًا لأننا لم نعد نستخدم مفتاح API المدخل
    // عرض رسالة إعلامية للمستخدم
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

  // طريقة لتغيير اللغة المختارة - تم الإبقاء عليها للتوافق
  void setSelectedLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Initialize animations
  void initializeAnimations() {
    // إعداد متحكم الرسوم المتحركة للتنقل بين الأسئلة
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
    questionsCountController.dispose();
    manualInputController.dispose();
    super.dispose();
  }

  // التقاط ملف (نصي أو PDF) وقراءته
  Future<void> pickFileAndReadContent(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await AiQuestionsFileService.pickAndReadFile();

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
          // عند اختيار ملف جديد، نمسح الأسئلة السابقة ونعيد ضبط الحالة
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
      _showErrorSnackBar(context, "${AiQuestionsStrings.filePickError}$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // استدعاء خدمة AI لإنشاء الأسئلة
  Future<void> generateQuestions(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // التحقق من وضع الاختبار
    if (_isTestMode) {
      _generateDummyQuestions();
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

    // التحقق من عدد الأسئلة
    int questionCount = int.tryParse(questionsCountController.text) ?? 1;
    if (questionCount < 1) {
      _showErrorSnackBar(
          context, AiQuestionsStrings.invalidQuestionsCountError);
      return;
    }

    // بدء حالة التحميل
    _isLoading = true;
    _questions = [];
    _showAnswers = false;
    _currentQuestionIndex = 0;
    _requestCounter += 100;
    _generatedQuestionsCount = 0;
    _totalQuestionsToGenerate = questionCount;
    notifyListeners();

    loadingController.repeat();

    try {
      // التأكد من استخدام العنوان الصحيح للخادم
      updateServerAddress("https://apii-1-kjff.onrender.com");

      // استدعاء خدمة توليد الأسئلة - استخدام "auto" كقيمة للغة للكشف التلقائي
      _questions = await AiQuestionsApiService.generateQuestions(
        text: textToUse,
        questionCount: questionCount,
        apiKey: "", // المفتاح غير مطلوب، سيتم استخدام المفتاح المضمن في الخادم
        language: _selectedLanguage, // استخدام اللغة المحددة (auto افتراضياً)
        clearHistory: true,
        fallbackToTestMode: () {
          // دالة للتبديل إلى وضع الاختبار عند فشل الاتصال
          _isTestMode = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "تم التبديل تلقائياً إلى وضع الاختبار بسبب مشكلة في الاتصال"),
              backgroundColor: Color(0xFF4338CA),
              duration: Duration(seconds: 5),
            ),
          );
        },
      );

      animationController.reset();
      animationController.forward();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AiQuestionsStrings.generationSuccessText
              .replaceFirst('%d', _questions.length.toString())),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("استثناء أثناء توليد الأسئلة: $e");

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

      // استخدام أسئلة تجريبية كحل احتياطي إذا فشلت كل المحاولات
      _generateDummyQuestions();
    } finally {
      loadingController.stop();
      _isLoading = false;
      _generatedQuestionsCount = 0;
      notifyListeners();
    }
  }

  // توليد أسئلة بسيطة من النص إذا فشل التحليل
  List<GeneratedQuestionModel> _generateQuestionsFromTextFallback(
      String text, int count) {
    List<GeneratedQuestionModel> generatedQuestions = [];

    // تقسيم النص إلى جمل
    List<String> sentences = text
        .split(RegExp(r'[.!?؟:;،\n]'))
        .where((s) => s.trim().length > 15)
        .toList();

    if (sentences.isEmpty) {
      return _generateBasicQuestions();
    }

    // اختيار عدد الجمل بناءً على المطلوب
    final questionsToGenerate = math.min(count, sentences.length);
    sentences.shuffle();

    for (int i = 0; i < questionsToGenerate; i++) {
      final sentence = sentences[i].trim();
      final words = sentence.split(' ').where((w) => w.length > 3).toList();

      if (words.length < 4) continue;

      words.shuffle();

      // استخراج كلمة رئيسية للسؤال
      final keyWord = words[0];
      final question =
          "ما هي الكلمة المناسبة التي تكمل الجملة: ${sentence.replaceFirst(keyWord, "________")}";

      // إنشاء الخيارات
      List<String> options = [keyWord];
      for (int j = 1; j < math.min(4, words.length); j++) {
        options.add(words[j]);
      }

      // إضافة خيارات إضافية إذا لزم الأمر
      while (options.length < 4) {
        options.add("خيار ${options.length + 1}");
      }

      // ترتيب الخيارات بشكل عشوائي
      options.shuffle();
      final correctIndex = options.indexOf(keyWord);

      generatedQuestions.add(GeneratedQuestionModel(
        question: question,
        options: options,
        correctIndex: correctIndex,
      ));
    }

    return generatedQuestions.isEmpty
        ? _generateBasicQuestions()
        : generatedQuestions;
  }

  // توليد أسئلة أساسية في حالة فشل كل الطرق
  List<GeneratedQuestionModel> _generateBasicQuestions() {
    return [
      GeneratedQuestionModel(
        question: "ما هو أكبر كوكب في المجموعة الشمسية؟",
        options: ["الأرض", "المشتري", "زحل", "المريخ"],
        correctIndex: 1,
      ),
      GeneratedQuestionModel(
        question: "من هو مؤلف رواية (مائة عام من العزلة)؟",
        options: [
          "نجيب محفوظ",
          "غابرييل غارسيا ماركيز",
          "إرنست همنغواي",
          "فيودور دوستويفسكي"
        ],
        correctIndex: 1,
      ),
      GeneratedQuestionModel(
        question: "ما هي العاصمة الفرنسية؟",
        options: ["لندن", "باريس", "برلين", "روما"],
        correctIndex: 1,
      ),
      GeneratedQuestionModel(
        question: "ما هي أكبر قارة في العالم؟",
        options: ["أفريقيا", "أوروبا", "أمريكا الشمالية", "آسيا"],
        correctIndex: 3,
      ),
      GeneratedQuestionModel(
        question: "ما هو العنصر الكيميائي الذي رمزه O؟",
        options: ["الأكسجين", "الأوزون", "الذهب", "الفضة"],
        correctIndex: 0,
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
            // تفعيل وضع الاختبار واستخدام أسئلة وهمية
            _isTestMode = true;
            _generateDummyQuestions();
          },
        ),
      ),
    );
  }

  // إنشاء أسئلة تجريبية للاختبار (بدلاً من الاتصال بالخادم)
  void _generateDummyQuestions() {
    _isLoading = true;
    notifyListeners();

    // محاكاة وقت التحميل
    Future.delayed(const Duration(seconds: 1), () {
      _questions = _generateBasicQuestions();

      _isLoading = false;
      _currentQuestionIndex = 0;
      _showAnswers = false;

      animationController.reset();
      animationController.forward();
      notifyListeners();
    });
  }

  // عند الضغط على زر "تحقق" نعرض الإجابات الصحيحة
  void checkAnswers(BuildContext context) {
    _showAnswers = true; // لعرض الألوان على الخيارات
    notifyListeners();

    // حساب عدد الصحيح والخطأ
    final correctCount = _calculateCorrectAnswers();
    final totalCount = _questions.length;

    // عرض نافذة النتيجة
    showDialog(
      context: context,
      builder: (ctx) => AiQuestionsResultDialogComponent(
        correctCount: correctCount,
        totalCount: totalCount,
      ),
    );
  }

  // انتقال للسؤال التالي مع رسوم متحركة
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      // تشغيل رسوم متحركة للخروج
      animationController.reverse().then((_) {
        _currentQuestionIndex++;
        notifyListeners();
        // تشغيل رسوم متحركة للدخول
        animationController.forward();
      });
    }
  }

  // انتقال للسؤال السابق مع رسوم متحركة
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      // تشغيل رسوم متحركة للخروج
      animationController.reverse().then((_) {
        _currentQuestionIndex--;
        notifyListeners();
        // تشغيل رسوم متحركة للدخول
        animationController.forward();
      });
    }
  }

  // تعيين إجابة المستخدم
  void setUserAnswer(int optionIndex) {
    _questions[_currentQuestionIndex].userAnswerIndex = optionIndex;
    notifyListeners();
  }

  // حساب عدد الإجابات الصحيحة
  int _calculateCorrectAnswers() {
    int correctCount = 0;
    for (final q in _questions) {
      if (q.userAnswerIndex == q.correctIndex) {
        correctCount++;
      }
    }
    return correctCount;
  }

  // إعادة تعيين المحتوى لإنشاء أسئلة جديدة
  void resetContent({bool fullReset = false}) {
    _questions = [];
    _showAnswers = false;
    _currentQuestionIndex = 0;

    // زيادة العداد بقيمة كبيرة لإجبار GPT على إعطاء أسئلة جديدة تماماً
    _requestCounter += 1000 + _random.nextInt(1000);

    if (fullReset) {
      // إعادة تعيين كاملة تشمل مسح قائمة الأسئلة السابقة
      _previousQuestionTexts = [];
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
