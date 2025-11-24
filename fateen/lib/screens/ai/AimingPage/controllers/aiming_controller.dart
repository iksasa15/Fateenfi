import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/aiming_api_service.dart';
import '../services/aiming_image_service.dart';
import '../../../../models/recognized_object_model.dart';

class AimingController extends ChangeNotifier {
  // Animation controllers injected from parent
  final TickerProvider vsync;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late AnimationController loadingController;

  // State variables
  bool _isLoading = false;
  String? _imagePath;
  String? _imageBase64;
  List<RecognizedObjectModel> _recognizedObjects = [];
  bool _isTestMode = false;

  // إضافة متغير لتتبع محاولات الفشل المتتالية
  int _failedCameraAttempts = 0;
  bool _cameraBlocked = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get imagePath => _imagePath;
  List<RecognizedObjectModel> get recognizedObjects => _recognizedObjects;
  bool get isTestMode => _isTestMode;
  bool get cameraBlocked => _cameraBlocked;

  // Constructor
  AimingController({required this.vsync}) {
    updateServerAddress("https://apii-image-recognition.onrender.com");
  }

  // Initialize animations
  void initializeAnimations() {
    // إعداد متحكم الرسوم المتحركة للنتائج
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
    super.dispose();
  }

  // التحقق من حالة الخادم عند بدء التطبيق
  Future<void> checkServerStatus() async {
    try {
      // محاولة التحقق من حالة الخادم
      bool isConnected = await AimingApiService.testConnection();
      if (!isConnected) {
        // إذا فشل الاتصال، قم بتفعيل وضع الاختبار تلقائياً
        _isTestMode = true;
        debugPrint("تم تفعيل وضع الاختبار تلقائياً لأن الخادم غير متوفر");
      } else {
        // إذا نجح الاتصال، قم بتعطيل وضع الاختبار
        _isTestMode = false;
        debugPrint("تم الاتصال بالخادم بنجاح: ${AimingApiService.serverInfo}");
      }
    } catch (e) {
      debugPrint("خطأ أثناء التحقق من حالة الخادم: $e");
      // تفعيل وضع الاختبار عند حدوث خطأ
      _isTestMode = true;
    }
    notifyListeners();
  }

  // تحديث عنوان الخادم
  void updateServerAddress(String newAddress) {
    try {
      if (newAddress.isEmpty) {
        // إذا كان العنوان فارغاً، استخدم العنوان الافتراضي
        AimingApiService.setServerAddress(
            "https://apii-image-recognition.onrender.com");
      } else {
        // قم بتحديث عنوان الخادم
        AimingApiService.setServerAddress(newAddress);
      }
      debugPrint("تم تحديث عنوان الخادم إلى: ${AimingApiService.serverInfo}");
    } catch (e) {
      debugPrint("خطأ أثناء تحديث عنوان الخادم: $e");
    }
  }

  // طريقة آمنة لالتقاط الصور مع معالجة الاستثناءات والخروج المفاجئ
  Future<void> safePickImage(ImageSource source, BuildContext context) async {
    // إذا كانت الكاميرا محظورة، اعرض رسالة ثم عد
    if (_cameraBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "يبدو أن هناك مشكلة في الوصول للكاميرا. الرجاء استخدام وضع الاختبار."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    try {
      // تسجيل محاولة التقاط الصورة في سجل التطبيق
      debugPrint("بدء محاولة التقاط الصورة...");

      // التقاط الصورة
      await pickImage(source, context);

      // إعادة ضبط عداد المحاولات الفاشلة عند النجاح
      _failedCameraAttempts = 0;
    } catch (e) {
      // زيادة عداد المحاولات الفاشلة
      _failedCameraAttempts++;

      debugPrint(
          "خطأ خطير أثناء التقاط الصورة (محاولة فاشلة رقم $_failedCameraAttempts): $e");

      // إذا كان عدد المحاولات الفاشلة تجاوز الحد، ضع علامة على الكاميرا كمحظورة
      if (_failedCameraAttempts >= 3) {
        _cameraBlocked = true;

        // إظهار رسالة مفصلة عن المشكلة
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text("مشكلة في الكاميرا"),
              content: const Text(
                  "هناك مشكلة مستمرة في الوصول للكاميرا. سنستخدم وضع الاختبار بدلاً من ذلك. هل تود المتابعة؟"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // تفعيل وضع الاختبار واستخدام بيانات تجريبية
                    _isTestMode = true;
                    _generateDummyImage();
                  },
                  child: const Text("متابعة"),
                ),
              ],
            ),
          );
        }
      } else {
        // إذا كان عدد المحاولات أقل من الحد، أعرض رسالة بسيطة
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "حدث خطأ أثناء فتح الكاميرا: ${e.toString().substring(0, min(50, e.toString().length))}..."),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  // إنشاء صورة وهمية للاختبار
  void _generateDummyImage() {
    _imagePath = "dummy_image_path"; // مسار وهمي فقط للتمثيل
    _imageBase64 = ""; // قيمة وهمية
    notifyListeners();

    // عرض رسالة للمستخدم
    debugPrint("تم إنشاء صورة وهمية في وضع الاختبار");
  }

  // التقاط صورة من الكاميرا أو معرض الصور
  Future<void> pickImage(ImageSource source, BuildContext context) async {
    try {
      // استخدام AimingImageService لالتقاط الصورة
      final result = await AimingImageService.pickImage(source);

      if (!context.mounted) return; // التحقق من أن السياق لا يزال صالحًا

      if (result['success']) {
        _imagePath = result['imagePath'];
        _imageBase64 = result['imageBase64'];

        // مسح النتائج السابقة إن وجدت
        _recognizedObjects = [];

        // عرض رسالة نجاح
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم التقاط الصورة بنجاح"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (context.mounted) {
          _showErrorSnackBar(
              context, result['error'] ?? "حدث خطأ أثناء التقاط الصورة");
        }
      }
    } catch (e) {
      debugPrint("خطأ أثناء التقاط الصورة: $e");
      if (context.mounted) {
        _showErrorSnackBar(context, "حدث خطأ أثناء التقاط الصورة");
      }

      // إعادة رفع الاستثناء ليتم التقاطه في safePickImage
      rethrow;
    }

    notifyListeners();
  }

  // معالجة الصورة والتعرف على محتواها
  Future<void> processImage(BuildContext context) async {
    if (_imagePath == null && !_isTestMode) {
      _showErrorSnackBar(context, "الرجاء التقاط صورة أولاً");
      return;
    }

    // التحقق من وضع الاختبار
    if (_isTestMode) {
      _generateDummyResults();
      return;
    }

    // بدء حالة التحميل
    _isLoading = true;
    _recognizedObjects = [];
    notifyListeners();

    loadingController.repeat();

    try {
      // استدعاء خدمة التعرف على الصور
      _recognizedObjects = await AimingApiService.recognizeImage(
        imageBase64: _imageBase64!,
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
          content:
              Text("تم التعرف على ${_recognizedObjects.length} عنصر في الصورة"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("استثناء أثناء التعرف على الصورة: $e");

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

      // استخدام نتائج تجريبية كحل احتياطي إذا فشلت كل المحاولات
      _generateDummyResults();
    } finally {
      loadingController.stop();
      _isLoading = false;
      notifyListeners();
    }
  }

  // إنشاء نتائج تجريبية في وضع الاختبار
  void _generateDummyResults() {
    _isLoading = true;
    notifyListeners();

    // محاكاة وقت التحميل
    Future.delayed(const Duration(seconds: 2), () {
      _recognizedObjects = [
        RecognizedObjectModel(
          name: "هاتف ذكي",
          confidence: 0.95,
          description: "هاتف ذكي من الجيل الحديث",
        ),
        RecognizedObjectModel(
          name: "مفتاح",
          confidence: 0.87,
          description: "مفتاح معدني لقفل الباب",
        ),
        RecognizedObjectModel(
          name: "نظارة شمسية",
          confidence: 0.82,
          description: "نظارة لحماية العينين من أشعة الشمس",
        ),
        RecognizedObjectModel(
          name: "محفظة",
          confidence: 0.78,
          description: "محفظة جلدية لحفظ النقود والبطاقات",
        ),
      ];

      _isLoading = false;
      animationController.reset();
      animationController.forward();
      notifyListeners();
    });
  }

  // إعادة تعيين المحتوى ومسح الصور
  void resetContent() {
    _imagePath = null;
    _imageBase64 = null;
    _recognizedObjects = [];
    notifyListeners();
  }

  // تفعيل/تعطيل وضع الاختبار
  void toggleTestMode() {
    _isTestMode = !_isTestMode;
    notifyListeners();
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
            // تفعيل وضع الاختبار واستخدام نتائج وهمية
            _isTestMode = true;
            _generateDummyResults();
          },
        ),
      ),
    );
  }
}

