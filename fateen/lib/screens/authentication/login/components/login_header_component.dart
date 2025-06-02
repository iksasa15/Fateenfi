import 'package:flutter/material.dart';
import '../../shared/constants/auth_colors.dart';
import '../constants/login_strings.dart';
import '../../signup/constants/signup_dimensions.dart'; // استخدام نفس الأبعاد من signup

class LoginHeaderComponent extends StatefulWidget {
  const LoginHeaderComponent({Key? key}) : super(key: key);

  @override
  State<LoginHeaderComponent> createState() => _LoginHeaderComponentState();
}

class _LoginHeaderComponentState extends State<LoginHeaderComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على حجم الشاشة للتصميم المتجاوب
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    // استخدام نفس هيكل الهوامش تمامًا كما في signup_header_component
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
                AuthColors.darkPurple,
                AuthColors.mediumPurple.withOpacity(0.9),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ).createShader(bounds),
            child: Text(
              LoginStrings.loginTitle,
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
              // أيقونة ترحيبية متحركة
              AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _waveAnimation.value * 0.2,
                    child: Icon(
                      Icons.waving_hand_rounded,
                      color: AuthColors.accentColor.withOpacity(0.7),
                      size: SignupDimensions.getSubtitleFontSize(context,
                              small: isSmallScreen) +
                          2,
                    ),
                  );
                },
              ),
              SizedBox(
                  width: SignupDimensions.getSpacing(context,
                          size: SpacingSize.small) /
                      2),
              Expanded(
                child: Text(
                  LoginStrings.formInfoText,
                  style: TextStyle(
                    fontSize: SignupDimensions.getSubtitleFontSize(context,
                        small: isSmallScreen),
                    color: AuthColors.hintColor,
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
