import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/constants/auth_colors.dart';
import '../constants/login_strings.dart';
import '../controllers/login_controller.dart';

class LoginFormComponent extends StatelessWidget {
  final LoginController controller;

  const LoginFormComponent({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // حقل البريد الإلكتروني
        _buildEnhancedInputField(
          context: context,
          title: LoginStrings.emailLabel,
          hintText: LoginStrings.emailHint,
          controller: controller.emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: controller.validateEmail,
          textInputAction: TextInputAction.next,
        ),

        // حقل كلمة المرور
        _buildEnhancedInputField(
          context: context,
          title: LoginStrings.passwordLabel,
          hintText: LoginStrings.passwordHint,
          controller: controller.passwordController,
          icon: Icons.lock_outline_rounded,
          obscureText: !controller.passwordVisible,
          suffixIcon: _buildPasswordToggleButton(context),
          validator: controller.validatePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            // عند الضغط على زر "تم" على لوحة المفاتيح
            if (controller.isFormValid) {
              final formKey = Form.of(context);
              if (formKey != null) {
                controller.login(formKey as GlobalKey<FormState>);
              }
            }
          },
        ),
      ],
    );
  }

  // زر إظهار/إخفاء كلمة المرور المحسّن
  Widget _buildPasswordToggleButton(BuildContext context) {
    // استخدام MediaQuery للحصول على حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            controller.togglePasswordVisibility();
            // تطبيق تأثير حسي عند الضغط
            HapticFeedback.selectionClick();
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
                    ? AuthColors.mediumPurple
                    : AuthColors.hintColor,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // حقل إدخال محسن يتماشى مع أسلوب حقول التسجيل
  Widget _buildEnhancedInputField({
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
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام حسب حجم الشاشة
    final fontSize = isTablet ? 17.0 : (isSmallScreen ? 14.0 : 15.0);
    final labelSize = isTablet ? 16.0 : (isSmallScreen ? 13.0 : 14.0);
    final iconSize = isTablet ? 26.0 : (isSmallScreen ? 20.0 : 22.0);
    final verticalPadding = isTablet ? 24.0 : (isSmallScreen ? 16.0 : 18.0);
    // استخدام النسب المئوية لضبط الهوامش بناءً على عرض الشاشة
    final horizontalPadding = screenWidth * 0.06; // 6% من عرض الشاشة

    // استخدام FocusNode داخلي لتتبع حالة التركيز
    final FocusNode focusNode = FocusNode();

    return StatefulBuilder(
      builder: (context, setState) {
        // إضافة مستمع لحالة التركيز
        focusNode.addListener(() {
          setState(() {});
        });

        return Padding(
          padding: EdgeInsets.symmetric(
              vertical: 10.0, horizontal: horizontalPadding),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  screenWidth * 0.04), // ~4% من عرض الشاشة
              boxShadow: [
                BoxShadow(
                  color: AuthColors.shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    screenWidth * 0.04), // ~4% من عرض الشاشة
                boxShadow: [
                  BoxShadow(
                    color: focusNode.hasFocus
                        ? AuthColors.mediumPurple.withOpacity(0.2)
                        : AuthColors.shadowColor.withOpacity(0.1),
                    blurRadius: focusNode.hasFocus ? 8 : 4,
                    spreadRadius: focusNode.hasFocus ? 2 : 1,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: focusNode.hasFocus
                      ? AuthColors.mediumPurple
                      : Colors.grey.shade200,
                  width: focusNode.hasFocus ? 1.5 : 1,
                ),
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                obscureText: obscureText,
                textAlign: TextAlign.right,
                textInputAction: textInputAction,
                onFieldSubmitted: onFieldSubmitted,
                onTap: () {
                  // تطبيق تأثير حسي عند الضغط
                  HapticFeedback.selectionClick();
                },
                style: TextStyle(
                  color: AuthColors.textColor,
                  fontSize: fontSize,
                  fontFamily: 'SYMBIOAR+LT',
                  letterSpacing: 0.2,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  labelText: title,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelStyle: TextStyle(
                    color: focusNode.hasFocus
                        ? AuthColors.mediumPurple
                        : AuthColors.textColor.withOpacity(0.7),
                    fontSize: labelSize,
                    fontFamily: 'SYMBIOAR+LT',
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(
                    color: AuthColors.hintColor,
                    fontSize: labelSize,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: focusNode.hasFocus
                        ? AuthColors.mediumPurple
                        : AuthColors.hintColor,
                    size: iconSize,
                  ),
                  suffixIcon: suffixIcon,
                  filled: true,
                  fillColor: focusNode.hasFocus
                      ? AuthColors.lightPurple.withOpacity(0.05)
                      : Colors.white,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  errorStyle: TextStyle(
                    color: AuthColors.accentColor,
                    fontSize: isSmallScreen ? 10 : 12,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: verticalPadding,
                    horizontal: 20,
                  ),
                ),
                validator: validator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
          ),
        );
      },
    );
  }
}
