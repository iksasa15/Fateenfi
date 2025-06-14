import 'package:fateen/core/constants/appColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/components/Header/header_component.dart'; // Updated import
import '../components/login_form_component.dart';
import '../components/login_footer_component.dart';
import '../controllers/login_controller.dart';
import '../constants/login_strings.dart'; // Added import for strings
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
      debugPrint('بدء عملية تسجيل الدخول');

      try {
        // تنفيذ تسجيل الدخول
        final success = await _controller.login(
          _formKey,
          context,
        );

        debugPrint('نتيجة تسجيل الدخول: $success');

        // التحقق من أن الشاشة لا تزال مثبتة وعرض رسالة الخطأ إذا لزم الأمر
        if (mounted && !success && _controller.errorMessage.isNotEmpty) {
          _showErrorMessage(_controller.errorMessage);
        }
      } catch (e) {
        debugPrint('استثناء في معالجة تسجيل الدخول: $e');
        if (mounted) {
          _showErrorMessage("حدث خطأ غير متوقع. حاول مرة أخرى.");
        }
      }
    } else {
      debugPrint('النموذج غير صالح');
    }
  }

  // عرض رسالة خطأ بشكل آمن
  void _showErrorMessage(String message) {
    // نستخدم WidgetsBinding لضمان أن التنفيذ يحدث بعد انتهاء بناء الإطار الحالي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors
                .accent, // Updated to use accent from the new color scheme
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        );
      }
    });
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
      backgroundColor: AppColors
          .background, // Updated to use background from the new color scheme
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
                      // رأس الصفحة - استخدام الهيدر المشترك
                      HeaderComponent(
                        title: LoginStrings.loginTitle,
                        subtitle: LoginStrings.formInfoText,
                        showWavingHand: true,
                        gradientColors: [
                          AppColors
                              .primaryDark, // Updated to use primaryDark from the new color scheme
                          AppColors
                              .primaryLight, // Updated to use primaryLight from the new color scheme
                        ],
                      ),

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
                        // نموذج تسجيل الدخول
                        LoginFormComponent(
                          controller: _controller,
                          onLogin: _handleLogin,
                        ),

                        // تم حذف SocialLoginComponent

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
