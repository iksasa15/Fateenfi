import 'package:flutter/material.dart';
import '../constants/signup_colors.dart';
import '../constants/signup_strings.dart';
import '../constants/signup_dimensions.dart';

class SignupButtonComponent extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const SignupButtonComponent({
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
        ? SignupDimensions.buttonFontSize + 2
        : (isSmallScreen
            ? SignupDimensions.smallButtonFontSize
            : SignupDimensions.buttonFontSize);
    final buttonHeight = isSmallScreen
        ? SignupDimensions.smallButtonHeight
        : SignupDimensions.buttonHeight;
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
              color: SignupColors.darkPurple.withOpacity(0.3),
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
                    SignupColors.mediumPurple,
                    SignupColors.darkPurple,
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
                        child: Text(
                          SignupStrings.signupButtonText,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'SYMBIOAR+LT',
                            letterSpacing: 0.5,
                          ),
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
