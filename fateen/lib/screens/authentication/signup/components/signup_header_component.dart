import 'package:flutter/material.dart';
import '../constants/signup_colors.dart';
import '../constants/signup_strings.dart';
import '../constants/signup_dimensions.dart';

class SignupHeaderComponent extends StatelessWidget {
  const SignupHeaderComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الحصول على حجم الشاشة للتصميم المتجاوب
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام والهوامش حسب حجم الشاشة
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    final titleSize = isTablet
        ? SignupDimensions.titleFontSize + 4
        : (isSmallScreen
            ? SignupDimensions.smallTitleFontSize
            : SignupDimensions.titleFontSize);
    final subtitleSize = isTablet
        ? SignupDimensions.subtitleFontSize + 2
        : (isSmallScreen
            ? SignupDimensions.smallSubtitleFontSize
            : SignupDimensions.subtitleFontSize);

    return Container(
      padding:
          EdgeInsets.fromLTRB(horizontalPadding, 40, horizontalPadding, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان مع تأثير تدرج لوني خفيف
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                SignupColors.darkPurple,
                SignupColors.mediumPurple.withOpacity(0.9),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ).createShader(bounds),
            child: Text(
              SignupStrings.signupTitle,
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
                Icons.app_registration_rounded,
                color: SignupColors.accentColor.withOpacity(0.7),
                size: subtitleSize + 2,
              ),
              const SizedBox(width: 8),
              Text(
                SignupStrings.formInfoText,
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: SignupColors.hintColor,
                  fontFamily: 'SYMBIOAR+LT',
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
