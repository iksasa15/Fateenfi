import 'package:flutter/material.dart';
import '../constants/signup_colors.dart';
import '../constants/signup_strings.dart';
import '../constants/signup_dimensions.dart';
import '../controllers/signup_controller.dart';

class SignupFormComponent extends StatelessWidget {
  final SignupController controller;

  const SignupFormComponent({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // حقل الاسم الكامل
        _buildInputField(
          context: context,
          title: SignupStrings.fullNameLabel,
          hintText: SignupStrings.fullNameHint,
          controller: controller.nameController,
          icon: Icons.person_outline,
          validator: controller.validateName,
          textInputAction: TextInputAction.next,
        ),

        // حقل البريد الإلكتروني
        _buildInputField(
          context: context,
          title: SignupStrings.emailLabel,
          hintText: SignupStrings.emailHint,
          controller: controller.emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: controller.validateEmail,
          textInputAction: TextInputAction.next,
        ),

        // حقل كلمة المرور
        _buildInputField(
          context: context,
          title: SignupStrings.passwordLabel,
          hintText: SignupStrings.passwordHint,
          controller: controller.passwordController,
          icon: Icons.lock_outline_rounded,
          obscureText: !controller.passwordVisible,
          suffixIcon: _buildPasswordToggleButton(context),
          validator: controller.validatePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            // عند الضغط على زر "تم" على لوحة المفاتيح
            if (controller.validateForm()) {
              final formKey = Form.of(context);
              if (formKey != null) {
                // استخدام registerUser بدلاً من signup
                controller.signup(formKey as GlobalKey<FormState>);
              }
            }
          },
        ),
      ],
    );
  }

  // زر إظهار/إخفاء كلمة المرور المحسّن
  Widget _buildPasswordToggleButton(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final iconSize = isSmallScreen ? 18.0 : 20.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SignupDimensions.mediumRadius),
          onTap: () {
            // استخدام الدالة بشكل صحيح كطريقة
            controller.togglePasswordVisibility();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                controller.passwordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                key: ValueKey<bool>(controller.passwordVisible),
                color: controller.passwordVisible
                    ? SignupColors.mediumPurple
                    : SignupColors.hintColor,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // بناء حقل إدخال بدون تأثير تغيير اللون عند الكتابة
  Widget _buildInputField({
    required BuildContext context,
    required String title,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    // استخدام LayoutBuilder للتصميم المتجاوب
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 360;
        final isTablet = screenWidth > 600;

        // تعديل الأحجام حسب حجم الشاشة
        final fontSize = isTablet
            ? 17.0
            : (isSmallScreen
                ? SignupDimensions.smallBodyFontSize
                : SignupDimensions.bodyFontSize);
        final labelSize = isTablet ? 16.0 : (isSmallScreen ? 13.0 : 14.0);
        final iconSize = isTablet ? 26.0 : (isSmallScreen ? 20.0 : 22.0);
        final verticalPadding = isTablet ? 24.0 : (isSmallScreen ? 16.0 : 18.0);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: SignupColors.shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              textAlign: TextAlign.right,
              textInputAction: textInputAction,
              onFieldSubmitted: onFieldSubmitted,
              style: TextStyle(
                color: SignupColors.textColor,
                fontSize: fontSize,
                fontFamily: 'SYMBIOAR+LT',
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                labelText: title,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle: TextStyle(
                  color: SignupColors.textColor.withOpacity(0.7),
                  fontSize: labelSize,
                  fontFamily: 'SYMBIOAR+LT',
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  color: SignupColors.hintColor,
                  fontSize: labelSize,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                prefixIcon: Icon(
                  icon,
                  color: SignupColors.hintColor,
                  size: iconSize,
                ),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: SignupColors.mediumPurple,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: SignupColors.accentColor,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: SignupColors.accentColor,
                    width: 1.5,
                  ),
                ),
                errorStyle: TextStyle(
                  color: SignupColors.accentColor,
                  fontSize: isSmallScreen ? 10 : 12,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: 20,
                ),
              ),
              validator: validator,
            ),
          ),
        );
      },
    );
  }
}
