import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/signup_controller.dart';
import '../components/signup_header_component.dart';
import '../components/error_message_component.dart';
import '../components/step_form_container.dart';
import '../../shared/components/auth_toggle_bar.dart';
import '../constants/signup_colors.dart';
import '../../verification/screens/verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  // وحدة التحكم بمنطق التسجيل
  late SignupController _controller;

  // Para la animación - usando inicialización sin late o con valores nulos
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  // مفتاح النموذج للتحقق من المدخلات
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // إعداد وحدة التحكم
    _controller = SignupController();
    _controller.init(context);

    // إعداد الرسوم المتحركة - inicialización segura
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController?.dispose(); // Dispose seguro con operador ?
    super.dispose();
  }

  // معالجة الانتقال للخطوة التالية مع تأثير اهتزاز
  void _handleNextStep() {
    // تطبيق تأثير اهتزاز لطيف
    HapticFeedback.selectionClick();

    if (_controller.validateCurrentStep()) {
      // للتحقق من اسم المستخدم عند الانتقال من خطوة اسم المستخدم
      if (_controller.currentStep == SignupStep.username) {
        _controller.checkUsernameUnique().then((isUnique) {
          if (isUnique) {
            _controller.moveToNextStep();
          }
        });
      }
      // للتحقق من البريد الإلكتروني
      else if (_controller.currentStep == SignupStep.email) {
        _controller.validateEmailExists().then((isValid) {
          if (isValid) {
            _controller.moveToNextStep();
          }
        });
      } else {
        _controller.moveToNextStep();
      }
    } else {
      // إذا كانت البيانات غير صحيحة، نطبق تأثير اهتزاز للإشارة للمستخدم
      HapticFeedback.heavyImpact();
    }
  }

  // معالجة الرجوع للخطوة السابقة
  void _handlePreviousStep() {
    HapticFeedback.lightImpact();
    _controller.moveToPreviousStep();
  }

  // معالجة التسجيل
  Future<void> _handleSignup() async {
    // تأثير اهتزاز عند الضغط على زر التسجيل
    HapticFeedback.mediumImpact();

    if (_formKey.currentState!.validate() &&
        _controller.validateMajor() &&
        _controller.validateUniversity()) {
      // إظهار رسالة التحميل مع تأثير متحرك
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
                'جاري تسجيل الحساب...',
                style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
            ],
          ),
          backgroundColor: SignupColors.mediumPurple,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // إجراء التسجيل
      final success = await _controller.signup(_formKey);

      if (mounted) {
        // إظهار رسالة النجاح أو الفشل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    success
                        ? 'تم التسجيل بنجاح، جاري الانتقال لصفحة التحقق...'
                        : 'حدث خطأ في التسجيل، حاول مرة أخرى',
                    style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            backgroundColor: success ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (success) {
          // تأخير بسيط قبل الانتقال
          await Future.delayed(const Duration(milliseconds: 1500));

          if (mounted) {
            // تطبيق تأثير متلاشي قبل الانتقال - manejo seguro de la animación
            _animationController?.reverse().then((_) {
              _navigateToVerification();
            });
          }
        }
      }
    }
  }

  // دالة الانتقال إلى صفحة التحقق
  void _navigateToVerification() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VerificationScreen(
          email: _controller.emailController.text,
          password: _controller.passwordController.text,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // الانتقال إلى شاشة تسجيل الدخول
  void _navigateToLogin() {
    HapticFeedback.lightImpact();

    // Manejo seguro de la animación
    _animationController?.reverse().then((_) {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: SignupColors.backgroundColor,
      body: FadeTransition(
        // Uso seguro de _fadeAnimation con un valor predeterminado
        opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
        child: AnimatedBuilder(
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
                        // رأس الصفحة - يظهر فقط في الخطوة الأولى
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SizeTransition(
                                sizeFactor: animation,
                                child: child,
                              ),
                            );
                          },
                          child: _controller.currentStep == SignupStep.name
                              ? Column(
                                  key: const ValueKey('header'),
                                  children: [
                                    // رأس الصفحة
                                    const SignupHeaderComponent(),

                                    // فاصل مرئي
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: size.height * 0.01,
                                        horizontal: size.width * 0.1,
                                      ),
                                      height: 1,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.grey.shade200,
                                            SignupColors.mediumPurple
                                                .withOpacity(0.5),
                                            Colors.grey.shade200,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                    ),

                                    // زر التبديل بين التسجيل وإنشاء الحساب
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: AuthToggleBar(
                                        currentMode: AuthToggleMode.signup,
                                        onLoginPressed: _navigateToLogin,
                                        onSignupPressed: () {},
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  key: const ValueKey('no-header'),
                                  height: size.height * 0.02,
                                ),
                        ),

                        // رسالة خطأ من السيرفر (إذا وجدت)
                        if (_controller.serverError != null)
                          ErrorMessageComponent(
                            errorMessage: _controller.serverError!,
                          ),

                        // مكون النموذج خطوة بخطوة
                        StepFormContainer(
                          controller: _controller,
                          onNextPressed: _handleNextStep,
                          onPrevPressed: _handlePreviousStep,
                          onSubmitPressed: _handleSignup,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
