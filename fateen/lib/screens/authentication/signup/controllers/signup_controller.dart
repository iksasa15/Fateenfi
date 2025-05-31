import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/signup_strings.dart';
import '../services/signup_firebase_service.dart';
import '../../../../models/student.dart'; // استخدام فئة Student

// تعريف خطوات التسجيل
enum SignupStep { name, username, email, password, university, major, terms }

class SignupController extends ChangeNotifier {
  // إضافة مثيل من SignupFirebaseService
  final SignupFirebaseService _firebaseService = SignupFirebaseService();

  // متحكمات النص للحقول
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController universityNameController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController majorController = TextEditingController();

  // نقاط التركيز
  final FocusNode majorFocusNode = FocusNode();
  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode universityFocusNode = FocusNode();

  // متغيرات الحالة
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _isFormValid = false;
  String? _selectedMajor;
  bool _isOtherMajor = false;
  String? _selectedUniversity;
  bool _isOtherUniversity = false;
  String? _serverError;
  double _signupProgress = 0.0;
  bool _isCheckingUsername = false;

  // متغيرات التحقق من البريد الإلكتروني
  bool _isCheckingEmail = false;
  String? _emailError;

  // متغيرات إدارة الخطوات
  SignupStep _currentStep = SignupStep.name;
  bool _canMoveToNextStep = false;

  // القوائم
  final List<String> _majorsList = SignupStrings.majors;
  final List<String> _universitiesList = SignupStrings.universities;

  // الحصول على الحالات
  bool get isLoading => _isLoading;
  bool get passwordVisible => _passwordVisible;
  bool get isFormValid => _isFormValid;
  bool get isOtherMajor => _isOtherMajor;
  bool get isOtherUniversity => _isOtherUniversity;
  String? get selectedMajor => _selectedMajor;
  String? get selectedUniversity => _selectedUniversity;
  String? get serverError => _serverError;
  double get signupProgress => _signupProgress;
  List<String> get getMajorsList => _majorsList;
  List<String> get getUniversitiesList => _universitiesList;
  bool get isCheckingUsername => _isCheckingUsername;
  bool get isCheckingEmail => _isCheckingEmail;
  String? get emailError => _emailError;

  // الحصول على حالات الخطوات
  SignupStep get currentStep => _currentStep;
  bool get canMoveToNextStep => _canMoveToNextStep;

  // تهيئة وحدة التحكم
  void init(BuildContext context) {
    // إضافة المستمعين لتحديث حالة الانتقال بين الخطوات
    nameController.addListener(_validateStepChanges);
    usernameController.addListener(_validateStepChanges);
    emailController.addListener(_validateStepChanges);
    passwordController.addListener(_validateStepChanges);
    universityNameController.addListener(_validateStepChanges);
    majorController.addListener(_validateStepChanges);
  }

  // تعيين حالة التحميل
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // تعيين حالة التحقق من اسم المستخدم
  void setCheckingUsername(bool checking) {
    _isCheckingUsername = checking;
    notifyListeners();
  }

  // تعيين حالة التحقق من البريد الإلكتروني
  void setCheckingEmail(bool checking) {
    _isCheckingEmail = checking;
    notifyListeners();
  }

  // تعيين خطأ البريد الإلكتروني
  void setEmailError(String? error) {
    _emailError = error;
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

  // تحديد التخصص - تحديث فوري عند الاختيار
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
    _validateStepChanges();
    notifyListeners();
  }

  // تحديد الجامعة - تحديث فوري عند الاختيار
  void selectUniversity(String? university) {
    _selectedUniversity = university;
    if (university == 'أخرى') {
      _isOtherUniversity = true;
      universityNameController.text = '';
    } else {
      _isOtherUniversity = false;
      if (university != null) {
        universityNameController.text = university;
      }
    }
    _validateStepChanges();
    notifyListeners();
  }

  // التحقق من الاسم - استخدام كلاس الطالب
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الاسم الكامل';
    }

    if (!Student.isValidName(value)) {
      return 'الاسم يجب أن يتكون من حروف فقط ويكون على الأقل 3 أحرف';
    }

    return null;
  }

  // التحقق من اسم المستخدم - استخدام الشروط المحسنة من كلاس الطالب
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال اسم المستخدم';
    }

    return Student.validateUsername(value);
  }

  // التحقق من البريد الإلكتروني
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }

    return Student.validateEmail(value);
  }

  // التحقق من كلمة المرور
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }

    return Student.validatePassword(value);
  }

  // التحقق من صحة الجامعة
  bool validateUniversity() {
    if (_isOtherUniversity) {
      return universityNameController.text.trim().length >= 2 &&
          Student.isValidUniversityName(universityNameController.text.trim());
    } else {
      return _selectedUniversity != null && _selectedUniversity!.isNotEmpty;
    }
  }

  // التحقق من صحة التخصص
  bool validateMajor() {
    if (_isOtherMajor) {
      return majorController.text.trim().length >= 2 &&
          Student.isValidMajor(majorController.text.trim());
    } else {
      return _selectedMajor != null && _selectedMajor!.isNotEmpty;
    }
  }

  // التحقق المباشر من وجود البريد الإلكتروني باستخدام كلاس الطالب
  Future<bool> validateEmailExists() async {
    try {
      // البريد فارغ أو غير صالح
      if (emailController.text.isEmpty ||
          validateEmail(emailController.text) != null) {
        setEmailError(null); // إزالة أي خطأ سابق
        return false;
      }

      setCheckingEmail(true);

      // تأخير بسيط لإظهار المؤشر
      await Future.delayed(const Duration(milliseconds: 300));

      // استخدام دالة التحقق من كلاس الطالب
      final bool emailExists =
          await Student.isEmailAlreadyRegistered(emailController.text.trim());

      setCheckingEmail(false);

      // إذا كان البريد موجودًا، نعرض خطأ
      if (emailExists) {
        setEmailError(
            "البريد الإلكتروني مستخدم بالفعل، هل تريد تسجيل الدخول بدلاً من ذلك؟");
        // تحديث حالة التحقق
        _canMoveToNextStep = false;
        notifyListeners();
      } else {
        setEmailError(null);
      }

      return !emailExists; // نعيد true إذا كان البريد غير موجود (صالح للتسجيل)
    } catch (e) {
      setCheckingEmail(false);
      debugPrint("خطأ في التحقق من البريد الإلكتروني: $e");
      setEmailError("حدث خطأ أثناء التحقق من البريد الإلكتروني");
      return false; // نفترض أنه موجود في حالة حدوث خطأ للأمان
    }
  }

  // التحقق من صحة النموذج بالكامل
  bool validateForm() {
    final isNameValid = validateName(nameController.text) == null;
    final isUsernameValid = validateUsername(usernameController.text) == null;
    final isUniversityValid = validateUniversity();
    final isEmailValid = validateEmail(emailController.text) == null;
    final isPasswordValid = validatePassword(passwordController.text) == null;
    final isMajorValid = validateMajor();

    _isFormValid = isNameValid &&
        isUsernameValid &&
        isUniversityValid &&
        isEmailValid &&
        isPasswordValid &&
        isMajorValid;
    return _isFormValid;
  }

  // دالة داخلية للتحقق من التغييرات وإمكانية الانتقال للخطوة التالية
  void _validateStepChanges() {
    validateCurrentStep();
    notifyListeners();
  }

  // التحقق من صحة الخطوة الحالية
  bool validateCurrentStep() {
    bool isValid = false;

    switch (_currentStep) {
      case SignupStep.name:
        isValid = validateName(nameController.text) == null;
        break;
      case SignupStep.username:
        isValid = validateUsername(usernameController.text) == null;
        break;
      case SignupStep.email:
        isValid =
            validateEmail(emailController.text) == null && _emailError == null;
        break;
      case SignupStep.password:
        isValid = validatePassword(passwordController.text) == null;
        break;
      case SignupStep.university:
        isValid = validateUniversity();
        break;
      case SignupStep.major:
        isValid = validateMajor();
        break;
      case SignupStep.terms:
        isValid = true; // دائمًا صالح في الخطوة النهائية
        break;
    }

    // تحديث حالة إمكانية الانتقال للخطوة التالية
    if (_canMoveToNextStep != isValid) {
      _canMoveToNextStep = isValid;
      notifyListeners();
    }

    return isValid;
  }

  // الانتقال إلى الخطوة التالية
  void moveToNextStep() {
    if (!validateCurrentStep()) return;

    switch (_currentStep) {
      case SignupStep.name:
        _currentStep = SignupStep.username;
        break;
      case SignupStep.username:
        _currentStep = SignupStep.email;
        break;
      case SignupStep.email:
        _currentStep = SignupStep.password;
        break;
      case SignupStep.password:
        _currentStep = SignupStep.university;
        break;
      case SignupStep.university:
        _currentStep = SignupStep.major;
        break;
      case SignupStep.major:
        _currentStep = SignupStep.terms;
        break;
      case SignupStep.terms:
        // آخر خطوة، يجب معالجة التسجيل
        break;
    }

    notifyListeners();
  }

  // الرجوع إلى الخطوة السابقة
  void moveToPreviousStep() {
    switch (_currentStep) {
      case SignupStep.name:
        // بالفعل في الخطوة الأولى
        break;
      case SignupStep.username:
        _currentStep = SignupStep.name;
        break;
      case SignupStep.email:
        _currentStep = SignupStep.username;
        break;
      case SignupStep.password:
        _currentStep = SignupStep.email;
        break;
      case SignupStep.university:
        _currentStep = SignupStep.password;
        break;
      case SignupStep.major:
        _currentStep = SignupStep.university;
        break;
      case SignupStep.terms:
        _currentStep = SignupStep.major;
        break;
    }

    notifyListeners();
  }

  // الحصول على عنوان للخطوة الحالية
  String getCurrentStepTitle() {
    switch (_currentStep) {
      case SignupStep.name:
        return 'أدخل اسمك الكامل';
      case SignupStep.username:
        return 'اختر اسم المستخدم';
      case SignupStep.email:
        return 'أدخل بريدك الإلكتروني';
      case SignupStep.password:
        return 'أنشئ كلمة المرور';
      case SignupStep.university:
        return 'حدد جامعتك';
      case SignupStep.major:
        return 'حدد تخصصك';
      case SignupStep.terms:
        return 'إكمال التسجيل';
    }
  }

  // الحصول على النسبة المئوية للتقدم
  double getProgressPercentage() {
    switch (_currentStep) {
      case SignupStep.name:
        return 0.14;
      case SignupStep.username:
        return 0.28;
      case SignupStep.email:
        return 0.42;
      case SignupStep.password:
        return 0.56;
      case SignupStep.university:
        return 0.70;
      case SignupStep.major:
        return 0.84;
      case SignupStep.terms:
        return 1.0;
    }
  }

  // التحقق من فرادة اسم المستخدم باستخدام كلاس الطالب
  Future<bool> checkUsernameUnique() async {
    try {
      setCheckingUsername(true);
      // استخدام دالة التحقق من كلاس الطالب
      final isUnique =
          await Student.isUsernameUnique(usernameController.text.trim());
      setCheckingUsername(false);

      if (!isUnique) {
        setServerError("اسم المستخدم مستخدم بالفعل، الرجاء اختيار اسم آخر");
      } else {
        setServerError(null);
      }

      return isUnique;
    } catch (e) {
      setCheckingUsername(false);
      setServerError("حدث خطأ أثناء التحقق من اسم المستخدم");
      return false;
    }
  }

  // حساب قوة كلمة المرور باستخدام كلاس الطالب
  double calculatePasswordStrength(String password) {
    return Student.calculatePasswordStrength(password);
  }

  // الحصول على نص قوة كلمة المرور باستخدام كلاس الطالب
  String getPasswordStrengthText(String password) {
    return Student.getPasswordStrengthText(password);
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
      await prefs.remove('user_username');
      await prefs.remove('user_university');
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
    if (!formKey.currentState!.validate() ||
        !validateMajor() ||
        !validateUniversity()) {
      print("[signup_controller] فشل التحقق من صحة النموذج");
      return false;
    }

    try {
      // التحقق من فرادة اسم المستخدم
      print("[signup_controller] التحقق من فرادة اسم المستخدم...");
      final isUsernameUnique = await checkUsernameUnique();
      if (!isUsernameUnique) {
        print("[signup_controller] اسم المستخدم مستخدم بالفعل");
        return false;
      }

      // التحقق من البريد الإلكتروني
      print("[signup_controller] التحقق من البريد الإلكتروني...");
      final isEmailValid = await validateEmailExists();
      if (!isEmailValid) {
        print("[signup_controller] البريد الإلكتروني مستخدم بالفعل");
        return false;
      }

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
        username: usernameController.text.trim(),
        universityName: universityNameController.text.trim(),
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
      final username = usernameController.text.trim();
      final universityName = universityNameController.text.trim();
      final major = majorController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // حفظ البيانات في Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': name,
        'username': username,
        'universityName': universityName,
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
      await prefs.remove('user_username');
      await prefs.remove('user_university');
      await prefs.remove('user_major');
      await prefs.remove('user_id');
      await prefs.remove('prefUserNameKey');
      await prefs.remove('prefUserMajorKey');
      await prefs.remove('prefUserIdKey');

      // حفظ البيانات الجديدة
      await prefs.setString('user_name', name);
      await prefs.setString('user_username', username);
      await prefs.setString('user_university', universityName);
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
    usernameController.dispose();
    universityNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    majorController.dispose();
    majorFocusNode.dispose();
    usernameFocusNode.dispose();
    universityFocusNode.dispose();

    // إزالة المستمعين
    nameController.removeListener(_validateStepChanges);
    usernameController.removeListener(_validateStepChanges);
    emailController.removeListener(_validateStepChanges);
    passwordController.removeListener(_validateStepChanges);
    universityNameController.removeListener(_validateStepChanges);
    majorController.removeListener(_validateStepChanges);

    super.dispose();
  }
}
