import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/login_colors.dart';

// نموذج بيانات المستخدم
class UserInfo {
  final String id;
  final String name;
  final String major;

  UserInfo({
    required this.id,
    required this.name,
    required this.major,
  });

  // إضافة طريقة لإنشاء النموذج من Map
  factory UserInfo.fromMap(String id, Map<String, dynamic> data) {
    return UserInfo(
      id: id,
      name: data['name'] ?? 'مستخدم',
      major: data['major'] ?? 'غير محدد',
    );
  }

  // إضافة طريقة حفظ المستخدم محليًا
  Future<void> saveLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_user_id', id);
    await prefs.setString('user_name', name);
    await prefs.setString('user_major', major);
  }
}

// نموذج نتيجة تسجيل الدخول
class SignInResult {
  final bool success;
  final UserInfo? userInfo;
  final String? errorMessage;

  SignInResult({
    required this.success,
    this.userInfo,
    this.errorMessage,
  });
}

class LoginFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // التحقق من وجود مستخدم مسجل بالفعل
  Future<UserInfo?> checkLoggedInUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;
      final userInfo = UserInfo.fromMap(user.uid, userData);

      // حفظ بيانات المستخدم محليًا
      await userInfo.saveLocally();

      return userInfo;
    } catch (e) {
      debugPrint('خطأ في استرجاع بيانات المستخدم: $e');
      return null;
    }
  }

  // تسجيل الدخول - تم تحسينه للأداء وإدارة الأخطاء الأفضل
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // تنفيذ عملية تسجيل الدخول من خلال Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // إذا لم يتم العثور على مستخدم، نعود بخطأ
      if (userCredential.user == null) {
        return SignInResult(
            success: false, errorMessage: 'تعذر الحصول على بيانات المستخدم');
      }

      // حفظ بيانات المستخدم في التخزين المحلي للتسجيل التلقائي
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);

      // جلب بيانات المستخدم من Firestore
      try {
        final userId = userCredential.user!.uid;
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final userInfo = UserInfo.fromMap(userId, userData);

          // حفظ البيانات محليًا
          await userInfo.saveLocally();

          return SignInResult(
            success: true,
            userInfo: userInfo,
          );
        }
      } catch (e) {
        debugPrint('خطأ في جلب بيانات المستخدم بعد تسجيل الدخول: $e');
      }

      return SignInResult(
          success: false, errorMessage: 'تعذر الحصول على بيانات المستخدم');
    } on FirebaseAuthException catch (e) {
      // استخدام Map للحصول على رسائل الخطأ بشكل أكثر فعالية
      final errorMessages = {
        'user-not-found': 'البريد الإلكتروني غير مسجل',
        'wrong-password': 'كلمة المرور غير صحيحة',
        'invalid-email': 'البريد الإلكتروني غير صالح',
        'user-disabled': 'هذا الحساب معطل',
        'too-many-requests': 'محاولات كثيرة جداً. حاول مرة أخرى لاحقاً',
      };

      final errorMsg = errorMessages[e.code] ?? 'حدث خطأ أثناء تسجيل الدخول';
      return SignInResult(success: false, errorMessage: errorMsg);
    } catch (e) {
      return SignInResult(
          success: false, errorMessage: 'حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  // عرض رسالة نجاح تسجيل الدخول
  void showLoginSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم تسجيل الدخول بنجاح',
          style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
          textAlign: TextAlign.center,
        ),
        backgroundColor: LoginColors.darkPurple,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  // الانتقال إلى الشاشة الرئيسية
  void navigateToHomeScreen(BuildContext context, UserInfo userInfo) {
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {
        'userName': userInfo.name,
        'userMajor': userInfo.major,
      },
    );
  }
}
