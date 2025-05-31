import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/signup_controller.dart';
import '../components/signup_header_component.dart';
import '../components/error_message_component.dart';
import '../components/step_form_container.dart';
import '../../shared/components/auth_toggle_bar.dart';
import '../constants/signup_colors.dart';
import '../../verification/screens/verification_screen.dart';
import '../../shared/helpers/custom_route_transitions.dart';
import '../../../authentication/login/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  // وحدة التحكم بمنطق التسجيل
  late SignupController _controller;

  // تحكم بالرسوم المتحركة للمكونات السفلية
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  // مفتاح النموذج للتحقق من المدخلات
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // إعداد وحدة التحكم
    _controller = SignupController();
    _controller.init(context);

    // إعداد الرسوم المتحركة للمكونات السفلية
    _animationController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 800), // توحيد المدة مع login_screen
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // توحيد قيمة الإزاحة مع login_screen
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad, // توحيد المنحنى مع login_screen
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
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
            // تطبيق تأثير سحب للأسفل قبل الانتقال
            _animationController.reverse().then((_) {
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
      MaterialPageRoute(
        builder: (context) => VerificationScreen(
          email: _controller.emailController.text,
          password: _controller.passwordController.text,
        ),
      ),
    );
  }

  // الانتقال إلى شاشة تسجيل الدخول
  void _navigateToLogin() {
    // توحيد تأثير اللمس مع login_screen
    HapticFeedback.selectionClick();

    // تطبيق تأثير الاختفاء نحو الأسفل قبل الانتقال
    _animationController.reverse().then((_) {
      Navigator.of(context).pushReplacement(
        NoTransitionRoute(
          page: const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة
    final size = MediaQuery.of(context).size;

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
                      // المكونات العلوية - تظهر بدون رسوم متحركة
                      Column(
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

                                      // تم حذف الفاصل المرئي هنا

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
                        ],
                      ),

                      // المكونات السفلية - تظهر مع رسوم متحركة من الأسفل
                      SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
