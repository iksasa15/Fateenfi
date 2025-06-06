import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/login_firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isLoggingIn = false;
  String _errorMessage = '';
  double loginProgress = 0.0;

  // القيم المُصدرة (getters)
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  bool get isLoggingIn => _isLoggingIn;
  String get errorMessage => _errorMessage;
  bool get passwordVisible => !_obscurePassword;

  // إضافة getters للتحقق من حالة النموذج
  bool get hasEmailInput => emailController.text.isNotEmpty;
  bool get hasPasswordInput => passwordController.text.isNotEmpty;
  bool get isFormValid => hasEmailInput && hasPasswordInput;

  late BuildContext _context;
  final LoginFirebaseService _firebaseService = LoginFirebaseService();

  // تهيئة وحدة التحكم
  void init(BuildContext context) {
    _context = context;
    // التحقق من وجود جلسة فعالة عند بدء التطبيق
    checkLoggedInUser();
    // إضافة مستمعي الأحداث لمتابعة تقدم النموذج
    emailController.addListener(_updateFormProgress);
    passwordController.addListener(_updateFormProgress);
  }

  // تنظيف الموارد
  @override
  void dispose() {
    emailController.removeListener(_updateFormProgress);
    passwordController.removeListener(_updateFormProgress);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // تحديث مؤشر تقدم النموذج
  void _updateFormProgress() {
    int filledFields = 0;
    if (hasEmailInput) filledFields++;
    if (hasPasswordInput) filledFields++;
    loginProgress = filledFields / 2;
    notifyListeners();
  }

  // تبديل حالة إظهار/إخفاء كلمة المرور
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    // تأثير حسي عند التبديل
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  // ضبط حالة التحميل
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ضبط حالة تسجيل الدخول
  void setLoggingIn(bool value) {
    _isLoggingIn = value;
    notifyListeners();
  }

  // ضبط رسالة الخطأ
  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // مسح رسالة الخطأ
  void clearError() {
    if (_errorMessage.isNotEmpty) {
      _errorMessage = '';
      notifyListeners();
    }
  }

  // التحقق من صحة البريد الإلكتروني أو اسم المستخدم
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني أو اسم المستخدم';
    }

    // إذا كان المدخل يحتوي على @ نتحقق من أنه بريد إلكتروني صالح
    if (value.contains('@')) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'الرجاء إدخال بريد إلكتروني صحيح';
      }
    } else {
      // تحقق من صحة اسم المستخدم
      if (value.length < 3) {
        return 'اسم المستخدم يجب أن يتكون من 3 أحرف على الأقل';
      }
    }

    return null;
  }

  // التحقق من صحة كلمة المرور
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تحتوي على 6 أحرف على الأقل';
    }
    return null;
  }

  // التحقق من وجود جلسة فعالة للمستخدم
  Future<void> checkLoggedInUser() async {
    setLoading(true);
    clearError();

    try {
      final userInfo = await _firebaseService.checkLoggedInUser();

      if (userInfo != null && _context.mounted) {
        // التوجيه إلى الشاشة الرئيسية
        _firebaseService.navigateToHomeScreen(_context, userInfo);
      }
    } catch (e) {
      debugPrint('خطأ في استرجاع بيانات المستخدم: $e');
    }

    setLoading(false);
  }

  // مسح بيانات المستخدم السابق
  Future<void> _clearPreviousUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // مسح بيانات المستخدم المحلية
      await prefs.remove('user_name');
      await prefs.remove('user_major');
      await prefs.remove('user_name_key');
      await prefs.remove('user_major_key');
      await prefs.remove('logged_user_id');
      await prefs.remove('prefUserNameKey');
      await prefs.remove('prefUserMajorKey');
      await prefs.remove('prefUserIdKey');
      debugPrint('تم مسح بيانات المستخدم السابق محلياً');
    } catch (e) {
      debugPrint('خطأ في مسح بيانات المستخدم السابق: $e');
    }
  }

  // وظيفة تسجيل الدخول باستخدام اسم المستخدم أو البريد الإلكتروني
  Future<bool> login(GlobalKey<FormState> formKey,
      [BuildContext? context]) async {
    // تحقق من النموذج قبل المتابعة
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return false;
    }

    // مسح بيانات المستخدم السابق
    await _clearPreviousUserData();

    setLoggingIn(true);
    clearError();

    try {
      // الحصول على اسم المستخدم أو البريد الإلكتروني وكلمة المرور
      final identifier = emailController.text.trim();
      final password = passwordController.text.trim();

      // تنفيذ عملية تسجيل الدخول من خلال خدمة Firebase
      final result = await _firebaseService.signIn(
        email: identifier, // يمكن أن يكون بريد إلكتروني أو اسم مستخدم
        password: password,
      );

      // استخدام السياق المقدم أو السياق المخزن في المتحكم
      final ctx = context ?? _context;

      if (ctx.mounted && result.success) {
        // تأثير حسي عند نجاح تسجيل الدخول
        HapticFeedback.heavyImpact();

        // حفظ بيانات تسجيل الدخول للاستخدام التلقائي
        final prefs = await SharedPreferences.getInstance();
        // تحديد إذا كان المعرف هو بريد إلكتروني أو اسم مستخدم
        if (identifier.contains('@')) {
          await prefs.setString('user_email', identifier);
        } else {
          await prefs.setString('user_username', identifier);
        }
        await prefs.setString('user_password', password);

        // عرض رسالة نجاح تسجيل الدخول
        _firebaseService.showLoginSuccessMessage(ctx);

        // انتقل للصفحة الرئيسية
        _firebaseService.navigateToHomeScreen(ctx, result.userInfo!);

        return true;
      } else if (result.errorMessage != null) {
        setErrorMessage(result.errorMessage!);
        return false;
      }

      // إذا وصلنا هنا، فهناك خطأ غير متوقع
      return false;
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تسجيل الدخول');
      return false;
    } finally {
      setLoggingIn(false);
    }
  }

  // إعداد تسجيل الدخول باسم المستخدم
  void setupLoginWithUsername(String username) {
    emailController.text = username;
    // تحديث حالة النموذج
    _updateFormProgress();
    notifyListeners();
  }
}
