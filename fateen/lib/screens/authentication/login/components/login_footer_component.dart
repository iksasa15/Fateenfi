import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/login_colors.dart';
import '../constants/login_strings.dart';
import '../constants/login_dimensions.dart';

class LoginFooterComponent extends StatelessWidget {
  final VoidCallback onSignup;
  final VoidCallback? onForgotPassword;

  const LoginFooterComponent({
    Key? key,
    required this.onSignup,
    this.onForgotPassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحقق من حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // ضبط الأحجام بناء على حجم الشاشة
    final fontSize = isSmallScreen ? 14.0 : (isTablet ? 16.0 : 15.0);
    final verticalPadding = isSmallScreen ? 16.0 : 24.0;

    return Column(
      children: [
        // زر استعادة كلمة المرور
        if (onForgotPassword != null)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onForgotPassword!();
              },
              child: Text(
                LoginStrings.forgotPasswordText,
                style: TextStyle(
                  color: LoginColors.mediumPurple,
                  fontSize: fontSize - 1,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
          ),

        // فاصل مع أو
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: verticalPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: LoginColors.dividerColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  LoginStrings.orRegisterWith,
                  style: TextStyle(
                    color: LoginColors.hintColor,
                    fontSize: fontSize - 1,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: LoginColors.dividerColor,
                ),
              ),
            ],
          ),
        ),

        // سؤال ليس لديك حساب؟
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 32.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LoginStrings.noAccountQuestion,
                style: TextStyle(
                  color: LoginColors.textColor,
                  fontSize: fontSize,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onSignup();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  LoginStrings.createAccountAction,
                  style: TextStyle(
                    color: LoginColors.mediumPurple,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
        ),

        // المساحة السفلية
        SizedBox(height: isTablet ? 40.0 : 24.0),
      ],
    );
  }
}
