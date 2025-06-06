import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/constants/auth_colors.dart';
import '../constants/login_strings.dart';
import '../controllers/login_controller.dart';
import '../constants/login_dimensions.dart';
import '../components/login_button_component.dart';
import '../../reset_password/screens/reset_password_screen.dart'; // إضافة استيراد شاشة استعادة كلمة المرور

class LoginFormComponent extends StatelessWidget {
  final LoginController controller;
  final VoidCallback onLogin;

  const LoginFormComponent({
    Key? key,
    required this.controller,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // حقل البريد الإلكتروني أو اسم المستخدم
        _buildEnhancedInputField(
          context: context,
          title: LoginStrings.emailOrUsernameLabel,
          hintText: LoginStrings.emailOrUsernameHint,
          controller: controller.emailController,
          icon: Icons.person_outline_rounded,
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
                onLogin();
              }
            }
          },
        ),

        // رابط نسيت كلمة المرور (مباشر بدون استخدام المكون المنفصل)
        _buildForgotPasswordLink(context),

        // زر تسجيل الدخول
        LoginButtonComponent(
          isLoading: controller.isLoggingIn,
          onPressed: onLogin,
        ),
      ],
    );
  }

  // إضافة دالة لبناء رابط نسيت كلمة المرور بشكل مباشر
  Widget _buildForgotPasswordLink(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: EdgeInsets.fromLTRB(
          LoginDimensions.getSpacing(context, size: SpacingSize.large),
          0,
          LoginDimensions.getSpacing(context, size: SpacingSize.large),
          LoginDimensions.getSpacing(context, size: SpacingSize.large) - 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
                BorderRadius.circular(LoginDimensions.getMediumRadius(context)),
            onTap: () {
              HapticFeedback.selectionClick();

              // الانتقال إلى شاشة استعادة كلمة المرور
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ResetPasswordScreen(),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: LoginDimensions.getSpacing(context,
                    size: SpacingSize.small),
                vertical: LoginDimensions.getSpacing(context,
                        size: SpacingSize.small) /
                    2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LoginStrings.forgotPasswordText,
                    style: TextStyle(
                      color: AuthColors.darkPurple,
                      fontSize: LoginDimensions.getBodyFontSize(context,
                          small: isSmallScreen),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                  SizedBox(
                      width: LoginDimensions.getSpacing(context,
                              size: SpacingSize.small) /
                          2),
                  Icon(
                    Icons.lock_reset_rounded,
                    color: AuthColors.darkPurple,
                    size: LoginDimensions.getBodyFontSize(context,
                            small: isSmallScreen) +
                        2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

  // حقل إدخال محسن مع إزالة فورية للخطأ عند الكتابة
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

    // استخدام FormFieldState للتحكم في حالة الخطأ
    final formFieldKey = GlobalKey<FormFieldState>();

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
            key: formFieldKey,
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
            onChanged: (value) {
              // عند تغيير النص، قم بإعادة التحقق من الحقل وإزالة رسالة الخطأ إذا كان النص صحيحاً
              if (formFieldKey.currentState != null &&
                  formFieldKey.currentState!.hasError) {
                // إعادة التحقق فقط إذا كان هناك خطأ
                if (validator(value) == null) {
                  formFieldKey.currentState!.validate();
                }
              }
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
