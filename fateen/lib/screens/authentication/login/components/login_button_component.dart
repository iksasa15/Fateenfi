import 'package:flutter/material.dart';
import '../constants/login_colors.dart';
import '../constants/login_strings.dart';
import '../constants/login_dimensions.dart';

class LoginButtonComponent extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const LoginButtonComponent({
    Key? key,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الحصول على حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام والهوامش حسب حجم الشاشة
    final horizontalPadding = isSmallScreen ? 24.0 : 32.0;
    final fontSize = isTablet
        ? LoginDimensions.buttonFontSize + 2
        : (isSmallScreen
            ? LoginDimensions.smallButtonFontSize
            : LoginDimensions.buttonFontSize);
    final buttonHeight = isSmallScreen
        ? LoginDimensions.smallButtonHeight
        : LoginDimensions.defaultButtonHeight;
    final loaderSize = isSmallScreen ? 20.0 : 24.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 24),
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: LoginColors.darkPurple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    LoginColors.mediumPurple,
                    LoginColors.darkPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: isLoading
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
                            const SizedBox(width: 8),
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
  }
}
