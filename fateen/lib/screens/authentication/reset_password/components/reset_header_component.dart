import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart'; // Updated import
import '../constants/reset_password_strings.dart';

class ResetHeaderComponent extends StatelessWidget {
  final double topPadding;

  const ResetHeaderComponent({
    Key? key,
    required this.topPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام والهوامش حسب حجم الشاشة
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    final titleSize = isTablet ? 28.0 : (isSmallScreen ? 24.0 : 26.0);
    final subtitleSize = isTablet ? 16.0 : (isSmallScreen ? 14.0 : 15.0);

    return Container(
      padding: EdgeInsets.fromLTRB(
          horizontalPadding, topPadding, horizontalPadding, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان مع تأثير تدرج لوني خفيف
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.primaryDark, // Updated
                AppColors.primaryLight.withOpacity(0.9), // Updated
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ).createShader(bounds),
            child: Text(
              ResetPasswordStrings.resetTitle,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white, // ستتغير بسبب الماسك
                fontFamily: 'SYMBIOAR+LT',
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // أيقونة ترحيبية لطيفة
              Icon(
                Icons.lock_reset_rounded,
                color: AppColors.accent.withOpacity(0.7), // Updated
                size: subtitleSize + 2,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ResetPasswordStrings.resetSubtitle,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: AppColors.textHint, // Updated
                    fontFamily: 'SYMBIOAR+LT',
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
