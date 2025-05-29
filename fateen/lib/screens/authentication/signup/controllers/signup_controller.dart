import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/signup_strings.dart';
import '../services/signup_firebase_service.dart';
import '../../../../models/student.dart'; // استخدام فئة Student

class SignupController extends ChangeNotifier {
  // إضافة مثيل من SignupFirebaseService
  final SignupFirebaseService _firebaseService = SignupFirebaseService();

  // متحكمات النص للحقول
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController majorController = TextEditingController();

  // نقطة تركيز للتخصص
  final FocusNode majorFocusNode = FocusNode();

  // متغيرات الحالة
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _isFormValid = false;
  String? _selectedMajor;
  bool _isOtherMajor = false;
  String? _serverError;
  double _signupProgress = 0.0;

  // القائمة الخاصة بالتخصصات
  final List<String> _majorsList = SignupStrings.majors;

  // الحصول على الحالات
  bool get isLoading => _isLoading;
  bool get passwordVisible => _passwordVisible;
  bool get isFormValid => _isFormValid;
  bool get isOtherMajor => _isOtherMajor;
  String? get selectedMajor => _selectedMajor;
  String? get serverError => _serverError;
  double get signupProgress => _signupProgress;
  List<String> get getMajorsList => _majorsList;

  // تهيئة وحدة التحكم
  void init(BuildContext context) {
    // أي تهيئة إضافية يمكن أن تتم هنا
  }

  // تعيين حالة التحميل
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // تبديل حالة عرض كلمة المرور
  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  // تعيين خطأ السيرفر
  void setServerError(String? error) {
    _serverError = error;
    notifyListeners();
  }

  // تحديد التخصص
  void selectMajor(String? major) {
    _selectedMajor = major;
    if (major == 'أخرى') {
      _isOtherMajor = true;
      majorController.text = '';
    } else {
      _isOtherMajor = false;
      if (major != null) {
        majorController.text = major;
      }
    }
    notifyListeners();
  }

  // التحقق من الاسم - مع منع الأرقام
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الاسم الكامل';
    }

    if (!Student.isValidName(value)) {
      return 'الاسم لا يجب أن يحتوي على أرقام';
    }

    return null;
  }

  // التحقق من البريد الإلكتروني
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }

    if (!Student.isValidEmail(value)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  // التحقق من كلمة المرور - استخدام منطق التحقق من Student
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }

    if (!Student.isValidPassword(value)) {
      return 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل، وحرف كبير، وحرف صغير، ورقم، ورمز خاص';
    }

    return null;
  }

  // التحقق من التخصص
  bool validateMajor() {
    if (_isOtherMajor) {
      return majorController.text.trim().length >= 2 &&
          Student.isValidMajor(majorController.text.trim());
    } else {
      return _selectedMajor != null && _selectedMajor!.isNotEmpty;
    }
  }

  // التحقق من صحة النموذج بالكامل
  bool validateForm() {
    final isNameValid = validateName(nameController.text) == null;
    final isEmailValid = validateEmail(emailController.text) == null;
    final isPasswordValid = validatePassword(passwordController.text) == null;
    final isMajorValid = validateMajor();

    _isFormValid =
        isNameValid && isEmailValid && isPasswordValid && isMajorValid;
    return _isFormValid;
  }

  // تغيير نسبة تقدم التسجيل
  void _updateProgress(double value) {
    _signupProgress = value;
    notifyListeners();
  }

  // مسح بيانات المستخدم السابق
  Future<void> _clearPreviousUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // مسح بيانات المستخدم المحلية
      await prefs.remove('user_name');
      await prefs.remove('user_major');
      await prefs.remove('user_name_key');
      await prefs.remove('user_major_key');
      await prefs.remove('logged_user_id');
      await prefs.remove('prefUserNameKey');
      await prefs.remove('prefUserMajorKey');
      await prefs.remove('prefUserIdKey');
      debugPrint('تم مسح بيانات المستخدم السابق محلياً');
    } catch (e) {
      debugPrint('خطأ في مسح بيانات المستخدم السابق: $e');
    }
  }

  // دالة التسجيل المعدلة مع رسائل تصحيح
  Future<bool> signup(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate() || !validateMajor()) {
      print("[signup_controller] فشل التحقق من صحة النموذج");
      return false;
    }

    try {
      // مسح بيانات المستخدم السابق
      await _clearPreviousUserData();

      // بدء التحميل
      setLoading(true);
      setServerError(null);

      // تحديث التقدم
      _updateProgress(0.0);
      await Future.delayed(const Duration(milliseconds: 200));
      _updateProgress(0.3);

      print("[signup_controller] جاري تسجيل المستخدم...");

      // استخدام خدمة Firebase للتسجيل
      final result = await _firebaseService.registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        major: majorController.text.trim(),
      );

      print("[signup_controller] نتيجة التسجيل: ${result.success}");
      if (result.errorMessage != null) {
        print("[signup_controller] رسالة الخطأ: ${result.errorMessage}");
      }

      _updateProgress(0.7);
      await Future.delayed(const Duration(milliseconds: 200));
      _updateProgress(1.0);

      // إذا نجحت عملية التسجيل، احفظ البيانات محليًا
      if (result.success) {
        await _saveUserData();
      }

      // إنهاء التحميل
      setLoading(false);

      // إذا كان هناك خطأ، نعينه في متغير serverError
      if (!result.success && result.errorMessage != null) {
        setServerError(result.errorMessage);
      }

      return result.success;
    } catch (e) {
      // إنهاء التحميل والإبلاغ عن الخطأ
      setLoading(false);
      final errorMsg = 'حدث خطأ أثناء التسجيل: ${e.toString()}';
      setServerError(errorMsg);

      print("[signup_controller] استثناء في التسجيل: ${e.toString()}");

      return false;
    }
  }

  // حفظ بيانات المستخدم بعد التسجيل
  Future<void> _saveUserData() async {
    try {
      // الحصول على معرف المستخدم الحالي
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint("[signup_controller] لا يوجد مستخدم حالي لحفظ بياناته");
        return;
      }

      final userId = currentUser.uid;
      final name = nameController.text.trim();
      final major = majorController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // حفظ البيانات في Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': name,
        'major': major,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'uid': userId,
      }, SetOptions(merge: true));

      // حفظ البيانات محليًا للوصول السريع
      final prefs = await SharedPreferences.getInstance();

      // مسح أي بيانات سابقة
      await prefs.remove('user_name');
      await prefs.remove('user_major');
      await prefs.remove('user_id');
      await prefs.remove('prefUserNameKey');
      await prefs.remove('prefUserMajorKey');
      await prefs.remove('prefUserIdKey');

      // حفظ البيانات الجديدة
      await prefs.setString('user_name', name);
      await prefs.setString('user_major', major);
      await prefs.setString('user_id', userId);
      await prefs.setString('prefUserNameKey', name);
      await prefs.setString('prefUserMajorKey', major);
      await prefs.setString('prefUserIdKey', userId);

      // حفظ بيانات تسجيل الدخول للاستخدام التلقائي
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);

      print("[signup_controller] تم حفظ بيانات المستخدم محلياً وفي Firestore");
    } catch (e) {
      print("[signup_controller] خطأ في حفظ بيانات المستخدم: $e");
    }
  }

  // تنظيف الموارد
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    majorController.dispose();
    majorFocusNode.dispose();
    super.dispose();
  }
}
