import 'package:flutter/material.dart';
import '../constants/login_colors.dart';
import '../constants/login_strings.dart';
import '../constants/login_dimensions.dart';

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
    extends State<ForgotPasswordLinkComponent> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // الحصول على حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام والهوامش حسب حجم الشاشة
    final horizontalPadding = isSmallScreen ? 24.0 : 32.0;
    final fontSize = isTablet ? 15.0 : (isSmallScreen ? 12.0 : 14.0);
    final bottomMargin = isSmallScreen ? 24.0 : 28.0;

    return Container(
      margin: EdgeInsets.fromLTRB(
          horizontalPadding, 0, horizontalPadding, bottomMargin),
      child: Align(
        alignment: Alignment.centerRight, // تغيير المحاذاة إلى اليمين
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isHovered
                    ? LoginColors.lightPurple.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(LoginDimensions.mediumRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LoginStrings.forgotPasswordText,
                    style: TextStyle(
                      color: LoginColors.darkPurple,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SYMBIOAR+LT',
                      decoration: _isHovered
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: LoginColors.darkPurple,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.lock_reset_rounded,
                    color: LoginColors.darkPurple,
                    size: fontSize + 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
