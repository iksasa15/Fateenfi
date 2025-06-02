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
        final isSmallScreen = MediaQuery.of(context).size.width < 360;

        // حساب العرض المناسب للزر
        final buttonWidth = constraints.maxWidth -
            (SignupDimensions.getSpacing(context, size: SpacingSize.large) * 2);

        return Padding(
          padding: EdgeInsets.fromLTRB(
              SignupDimensions.getSpacing(context, size: SpacingSize.large),
              SignupDimensions.getSpacing(context, size: SpacingSize.small),
              SignupDimensions.getSpacing(context, size: SpacingSize.large),
              SignupDimensions.getSpacing(context, size: SpacingSize.large)),
          child: Container(
            width: buttonWidth,
            height:
                SignupDimensions.getButtonHeight(context, small: isSmallScreen),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  SignupDimensions.getLargeRadius(context)),
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
                borderRadius: BorderRadius.circular(
                    SignupDimensions.getLargeRadius(context)),
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
                    borderRadius: BorderRadius.circular(
                        SignupDimensions.getLargeRadius(context)),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: isLoading
                        ? Center(
                            key: const ValueKey('loading'),
                            child: SizedBox(
                              width: SignupDimensions.getIconSize(context,
                                  small: isSmallScreen),
                              height: SignupDimensions.getIconSize(context,
                                  small: isSmallScreen),
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
                                    fontSize:
                                        SignupDimensions.getButtonFontSize(
                                            context,
                                            small: isSmallScreen),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'SYMBIOAR+LT',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(
                                    width: SignupDimensions.getSpacing(context,
                                        size: SpacingSize.small)),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: SignupDimensions.getButtonFontSize(
                                          context,
                                          small: isSmallScreen) *
                                      0.8,
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
