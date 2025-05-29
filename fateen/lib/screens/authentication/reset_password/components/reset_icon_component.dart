import 'package:flutter/material.dart';
import '../constants/reset_password_colors.dart';
import '../../shared/helpers/responsive_helper.dart';

class ResetIconComponent extends StatelessWidget {
  const ResetIconComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallMobile(context) ||
        ResponsiveHelper.isTinyMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isTinyScreen = ResponsiveHelper.isTinyMobile(context);

    // تعديل حجم الأيقونة حسب حجم الشاشة
    final iconSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobileSmallValue: isTinyScreen ? 45.0 : 50.0,
      mobileNormalValue: 60.0,
      mobileLargeValue: 70.0,
      tabletValue: 80.0,
      desktopValue: 90.0,
    );

    // حساب حجم الحاوية يعتمد على حجم الشاشة
    final containerSize = isTablet ? iconSize * 2.0 : iconSize * 1.8;

    // تعديل هوامش العنصر حسب حجم الشاشة
    final verticalMargin = isSmallScreen ? 10.0 : (isTablet ? 25.0 : 20.0);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: verticalMargin),
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: ResetPasswordColors.lightPurple,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.lock_reset_rounded,
            size: iconSize,
            color: ResetPasswordColors.darkPurple,
          ),
        ),
      ),
    );
  }
}
