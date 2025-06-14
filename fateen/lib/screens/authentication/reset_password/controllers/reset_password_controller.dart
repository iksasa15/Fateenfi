import 'package:flutter/material.dart';
import '../services/reset_password_firebase_service.dart';

class ResetPasswordController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final ResetPasswordFirebaseService _firebaseService =
      ResetPasswordFirebaseService();

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _serverError;
  double _resetProgress = 0.0;

  // القيم المُصدرة (getters)
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get serverError => _serverError;
  double get resetProgress => _resetProgress;

  // تهيئة وحدة التحكم
  void init(BuildContext context) {
    // إضافة مستمعي الأحداث لمتابعة تقدم النموذج
    emailController.addListener(_updateFormProgress);
  }

  // تنظيف الموارد
  @override
  void dispose() {
    emailController.removeListener(_updateFormProgress);
    emailController.dispose();
    super.dispose();
  }

  // تحديث مؤشر تقدم النموذج
  void _updateFormProgress() {
    _resetProgress = emailController.text.isNotEmpty ? 1.0 : 0.0;
    notifyListeners();
  }

  // ضبط حالة التحميل
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ضبط حالة النجاح
  void setSuccess(bool value) {
    _isSuccess = value;
    notifyListeners();
  }

  // ضبط رسالة الخطأ
  void setServerError(String? message) {
    _serverError = message;
    notifyListeners();
  }

  // التحقق من صحة البريد الإلكتروني
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  // إرسال طلب إعادة تعيين كلمة المرور
  Future<void> resetPassword(GlobalKey<FormState> formKey) async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    setLoading(true);
    setServerError(null);

    try {
      final result = await _firebaseService.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (result.success) {
        setSuccess(true);
      } else if (result.errorMessage != null) {
        setServerError(result.errorMessage);
      }
    } catch (e) {
      setServerError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void clearError() {}
}
