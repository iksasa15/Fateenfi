import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/login_header_component.dart';
import '../components/login_form_component.dart';
import '../components/login_footer_component.dart';
import '../components/social_login_component.dart';
import '../components/error_message_component.dart';
import '../controllers/login_controller.dart';
import '../constants/login_colors.dart';
import '../../shared/components/auth_toggle_bar.dart';
import '../../signup/screens/signup_screen.dart';
import '../../shared/helpers/custom_route_transitions.dart';

class LoginScreen extends StatefulWidget {
  final bool showBackButton;
  final String? initialUsername;

  const LoginScreen({
    Key? key,
    this.showBackButton = false,
    this.initialUsername,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final LoginController _controller;
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // إعداد وحدة التحكم
    _controller = LoginController();

    // إعداد الرسوم المتحركة
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));

    _animationController.forward();

    // تهيئة المتحكم بالسياق
    _controller.init(context);

    // إذا تم تمرير اسم مستخدم، قم بإعداده في حقل البريد الإلكتروني
    if (widget.initialUsername != null && widget.initialUsername!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.emailController.text = widget.initialUsername!;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // معالجة تسجيل الدخول
  Future<void> _handleLogin() async {
    // تطبيق تأثير اهتزاز لطيف
    HapticFeedback.mediumImpact();

    if (_formKey.currentState!.validate()) {
      // إظهار رسالة التحميل
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'جاري تسجيل الدخول...',
                  style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
                ),
              ],
            ),
            backgroundColor: LoginColors.mediumPurple,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      // إجراء تسجيل الدخول - تعديل التعامل مع القيمة المرجعة
      final success = await _controller.login(
        _formKey,
        context,
      );

      // لا حاجة لإظهار رسالة النجاح حيث سننتقل مباشرة للصفحة الرئيسية
      if (mounted && success == false) {
        // تعديل شرط التحقق
        // إظهار رسالة الفشل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _controller.errorMessage ??
                        'حدث خطأ في تسجيل الدخول، حاول مرة أخرى',
                    style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // الانتقال إلى شاشة إنشاء الحساب
  void _navigateToSignup() {
    // تطبيق تأثير اللمس
    HapticFeedback.selectionClick();

    // تطبيق تأثير الاختفاء نحو الأسفل قبل الانتقال
    _animationController.reverse().then((_) {
      Navigator.of(context).pushReplacement(
        NoTransitionRoute(
          page: const SignUpScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.backgroundColor,
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
                  // المكونات العلوية - تظهر بدون رسوم متحركة
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // رأس الصفحة
                      const LoginHeaderComponent(),

                      // زر التبديل بين التسجيل وإنشاء الحساب - نضعه هنا ليتطابق مع شاشة التسجيل
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: AuthToggleBar(
                          currentMode: AuthToggleMode.login,
                          onLoginPressed: () {
                            // بالفعل في شاشة تسجيل الدخول
                          },
                          onSignupPressed: _navigateToSignup,
                        ),
                      ),
                    ],
                  ),

                  // المكونات السفلية - تظهر مع رسوم متحركة من الأسفل
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // عرض رسالة الخطأ إذا كانت موجودة
                        if (_controller.errorMessage.isNotEmpty)
                          ErrorMessageComponent(
                            errorMessage: _controller.errorMessage,
                          ),

                        // نموذج تسجيل الدخول
                        LoginFormComponent(
                          controller: _controller,
                          onLogin: _handleLogin,
                        ),

                        // مكونات إضافية
                        const SocialLoginComponent(),

                        // تذييل الصفحة
                        LoginFooterComponent(
                          onSignup: _navigateToSignup,
                          onForgotPassword: () {
                            // TODO: إضافة انتقال لصفحة نسيت كلمة المرور
                          },
                        ),
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
