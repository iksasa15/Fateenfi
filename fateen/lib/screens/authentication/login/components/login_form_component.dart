import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/constants/auth_colors.dart';
import '../constants/login_strings.dart';
import '../controllers/login_controller.dart';
import '../constants/login_dimensions.dart';

class LoginFormComponent extends StatelessWidget {
  final LoginController controller;
  final VoidCallback onLogin; // إضافة المعلمة الجديدة

  const LoginFormComponent({
    Key? key,
    required this.controller,
    required this.onLogin, // إضافة المعلمة الجديدة
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
              if (formKey.currentState?.validate() == true) {
                onLogin(); // استخدام دالة تسجيل الدخول
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
    final iconSize = LoginDimensions.getIconSize(context, small: isSmallScreen);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(LoginDimensions.getMediumRadius(context)),
        onTap: () {
          controller.togglePasswordVisibility();
          // تطبيق تأثير حسي عند الضغط
          HapticFeedback.selectionClick();
        },
        child: Padding(
          padding: EdgeInsets.all(
              LoginDimensions.getSpacing(context, size: SpacingSize.small)),
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
    );
  }

  // حقل إدخال محسن يتماشى مع حقول صفحة نسيت كلمة المرور
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
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    // استخدام دوال الأبعاد الجديدة
    final fontSize =
        LoginDimensions.getBodyFontSize(context, small: isSmallScreen);
    final labelSize =
        LoginDimensions.getLabelFontSize(context, small: isSmallScreen);
    final iconSize = LoginDimensions.getIconSize(context, small: isSmallScreen);

    // استخدام النسب المئوية لضبط الهوامش بناءً على عرض الشاشة
    final horizontalPadding =
        LoginDimensions.getSpacing(context, size: SpacingSize.large);

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
              vertical:
                  LoginDimensions.getSpacing(context, size: SpacingSize.small) +
                      2,
              horizontal: horizontalPadding),
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
            ),
            decoration: InputDecoration(
              hintText: hintText,
              labelText: title,
              labelStyle: TextStyle(
                color: focusNode.hasFocus
                    ? AuthColors.mediumPurple
                    : AuthColors.textColor.withOpacity(0.7),
                fontSize: labelSize,
                fontFamily: 'SYMBIOAR+LT',
              ),
              hintStyle: TextStyle(
                color: AuthColors.hintColor,
                fontSize: labelSize,
                fontFamily: 'SYMBIOAR+LT',
              ),
              prefixIcon: Icon(
                icon,
                color: focusNode.hasFocus || controller.text.isNotEmpty
                    ? AuthColors.mediumPurple
                    : AuthColors.hintColor,
                size: iconSize,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    LoginDimensions.getMediumRadius(context)),
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    LoginDimensions.getMediumRadius(context)),
                borderSide: BorderSide(
                  color: AuthColors.mediumPurple,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    LoginDimensions.getMediumRadius(context)),
                borderSide: BorderSide(
                  color: AuthColors.accentColor,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    LoginDimensions.getMediumRadius(context)),
                borderSide: BorderSide(
                  color: AuthColors.accentColor,
                  width: 1.5,
                ),
              ),
              errorStyle: TextStyle(
                color: AuthColors.accentColor,
                fontSize: isSmallScreen ? 10 : 12,
                fontFamily: 'SYMBIOAR+LT',
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: LoginDimensions.getInputFieldPadding(context,
                    small: isSmallScreen),
                horizontal: 20,
              ),
            ),
            validator: validator,
          ),
        );
      },
    );
  }
}

extension on FormState {
  get currentState => null;
}
