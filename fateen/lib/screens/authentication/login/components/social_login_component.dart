import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/login_colors.dart';
import '../constants/login_strings.dart';
import '../constants/login_dimensions.dart';

class SocialLoginComponent extends StatelessWidget {
  const SocialLoginComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: LoginDimensions.getSpacing(context, size: SpacingSize.medium),
      ),
      child: Column(
        children: [
          // أزرار وسائل التواصل الاجتماعي (دون النص في الأعلى)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                context: context,
                icon: 'assets/icons/google_icon.png',
                label: LoginStrings.googleLogin,
                onTap: () {
                  // تنفيذ تسجيل الدخول بحساب جوجل
                  HapticFeedback.mediumImpact();
                },
              ),
              SizedBox(
                  width: LoginDimensions.getSpacing(context,
                      size: SpacingSize.medium)),
              _buildSocialButton(
                context: context,
                icon: 'assets/icons/facebook_icon.png',
                label: LoginStrings.facebookLogin,
                onTap: () {
                  // تنفيذ تسجيل الدخول بحساب فيسبوك
                  HapticFeedback.mediumImpact();
                },
              ),
              SizedBox(
                  width: LoginDimensions.getSpacing(context,
                      size: SpacingSize.medium)),
              _buildSocialButton(
                context: context,
                icon: 'assets/icons/apple_icon.png',
                label: LoginStrings.appleLogin,
                onTap: () {
                  // تنفيذ تسجيل الدخول بحساب آبل
                  HapticFeedback.mediumImpact();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(LoginDimensions.getMediumRadius(context)),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(
              LoginDimensions.getSpacing(context, size: SpacingSize.small)),
          child: Column(
            children: [
              Image.asset(
                icon,
                width: LoginDimensions.getSocialButtonSize(context,
                        small: isSmallScreen) *
                    0.6,
                height: LoginDimensions.getSocialButtonSize(context,
                        small: isSmallScreen) *
                    0.6,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: LoginColors.textColor,
                  fontSize:
                      LoginDimensions.getLabelFontSize(context, small: true),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
