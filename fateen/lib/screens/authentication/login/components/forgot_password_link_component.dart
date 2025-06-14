import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/appColor.dart';
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
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: EdgeInsets.fromLTRB(
          LoginDimensions.getSpacing(context, size: SpacingSize.large),
          0,
          LoginDimensions.getSpacing(context, size: SpacingSize.large),
          LoginDimensions.getSpacing(context, size: SpacingSize.large) - 8),
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
                      horizontal: LoginDimensions.getSpacing(context,
                          size: SpacingSize.small),
                      vertical: LoginDimensions.getSpacing(context,
                              size: SpacingSize.small) /
                          2,
                    ),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? AppColors.lightPurple.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                          LoginDimensions.getMediumRadius(context)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          LoginStrings.forgotPasswordText,
                          style: TextStyle(
                            color: AppColors.darkPurple,
                            fontSize: LoginDimensions.getBodyFontSize(context,
                                small: isSmallScreen),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'SYMBIOAR+LT',
                            decoration: _isHovered
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            decorationColor: AppColors.darkPurple,
                          ),
                        ),
                        SizedBox(
                            width: LoginDimensions.getSpacing(context,
                                    size: SpacingSize.small) /
                                2),
                        Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.darkPurple,
                          size: LoginDimensions.getBodyFontSize(context,
                                  small: isSmallScreen) +
                              2,
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
