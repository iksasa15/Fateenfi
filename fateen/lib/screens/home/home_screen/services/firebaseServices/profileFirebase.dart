import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// واجهة التعامل مع Firebase للملف الشخصي
class ProfileFirebase {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// جلب بيانات المستخدم
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      // التحقق من وجود اتصال بالإنترنت
      // (هنا يمكن إضافة كود التحقق من الاتصال)

      // جلب بيانات المستخدم من Firestore
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data;
      } else {
        // إنشاء وثيقة جديدة إذا لم تكن موجودة
        await createUserDocumentIfNotExists(userId);

        // في حالة عدم وجود بيانات، إرجاع خريطة فارغة
        return {};
      }
    } catch (e) {
      debugPrint('ProfileFirebase: خطأ في جلب بيانات المستخدم: $e');
      throw Exception('فشل في جلب بيانات المستخدم');
    }
  }

  /// إنشاء وثيقة المستخدم إذا لم تكن موجودة
  static Future<void> createUserDocumentIfNotExists(String userId) async {
    try {
      // التحقق من وجود المستخدم
      final docRef = _firestore.collection('users').doc(userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // إنشاء وثيقة جديدة بالبيانات الأساسية
        final currentUser = _auth.currentUser;
        await docRef.set({
          'name': currentUser?.displayName ?? 'مستخدم',
          'email': currentUser?.email ?? '',
          'major': 'غير محدد',
          'createdAt': FieldValue.serverTimestamp(),
        });

        debugPrint('ProfileFirebase: تم إنشاء وثيقة المستخدم $userId');
      }
    } catch (e) {
      debugPrint('ProfileFirebase: خطأ في إنشاء وثيقة المستخدم: $e');
      throw Exception('فشل في إنشاء وثيقة المستخدم');
    }
  }

  /// تحديث بيانات المستخدم
  static Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? major,
    String? email,
  }) async {
    try {
      // التحقق من وجود المستخدم وإنشائه إذا لم يكن موجوداً
      await createUserDocumentIfNotExists(userId);

      // بناء البيانات للتحديث
      Map<String, dynamic> updateData = {};

      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
      }

      if (major != null && major.isNotEmpty) {
        updateData['major'] = major;
      }

      // إضافة وقت التحديث
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // تحديث البيانات في Firestore
      await _firestore.collection('users').doc(userId).update(updateData);

      // تحديث بيانات المستخدم في Firebase Auth
      if (name != null && name.isNotEmpty) {
        await _auth.currentUser?.updateDisplayName(name);
      }

      // تحديث البريد الإلكتروني إذا تم تغييره
      if (email != null && email.isNotEmpty) {
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email != email) {
          await currentUser.updateEmail(email);
          await _firestore
              .collection('users')
              .doc(userId)
              .update({'email': email});
        }
      }

      debugPrint('ProfileFirebase: تم تحديث بيانات المستخدم $userId');
      return true;
    } catch (e) {
      debugPrint('ProfileFirebase: خطأ في تحديث بيانات المستخدم: $e');
      return false;
    }
  }

  /// تغيير كلمة المرور
  static Future<bool> changeUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null || user.email == null) {
        return false;
      }

      // إعادة المصادقة قبل تغيير كلمة المرور
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // تغيير كلمة المرور
      await user.updatePassword(newPassword);

      debugPrint('ProfileFirebase: تم تغيير كلمة المرور بنجاح');
      return true;
    } catch (e) {
      debugPrint('ProfileFirebase: خطأ في تغيير كلمة المرور: $e');
      return false;
    }
  }

  /// حذف حساب المستخدم
  static Future<bool> deleteUserAccount(String currentPassword) async {
    try {
      final user = _auth.currentUser;

      if (user == null || user.email == null) {
        return false;
      }

      // إعادة المصادقة قبل حذف الحساب
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // حذف بيانات المستخدم من Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // حذف الحساب من Firebase Auth
      await user.delete();

      debugPrint('ProfileFirebase: تم حذف الحساب بنجاح');
      return true;
    } catch (e) {
      debugPrint('ProfileFirebase: خطأ في حذف الحساب: $e');
      return false;
    }
  }

  /// التحقق من اتصال الإنترنت
  static Future<bool> checkInternetConnection() async {
    try {
      // يمكن استخدام حزمة connectivity أو connectivity_plus للتحقق من الاتصال
      // هنا نفترض وجود اتصال
      return true;
    } catch (e) {
      return false;
    }
  }
}
