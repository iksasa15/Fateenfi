import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // التحقق من تأكيد البريد الإلكتروني مع إعادة تحميل بيانات المستخدم
  Future<bool> checkEmailVerification() async {
    try {
      // الحصول على المستخدم الحالي
      User? user = _auth.currentUser;

      // إعادة تحميل بيانات المستخدم من السيرفر
      if (user != null) {
        await user.reload();
        // استخدام بيانات المستخدم المحدثة
        final isVerified = _auth.currentUser?.emailVerified ?? false;

        // تحديث حالة التحقق في Firestore
        if (isVerified) {
          try {
            await _firestore.collection('users').doc(user.uid).update({
              'emailVerified': true,
            });
          } catch (e) {
            debugPrint('خطأ في تحديث Firestore: $e');
            // استمر حتى لو حدث خطأ في التحديث
          }
        }

        return isVerified;
      }

      return false;
    } catch (e) {
      debugPrint('خطأ في التحقق من البريد: $e');
      return false;
    }
  }

  // التحقق من البريد الإلكتروني بعد تسجيل الدخول
  Future<bool> checkEmailVerificationWithCredentials({
    required String email,
    required String password,
  }) async {
    try {
      // تسجيل الخروج أولاً
      await _auth.signOut();

      // إعادة تسجيل الدخول
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // إعادة تحميل بيانات المستخدم
      User? user = userCred.user;
      await user?.reload();

      // التحقق من حالة البريد بعد التحميل
      final verified = _auth.currentUser?.emailVerified ?? false;

      // تحديث البيانات في Firestore
      if (verified && user != null) {
        try {
          await _firestore.collection('users').doc(user.uid).update({
            'emailVerified': true,
          });
        } catch (e) {
          debugPrint('خطأ في تحديث Firestore: $e');
          // استمر حتى لو حدث خطأ في التحديث
        }
      }

      return verified;
    } catch (e) {
      debugPrint('خطأ في التحقق المعزز من البريد: $e');
      return false;
    }
  }

  // إعادة ارسال بريد التحقق
  Future<String?> resendVerificationEmail(String email) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        // محاولة تسجيل الدخول إذا لم يكن هناك مستخدم حالي
        try {
          return "يجب تسجيل الدخول أولاً";
        } catch (loginError) {
          return "تعذر تسجيل الدخول: $loginError";
        }
      }

      // التحقق إذا كان البريد مؤكد بالفعل
      await user.reload();
      if (user.emailVerified) {
        return "البريد الإلكتروني مؤكد بالفعل";
      }

      // إرسال بريد التأكيد
      await user.sendEmailVerification();
      return null; // نجاح
    } catch (e) {
      return "حدث خطأ في إرسال بريد التحقق: $e";
    }
  }

  // تسجيل الدخول البسيط
  Future<UserCredential?> simpleSignIn({
    required String email,
    required String password,
  }) async {
    try {
      // تسجيل الدخول
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } catch (e) {
      debugPrint('خطأ في تسجيل الدخول البسيط: $e');
      throw e; // إعادة رمي الخطأ للمعالجة في المستوى الأعلى
    }
  }
}
