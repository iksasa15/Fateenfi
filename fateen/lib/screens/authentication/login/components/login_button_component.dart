import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/appColor.dart';
import '../constants/login_strings.dart';
import '../constants/login_dimensions.dart';

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

class _LoginButtonComponentState extends State<LoginButtonComponent> {
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        LoginDimensions.getSpacing(context, size: SpacingSize.large),
        LoginDimensions.getSpacing(context, size: SpacingSize.small),
        LoginDimensions.getSpacing(context, size: SpacingSize.large),
        LoginDimensions.getSpacing(context, size: SpacingSize.large),
      ),
      child: Container(
        width: double.infinity,
        height: LoginDimensions.getButtonHeight(context, small: isSmallScreen),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(LoginDimensions.getLargeRadius(context)),
          boxShadow: [
            BoxShadow(
              color: AuthColors.darkPurple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading
                ? null // تعطيل الزر أثناء التحميل
                : () {
                    HapticFeedback.mediumImpact();
                    if (widget.onPressed != null) {
                      debugPrint('تم النقر على زر تسجيل الدخول');
                      widget.onPressed!();
                    }
                  },
            borderRadius:
                BorderRadius.circular(LoginDimensions.getLargeRadius(context)),
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    widget.isLoading
                        ? AuthColors.mediumPurple.withOpacity(0.8)
                        : AuthColors.mediumPurple,
                    widget.isLoading
                        ? AuthColors.darkPurple.withOpacity(0.8)
                        : AuthColors.darkPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(
                    LoginDimensions.getLargeRadius(context)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: widget.isLoading
                    ? Center(
                        key: const ValueKey('loading'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'جاري تسجيل الدخول...',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'SYMBIOAR+LT',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        key: const ValueKey('normal'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              LoginStrings.loginButtonText,
                              style: TextStyle(
                                fontSize: LoginDimensions.getButtonFontSize(
                                    context,
                                    small: isSmallScreen),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'SYMBIOAR+LT',
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(
                                width: LoginDimensions.getSpacing(context,
                                    size: SpacingSize.small)),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: LoginDimensions.getButtonFontSize(context,
                                      small: isSmallScreen) +
                                  4,
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

  @override
  void didUpdateWidget(covariant LoginButtonComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // سجل التغييرات في حالة التحميل للتأكد من أن التغييرات تحدث بشكل صحيح
    if (oldWidget.isLoading != widget.isLoading) {
      debugPrint('تغيير حالة زر تسجيل الدخول: ${widget.isLoading}');
    }
  }
}
