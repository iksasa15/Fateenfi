import 'package:flutter/material.dart';
import '../constants/login_colors.dart';
import '../constants/login_strings.dart';
import '../constants/login_dimensions.dart';

class LoginHeaderComponent extends StatelessWidget {
  const LoginHeaderComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الحصول على حجم الشاشة للتصميم المتجاوب
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام والهوامش حسب حجم الشاشة - مطابقة تمامًا لصفحة التسجيل
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    final titleSize = isTablet
        ? LoginDimensions.titleFontSize + 4
        : (isSmallScreen
            ? LoginDimensions.smallTitleFontSize
            : LoginDimensions.titleFontSize);
    final subtitleSize = isTablet
        ? LoginDimensions.subtitleFontSize + 2
        : (isSmallScreen
            ? LoginDimensions.smallSubtitleFontSize
            : LoginDimensions.subtitleFontSize);

    return Container(
      padding:
          EdgeInsets.fromLTRB(horizontalPadding, 40, horizontalPadding, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان مع تأثير تدرج لوني خفيف - نفس التنسيق الخاص بصفحة التسجيل
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                LoginColors.darkPurple,
                LoginColors.mediumPurple.withOpacity(0.9),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ).createShader(bounds),
            child: Text(
              LoginStrings.loginTitle,
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
                Icons.waving_hand_rounded,
                color: LoginColors.accentColor.withOpacity(0.7),
                size: subtitleSize + 2,
              ),
              const SizedBox(width: 8),
              Expanded(
                // إضافة Expanded لضمان أن النص لا يتجاوز العرض المتاح
                child: Text(
                  LoginStrings.formInfoText,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: LoginColors.hintColor,
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
