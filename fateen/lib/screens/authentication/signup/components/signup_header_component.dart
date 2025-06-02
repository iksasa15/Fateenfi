import 'package:flutter/material.dart';
import '../constants/signup_colors.dart';
import '../constants/signup_strings.dart';
import '../constants/signup_dimensions.dart';

class SignupHeaderComponent extends StatelessWidget {
  const SignupHeaderComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الحصول على حجم الشاشة للتصميم المتجاوب
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.fromLTRB(
          SignupDimensions.getSpacing(context, size: SpacingSize.large),
          SignupDimensions.getSpacing(context, size: SpacingSize.extraLarge) +
              8,
          SignupDimensions.getSpacing(context, size: SpacingSize.large),
          SignupDimensions.getSpacing(context, size: SpacingSize.medium)),
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
                fontSize: SignupDimensions.getTitleFontSize(context,
                    small: isSmallScreen),
                fontWeight: FontWeight.bold,
                color: Colors.white, // ستتغير بسبب الماسك
                fontFamily: 'SYMBIOAR+LT',
                letterSpacing: 0.3,
              ),
            ),
          ),
          SizedBox(
              height: SignupDimensions.getSpacing(context,
                  size: SpacingSize.small)),
          Row(
            children: [
              // أيقونة ترحيبية لطيفة
              Icon(
                Icons.app_registration_rounded,
                color: SignupColors.accentColor.withOpacity(0.7),
                size: SignupDimensions.getSubtitleFontSize(context,
                        small: isSmallScreen) +
                    2,
              ),
              SizedBox(
                  width: SignupDimensions.getSpacing(context,
                          size: SpacingSize.small) /
                      2),
              Text(
                SignupStrings.formInfoText,
                style: TextStyle(
                  fontSize: SignupDimensions.getSubtitleFontSize(context,
                      small: isSmallScreen),
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
