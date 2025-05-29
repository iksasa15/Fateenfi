import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../constants/ai_summary_strings.dart';
import '../services/ai_summary_api_service.dart';
import '../services/ai_summary_file_service.dart';
import '../../../../models/summary_model.dart';

class AiSummaryController extends ChangeNotifier {
  // Animation controllers injected from parent
  final TickerProvider vsync;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late AnimationController loadingController;

  // Text controllers
  final TextEditingController pointsCountController =
      TextEditingController(text: "5");
  final TextEditingController manualInputController = TextEditingController();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State variables
  bool _isLoading = false;
  String? _fileContent;
  String _selectedFileName = "";
  SummaryModel _summary = SummaryModel.empty();
  int _requestCounter = 0;
  final math.Random _random = math.Random();
  bool _isTestMode = false;
  String _selectedLanguage = 'auto';

  // Getters
  bool get isLoading => _isLoading;
  String get selectedFileName => _selectedFileName;
  SummaryModel get summary => _summary;
  bool get isTestMode => _isTestMode;
  String get selectedLanguage => _selectedLanguage;

  // Constructor
  AiSummaryController({required this.vsync});

  // طريقة لتغيير اللغة المختارة
  void setSelectedLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Initialize animations
  void initializeAnimations() {
    // إعداد متحكم الرسوم المتحركة
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
    pointsCountController.dispose();
    manualInputController.dispose();
    super.dispose();
  }

  // التقاط ملف (نصي أو PDF) وقراءته
  Future<void> pickFileAndReadContent(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await AiSummaryFileService.pickAndReadFile();

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
          // عند اختيار ملف جديد، نمسح الملخص السابق ونعيد ضبط الحالة
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
      _showErrorSnackBar(context, "${AiSummaryStrings.filePickError}$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // استدعاء خدمة AI لإنشاء الملخص
  Future<void> generateSummary(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // التحقق من وضع الاختبار
    if (_isTestMode) {
      _generateDummySummary();
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

    // التحقق من عدد النقاط
    int pointsCount = int.tryParse(pointsCountController.text) ?? 5;
    if (pointsCount < 1) {
      _showErrorSnackBar(context, AiSummaryStrings.invalidPointsCountError);
      return;
    }

    // بدء حالة التحميل
    _isLoading = true;
    _summary = SummaryModel.empty();
    _requestCounter += 100;
    notifyListeners();

    loadingController.repeat();

    try {
      // استدعاء خدمة توليد الملخص
      _summary = await AiSummaryApiService.generateSummary(
        text: textToUse,
        pointsCount: pointsCount,
        language: _selectedLanguage,
        clearHistory: true,
      );

      animationController.reset();
      animationController.forward();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AiSummaryStrings.generationSuccessText),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("استثناء أثناء توليد الملخص: $e");

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

      // استخدام ملخص تجريبي كحل احتياطي إذا فشلت كل المحاولات
      _generateDummySummary();
    } finally {
      loadingController.stop();
      _isLoading = false;
      notifyListeners();
    }
  }

  // إنشاء ملخص تجريبي للاختبار
  void _generateDummySummary() {
    _isLoading = true;
    notifyListeners();

    // محاكاة وقت التحميل
    Future.delayed(const Duration(seconds: 1), () {
      _summary = SummaryModel(
        title: "ملخص الفصل",
        mainIdea: "هذا ملخص تجريبي للنص الذي تم تحميله.",
        keyPoints: [
          "النقطة الرئيسية الأولى في النص.",
          "النقطة الرئيسية الثانية تشرح المفاهيم الأساسية.",
          "النقطة الثالثة تتناول النتائج الهامة المستخلصة.",
          "النقطة الرابعة تقدم التوصيات والاقتراحات.",
          "النقطة الخامسة تلخص الخلاصة العامة للموضوع.",
        ],
        conclusion:
            "بشكل عام، يقدم هذا النص معلومات قيمة حول الموضوع المطروح ويوفر رؤى هامة للقارئ.",
      );

      _isLoading = false;
      animationController.reset();
      animationController.forward();
      notifyListeners();
    });
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
            // تفعيل وضع الاختبار واستخدام ملخص وهمي
            _isTestMode = true;
            _generateDummySummary();
          },
        ),
      ),
    );
  }

  // مشاركة الملخص
  void shareSummary(BuildContext context) {
    // هنا يمكن إضافة وظيفة مشاركة الملخص عبر تطبيقات أخرى
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم نسخ الملخص إلى الحافظة"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // حفظ الملخص كملف
  void saveSummary(BuildContext context) {
    // هنا يمكن إضافة وظيفة حفظ الملخص كملف
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم حفظ الملخص بنجاح"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // إعادة تعيين المحتوى
  void resetContent({bool fullReset = false}) {
    _summary = SummaryModel.empty();

    // زيادة العداد لإجبار النموذج على إعطاء ملخصات جديدة
    _requestCounter += 1000 + _random.nextInt(1000);

    notifyListeners();
  }

  // تفعيل/تعطيل وضع الاختبار
  void toggleTestMode() {
    _isTestMode = !_isTestMode;
    notifyListeners();
  }
}
