import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart'; // Updated import

class VerificationIconComponent extends StatelessWidget {
  final bool isVerified;

  const VerificationIconComponent({
    Key? key,
    required this.isVerified,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل حجم الأيقونة حسب حجم الشاشة
    final iconSize = isTablet ? 80.0 : (isSmallScreen ? 60.0 : 70.0);

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
          color: AppColors.primaryExtraLight, // Updated
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            isVerified ? Icons.check_circle : Icons.mark_email_unread,
            size: iconSize,
            color: isVerified
                ? AppColors.success // Updated
                : AppColors.primaryLight, // Updated
          ),
        ),
      ),
    );
  }
}
