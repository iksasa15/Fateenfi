import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart';
import '../constants/login_dimensions.dart';

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
    // استخدام دوال الأبعاد الجديدة
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

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
                    LoginDimensions.getSpacing(context,
                        size: SpacingSize.large),
                    0,
                    LoginDimensions.getSpacing(context,
                        size: SpacingSize.large),
                    LoginDimensions.getSpacing(context,
                        size: SpacingSize.small)),
                padding: EdgeInsets.all(LoginDimensions.getSpacing(context,
                    size: SpacingSize.small)),
                decoration: BoxDecoration(
                  color: context.colorAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(
                      LoginDimensions.getMediumRadius(context)),
                  border: Border.all(
                    color: context.colorAccent.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorAccent.withOpacity(0.05),
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
                      padding: EdgeInsets.all(LoginDimensions.getSpacing(
                              context,
                              size: SpacingSize.small) /
                          2),
                      decoration: BoxDecoration(
                        color: context.colorAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: context.colorAccent,
                        size: isSmallScreen
                            ? LoginDimensions.getIconSize(context, small: true)
                            : LoginDimensions.getIconSize(context),
                      ),
                    ),
                    SizedBox(
                        width: LoginDimensions.getSpacing(context,
                            size: SpacingSize.small)),
                    Expanded(
                      child: Text(
                        widget.errorMessage,
                        style: TextStyle(
                          color: context.colorAccent,
                          fontSize: LoginDimensions.getBodyFontSize(context,
                              small: isSmallScreen),
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
