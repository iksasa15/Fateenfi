import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/headerConstants.dart';

/// خدمة تعامل مع Firebase لمكون الهيدر
class HeaderFirebase {
  // المستخدم الحالي
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  /// جلب بيانات المستخدم من Firestore
  static Future<Map<String, String>> getUserData() async {
    try {
      // التحقق من وجود مستخدم
      final user = currentUser;
      if (user == null) {
        debugPrint('HeaderFirebase: لا يوجد مستخدم حالي');
        return {
          'name': HeaderConstants.defaultUserName,
          'major': HeaderConstants.defaultUserMajor,
        };
      }

      // محاولة قراءة البيانات المحفوظة محليًا أولًا
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString(HeaderConstants.prefUserNameKey);
      final savedMajor = prefs.getString(HeaderConstants.prefUserMajorKey);
      final savedUserId = prefs.getString(HeaderConstants.prefUserIdKey);

      // تحقق من أن البيانات المحفوظة تخص المستخدم الحالي
      bool useLocalData =
          savedUserId == user.uid && savedName != null && savedMajor != null;

      // نتيجة البحث المبدئية
      Map<String, String> result = {
        'name': useLocalData ? savedName! : HeaderConstants.defaultUserName,
        'major': useLocalData ? savedMajor! : HeaderConstants.defaultUserMajor,
      };

      // جلب البيانات من Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection(HeaderConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // تحديث الاسم إذا كان موجوداً في Firestore
        if (userData.containsKey(HeaderConstants.nameField) &&
            userData[HeaderConstants.nameField] != null &&
            userData[HeaderConstants.nameField].toString().isNotEmpty) {
          result['name'] = userData[HeaderConstants.nameField].toString();
          await prefs.setString(
              HeaderConstants.prefUserNameKey, result['name']!);
        }

        // تحديث التخصص إذا كان موجوداً في Firestore
        if (userData.containsKey(HeaderConstants.majorField) &&
            userData[HeaderConstants.majorField] != null &&
            userData[HeaderConstants.majorField].toString().isNotEmpty) {
          result['major'] = userData[HeaderConstants.majorField].toString();
          await prefs.setString(
              HeaderConstants.prefUserMajorKey, result['major']!);
        }

        // تحديث معرّف المستخدم المحفوظ
        await prefs.setString(HeaderConstants.prefUserIdKey, user.uid);
      } else {
        debugPrint('HeaderFirebase: لا توجد وثيقة للمستخدم في Firestore');
        // إنشاء وثيقة جديدة للمستخدم
        await createUserDocumentIfNotExists();
      }

      return result;
    } catch (e) {
      debugPrint('HeaderFirebase: خطأ في جلب بيانات المستخدم: $e');
      return {
        'name': HeaderConstants.defaultUserName,
        'major': HeaderConstants.defaultUserMajor,
      };
    }
  }

  /// تحديث بيانات المستخدم في Firestore
  static Future<bool> updateUserData({String? name, String? major}) async {
    try {
      final user = currentUser;
      if (user == null) {
        debugPrint('HeaderFirebase: لا يوجد مستخدم حالي');
        return false;
      }

      final Map<String, dynamic> updateData = {};

      if (name != null && name.isNotEmpty) {
        updateData[HeaderConstants.nameField] = name;
      }

      if (major != null && major.isNotEmpty) {
        updateData[HeaderConstants.majorField] = major;
      }

      if (updateData.isEmpty) {
        debugPrint('HeaderFirebase: لا توجد بيانات للتحديث');
        return false;
      }

      // إضافة تاريخ التحديث
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // تحديث البيانات في Firestore
      await FirebaseFirestore.instance
          .collection(HeaderConstants.usersCollection)
          .doc(user.uid)
          .update(updateData);

      // حفظ البيانات محلياً
      final prefs = await SharedPreferences.getInstance();

      if (name != null && name.isNotEmpty) {
        await prefs.setString(HeaderConstants.prefUserNameKey, name);
      }

      if (major != null && major.isNotEmpty) {
        await prefs.setString(HeaderConstants.prefUserMajorKey, major);
      }

      // تأكد من حفظ معرّف المستخدم
      await prefs.setString(HeaderConstants.prefUserIdKey, user.uid);

      debugPrint('HeaderFirebase: تم تحديث بيانات المستخدم بنجاح');
      return true;
    } catch (e) {
      debugPrint('HeaderFirebase: خطأ في تحديث بيانات المستخدم: $e');
      return false;
    }
  }

  /// إنشاء وثيقة المستخدم إذا لم تكن موجودة
  static Future<void> createUserDocumentIfNotExists() async {
    try {
      final user = currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection(HeaderConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('HeaderFirebase: إنشاء وثيقة مستخدم جديدة');

        await FirebaseFirestore.instance
            .collection(HeaderConstants.usersCollection)
            .doc(user.uid)
            .set({
          HeaderConstants.nameField:
              user.displayName ?? HeaderConstants.defaultUserName,
          HeaderConstants.majorField: HeaderConstants.defaultUserMajor,
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'uid': user.uid,
        });

        // حفظ البيانات محلياً
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(HeaderConstants.prefUserNameKey,
            user.displayName ?? HeaderConstants.defaultUserName);
        await prefs.setString(
            HeaderConstants.prefUserMajorKey, HeaderConstants.defaultUserMajor);
        await prefs.setString(HeaderConstants.prefUserIdKey, user.uid);
      }
    } catch (e) {
      debugPrint('HeaderFirebase: خطأ في إنشاء وثيقة المستخدم: $e');
    }
  }

  /// محاولة تسجيل الدخول التلقائي
  static Future<User?> tryAutoLogin() async {
    try {
      // التحقق مما إذا كان المستخدم مسجل الدخول بالفعل
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        debugPrint(
            'HeaderFirebase: المستخدم مسجل الدخول بالفعل: ${currentUser.email}');
        return currentUser;
      }

      // لا نحاول تسجيل الدخول مرة أخرى هنا، ندع AuthChecker يتولى ذلك
      debugPrint(
          'HeaderFirebase: لا يوجد مستخدم حالي، تفويض AuthChecker لعملية تسجيل الدخول');
      return null;
    } catch (e) {
      debugPrint('HeaderFirebase: خطأ في فحص حالة المستخدم: $e');
      return null;
    }
  }

  /// تسجيل الخروج
  static Future<bool> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // حذف بيانات تسجيل الدخول التلقائي
      await prefs.remove('user_email');
      await prefs.remove('user_password');

      // حذف بيانات المستخدم الشخصية
      await prefs.remove(HeaderConstants.prefUserNameKey);
      await prefs.remove(HeaderConstants.prefUserMajorKey);
      await prefs.remove(HeaderConstants.prefUserIdKey);

      // يمكن إضافة مسح أي بيانات أخرى محفوظة

      // تسجيل الخروج من Firebase
      await FirebaseAuth.instance.signOut();

      debugPrint('HeaderFirebase: تم تسجيل الخروج ومسح بيانات المستخدم بنجاح');
      return true;
    } catch (e) {
      debugPrint('HeaderFirebase: خطأ في تسجيل الخروج: $e');
      return false;
    }
  }

  /// حفظ بيانات تسجيل الدخول للدخول التلقائي
  static Future<bool> saveLoginCredentials(
      String email, String password) async {
    try {
      debugPrint('HeaderFirebase: حفظ بيانات تسجيل الدخول للبريد: $email');

      final prefs = await SharedPreferences.getInstance();

      // حفظ البيانات
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);

      // حفظ معرف المستخدم إذا كان متاحًا
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await prefs.setString(HeaderConstants.prefUserIdKey, user.uid);
      }

      debugPrint('HeaderFirebase: تم حفظ بيانات تسجيل الدخول بنجاح');
      return true;
    } catch (e) {
      debugPrint('HeaderFirebase: خطأ في حفظ بيانات تسجيل الدخول: $e');
      return false;
    }
  }

  /// جلب البيانات مباشرة من المخزن المحلي
  static Future<Map<String, String>> getLocalUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // التحقق من وجود معرّف المستخدم أولاً
      final savedUserId = prefs.getString(HeaderConstants.prefUserIdKey);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      // جلب البيانات فقط إذا كانت تخص المستخدم الحالي
      if (savedUserId != null &&
          currentUserId != null &&
          savedUserId == currentUserId) {
        final savedName = prefs.getString(HeaderConstants.prefUserNameKey);
        final savedMajor = prefs.getString(HeaderConstants.prefUserMajorKey);

        if (savedName != null && savedMajor != null) {
          return {
            'name': savedName,
            'major': savedMajor,
          };
        }
      }

      // إذا لم تكن البيانات متطابقة، استخدم القيم الافتراضية
      return {
        'name': HeaderConstants.defaultUserName,
        'major': HeaderConstants.defaultUserMajor,
      };
    } catch (e) {
      debugPrint('HeaderFirebase: خطأ في جلب البيانات المحلية: $e');
      return {
        'name': HeaderConstants.defaultUserName,
        'major': HeaderConstants.defaultUserMajor,
      };
    }
  }

  /// التحقق من حالة الاتصال بالإنترنت
  static Future<bool> checkInternetConnection() async {
    try {
      // يمكن استخدام حزمة مثل connectivity_plus لفحص الاتصال بالإنترنت
      // هذه الدالة تحتاج إلى تنفيذ الفحص الفعلي حسب الحزمة المستخدمة

      // مجرد مثال - يجب تنفيذ الفحص الفعلي
      return true;
    } catch (e) {
      debugPrint('HeaderFirebase: خطأ في التحقق من حالة الاتصال بالإنترنت: $e');
      return false;
    }
  }
}
