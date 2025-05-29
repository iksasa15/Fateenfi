import 'package:flutter/material.dart';
import '../constants/reset_password_colors.dart';
import '../constants/reset_password_strings.dart';
import '../../shared/helpers/responsive_helper.dart';

class SuccessViewComponent extends StatelessWidget {
  final String email;
  final VoidCallback onBackPressed;

  const SuccessViewComponent({
    Key? key,
    required this.email,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام ResponsiveHelper للحصول على قيم متجاوبة
    final isTablet = ResponsiveHelper.isTablet(context);
    final isSmallScreen = ResponsiveHelper.isSmallMobile(context);
    final horizontalPadding =
        ResponsiveHelper.getResponsiveHorizontalPadding(context);

    return Column(
      children: [
        // أيقونة النجاح
        Padding(
          padding: EdgeInsets.only(
              top: ResponsiveHelper.isLandscape(context) ? 30 : 40, bottom: 20),
          child: Icon(
            Icons.check_circle_outline,
            color: ResetPasswordColors.mediumPurple,
            size: ResponsiveHelper.getResponsiveValue(
              context,
              mobileSmallValue: 80.0,
              mobileNormalValue: 90.0,
              mobileLargeValue: 100.0,
              tabletValue: 120.0,
              desktopValue: 140.0,
            ),
          ),
        ),

        // عنوان النجاح
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            ResetPasswordStrings.resetSuccessTitle,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context,
                  smallSize: 20, mediumSize: 22, largeSize: 24),
              fontWeight: FontWeight.bold,
              color: ResetPasswordColors.darkPurple,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // رسالة النجاح
        Container(
          padding: EdgeInsets.all(isTablet ? 24 : (isSmallScreen ? 14 : 16)),
          margin: EdgeInsets.symmetric(
              horizontal: horizontalPadding.horizontal / 2, vertical: 16.0),
          decoration: BoxDecoration(
            color: ResetPasswordColors.lightPurple,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ResetPasswordColors.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            ResetPasswordStrings.resetSuccessMessage
                .replaceAll('{email}', email),
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context,
                  smallSize: 13, mediumSize: 14, largeSize: 16),
              color: Colors.grey.shade700,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // زر العودة إلى تسجيل الدخول (بدون سهم)
        Container(
          width: double.infinity,
          height: ResponsiveHelper.getResponsiveButtonHeight(context),
          margin: EdgeInsets.symmetric(
            horizontal: horizontalPadding.horizontal / 2,
            vertical: 24.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ResetPasswordColors.darkPurple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBackPressed,
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      ResetPasswordColors.mediumPurple,
                      ResetPasswordColors.darkPurple,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    ResetPasswordStrings.backToLoginText,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context,
                          smallSize: 15, mediumSize: 16, largeSize: 18),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'SYMBIOAR+LT',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // مساحة إضافية في الأسفل
        SizedBox(
          height: isTablet ? 100 : (isSmallScreen ? 60 : 80),
        ),
      ],
    );
  }
}
