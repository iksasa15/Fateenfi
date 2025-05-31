import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../shared/constants/auth_colors.dart';

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

  // تحكم بالرسوم المتحركة للواجهة
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation; // تصحيح نوع البيانات
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // تهيئة وحدة التحكم
    _controller = LoginController();
    _controller.init(context);

    // إعداد الرسوم المتحركة
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // تصحيح تعريف _slideAnimation بإزالة التحويل الخاطئ
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

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
    Navigator.pushReplacementNamed(context, '/signup');
  }

  // الانتقال إلى شاشة استعادة كلمة المرور
  void _navigateToResetPassword() {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, '/reset-password');
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
    return Scaffold(
      backgroundColor: AuthColors.backgroundColor,
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
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
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
                              onLoginPressed: () {
                                /* بالفعل في صفحة تسجيل الدخول */
                              },
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
                              baseColor: AuthColors.shimmerBase,
                              highlightColor: AuthColors.shimmerHighlight,
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
