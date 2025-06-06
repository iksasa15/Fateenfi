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
                  LoginStrings.orLoginWith,
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

        // تم حذف سؤال "ليس لديك حساب؟ إنشاء حساب"

        // المساحة السفلية
        SizedBox(height: isTablet ? 40.0 : 24.0),
      ],
    );
  }
}
