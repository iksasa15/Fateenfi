import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../shared/constants/auth_colors.dart';

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

  // البحث عن مستخدم بواسطة اسم المستخدم
  Future<Map<String, dynamic>?> findUserByUsername(String username) async {
    try {
      // تحويل اسم المستخدم إلى أحرف صغيرة للبحث بغض النظر عن حالة الأحرف
      final lowercaseUsername = username.toLowerCase();

      // البحث باستخدام الحقل usernameSearchable للتأكد من تطابق النتائج
      final querySnapshot = await _firestore
          .collection('users')
          .where('usernameSearchable', isEqualTo: lowercaseUsername)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      userData['uid'] = userDoc.id; // إضافة معرف المستند

      return userData;
    } catch (e) {
      debugPrint('خطأ في البحث عن المستخدم بواسطة اسم المستخدم: $e');
      return null;
    }
  }

  // تسجيل الدخول باستخدام اسم المستخدم
  Future<SignInResult> signInWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      // البحث عن المستخدم باستخدام اسم المستخدم
      final userData = await findUserByUsername(username);

      if (userData == null) {
        return SignInResult(
            success: false, errorMessage: 'اسم المستخدم غير موجود');
      }

      // استخدام البريد الإلكتروني المرتبط باسم المستخدم للتسجيل
      final email = userData['email'] as String;

      // تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user == null) {
          return SignInResult(
              success: false, errorMessage: 'تعذر الحصول على بيانات المستخدم');
        }

        // تطبيق تأثير اهتزاز خفيف للنجاح
        HapticFeedback.lightImpact();

        // إنشاء كائن UserInfo من البيانات
        final userInfo = UserInfo.fromMap(
          userCredential.user!.uid,
          userData,
        );

        // حفظ بيانات المستخدم محليًا
        await userInfo.saveLocally();

        // حفظ اسم المستخدم وكلمة المرور للتسجيل التلقائي
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_username', username);
        await prefs.setString('user_password', password);

        return SignInResult(
          success: true,
          userInfo: userInfo,
        );
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'wrong-password') {
            return SignInResult(
                success: false, errorMessage: 'كلمة المرور غير صحيحة');
          }
        }
        throw e;
      }
    } on FirebaseAuthException catch (e) {
      // تطبيق تأثير اهتزاز للأخطاء
      HapticFeedback.mediumImpact();

      // استخدام Map للحصول على رسائل الخطأ بشكل أكثر فعالية
      final errorMessages = {
        'user-not-found': 'اسم المستخدم غير مسجل',
        'wrong-password': 'كلمة المرور غير صحيحة',
        'user-disabled': 'هذا الحساب معطل',
        'too-many-requests': 'محاولات كثيرة جداً. حاول مرة أخرى لاحقاً',
      };

      final errorMsg = errorMessages[e.code] ?? 'حدث خطأ أثناء تسجيل الدخول';
      return SignInResult(success: false, errorMessage: errorMsg);
    } catch (e) {
      HapticFeedback.vibrate();
      return SignInResult(
          success: false, errorMessage: 'حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  // تسجيل الدخول - تم تحسينه للأداء وإدارة الأخطاء الأفضل
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // التحقق إذا كان المدخل هو اسم مستخدم وليس بريد إلكتروني
      if (!email.contains('@')) {
        // استخدام دالة تسجيل الدخول باسم المستخدم
        return signInWithUsername(
          username: email,
          password: password,
        );
      }

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

      // تطبيق تأثير اهتزاز خفيف للنجاح
      HapticFeedback.lightImpact();

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
      // تطبيق تأثير اهتزاز للأخطاء
      HapticFeedback.mediumImpact();

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
      HapticFeedback.vibrate();
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
        backgroundColor: AuthColors.darkPurple,
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
