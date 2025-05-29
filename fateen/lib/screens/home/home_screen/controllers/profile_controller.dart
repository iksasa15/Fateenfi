import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/profileConstants.dart';
import '../services/firebaseServices/profileFirebase.dart';

/// وحدة تحكم الملف الشخصي
class ProfileController extends ChangeNotifier {
  String userName = ProfileConstants.defaultUserName;
  String userMajor = ProfileConstants.defaultUserMajor;
  String userEmail = '';
  String userId = '';
  bool isLoading = false;
  bool isSaving = false;
  bool hasError = false;
  String? errorMessage;

  // مفتاح النموذج للتحقق
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // أدوات التحكم في النماذج
  final TextEditingController nameController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // البناء
  ProfileController({String? uid}) {
    if (uid != null) {
      userId = uid;
    }
  }

  // التخلص
  @override
  void dispose() {
    nameController.dispose();
    majorController.dispose();
    emailController.dispose();
    super.dispose();
  }

  /// تهيئة البيانات
  Future<void> initialize() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // الحصول على المستخدم الحالي
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userId = currentUser.uid;
        userEmail = currentUser.email ?? '';

        // جلب بيانات المستخدم من Firebase
        await loadUserProfile();
      } else {
        // لا يوجد مستخدم مسجل دخول
        await loadLocalUserData();
      }

      // تعيين قيم وحدات التحكم في النص
      nameController.text = userName;
      majorController.text = userMajor;
      emailController.text = userEmail;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('ProfileController: خطأ في تهيئة البيانات: $e');
      isLoading = false;
      hasError = true;
      errorMessage = 'حدث خطأ أثناء تحميل بيانات الملف الشخصي';
      notifyListeners();
    }
  }

  /// تحميل بيانات المستخدم
  Future<void> loadUserData() async {
    await initialize();
  }

  /// تحميل بيانات المستخدم من Firebase
  Future<void> loadUserProfile() async {
    try {
      final userData = await ProfileFirebase.getUserProfile(userId);

      // تحديث البيانات المحلية
      userName = userData['name'] ?? ProfileConstants.defaultUserName;
      userMajor = userData['major'] ?? ProfileConstants.defaultUserMajor;

      // تحقق إذا كان هناك بيانات محدثة لم تكن موجودة في Firebase Auth
      if (userData['email'] != null &&
          userData['email'].toString().isNotEmpty) {
        userEmail = userData['email'];
      }

      // حفظ البيانات محلياً للوصول السريع مستقبلاً
      await saveLocalUserData();

      debugPrint(
          'ProfileController: تم تحميل ملف المستخدم، اسم: $userName، تخصص: $userMajor');
    } catch (e) {
      debugPrint('ProfileController: خطأ في تحميل بيانات المستخدم: $e');
      // عند حدوث خطأ، نحاول تحميل البيانات المحلية
      await loadLocalUserData();
    }
  }

  /// تحميل البيانات من التخزين المحلي
  Future<void> loadLocalUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userName = prefs.getString(ProfileConstants.prefUserNameKey) ??
          ProfileConstants.defaultUserName;
      userMajor = prefs.getString(ProfileConstants.prefUserMajorKey) ??
          ProfileConstants.defaultUserMajor;

      // الحصول على الـ userId المحفوظ محلياً
      final savedUserId = prefs.getString(ProfileConstants.prefUserIdKey);
      if (savedUserId != null && savedUserId.isNotEmpty) {
        userId = savedUserId;
      }

      debugPrint('ProfileController: تم تحميل البيانات المحلية');
    } catch (e) {
      debugPrint('ProfileController: خطأ في تحميل البيانات المحلية: $e');
      // استخدام القيم الافتراضية
      userName = ProfileConstants.defaultUserName;
      userMajor = ProfileConstants.defaultUserMajor;
    }
  }

  /// حفظ البيانات محلياً
  Future<void> saveLocalUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ProfileConstants.prefUserNameKey, userName);
      await prefs.setString(ProfileConstants.prefUserMajorKey, userMajor);
      await prefs.setString(ProfileConstants.prefUserIdKey, userId);

      debugPrint('ProfileController: تم حفظ البيانات محلياً');
    } catch (e) {
      debugPrint('ProfileController: خطأ في حفظ البيانات محلياً: $e');
    }
  }

  /// تحديث الملف الشخصي
  Future<bool> updateProfile({
    String? newName,
    String? newMajor,
    String? newEmail,
  }) async {
    try {
      isSaving = true;
      errorMessage = null;
      notifyListeners();

      // تحديث البيانات في Firebase
      final result = await ProfileFirebase.updateUserProfile(
        userId: userId,
        name: newName,
        major: newMajor,
        email: newEmail,
      );

      if (result) {
        // تحديث البيانات المحلية
        if (newName != null && newName.isNotEmpty) {
          userName = newName;
        }
        if (newMajor != null && newMajor.isNotEmpty) {
          userMajor = newMajor;
        }
        if (newEmail != null && newEmail.isNotEmpty) {
          userEmail = newEmail;
        }

        // حفظ البيانات المحدثة محلياً
        await saveLocalUserData();

        debugPrint('ProfileController: تم تحديث الملف الشخصي بنجاح');
      } else {
        hasError = true;
        errorMessage = ProfileConstants.updateFailMessage;
        debugPrint('ProfileController: فشل تحديث الملف الشخصي');
      }

      isSaving = false;
      notifyListeners();
      return result;
    } catch (e) {
      isSaving = false;
      hasError = true;
      errorMessage = 'حدث خطأ أثناء تحديث الملف الشخصي: $e';
      debugPrint('ProfileController: خطأ في تحديث الملف الشخصي: $e');
      notifyListeners();
      return false;
    }
  }

  /// التحقق من صحة النموذج
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// حفظ التغييرات
  Future<String?> saveChanges() async {
    if (!validateForm()) {
      return ProfileConstants.formValidationError;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newName = nameController.text.trim();
      final newMajor = majorController.text.trim();
      final newEmail = emailController.text.trim();

      final success = await updateProfile(
        newName: newName,
        newMajor: newMajor,
        newEmail: newEmail,
      );

      isSaving = false;
      notifyListeners();

      if (success) {
        return null; // نجاح
      } else {
        return errorMessage ?? ProfileConstants.updateFailMessage;
      }
    } catch (e) {
      isSaving = false;
      errorMessage = 'حدث خطأ أثناء حفظ البيانات: $e';
      notifyListeners();
      return errorMessage;
    }
  }

  /// تغيير كلمة المرور
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await ProfileFirebase.changeUserPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      isLoading = false;
      notifyListeners();

      if (!result) {
        hasError = true;
        errorMessage = ProfileConstants.invalidCurrentPasswordMessage;
        notifyListeners();
      }

      return result;
    } catch (e) {
      isLoading = false;
      hasError = true;
      errorMessage = 'حدث خطأ أثناء تغيير كلمة المرور: $e';
      debugPrint('ProfileController: خطأ في تغيير كلمة المرور: $e');
      notifyListeners();
      return false;
    }
  }

  /// التحقق من صحة البيانات
  static bool isNameValid(String? name) {
    final nameValue = name?.trim() ?? '';
    return nameValue.isNotEmpty && nameValue.length >= 3;
  }

  static bool isMajorValid(String? major) {
    final majorValue = major?.trim() ?? '';
    return majorValue.isNotEmpty;
  }

  static bool isEmailValid(String? email) {
    final emailValue = email?.trim() ?? '';
    if (emailValue.isEmpty)
      return true; // يمكن أن يكون البريد الإلكتروني اختياريًا

    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    return emailRegex.hasMatch(emailValue);
  }

  /// الحصول على اسم مناسب للعرض
  String getDisplayName() {
    if (userName == ProfileConstants.defaultUserName || userName.isEmpty) {
      // استخدم البريد الإلكتروني كبديل إذا كان متاحاً
      if (userEmail.isNotEmpty) {
        final emailName = userEmail.split('@').first;
        return emailName;
      }
      return ProfileConstants.defaultUserName;
    }
    return userName;
  }

  /// الحصول على البريد الإلكتروني مخفياً جزئياً
  String getPartiallyHiddenEmail() {
    if (userEmail.isEmpty) return '';

    final parts = userEmail.split('@');
    if (parts.length != 2) return userEmail;

    String username = parts[0];
    String domain = parts[1];

    // إخفاء جزء من اسم المستخدم
    if (username.length > 3) {
      username = username.substring(0, 2) + '*' * (username.length - 2);
    }

    return '$username@$domain';
  }

  /// حذف حساب المستخدم
  Future<bool> deleteUserAccount(String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await ProfileFirebase.deleteUserAccount(password);

      isLoading = false;
      notifyListeners();

      if (!result) {
        hasError = true;
        errorMessage = 'فشل في حذف الحساب، تأكد من كلمة المرور';
        notifyListeners();
      }

      return result;
    } catch (e) {
      isLoading = false;
      hasError = true;
      errorMessage = 'حدث خطأ أثناء حذف الحساب: $e';
      debugPrint('ProfileController: خطأ في حذف الحساب: $e');
      notifyListeners();
      return false;
    }
  }
}
