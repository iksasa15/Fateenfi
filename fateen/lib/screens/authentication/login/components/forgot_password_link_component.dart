import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/constants/auth_colors.dart';
import '../constants/login_strings.dart';

class ForgotPasswordLinkComponent extends StatefulWidget {
  final VoidCallback onPressed;

  const ForgotPasswordLinkComponent({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<ForgotPasswordLinkComponent> createState() =>
      _ForgotPasswordLinkComponentState();
}

class _ForgotPasswordLinkComponentState
    extends State<ForgotPasswordLinkComponent>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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

    // حساب الهوامش والأبعاد كنسبة من حجم الشاشة
    final horizontalPadding = screenWidth * 0.06; // 6% من عرض الشاشة
    final fontSize = isTablet
        ? screenWidth * 0.025
        : (isSmallScreen
            ? screenWidth * 0.033
            : screenWidth * 0.039); // نسبة من عرض الشاشة
    final bottomMargin = isSmallScreen
        ? screenHeight * 0.03
        : screenHeight * 0.035; // نسبة من ارتفاع الشاشة

    return Container(
      margin: EdgeInsets.fromLTRB(
          horizontalPadding, 0, horizontalPadding, bottomMargin),
      child: Align(
        alignment: Alignment.centerRight, // تغيير المحاذاة إلى اليمين
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _controller.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _controller.reverse();
          },
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onPressed();
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025, // 2.5% من عرض الشاشة
                      vertical: screenHeight * 0.008, // 0.8% من ارتفاع الشاشة
                    ),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? AuthColors.lightPurple.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                          screenWidth * 0.03), // 3% من عرض الشاشة
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          LoginStrings.forgotPasswordText,
                          style: TextStyle(
                            color: AuthColors.darkPurple,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'SYMBIOAR+LT',
                            decoration: _isHovered
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            decorationColor: AuthColors.darkPurple,
                          ),
                        ),
                        SizedBox(
                            width: screenWidth * 0.015), // 1.5% من عرض الشاشة
                        Icon(
                          Icons.lock_reset_rounded,
                          color: AuthColors.darkPurple,
                          size: fontSize + 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
