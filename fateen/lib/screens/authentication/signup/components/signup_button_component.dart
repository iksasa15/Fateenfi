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
    // استخدام LayoutBuilder للحصول على قيود الحاوية
    return LayoutBuilder(
      builder: (context, constraints) {
        // الحصول على أبعاد الشاشة
        final size = MediaQuery.of(context).size;
        final screenWidth = size.width;
        final screenHeight = size.height;

        final isSmallScreen = screenWidth < 360;
        final isTablet = screenWidth > 600;

        // تعديل الأحجام والهوامش حسب حجم الشاشة بنسبة مئوية
        final horizontalPadding = screenWidth * 0.06;
        final fontSize = isTablet
            ? screenWidth * 0.03
            : (isSmallScreen ? screenWidth * 0.04 : screenWidth * 0.035);

        final buttonHeight =
            isSmallScreen ? screenHeight * 0.064 : screenHeight * 0.07;

        final loaderSize =
            isSmallScreen ? screenWidth * 0.055 : screenWidth * 0.05;

        // حساب العرض المناسب للزر
        final buttonWidth = constraints.maxWidth - (horizontalPadding * 2);

        return Padding(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 24),
          child: Container(
            width: buttonWidth,
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
                            key: const ValueKey('loading'),
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
                            key: const ValueKey('text'),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  SignupStrings.signupButtonText,
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
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: fontSize * 0.8,
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
    );
  }
}
