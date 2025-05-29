import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// مدير جلسة المستخدم - للتحكم بحالة تسجيل الدخول وبيانات المستخدم
class SessionManager {
  // تصميم Singleton للوصول العالمي
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() => _instance;

  SessionManager._internal();

  // المراجع
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // متغيرات الحالة
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  User? _currentUser;
  Map<String, dynamic> _userData = {};

  // الحصول على المتغيرات
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  Map<String, dynamic> get userData => _userData;

  // ثوابت
  static const String usersCollection = 'users';
  static const String prefUserIdKey = 'user_id';
  static const String prefUserNameKey = 'user_name';
  static const String prefUserMajorKey = 'user_major';
  static const String prefUserEmailKey = 'user_email';
  static const String prefUserPasswordKey = 'user_password';
  static const String prefIsLoggedInKey = 'is_logged_in';

  /// تهيئة الجلسة - يجب استدعاؤها عند بدء التطبيق
  Future<bool> initialize() async {
    if (_isInitialized) return _isLoggedIn;

    try {
      debugPrint('SessionManager: بدء تهيئة الجلسة');

      // التحقق من المستخدم الحالي في Firebase Auth
      _currentUser = _auth.currentUser;

      if (_currentUser != null) {
        _isLoggedIn = true;
        debugPrint(
            'SessionManager: وجد مستخدم مسجل الدخول في Firebase Auth: ${_currentUser!.uid}');

        // جلب بيانات المستخدم وحفظها محلياً
        await _fetchAndCacheUserData(_currentUser!.uid);
      } else {
        // محاولة تسجيل الدخول التلقائي
        final autoLoginSuccess = await tryAutoLogin();
        _isLoggedIn = autoLoginSuccess;
      }

      _isInitialized = true;
      debugPrint(
          'SessionManager: تمت تهيئة الجلسة بنجاح، حالة تسجيل الدخول: $_isLoggedIn');
      return _isLoggedIn;
    } catch (e) {
      debugPrint('SessionManager: خطأ في تهيئة الجلسة: $e');
      _isInitialized = true;
      _isLoggedIn = false;
      return false;
    }
  }

  /// محاولة تسجيل الدخول التلقائي باستخدام البيانات المخزنة
  Future<bool> tryAutoLogin() async {
    try {
      debugPrint('SessionManager: محاولة تسجيل الدخول التلقائي');

      // التحقق من وجود بيانات التسجيل
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(prefUserEmailKey);
      final password = prefs.getString(prefUserPasswordKey);

      if (email == null ||
          email.isEmpty ||
          password == null ||
          password.isEmpty) {
        debugPrint('SessionManager: لا توجد بيانات تسجيل دخول مخزنة');
        return false;
      }

      // محاولة تسجيل الدخول
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        _currentUser = userCredential.user;
        _isLoggedIn = true;

        // جلب بيانات المستخدم وحفظها
        if (_currentUser != null) {
          await _fetchAndCacheUserData(_currentUser!.uid);
        }

        debugPrint('SessionManager: تسجيل الدخول التلقائي ناجح');
        return true;
      } on FirebaseAuthException catch (authError) {
        debugPrint(
            'SessionManager: خطأ في تسجيل الدخول التلقائي - FirebaseAuth: ${authError.message}');

        // حذف بيانات التسجيل الخاطئة
        await prefs.remove(prefUserEmailKey);
        await prefs.remove(prefUserPasswordKey);
        await prefs.setBool(prefIsLoggedInKey, false);

        return false;
      }
    } catch (e) {
      debugPrint('SessionManager: خطأ عام في محاولة تسجيل الدخول التلقائي: $e');
      return false;
    }
  }

  /// التحقق من حالة تسجيل الدخول
  Future<bool> checkLoginStatus() async {
    if (!_isInitialized) {
      return await initialize();
    }

    // التحقق من المستخدم الحالي
    final user = _auth.currentUser;
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      return true;
    }

    // في حالة عدم وجود مستخدم حالي، نحاول تسجيل الدخول تلقائياً
    final autoLoginSuccess = await tryAutoLogin();
    _isLoggedIn = autoLoginSuccess;

    return _isLoggedIn;
  }

  /// تسجيل الدخول يدوياً وحفظ البيانات
  Future<bool> login(String email, String password, bool rememberMe) async {
    try {
      // تسجيل الدخول باستخدام Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      _currentUser = userCredential.user;
      _isLoggedIn = true;

      // حفظ بيانات التسجيل إذا كان rememberMe صحيح
      if (rememberMe && _currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(prefUserEmailKey, email);
        await prefs.setString(prefUserPasswordKey, password);
        await prefs.setString(prefUserIdKey, _currentUser!.uid);
        await prefs.setBool(prefIsLoggedInKey, true);
      }

      // جلب بيانات المستخدم
      if (_currentUser != null) {
        await _fetchAndCacheUserData(_currentUser!.uid);
      }

      debugPrint(
          'SessionManager: تم تسجيل الدخول بنجاح - ${_currentUser?.uid}');
      return true;
    } on FirebaseAuthException catch (authError) {
      debugPrint(
          'SessionManager: خطأ في تسجيل الدخول - FirebaseAuth: ${authError.message}');
      return false;
    } catch (e) {
      debugPrint('SessionManager: خطأ عام في تسجيل الدخول: $e');
      return false;
    }
  }

  /// تسجيل الخروج
  Future<bool> logout() async {
    try {
      // حفظ البيانات غير الحساسة قبل تسجيل الخروج
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString(prefUserNameKey);
      final userMajor = prefs.getString(prefUserMajorKey);

      // حذف بيانات تسجيل الدخول
      await prefs.remove(prefUserEmailKey);
      await prefs.remove(prefUserPasswordKey);
      await prefs.setBool(prefIsLoggedInKey, false);

      // تسجيل الخروج من Firebase Auth
      await _auth.signOut();

      // إعادة ضبط الحالة
      _currentUser = null;
      _isLoggedIn = false;
      _userData = {};

      // استعادة البيانات غير الحساسة
      if (userName != null && userName.isNotEmpty) {
        await prefs.setString(prefUserNameKey, userName);
      }

      if (userMajor != null && userMajor.isNotEmpty) {
        await prefs.setString(prefUserMajorKey, userMajor);
      }

      debugPrint('SessionManager: تم تسجيل الخروج بنجاح');
      return true;
    } catch (e) {
      debugPrint('SessionManager: خطأ في تسجيل الخروج: $e');
      return false;
    }
  }

  /// استرجاع بيانات المستخدم
  Future<Map<String, dynamic>> getUserData() async {
    if (!_isLoggedIn || _currentUser == null) {
      return {};
    }

    if (_userData.isNotEmpty) {
      return _userData;
    }

    await _fetchAndCacheUserData(_currentUser!.uid);
    return _userData;
  }

  /// جلب بيانات المستخدم من Firestore وحفظها محلياً
  Future<void> _fetchAndCacheUserData(String userId) async {
    try {
      debugPrint('SessionManager: جلب بيانات المستخدم من Firestore - $userId');

      // قراءة البيانات المحلية أولاً
      final prefs = await SharedPreferences.getInstance();
      final cachedName = prefs.getString(prefUserNameKey) ?? '';
      final cachedMajor = prefs.getString(prefUserMajorKey) ?? '';

      // جلب البيانات من Firestore
      final userDoc =
          await _firestore.collection(usersCollection).doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        // استخراج الاسم والتخصص
        final name = data['name'] ?? cachedName;
        final major = data['major'] ?? cachedMajor;

        // حفظ البيانات في ذاكرة التطبيق
        _userData = {
          'name': name,
          'major': major,
          ...data,
        };

        // حفظ البيانات الأساسية محلياً
        await prefs.setString(prefUserNameKey, name.toString());
        await prefs.setString(prefUserMajorKey, major.toString());

        debugPrint(
            'SessionManager: تم جلب وحفظ بيانات المستخدم بنجاح - اسم: $name، تخصص: $major');
      } else {
        debugPrint('SessionManager: وثيقة المستخدم غير موجودة في Firestore');

        // استخدام البيانات المحلية
        _userData = {
          'name': cachedName.isNotEmpty ? cachedName : 'مستخدم',
          'major': cachedMajor.isNotEmpty ? cachedMajor : 'غير محدد',
        };

        // إنشاء وثيقة جديدة في Firestore
        await _createUserDocument(userId);
      }
    } catch (e) {
      debugPrint('SessionManager: خطأ في جلب بيانات المستخدم: $e');

      // استخدام القيم الافتراضية في حالة الخطأ
      _userData = {
        'name': 'مستخدم',
        'major': 'غير محدد',
      };
    }
  }

  /// إنشاء وثيقة جديدة للمستخدم
  Future<void> _createUserDocument(String userId) async {
    try {
      debugPrint(
          'SessionManager: إنشاء وثيقة مستخدم جديدة في Firestore - $userId');

      // جلب بيانات المستخدم من LocalStorage
      final prefs = await SharedPreferences.getInstance();
      final cachedName = prefs.getString(prefUserNameKey) ?? '';
      final cachedMajor = prefs.getString(prefUserMajorKey) ?? '';

      final userName = cachedName.isNotEmpty
          ? cachedName
          : (_currentUser?.displayName ?? 'مستخدم');
      final userMajor = cachedMajor.isNotEmpty ? cachedMajor : 'غير محدد';

      // إنشاء وثيقة جديدة
      await _firestore.collection(usersCollection).doc(userId).set({
        'name': userName,
        'major': userMajor,
        'email': _currentUser?.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'uid': userId,
      });

      // تحديث البيانات المحلية
      _userData = {
        'name': userName,
        'major': userMajor,
      };

      // حفظ البيانات في SharedPreferences
      await prefs.setString(prefUserNameKey, userName);
      await prefs.setString(prefUserMajorKey, userMajor);

      debugPrint('SessionManager: تم إنشاء وثيقة المستخدم بنجاح');
    } catch (e) {
      debugPrint('SessionManager: خطأ في إنشاء وثيقة المستخدم: $e');
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateUserProfile({String? name, String? major}) async {
    if (!_isLoggedIn || _currentUser == null) {
      debugPrint('SessionManager: لا يمكن تحديث البيانات قبل تسجيل الدخول');
      return false;
    }

    try {
      final updateData = <String, dynamic>{};

      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
      }

      if (major != null && major.isNotEmpty) {
        updateData['major'] = major;
      }

      if (updateData.isEmpty) {
        return false;
      }

      // إضافة وقت التحديث
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // تحديث في Firestore
      await _firestore
          .collection(usersCollection)
          .doc(_currentUser!.uid)
          .update(updateData);

      // تحديث البيانات المحلية
      if (name != null && name.isNotEmpty) {
        _userData['name'] = name;
      }

      if (major != null && major.isNotEmpty) {
        _userData['major'] = major;
      }

      // تحديث في SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      if (name != null && name.isNotEmpty) {
        await prefs.setString(prefUserNameKey, name);
      }

      if (major != null && major.isNotEmpty) {
        await prefs.setString(prefUserMajorKey, major);
      }

      debugPrint('SessionManager: تم تحديث بيانات المستخدم بنجاح');
      return true;
    } catch (e) {
      debugPrint('SessionManager: خطأ في تحديث بيانات المستخدم: $e');
      return false;
    }
  }

  /// الحصول على البيانات المخزنة محلياً
  Future<Map<String, dynamic>> getLocalUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(prefUserNameKey) ?? 'مستخدم';
      final major = prefs.getString(prefUserMajorKey) ?? 'غير محدد';

      return {
        'name': name,
        'major': major,
      };
    } catch (e) {
      debugPrint('SessionManager: خطأ في جلب البيانات المحلية: $e');
      return {
        'name': 'مستخدم',
        'major': 'غير محدد',
      };
    }
  }

  /// الحصول على معرف المستخدم الحالي إن وجد
  String? getUserId() {
    return _currentUser?.uid;
  }

  /// تحديث بيانات الجلسة بعد عمليات مثل تغيير الملف الشخصي
  Future<void> refreshSession() async {
    if (_currentUser != null) {
      await _fetchAndCacheUserData(_currentUser!.uid);
    }
  }
}
