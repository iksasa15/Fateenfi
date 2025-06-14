import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../signup_controller/controllers/signup_controller.dart';
import '../../../../core/components/Header/header_component.dart'; // Changed import
import '../components/input_fields/error_message_component.dart';
import '../components/step_form/step_form_container.dart';
import '../../shared/components/auth_toggle_bar.dart';
import '../../../../core/constants/appColor.dart'; // Changed from signup_colors.dart to appColor.dart
import '../constants/signup_strings.dart'; // Make sure this exists
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

    // الاستماع للتغييرات في خطوات التسجيل
    _controller.addListener(() {
      // إعادة بناء الواجهة عند تغيير الخطوة لتحديث ظهور شريط التبديل
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // معالجة الانتقال للخطوة التالية مع تأثير اهتزاز - تم تحويلها إلى async
  Future<void> _handleNextStep() async {
    // تطبيق تأثير اهتزاز لطيف
    HapticFeedback.selectionClick();

    if (_controller.validateCurrentStep()) {
      // للتحقق من اسم المستخدم عند الانتقال من خطوة اسم المستخدم
      if (_controller.currentStep == SignupStep.username) {
        // تعيين حالة التحقق إلى true قبل البدء
        setState(() {
          _controller.setCheckingUsername(true);
        });

        // استخدام await بدلاً من then
        final isUnique = await _controller.checkUsernameUnique();

        // إعادة تعيين حالة التحقق بعد الانتهاء
        setState(() {
          _controller.setCheckingUsername(false);
        });

        if (isUnique) {
          _controller.moveToNextStep();
        }
      }
      // للتحقق من البريد الإلكتروني
      else if (_controller.currentStep == SignupStep.email) {
        // تعيين حالة التحقق إلى true قبل البدء
        setState(() {
          _controller.setCheckingEmail(true);
        });

        // استخدام await بدلاً من then
        final isValid = await _controller.validateEmailExists();

        // إعادة تعيين حالة التحقق بعد الانتهاء
        setState(() {
          _controller.setCheckingEmail(false);
        });

        if (isValid) {
          _controller.moveToNextStep();
        }
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

  // معالجة التسجيل - تم إزالة جميع رسائل Snackbar
  Future<void> _handleSignup() async {
    // تأثير اهتزاز عند الضغط على زر التسجيل
    HapticFeedback.mediumImpact();

    if (_formKey.currentState!.validate() &&
        _controller.validateMajor() &&
        _controller.validateUniversity()) {
      // تعيين حالة التحميل للكونترولر
      setState(() {
        _controller.setLoading(true);
      });

      // إجراء التسجيل
      bool success = false;
      try {
        success = await _controller.signup(_formKey);
      } catch (e) {
        print("خطأ في عملية التسجيل: $e");
      } finally {
        // إنهاء حالة التحميل بغض النظر عن النتيجة
        if (mounted) {
          setState(() {
            _controller.setLoading(false);
          });
        }
      }

      // في حالة النجاح، انتقل مباشرة إلى صفحة التحقق
      if (mounted && success) {
        // تطبيق تأثير سحب للأسفل قبل الانتقال
        _animationController.reverse().then((_) {
          _navigateToVerification();
        });
      } else if (mounted && !success) {
        // في حالة الفشل فقط، عرض رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'حدث خطأ في التسجيل، حاول مرة أخرى',
                    style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      // إذا كان التحقق من الصحة فاشلاً، نطبق تأثير اهتزاز قوي
      HapticFeedback.heavyImpact();

      // عرض رسالة خطأ للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'يرجى التحقق من صحة البيانات المدخلة',
                  style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
    return Scaffold(
      backgroundColor: AppColors
          .background, // Changed from SignupColors.backgroundColor to AppColors.background
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
                      // المكونات العلوية
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // رأس الصفحة - يظهر فقط في الخطوة الأولى
                          AnimatedOpacity(
                            opacity: _controller.currentStep == SignupStep.name
                                ? 1.0
                                : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: _controller.currentStep == SignupStep.name
                                  ? null
                                  : 0,
                              // استخدام الهيدر المشترك بدلاً من الخاص
                              child: HeaderComponent(
                                title:
                                    "إنشاء حساب", // استخدم SignupStrings.signupTitle بدلاً من هذا إذا كان متوفرًا
                                subtitle:
                                    "قم بإكمال البيانات التالية لإنشاء حسابك", // استخدم SignupStrings.formInfoText بدلاً من هذا
                                showWavingHand: false,
                                iconColor: AppColors.accent.withOpacity(
                                    0.7), // Changed from SignupColors.accentColor to AppColors.accent
                                gradientColors: [
                                  AppColors
                                      .primaryDark, // Changed from SignupColors.darkPurple to AppColors.primaryDark
                                  AppColors
                                      .primaryLight, // Changed from SignupColors.mediumPurple to AppColors.primaryLight
                                ],
                              ),
                            ),
                          ),

                          // زر التبديل بين التسجيل وإنشاء الحساب - يظهر فقط في الخطوة الأولى
                          AnimatedOpacity(
                            opacity: _controller.currentStep == SignupStep.name
                                ? 1.0
                                : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: _controller.currentStep == SignupStep.name
                                  ? null
                                  : 0,
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: AuthToggleBar(
                                  currentMode: AuthToggleMode.signup,
                                  onLoginPressed: _navigateToLogin,
                                  onSignupPressed: () {
                                    // بالفعل في شاشة إنشاء الحساب
                                  },
                                ),
                              ),
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
                              onLoginPressed: _navigateToLogin,
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
