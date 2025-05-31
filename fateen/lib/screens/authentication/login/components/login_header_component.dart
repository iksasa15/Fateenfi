import 'package:flutter/material.dart';
import '../../shared/constants/auth_colors.dart';
import '../constants/login_strings.dart';

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
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ضبط القيم بناءً على حجم الشاشة
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // حساب الأبعاد كنسبة من حجم الشاشة
    final horizontalPadding = screenWidth * 0.06; // 6% من عرض الشاشة
    final topPadding = screenHeight * 0.05; // 5% من ارتفاع الشاشة
    final bottomPadding = screenHeight * 0.02; // 2% من ارتفاع الشاشة

    final titleSize = isTablet
        ? screenWidth * 0.05
        : (isSmallScreen
            ? screenWidth * 0.067
            : screenWidth * 0.078); // نسبة من عرض الشاشة
    final subtitleSize = isTablet
        ? screenWidth * 0.03
        : (isSmallScreen
            ? screenWidth * 0.039
            : screenWidth * 0.044); // نسبة من عرض الشاشة

    return Container(
      padding: EdgeInsets.fromLTRB(
          horizontalPadding, topPadding, horizontalPadding, bottomPadding),
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
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white, // ستتغير بسبب الماسك
                fontFamily: 'SYMBIOAR+LT',
                letterSpacing: 0.3,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.015), // 1.5% من ارتفاع الشاشة
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
                      size: subtitleSize + 2,
                    ),
                  );
                },
              ),
              SizedBox(width: screenWidth * 0.02), // 2% من عرض الشاشة
              Expanded(
                // إضافة Expanded لضمان أن النص لا يتجاوز العرض المتاح
                child: Text(
                  LoginStrings.formInfoText,
                  style: TextStyle(
                    fontSize: subtitleSize,
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
