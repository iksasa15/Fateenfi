import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart'; // Updated import
import '../constants/reset_password_strings.dart';
import '../../shared/helpers/responsive_helper.dart';

class ResetButtonComponent extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const ResetButtonComponent({
    Key? key,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallMobile(context) ||
        ResponsiveHelper.isTinyMobile(context);
    final isTinyScreen = ResponsiveHelper.isTinyMobile(context);
    final isLandscape = ResponsiveHelper.isLandscape(context);

    // تعديل حجم الخط حسب حجم الشاشة
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context,
        smallSize: isTinyScreen ? 13 : 14, mediumSize: 16, largeSize: 17);

    // تعديل ارتفاع الزر حسب حجم الشاشة وتوجيهها
    final buttonHeight = isLandscape
        ? ResponsiveHelper.getResponsiveButtonHeight(context) - 4
        : ResponsiveHelper.getResponsiveButtonHeight(context);

    // تعديل الهوامش الجانبية حسب حجم الشاشة
    final horizontalPadding =
        ResponsiveHelper.getResponsiveHorizontalPadding(context).horizontal / 2;

    // تعديل حجم المؤشر الدائري (loader) حسب حجم الشاشة
    final loaderSize = isTinyScreen ? 18.0 : (isSmallScreen ? 20.0 : 24.0);

    // تقليل الهوامش العمودية في الوضع الأفقي
    final verticalMargin = isLandscape ? 5.0 : 10.0;

    return Container(
      width: double.infinity,
      height: buttonHeight,
      margin: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                context.colorPrimaryDark.withOpacity(0.3), // استخدام Extension
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  context.colorPrimaryLight, // استخدام Extension
                  context.colorPrimaryDark, // استخدام Extension
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: loaderSize,
                      height: loaderSize,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth:
                            isTinyScreen ? 1.5 : (isSmallScreen ? 2.0 : 2.5),
                      ),
                    )
                  : Text(
                      ResetPasswordStrings.resetButtonText,
                      style: TextStyle(
                        fontSize: fontSize,
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
    );
  }
}
