import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart'; // Updated import
import '../constants/verification_strings.dart';

class VerificationHeaderComponent extends StatelessWidget {
  final double topPadding;

  const VerificationHeaderComponent({
    Key? key,
    this.topPadding = 40,
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
                context.colorPrimaryDark, // استخدام Extension
                context.colorPrimaryLight.withOpacity(0.9), // استخدام Extension
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ).createShader(bounds),
            child: Text(
              VerificationStrings.verificationTitle,
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
                Icons.email_outlined,
                color:
                    context.colorAccent.withOpacity(0.7), // استخدام Extension
                size: subtitleSize + 2,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  VerificationStrings.verificationSent,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: context.colorTextHint, // استخدام Extension
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
