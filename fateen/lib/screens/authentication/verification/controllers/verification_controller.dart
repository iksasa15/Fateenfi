import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/verification_strings.dart';
import '../services/verification_firebase_service.dart';
import '../../../../models/student.dart';

class VerificationResult {
  final bool success;
  final String? errorMessage;

  VerificationResult({
    required this.success,
    this.errorMessage,
  });
}

class VerificationController extends ChangeNotifier {
  final String email;
  final String password;
  final VerificationFirebaseService _firebaseService =
      VerificationFirebaseService();

  bool _isVerified = false;
  bool _isLoading = false;
  bool _resendingEmail = false;
  Timer? _timer;
  int _countdown = 60;
  bool _isInitialized = false;

  // القيم المُصدرة (getters)
  bool get isVerified => _isVerified;
  bool get isLoading => _isLoading;
  bool get resendingEmail => _resendingEmail;
  int get countdown => _countdown;
  bool get isInitialized => _isInitialized;

  VerificationController({required this.email, required this.password});

  // تهيئة وحدة التحكم
  void init(BuildContext context) {
    if (_isInitialized) return;

    _checkEmailVerification();
    _startCountdown();

    _isInitialized = true;
  }

  // تنظيف الموارد
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // بدء العد التنازلي لإعادة الإرسال
  void _startCountdown() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        _countdown--;
        notifyListeners();
      }
    });
  }

  // فحص حالة التحقق من البريد - مع إضافة وقت انتظار بين الفحوصات
  void _checkEmailVerification() {
    // تحديد مدة بين الفحوصات (10 ثواني)
    const Duration checkInterval = Duration(seconds: 10);

    _timer = Timer.periodic(checkInterval, (_) async {
      try {
        // استخدام طريقة التحقق المباشرة التي تقلل من عمليات تسجيل الدخول
        final verified = await _checkCurrentUserEmailVerification();

        if (verified) {
          _isVerified = true;
          notifyListeners();
          _timer?.cancel();
        }
      } catch (e) {
        debugPrint("خطأ أثناء فحص حالة التحقق: $e");
      }
    });
  }

  // تحقق بسيط من حالة البريد للمستخدم الحالي
  Future<bool> _checkCurrentUserEmailVerification() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // إعادة تحميل بيانات المستخدم من السيرفر
        await currentUser.reload();

        // الحصول على الحالة المحدثة بعد إعادة التحميل
        final isVerified =
            FirebaseAuth.instance.currentUser?.emailVerified ?? false;

        if (isVerified) {
          // تحديث في Firestore
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .update({
              'emailVerified': true,
            });
          } catch (e) {
            debugPrint("خطأ في تحديث Firestore: $e");
            // استمر حتى لو حدث خطأ في التحديث
          }
        }

        return isVerified;
      }
      return false;
    } catch (e) {
      debugPrint("خطأ في التحقق البسيط من البريد: $e");
      return false;
    }
  }

  // ضبط حالة التحميل
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // تعيين حالة التحقق (للتجاوز المؤقت)
  void setVerified(bool verified) {
    _isVerified = verified;
    notifyListeners();
  }

  // طريقة التحقق المعززة من البريد الإلكتروني - مع التعامل مع تجاوز الحصة
  Future<bool> forceCheckEmailVerification() async {
    try {
      // محاولة التحقق مباشرة من الحالة الحالية أولاً
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.reload();
        if (currentUser.emailVerified) {
          _isVerified = true;
          notifyListeners();
          return true;
        }
      }

      // ضوابط إضافية للحد من الطلبات
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt('last_email_check');
      final now = DateTime.now().millisecondsSinceEpoch;

      // تقييد التحقق المعزز مرة واحدة كل 30 ثانية
      if (lastCheck != null && now - lastCheck < 30000) {
        debugPrint('تجنب التحقق المتكرر من حالة البريد الإلكتروني');
        return _isVerified;
      }

      // تحديث وقت آخر تحقق
      await prefs.setInt('last_email_check', now);

      // استخدام الطريقة المحسنة للتحقق باستخدام البيانات
      final verified = await _checkEmailVerificationWithCredentials();

      if (verified) {
        _isVerified = true;
        notifyListeners();
      }

      return verified;
    } catch (e) {
      debugPrint('خطأ في التحقق المعزز من البريد: $e');
      return _isVerified;
    }
  }

  // التحقق من البريد الإلكتروني بعد تحديث الجلسة - مع التعامل مع تجاوز الحصة
  Future<bool> _checkEmailVerificationWithCredentials() async {
    try {
      // التحقق أولاً من قيود الحصة
      final prefs = await SharedPreferences.getInstance();
      final lastLoginAttempt = prefs.getInt('last_login_attempt');
      final now = DateTime.now().millisecondsSinceEpoch;

      // إذا كانت المحاولة الأخيرة منذ أقل من 30 ثانية، لا تحاول مرة أخرى
      if (lastLoginAttempt != null && now - lastLoginAttempt < 30000) {
        debugPrint(
            "محاولة تسجيل دخول متكررة، تجاوز المحاولة للحد من تجاوز الحصة");
        return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      }

      // تحديث وقت آخر محاولة
      await prefs.setInt('last_login_attempt', now);

      // تسجيل الخروج
      await FirebaseAuth.instance.signOut();

      // إعادة تسجيل الدخول
      // تعديل: أضف try-catch لتجنب الاستمرار في المحاولة عند وجود خطأ
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        if (e.toString().contains('too-many-requests') ||
            e.toString().contains('quota')) {
          debugPrint("تم تجاوز حصة محاولات تسجيل الدخول: $e");
          // استخدام الحالة الحالية
          return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
        }
        throw e;
      }

      // إعادة تحميل المستخدم من السيرفر
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        bool verified =
            FirebaseAuth.instance.currentUser?.emailVerified ?? false;

        // تحديث في Firestore إذا كان البريد مؤكدًا
        if (verified) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({
              'emailVerified': true,
            });
          } catch (e) {
            debugPrint("خطأ في تحديث Firestore: $e");
          }
        }

        return verified;
      }

      return false;
    } catch (e) {
      // تسجيل الخطأ لكن تجنب رمي استثناء قد يؤدي إلى المزيد من محاولات تسجيل الدخول
      debugPrint("خطأ في التحقق من البريد بعد تحديث الجلسة: $e");
      return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    }
  }

  // تسجيل الدخول تلقائياً بعد التحقق - النسخة المعدلة لتتعامل مع تجاوز الحصة
  Future<VerificationResult> signInAutomatically(BuildContext context) async {
    if (_isLoading || !_isInitialized) {
      return VerificationResult(
        success: false,
        errorMessage: 'العملية قيد التنفيذ بالفعل',
      );
    }

    setLoading(true);

    try {
      // التحقق من وقت آخر محاولة تسجيل دخول
      final prefs = await SharedPreferences.getInstance();
      final lastSignIn = prefs.getInt('last_signin_attempt');
      final now = DateTime.now().millisecondsSinceEpoch;

      // تقييد محاولات تسجيل الدخول المتكررة
      if (lastSignIn != null && now - lastSignIn < 10000) {
        // 10 ثواني
        setLoading(false);
        return VerificationResult(
          success: false,
          errorMessage: 'يرجى الانتظار قليلاً قبل المحاولة مرة أخرى',
        );
      }

      await prefs.setInt('last_signin_attempt', now);

      // استخدم طريقة تسجيل دخول بسيطة بدون تحقق إضافي
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        // حفظ بيانات الاعتماد للتسجيل التلقائي
        await prefs.setString('user_email', email.trim());
        await prefs.setString('user_password', password.trim());

        // تأكد من وجود مستخدم صالح
        if (userCredential.user == null) {
          setLoading(false);
          return VerificationResult(
            success: false,
            errorMessage: 'فشل تسجيل الدخول: لم يتم العثور على المستخدم',
          );
        }

        // تحديث آخر تسجيل دخول فقط إذا كان ذلك ممكنًا
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        } catch (firestoreError) {
          // تجاهل أخطاء Firestore - لا نريد أن تمنع تسجيل الدخول
          debugPrint('تحذير: لم يتم تحديث آخر وقت تسجيل دخول: $firestoreError');
        }

        setLoading(false);
        return VerificationResult(success: true);
      } catch (e) {
        setLoading(false);

        // تسجيل الخطأ للتشخيص
        debugPrint('خطأ تفصيلي في تسجيل الدخول: $e');

        // معالجة خاصة بأخطاء Firebase
        if (e is FirebaseAuthException) {
          if (e.code == 'too-many-requests' || e.toString().contains('quota')) {
            return VerificationResult(
              success: false,
              errorMessage:
                  'تم تجاوز الحد المسموح به من المحاولات، يرجى المحاولة لاحقًا',
            );
          } else if (e.code == 'user-not-found') {
            return VerificationResult(
              success: false,
              errorMessage: 'البريد الإلكتروني غير مسجل',
            );
          } else if (e.code == 'wrong-password') {
            return VerificationResult(
              success: false,
              errorMessage: 'كلمة المرور غير صحيحة',
            );
          } else if (e.code == 'invalid-credential') {
            return VerificationResult(
              success: false,
              errorMessage:
                  'بيانات الاعتماد غير صالحة، يرجى التحقق من البريد وكلمة المرور',
            );
          }
        }

        return VerificationResult(
          success: false,
          errorMessage: 'حدث خطأ أثناء تسجيل الدخول، الرجاء المحاولة مرة أخرى',
        );
      }
    } catch (e) {
      setLoading(false);

      debugPrint('استثناء غير متوقع: $e');

      return VerificationResult(
        success: false,
        errorMessage: 'حدث خطأ غير متوقع، الرجاء المحاولة مرة أخرى لاحقًا',
      );
    }
  }

  // إعادة إرسال بريد التحقق - مع التعامل مع تجاوز الحصة
  Future<void> resendVerificationEmail() async {
    if (_resendingEmail || _countdown > 0 || !_isInitialized) return;

    _resendingEmail = true;
    notifyListeners();

    try {
      // التحقق من وقت آخر محاولة إرسال
      final prefs = await SharedPreferences.getInstance();
      final lastResend = prefs.getInt('last_resend_attempt');
      final now = DateTime.now().millisecondsSinceEpoch;

      // لا تسمح بإعادة الإرسال أكثر من مرة كل 2 دقيقة
      if (lastResend != null && now - lastResend < 120000) {
        _resendingEmail = false;
        notifyListeners();
        return;
      }

      await prefs.setInt('last_resend_attempt', now);

      // استخدام Student.resendVerificationEmail
      final result = await Student.resendVerificationEmail(email);

      if (result == null) {
        // بدء العد التنازلي لإعادة الإرسال
        _countdown = 60;
        _startCountdown();
      } else {
        // إظهار رسالة الخطأ (يمكن إضافة معالجة الأخطاء هنا)
        debugPrint("خطأ في إعادة إرسال البريد: $result");
      }
    } catch (e) {
      debugPrint("استثناء في إعادة إرسال البريد: $e");
    } finally {
      _resendingEmail = false;
      notifyListeners();
    }
  }
}
