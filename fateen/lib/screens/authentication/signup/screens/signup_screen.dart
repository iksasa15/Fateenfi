import 'package:flutter/material.dart';
import '../controllers/signup_controller.dart';
import '../components/signup_header_component.dart';
import '../components/signup_form_component.dart';
import '../components/signup_major_field.dart';
import '../components/signup_university_field.dart';
import '../components/social_signup_component.dart';
import '../components/terms_agreement_component.dart';
import '../components/signup_button_component.dart';
import '../components/error_message_component.dart';
import '../components/signup_skeletonizer_component.dart';
import '../components/major_picker_component.dart';
import '../components/university_picker_component.dart';
import '../../shared/components/auth_toggle_bar.dart';
import '../constants/signup_strings.dart';
import '../constants/signup_colors.dart';
// استيراد مباشر لشاشة التحقق
import '../../verification/screens/verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // وحدة التحكم بمنطق التسجيل
  late SignupController _controller;

  // مفتاح النموذج للتحقق من المدخلات
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = SignupController();
    _controller.init(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // عرض منتقي التخصص
  void _showMajorPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MajorPickerComponent(
        majorsList: _controller.getMajorsList,
        selectedMajor: _controller.selectedMajor,
        onMajorSelected: (major) {
          // التحديث الفوري للاختيار
          _controller.selectMajor(major);
        },
        onCancel: () {
          Navigator.pop(context);
        },
        onDone: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  // عرض منتقي الجامعة
  void _showUniversityPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UniversityPickerComponent(
        universitiesList: _controller.getUniversitiesList,
        selectedUniversity: _controller.selectedUniversity,
        onUniversitySelected: (university) {
          // التحديث الفوري للاختيار
          _controller.selectUniversity(university);
        },
        onCancel: () {
          Navigator.pop(context);
        },
        onDone: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  // معالجة النقر على زر التسجيل - مع إجبار الانتقال لصفحة التحقق
  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate() &&
        _controller.validateMajor() &&
        _controller.validateUniversity()) {
      // عرض مؤشر تقدم مؤقت
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري تسجيل الحساب...'),
          duration: Duration(seconds: 1),
        ),
      );

      print("[signup_screen] بدء عملية التسجيل");
      final success = await _controller.signup(_formKey);
      print("[signup_screen] نتيجة التسجيل: $success");

      // عرض رسالة توضيحية
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'تم التسجيل بنجاح، جاري الانتقال لصفحة التحقق...'
                : 'حدث خطأ في التسجيل، سيتم الانتقال لصفحة التحقق رغم ذلك',
            style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          backgroundColor: success ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );

      // تأخير بسيط
      await Future.delayed(const Duration(milliseconds: 1000));

      // الانتقال إلى صفحة التحقق بغض النظر عن النتيجة
      if (mounted) {
        print("[signup_screen] الانتقال لصفحة التحقق");
        _navigateToVerification();
      }
    } else {
      print("[signup_screen] لم تتم المصادقة على النموذج");
    }
  }

  // دالة الانتقال إلى صفحة التحقق - طريقة مباشرة
  void _navigateToVerification() {
    print("[signup_screen] تنفيذ عملية الانتقال إلى صفحة التحقق");

    // استخدام طريقة مباشرة للتنقل بدلاً من المسارات
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => VerificationScreen(
          email: _controller.emailController.text,
          password: _controller.passwordController.text,
        ),
      ),
    );
  }

  // عرض شروط الاستخدام
  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'الشروط والأحكام',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'هذه الشروط والأحكام الخاصة باستخدام التطبيق. يرجى قراءتها بعناية قبل التسجيل.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'موافق',
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // الانتقال إلى شاشة تسجيل الدخول
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SignupColors.backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // رأس الصفحة
                      const SignupHeaderComponent(),

                      // زر التبديل بين التسجيل وإنشاء الحساب - تم وضعه تحت رأس الصفحة
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: AuthToggleBar(
                          currentMode: AuthToggleMode.signup,
                          onLoginPressed: _navigateToLogin,
                          onSignupPressed: () {/* بالفعل في صفحة التسجيل */},
                        ),
                      ),

                      // رسالة خطأ من السيرفر (إذا وجدت)
                      if (_controller.serverError != null)
                        ErrorMessageComponent(
                          errorMessage: _controller.serverError!,
                        ),

                      // حقول النموذج الأساسية (الاسم، البريد الإلكتروني، كلمة المرور)
                      SignupSkeletonizerComponent(
                        isLoading: _controller.isLoading &&
                            _controller.signupProgress == 0,
                        child: SignupFormComponent(
                          controller: _controller,
                        ),
                      ),

                      // حقل الجامعة
                      SignupSkeletonizerComponent(
                        isLoading: _controller.isLoading &&
                            _controller.signupProgress == 0,
                        child: SignupUniversityField(
                          controller: _controller.universityNameController,
                          focusNode: _controller.universityFocusNode,
                          isOtherUniversity: _controller.isOtherUniversity,
                          onTap: _showUniversityPicker,
                          errorText: !_controller.validateUniversity() &&
                                  _controller.isFormValid
                              ? SignupStrings.universityRequiredError
                              : null,
                        ),
                      ),

                      // حقل التخصص
                      SignupSkeletonizerComponent(
                        isLoading: _controller.isLoading &&
                            _controller.signupProgress == 0,
                        child: SignupMajorField(
                          controller: _controller.majorController,
                          focusNode: _controller.majorFocusNode,
                          isOtherMajor: _controller.isOtherMajor,
                          onTap: _showMajorPicker,
                          errorText: !_controller.validateMajor() &&
                                  _controller.isFormValid
                              ? SignupStrings.majorRequiredError
                              : null,
                        ),
                      ),

                      // زر التسجيل
                      SignupButtonComponent(
                        isLoading: _controller.isLoading,
                        onPressed: _handleSignup,
                      ),

                      // مكون التسجيل بوسائل التواصل الاجتماعي
                      const SocialSignupComponent(),

                      // الشروط والأحكام
                      TermsAgreementComponent(
                        onTap: _showTermsAndConditions,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
