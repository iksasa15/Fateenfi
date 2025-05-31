import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/login_header_component.dart';
import '../components/login_form_component.dart';
import '../components/social_login_component.dart';
import '../components/forgot_password_link_component.dart';
import '../components/login_button_component.dart';
import '../components/error_message_component.dart';
import '../../shared/components/auth_toggle_bar.dart';
import '../controllers/login_controller.dart';
import '../../shared/constants/auth_colors.dart';
import '../../shared/helpers/custom_route_transitions.dart';
import '../../../authentication/signup/screens/signup_screen.dart';
import '../../../authentication/reset_password/screens/reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // وحدة التحكم بمنطق تسجيل الدخول
  late LoginController _controller;

  // مفتاح النموذج للتحقق من المدخلات
  final _formKey = GlobalKey<FormState>();

  // تحكم بالرسوم المتحركة للمكونات السفلية فقط
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // تهيئة وحدة التحكم
    _controller = LoginController();
    _controller.init(context);

    // إعداد الرسوم المتحركة للمكونات السفلية
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // تقليل المسافة للحصول على تأثير أكثر نعومة
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));

    _animationController.forward();

    // تحسين تجربة المستخدم: إضافة رد فعل حسي عند ظهور أخطاء
    _controller.addListener(() {
      if (_controller.errorMessage.isNotEmpty) {
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // الانتقال إلى شاشة إنشاء حساب
  void _navigateToSignup() {
    // تحسين تجربة المستخدم: إضافة تأثير حسي عند التنقل
    HapticFeedback.selectionClick();

    // إخفاء المكونات السفلية للأسفل قبل الانتقال
    _animationController.reverse().then((_) {
      Navigator.of(context).pushReplacement(
        NoTransitionRoute(
          page: const SignUpScreen(),
        ),
      );
    });
  }

  // الانتقال إلى شاشة استعادة كلمة المرور
  void _navigateToResetPassword() {
    HapticFeedback.selectionClick();

    // إخفاء المكونات السفلية للأسفل قبل الانتقال
    _animationController.reverse().then((_) {
      Navigator.of(context).pushReplacement(
        NoTransitionRoute(
          page: const ResetPasswordScreen(),
        ),
      );
    });
  }

  // معالجة تسجيل الدخول
  Future<void> _handleLogin() async {
    HapticFeedback.mediumImpact();

    if (_formKey.currentState!.validate()) {
      await _controller.login(_formKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AuthColors.backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // المكونات العلوية - ثابتة بدون رسوم متحركة
                  Container(
                    padding: EdgeInsets.only(bottom: size.height * 0.01),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // رأس الصفحة
                        const LoginHeaderComponent(),

                        // زر التبديل بين تسجيل الدخول وإنشاء الحساب
                        AuthToggleBar(
                          currentMode: AuthToggleMode.login,
                          onLoginPressed: () {
                            /* بالفعل في صفحة تسجيل الدخول */
                          },
                          onSignupPressed: _navigateToSignup,
                        ),
                      ],
                    ),
                  ),

                  // المكونات السفلية - تظهر مع رسوم متحركة من الأسفل
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // عرض رسالة الخطأ إذا وجدت
                        if (_controller.errorMessage.isNotEmpty)
                          ErrorMessageComponent(
                            errorMessage: _controller.errorMessage,
                          ),

                        // نموذج تسجيل الدخول (البريد الإلكتروني وكلمة المرور)
                        LoginFormComponent(
                          controller: _controller,
                        ),

                        // رابط نسيت كلمة المرور
                        ForgotPasswordLinkComponent(
                          onPressed: _navigateToResetPassword,
                        ),

                        // زر تسجيل الدخول
                        LoginButtonComponent(
                          isLoading: _controller.isLoggingIn,
                          onPressed: _handleLogin,
                        ),

                        // مكون التسجيل بوسائل التواصل الاجتماعي
                        const SocialLoginComponent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
