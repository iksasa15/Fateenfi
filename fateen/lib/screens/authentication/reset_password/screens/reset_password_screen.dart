import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/reset_password_colors.dart';
import '../constants/reset_password_strings.dart';
import '../controllers/reset_password_controller.dart';
import '../components/reset_header_component.dart';
import '../components/reset_subheader_component.dart';
import '../components/reset_icon_component.dart';
import '../components/reset_form_component.dart';
import '../components/reset_button_component.dart';
import '../components/error_message_component.dart';
import '../components/success_view_component.dart';
import '../../shared/helpers/responsive_helper.dart';
import '../../shared/helpers/custom_route_transitions.dart';
import '../../../authentication/login/screens/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  // وحدة التحكم بمنطق استعادة كلمة المرور
  late ResetPasswordController _controller;

  // مفتاح النموذج للتحقق من المدخلات
  final _formKey = GlobalKey<FormState>();

  // تحكم بالرسوم المتحركة للمكونات
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = ResetPasswordController();
    _controller.init(context);

    // إعداد الرسوم المتحركة - نفس الإعدادات بالضبط مثل شاشة تسجيل الدخول
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // العودة إلى شاشة تسجيل الدخول
  void _navigateToLogin() {
    HapticFeedback.selectionClick();

    // تطبيق تأثير الانتقال العكسي قبل الانتقال
    _animationController.reverse().then((_) {
      Navigator.of(context).pushReplacement(
        NoTransitionRoute(
          page: const LoginScreen(),
        ),
      );
    });
  }

  // معالجة إرسال طلب استعادة كلمة المرور
  Future<void> _handleResetPassword() async {
    HapticFeedback.mediumImpact();

    if (_formKey.currentState!.validate()) {
      await _controller.resetPassword(_formKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery للحصول على معلومات الشاشة
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final width = size.width;
    final height = size.height;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isSmallScreen = width < 360;
    final isTablet = width > 600;

    // حساب النسب والقيم الديناميكية باستخدام MediaQuery
    final topPadding = isLandscape ? height * 0.04 : height * 0.06;
    final contentPadding = width * 0.06; // 6% من عرض الشاشة
    final horizontalPadding = EdgeInsets.symmetric(horizontal: contentPadding);
    final screenSizeRatio = width / 375; // نسبة مقارنة بشاشة iPhone قياسية

    // استخدام ResponsiveHelper للحصول على قيم متجاوبة إضافية
    final responsiveHorizontalPadding =
        ResponsiveHelper.getResponsiveHorizontalPadding(context);

    return Scaffold(
      backgroundColor: ResetPasswordColors.backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: _controller.isSuccess
                ? SlideTransition(
                    position: _slideAnimation,
                    child: _buildSuccessView(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // المكونات العلوية - ثابتة بدون رسوم متحركة
                      Container(
                        padding: EdgeInsets.only(bottom: height * 0.01),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // رأس الصفحة
                            ResetHeaderComponent(topPadding: topPadding),

                            // أيقونة إعادة تعيين كلمة المرور
                            const ResetIconComponent(),
                          ],
                        ),
                      ),

                      // المكونات السفلية - تظهر مع رسوم متحركة من الأسفل
                      SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // عنوان فرعي
                            const ResetSubheaderComponent(),

                            // وصف الاستعادة
                            Padding(
                              padding: horizontalPadding.copyWith(
                                  top: height * 0.01, bottom: height * 0.02),
                              child: Text(
                                ResetPasswordStrings.resetInfoText,
                                style: TextStyle(
                                  fontSize:
                                      14 * screenSizeRatio.clamp(0.8, 1.2),
                                  color: Colors.grey.shade700,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            // عرض رسالة الخطأ إذا وجدت
                            if (_controller.serverError != null)
                              Padding(
                                padding: horizontalPadding,
                                child: ErrorMessageComponent(
                                  errorMessage: _controller.serverError!,
                                ),
                              ),

                            // نموذج البريد الإلكتروني
                            Padding(
                              padding: horizontalPadding.copyWith(
                                  top: height * 0.01, bottom: height * 0.02),
                              child: ResetFormComponent(
                                controller: _controller,
                                validator: _controller.validateEmail,
                              ),
                            ),

                            // زر إرسال رابط الاستعادة - بالشكل الأصلي
                            ResetButtonComponent(
                              isLoading: _controller.isLoading,
                              onPressed: _handleResetPassword,
                            ),

                            // زر العودة إلى تسجيل الدخول
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: height * 0.02),
                                child: TextButton(
                                  onPressed: _navigateToLogin,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        vertical: height * 0.015,
                                        horizontal: width * 0.04),
                                    foregroundColor:
                                        ResetPasswordColors.darkPurple,
                                  ),
                                  child: Text(
                                    ResetPasswordStrings.backToLoginText,
                                    style: TextStyle(
                                      fontSize:
                                          14 * screenSizeRatio.clamp(0.8, 1.2),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'SYMBIOAR+LT',
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // مساحة في الأسفل للشاشات الكبيرة
                            SizedBox(
                                height:
                                    isTablet ? height * 0.1 : height * 0.05),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // بناء واجهة النجاح بعد إرسال طلب الاستعادة
  Widget _buildSuccessView() {
    return SuccessViewComponent(
      email: _controller.emailController.text,
      onBackPressed: _navigateToLogin,
    );
  }
}
