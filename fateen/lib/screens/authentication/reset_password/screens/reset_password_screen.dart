import 'package:flutter/material.dart';
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

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // وحدة التحكم بمنطق استعادة كلمة المرور
  late ResetPasswordController _controller;

  // مفتاح النموذج للتحقق من المدخلات
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = ResetPasswordController();
    _controller.init(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // العودة إلى شاشة تسجيل الدخول
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  // معالجة إرسال طلب استعادة كلمة المرور
  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      await _controller.resetPassword(_formKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    // التحقق من أبعاد الشاشة للتصميم المتجاوب
    final topPadding = ResponsiveHelper.isLandscape(context) ? 20.0 : 40.0;
    final horizontalPadding =
        ResponsiveHelper.getResponsiveHorizontalPadding(context);

    return Scaffold(
      backgroundColor: ResetPasswordColors.backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _controller.isSuccess
                    ? _buildSuccessView()
                    : _buildResetFormView(topPadding, horizontalPadding),
              ),
            ),
          );
        },
      ),
    );
  }

  // بناء واجهة استعادة كلمة المرور الرئيسية
  Widget _buildResetFormView(double topPadding, EdgeInsets horizontalPadding) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس الصفحة
          ResetHeaderComponent(topPadding: topPadding),

          // أيقونة إعادة تعيين كلمة المرور
          const ResetIconComponent(),

          // عنوان فرعي
          const ResetSubheaderComponent(),

          // وصف الاستعادة
          Padding(
            padding: horizontalPadding.copyWith(top: 8, bottom: 16),
            child: Text(
              ResetPasswordStrings.resetInfoText,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context,
                    smallSize: 12, mediumSize: 14, largeSize: 16),
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
            padding: horizontalPadding.copyWith(top: 10, bottom: 16),
            child: ResetFormComponent(
              controller: _controller,
              validator: _controller.validateEmail,
            ),
          ),

          // زر إرسال رابط الاستعادة
          ResetButtonComponent(
            isLoading: _controller.isLoading,
            onPressed: _handleResetPassword,
          ),

          // زر العودة إلى تسجيل الدخول (تم حذف السهم)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextButton(
                onPressed: _navigateToLogin,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  foregroundColor: ResetPasswordColors.darkPurple,
                ),
                child: Text(
                  ResetPasswordStrings.backToLoginText,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context,
                        smallSize: 13, mediumSize: 14, largeSize: 16),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ),
          ),

          // مساحة في الأسفل للشاشات الكبيرة
          SizedBox(height: ResponsiveHelper.isTablet(context) ? 80 : 40),
        ],
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
