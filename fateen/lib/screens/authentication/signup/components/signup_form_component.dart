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
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      final fieldWidth = maxWidth > 600 ? maxWidth * 0.8 : maxWidth;

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
            maxWidth: fieldWidth,
          ),

          // حقل اسم المستخدم
          _buildInputField(
            context: context,
            title: SignupStrings.usernameLabel,
            hintText: SignupStrings.usernameHint,
            controller: controller.usernameController,
            focusNode: controller.usernameFocusNode,
            icon: Icons.alternate_email,
            validator: controller.validateUsername,
            textInputAction: TextInputAction.next,
            maxWidth: fieldWidth,
            suffixIcon:
                controller.isCheckingUsername ? _buildLoadingIndicator() : null,
            onFieldSubmitted: (_) async {
              // التحقق من فرادة اسم المستخدم عند الانتهاء من الكتابة
              await controller.checkUsernameUnique();
            },
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
            maxWidth: fieldWidth,
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
            maxWidth: fieldWidth,
            onFieldSubmitted: (_) {
              // عند الضغط على زر "تم" على لوحة المفاتيح
              if (controller.validateForm()) {
                final formKey = Form.of(context);
                if (formKey != null) {
                  controller.signup(formKey as GlobalKey<FormState>);
                }
              }
            },
          ),
        ],
      );
    });
  }

  // مؤشر التحميل لحقل اسم المستخدم
  Widget _buildLoadingIndicator() {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.all(12),
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: SignupColors.mediumPurple,
      ),
    );
  }

  // زر إظهار/إخفاء كلمة المرور المحسّن
  Widget _buildPasswordToggleButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final iconSize = isSmallScreen ? 18.0 : 20.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SignupDimensions.mediumRadius),
          onTap: () {
            controller.togglePasswordVisibility();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Hero(
              tag: 'password-visibility',
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
      ),
    );
  }

  // بناء حقل إدخال محسن بتجاوب كامل مع أحجام الشاشات
  Widget _buildInputField({
    required BuildContext context,
    required String title,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    required double maxWidth,
  }) {
    // استخدام قيم نسبية للحجم
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام حسب حجم الشاشة
    final fontSize = isTablet
        ? size.width * 0.028
        : (isSmallScreen ? size.width * 0.035 : size.width * 0.032);

    final labelSize = isTablet
        ? size.width * 0.026
        : (isSmallScreen ? size.width * 0.032 : size.width * 0.03);

    final iconSize = isTablet
        ? size.width * 0.035
        : (isSmallScreen ? size.width * 0.055 : size.width * 0.05);

    final verticalPadding = isTablet
        ? screenHeight * 0.022
        : (isSmallScreen ? screenHeight * 0.018 : screenHeight * 0.02);

    final horizontalPadding =
        isTablet ? screenWidth * 0.05 : screenWidth * 0.06;

    // عرض الهوامش المتجاوب
    final verticalMargin = screenHeight * 0.008;
    final horizontalMargin = screenWidth * 0.012;

    return Container(
      width: maxWidth,
      margin: EdgeInsets.symmetric(
        vertical: verticalMargin,
        horizontal: horizontalMargin,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
          focusNode: focusNode,
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
              color: focusNode?.hasFocus ?? false
                  ? SignupColors.mediumPurple
                  : SignupColors.hintColor,
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
              fontSize: isSmallScreen ? size.width * 0.028 : size.width * 0.025,
              fontFamily: 'SYMBIOAR+LT',
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ),
    );
  }
}
