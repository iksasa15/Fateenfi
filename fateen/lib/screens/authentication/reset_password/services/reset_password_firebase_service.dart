import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordResult {
  final bool success;
  final String? errorMessage;

  ResetPasswordResult({
    required this.success,
    this.errorMessage,
  });
}

class ResetPasswordFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // إرسال بريد إعادة تعيين كلمة المرور
  Future<ResetPasswordResult> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return ResetPasswordResult(success: true);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ أثناء إرسال رابط إعادة التعيين';

      // ترجمة أخطاء Firebase
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لا يوجد حساب بهذا البريد الإلكتروني';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صالح';
          break;
        case 'too-many-requests':
          errorMessage = 'لقد تم إرسال الكثير من الطلبات، يرجى المحاولة لاحقًا';
          break;
      }

      return ResetPasswordResult(success: false, errorMessage: errorMessage);
    } catch (e) {
      return ResetPasswordResult(
        success: false,
        errorMessage: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }
}
