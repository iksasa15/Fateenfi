import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/appColor.dart';
import '../constants/auth_strings.dart';

enum AuthToggleMode {
  login,
  signup,
}

class AuthToggleBar extends StatefulWidget {
  final AuthToggleMode currentMode;
  final VoidCallback onLoginPressed;
  final VoidCallback onSignupPressed;

  const AuthToggleBar({
    Key? key,
    required this.currentMode,
    required this.onLoginPressed,
    required this.onSignupPressed,
  }) : super(key: key);

  @override
  State<AuthToggleBar> createState() => _AuthToggleBarState();
}

class _AuthToggleBarState extends State<AuthToggleBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<double> _scaleLogin;
  late final Animation<double> _scaleSignup;
  late final Animation<double> _rotationLogin;
  late final Animation<double> _rotationSignup;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      value: widget.currentMode == AuthToggleMode.signup ? 1.0 : 0.0,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeOutBack,
    );

    _scaleLogin = Tween<double>(begin: 1.05, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleSignup = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _rotationLogin = Tween<double>(begin: 0.01, end: -0.01).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _rotationSignup = Tween<double>(begin: -0.01, end: 0.01).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void didUpdateWidget(AuthToggleBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMode != widget.currentMode) {
      if (widget.currentMode == AuthToggleMode.login) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // دالة لحساب لون النص بناءً على قيمة الانيميشن
  Color _getTextColor(bool isLogin) {
    if (isLogin) {
      return Color.lerp(
              Colors.white, AppColors.textPrimary, _animation.value) ??
          Colors.white;
    } else {
      return Color.lerp(
              AppColors.textPrimary, Colors.white, _animation.value) ??
          AppColors.textPrimary;
    }
  }

  // دالة لإنشاء التدرج اللوني
  LinearGradient? _getGradient(bool isLogin) {
    if (isLogin) {
      return _animation.value < 0.5
          ? const LinearGradient(
              colors: [
                AppColors.primaryLight,
                AppColors.primaryDark,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          : null;
    } else {
      return _animation.value >= 0.5
          ? const LinearGradient(
              colors: [
                AppColors.primaryLight,
                AppColors.primaryDark,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          : null;
    }
  }

  // دالة لإنشاء ظل الحاوية
  List<BoxShadow>? _getShadow(bool isLogin) {
    if (isLogin) {
      return _animation.value < 0.5
          ? [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null;
    } else {
      return _animation.value >= 0.5
          ? [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null;
    }
  }

  // تطبيق تأثير حسي عند الضغط
  void _handleLoginPressed() {
    HapticFeedback.selectionClick();
    widget.onLoginPressed();
  }

  // تطبيق تأثير حسي عند الضغط
  void _handleSignupPressed() {
    HapticFeedback.selectionClick();
    widget.onSignupPressed();
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // تعديل الأحجام والهوامش حسب حجم الشاشة
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    final fontSize = isSmallScreen ? 14.0 : 15.0;
    final buttonHeight = isSmallScreen ? 45.0 : 50.0;

    return Container(
      margin: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 32),
      height: buttonHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            children: [
              // زر تسجيل الدخول
              Expanded(
                child: Transform.scale(
                  scale: _scaleLogin.value,
                  child: Transform.rotate(
                    angle: _rotationLogin.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _getGradient(true),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _getShadow(true),
                      ),
                      child: MaterialButton(
                        onPressed: _handleLoginPressed,
                        elevation: 0,
                        focusElevation: 0,
                        highlightElevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          AuthStrings.loginTitle,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: _getTextColor(true),
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // زر إنشاء حساب
              Expanded(
                child: Transform.scale(
                  scale: _scaleSignup.value,
                  child: Transform.rotate(
                    angle: _rotationSignup.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _getGradient(false),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _getShadow(false),
                      ),
                      child: MaterialButton(
                        onPressed: _handleSignupPressed,
                        elevation: 0,
                        highlightElevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          AuthStrings.signupTitle,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                            color: _getTextColor(false),
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
