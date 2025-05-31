import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/constants/auth_colors.dart';
import '../constants/login_strings.dart';

class LoginButtonComponent extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const LoginButtonComponent({
    Key? key,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<LoginButtonComponent> createState() => _LoginButtonComponentState();
}

class _LoginButtonComponentState extends State<LoginButtonComponent>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
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
    final fontSize = isTablet ? 18.0 : (isSmallScreen ? 15.0 : 16.0);
    final buttonHeight = isSmallScreen
        ? screenHeight * 0.065
        : screenHeight * 0.075; // 6.5% أو 7.5% من ارتفاع الشاشة
    final loaderSize = isSmallScreen ? 20.0 : 24.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 24),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
          _controller.forward();
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isLoading ? 1.0 : _scaleAnimation.value,
              child: Container(
                width: double.infinity,
                height: buttonHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      screenWidth * 0.04), // 4% من عرض الشاشة
                  boxShadow: [
                    BoxShadow(
                      color: AuthColors.darkPurple
                          .withOpacity(_isHovered ? 0.4 : 0.3),
                      blurRadius: _isHovered ? 15 : 12,
                      offset: const Offset(0, 4),
                      spreadRadius: _isHovered ? 0 : -2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.isLoading
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            widget.onPressed?.call();
                          },
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    splashColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.05),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            AuthColors.mediumPurple,
                            AuthColors.darkPurple,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: widget.isLoading
                            ? Center(
                                child: SizedBox(
                                  width: loaderSize,
                                  height: loaderSize,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: isSmallScreen ? 2.0 : 2.5,
                                  ),
                                ),
                              )
                            : Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      LoginStrings.loginButtonText,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'SYMBIOAR+LT',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(
                                        width: screenWidth *
                                            0.02), // 2% من عرض الشاشة
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: fontSize + 4,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
