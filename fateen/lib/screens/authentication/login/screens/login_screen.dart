import 'package:flutter/material.dart';
import '../components/login_header_component.dart';
import '../components/login_form_component.dart';
import '../components/social_login_component.dart';
import '../components/forgot_password_link_component.dart';
import '../components/login_button_component.dart';
import '../components/error_message_component.dart';
import '../components/skeletonizer_component.dart';
import '../components/loading_state_component.dart';
import '../../shared/components/auth_toggle_bar.dart';
import '../controllers/login_controller.dart';
import '../constants/login_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // وحدة التحكم بمنطق تسجيل الدخول
  late LoginController _controller;

  // مفتاح النموذج للتحقق من المدخلات
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
    _controller.init(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // الانتقال إلى شاشة إنشاء حساب
  void _navigateToSignup() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  // الانتقال إلى شاشة استعادة كلمة المرور
  void _navigateToResetPassword() {
    Navigator.pushNamed(context, '/reset-password');
  }

  // معالجة تسجيل الدخول
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await _controller.login(_formKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // إذا كان التطبيق في حالة تحميل أولية، نعرض مكون التحميل
          if (_controller.isLoading) {
            return const SafeArea(
              child: LoadingStateComponent(),
            );
          }

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
                      const LoginHeaderComponent(),

                      // زر التبديل بين تسجيل الدخول وإنشاء الحساب
                      AuthToggleBar(
                        currentMode: AuthToggleMode.login,
                        onLoginPressed: () {/* بالفعل في صفحة تسجيل الدخول */},
                        onSignupPressed: _navigateToSignup,
                      ),

                      // عرض رسالة الخطأ إذا وجدت
                      if (_controller.errorMessage.isNotEmpty)
                        ErrorMessageComponent(
                          errorMessage: _controller.errorMessage,
                        ),

                      // نموذج تسجيل الدخول (البريد الإلكتروني وكلمة المرور)
                      SkeletonizerComponent(
                        isLoading: _controller.isLoggingIn &&
                            _controller.loginProgress == 0,
                        child: LoginFormComponent(
                          controller: _controller,
                        ),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
