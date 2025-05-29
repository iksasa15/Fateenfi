import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/headerConstants.dart';
import '../services/firebaseServices/headrFirebase.dart';

/// وحدة تحكم مكون الهيدر
class HeaderController {
  String userName = HeaderConstants.defaultUserName;
  String userMajor = HeaderConstants.defaultUserMajor;
  bool isLoading = false;

  /// تهيئة البيانات
  Future<void> initialize() async {
    try {
      isLoading = true;

      // جلب بيانات المستخدم من Firebase
      await loadUserData();

      isLoading = false;
    } catch (e) {
      debugPrint('HeaderController: خطأ في تهيئة البيانات: $e');
      isLoading = false;
    }
  }

  /// تحميل بيانات المستخدم من Firebase
  Future<void> loadUserData() async {
    try {
      // جلب بيانات المستخدم من Firebase مباشرة
      final userData = await HeaderFirebase.getUserData();

      // تحديث البيانات المحلية
      userName = userData['name'] ?? HeaderConstants.defaultUserName;
      userMajor = userData['major'] ?? HeaderConstants.defaultUserMajor;

      debugPrint(
          'HeaderController: تم تحميل بيانات المستخدم من Firebase - اسم: $userName، تخصص: $userMajor');
    } catch (e) {
      debugPrint(
          'HeaderController: خطأ في تحميل بيانات المستخدم من Firebase: $e');
      // عند حدوث خطأ، نستخدم القيم الافتراضية
      userName = HeaderConstants.defaultUserName;
      userMajor = HeaderConstants.defaultUserMajor;
    }
  }

  /// تحديث بيانات المستخدم في Firebase
  Future<bool> updateUserProfile({String? newName, String? newMajor}) async {
    try {
      // تحديث البيانات في Firebase مباشرة
      final result = await HeaderFirebase.updateUserData(
        name: newName,
        major: newMajor,
      );

      if (result) {
        // تحديث البيانات المحلية فقط بعد التأكد من نجاح العملية في Firebase
        if (newName != null && newName.isNotEmpty) {
          userName = newName;
        }

        if (newMajor != null && newMajor.isNotEmpty) {
          userMajor = newMajor;
        }

        debugPrint(
            'HeaderController: تم تحديث بيانات المستخدم في Firebase بنجاح');
      } else {
        debugPrint('HeaderController: فشل تحديث بيانات المستخدم في Firebase');
      }

      return result;
    } catch (e) {
      debugPrint(
          'HeaderController: خطأ في تحديث بيانات المستخدم في Firebase: $e');
      return false;
    }
  }

  /// إنشاء مستخدم جديد في Firebase
  Future<bool> createUserInFirebase() async {
    try {
      await HeaderFirebase.createUserDocumentIfNotExists();
      await loadUserData(); // إعادة تحميل البيانات بعد الإنشاء
      return true;
    } catch (e) {
      debugPrint('HeaderController: خطأ في إنشاء المستخدم في Firebase: $e');
      return false;
    }
  }

  /// التحقق من وجود المستخدم الحالي
  bool hasCurrentUser() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// الحصول على معرّف المستخدم الحالي
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// الحصول على التاريخ المنسق
  String getFormattedDate() {
    final now = DateTime.now();
    final currentDay = getArabicDayName(now.weekday);
    final currentDate =
        "${now.day} ${getArabicMonthName(now.month)} ${now.year}";
    return '$currentDay، $currentDate';
  }

  /// الحصول على اسم اليوم بالعربية
  String getArabicDayName(int weekday) {
    return HeaderConstants.arabicDays[weekday] ?? '';
  }

  /// الحصول على اسم الشهر بالعربية
  String getArabicMonthName(int month) {
    return HeaderConstants.arabicMonths[month] ?? '';
  }

  /// تحديث بيانات المستخدم من الذاكرة المحلية
  Future<void> refreshFromLocalStorage() async {
    try {
      final userData = await HeaderFirebase.getLocalUserData();

      // تحديث البيانات المحلية
      userName = userData['name'] ?? HeaderConstants.defaultUserName;
      userMajor = userData['major'] ?? HeaderConstants.defaultUserMajor;

      debugPrint('HeaderController: تم تحديث البيانات من الذاكرة المحلية');
    } catch (e) {
      debugPrint(
          'HeaderController: خطأ في تحديث البيانات من الذاكرة المحلية: $e');
    }
  }

  /// مزامنة البيانات المحلية مع Firebase
  Future<void> syncWithFirebase() async {
    try {
      isLoading = true;

      // التحقق من الاتصال بالإنترنت
      final hasInternet = await HeaderFirebase.checkInternetConnection();
      if (!hasInternet) {
        // إذا لم يكن هناك اتصال بالإنترنت، قم بتحميل البيانات من التخزين المحلي
        await refreshFromLocalStorage();
        isLoading = false;
        debugPrint(
            'HeaderController: لا يوجد اتصال بالإنترنت، تم تحميل البيانات المحلية');
        return;
      }

      // إنشاء وثيقة المستخدم إذا لم تكن موجودة
      await HeaderFirebase.createUserDocumentIfNotExists();

      // تحديث البيانات من Firebase
      await loadUserData();

      isLoading = false;

      debugPrint('HeaderController: تمت المزامنة مع Firebase بنجاح');
    } catch (e) {
      debugPrint('HeaderController: خطأ في مزامنة البيانات مع Firebase: $e');

      // في حالة الخطأ، حاول تحميل البيانات من التخزين المحلي
      await refreshFromLocalStorage();
      isLoading = false;
    }
  }

  /// محاولة تسجيل الدخول التلقائي
  Future<User?> tryAutoLogin() async {
    try {
      final user = await HeaderFirebase.tryAutoLogin();

      if (user != null) {
        // إذا نجح تسجيل الدخول، قم بتحميل بيانات المستخدم
        await loadUserData();
      } else {
        // إذا لم ينجح تسجيل الدخول، حاول تحميل البيانات المحلية فقط
        await refreshFromLocalStorage();
      }

      return user;
    } catch (e) {
      debugPrint('HeaderController: خطأ في محاولة تسجيل الدخول التلقائي: $e');

      // في حالة الخطأ، حاول تحميل البيانات المحلية
      await refreshFromLocalStorage();
      return null;
    }
  }

  /// تسجيل الدخول يدوياً والاحتفاظ بالبيانات
  Future<User?> signInManually(
      String email, String password, bool rememberMe) async {
    try {
      // محاولة تسجيل الدخول باستخدام Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // إذا كان المستخدم يريد تذكر بيانات تسجيل الدخول
      if (rememberMe) {
        await HeaderFirebase.saveLoginCredentials(email, password);
      }

      // تحميل بيانات المستخدم بعد تسجيل الدخول
      await loadUserData();

      return userCredential.user;
    } catch (e) {
      debugPrint('HeaderController: خطأ في تسجيل الدخول: $e');
      return null;
    }
  }

  /// تسجيل الخروج
  Future<bool> signOut() async {
    try {
      final result = await HeaderFirebase.signOut();

      if (result) {
        // إعادة تعيين البيانات المحلية
        userName = HeaderConstants.defaultUserName;
        userMajor = HeaderConstants.defaultUserMajor;
        debugPrint('HeaderController: تم تسجيل الخروج بنجاح');
      }

      return result;
    } catch (e) {
      debugPrint('HeaderController: خطأ في تسجيل الخروج: $e');
      return false;
    }
  }

  /// التحقق من حالة تسجيل الدخول والتحديث وفقًا لذلك
  Future<void> checkAuthState() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // المستخدم مسجل الدخول، تحميل بياناته
        await loadUserData();
      } else {
        // المستخدم غير مسجل الدخول، محاولة تسجيل الدخول التلقائي
        final user = await tryAutoLogin();

        if (user == null) {
          // إذا فشلت محاولة تسجيل الدخول التلقائي، استخدم البيانات المحلية فقط
          await refreshFromLocalStorage();
        }
      }
    } catch (e) {
      debugPrint('HeaderController: خطأ في التحقق من حالة تسجيل الدخول: $e');
      // في حالة الخطأ، استخدم البيانات المحلية
      await refreshFromLocalStorage();
    }
  }

  /// إظهار رسالة تحية مناسبة للوقت (صباح/مساء)
  String getTimeBasedGreeting() {
    final hourNow = DateTime.now().hour;
    if (hourNow >= 5 && hourNow < 12) {
      return 'صباح الخير';
    } else if (hourNow >= 12 && hourNow < 17) {
      return 'مساء الخير';
    } else if (hourNow >= 17 && hourNow < 22) {
      return 'مساء الخير';
    } else {
      return 'تصبح على خير';
    }
  }

  /// الحصول على تحية كاملة مع اسم المستخدم
  String getFullGreeting() {
    final greeting = getTimeBasedGreeting();

    if (userName == HeaderConstants.defaultUserName || userName.isEmpty) {
      return greeting;
    } else {
      return '$greeting $userName';
    }
  }
}
