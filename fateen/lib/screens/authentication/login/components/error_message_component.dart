import 'package:flutter/material.dart';
import '../../shared/constants/auth_colors.dart';

class ErrorMessageComponent extends StatefulWidget {
  final String errorMessage;

  const ErrorMessageComponent({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  @override
  State<ErrorMessageComponent> createState() => _ErrorMessageComponentState();
}

class _ErrorMessageComponentState extends State<ErrorMessageComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: -0.1), weight: 2),
      TweenSequenceItem(
          tween: Tween<double>(begin: -0.1, end: 0.05), weight: 2),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.05, end: -0.05), weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: -0.05, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _controller.forward();
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
    final fontSize = isTablet
        ? screenWidth * 0.025
        : (isSmallScreen
            ? screenWidth * 0.033
            : screenWidth * 0.039); // نسبة من عرض الشاشة
    final iconSize = isTablet
        ? screenWidth * 0.037
        : (isSmallScreen
            ? screenWidth * 0.05
            : screenWidth * 0.055); // نسبة من عرض الشاشة
    final padding = isTablet
        ? screenWidth * 0.023
        : (isSmallScreen
            ? screenWidth * 0.028
            : screenWidth * 0.033); // نسبة من عرض الشاشة

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Transform.translate(
            offset: Offset(_shakeAnimation.value * 10, 0),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                margin: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    screenHeight * 0.02), // 2% من ارتفاع الشاشة
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: AuthColors.accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(
                      screenWidth * 0.04), // 4% من عرض الشاشة
                  border: Border.all(
                    color: AuthColors.accentColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AuthColors.accentColor.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                          screenWidth * 0.015), // 1.5% من عرض الشاشة
                      decoration: BoxDecoration(
                        color: AuthColors.accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: AuthColors.accentColor,
                        size: iconSize,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03), // 3% من عرض الشاشة
                    Expanded(
                      child: Text(
                        widget.errorMessage,
                        style: TextStyle(
                          color: AuthColors.accentColor,
                          fontSize: fontSize,
                          fontFamily: 'SYMBIOAR+LT',
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
