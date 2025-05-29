import 'package:flutter/material.dart';
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

  // التحقق من صحة البريد الإلكتروني
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
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

  // وظيفة تسجيل الدخول
  Future<void> login(GlobalKey<FormState> formKey) async {
    // تحقق من النموذج قبل المتابعة
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    // مسح بيانات المستخدم السابق
    await _clearPreviousUserData();

    setLoggingIn(true);
    clearError();

    try {
      // تنفيذ عملية تسجيل الدخول من خلال خدمة Firebase
      final result = await _firebaseService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (_context.mounted && result.success) {
        // حفظ بيانات تسجيل الدخول للاستخدام التلقائي
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', emailController.text.trim());
        await prefs.setString('user_password', passwordController.text.trim());

        // عرض رسالة نجاح تسجيل الدخول
        _firebaseService.showLoginSuccessMessage(_context);

        // انتقل للصفحة الرئيسية
        _firebaseService.navigateToHomeScreen(_context, result.userInfo!);
      } else if (result.errorMessage != null) {
        setErrorMessage(result.errorMessage!);
      }
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تسجيل الدخول');
    } finally {
      setLoggingIn(false);
    }
  }
}
