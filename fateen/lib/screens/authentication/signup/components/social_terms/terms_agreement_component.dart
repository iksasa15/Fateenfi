import 'package:flutter/material.dart';
import '../../../../../core/constants/appColor.dart'; // Updated import
import '../../constants/signup_strings.dart';
import '../../../../../core/constants/app_dimensions.dart';

class TermsAgreementComponent extends StatefulWidget {
  final VoidCallback onTap;

  const TermsAgreementComponent({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<TermsAgreementComponent> createState() =>
      _TermsAgreementComponentState();
}

class _TermsAgreementComponentState extends State<TermsAgreementComponent>
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
    final isTablet = MediaQuery.of(context).size.width > 600;
    final fontSize = isTablet ? 15.0 : (isSmallScreen ? 12.0 : 13.0);

    final horizontalPadding = isSmallScreen ? 24.0 : 32.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Container(
          margin:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                SignupStrings.termsAgreementText,
                style: TextStyle(
                  color: context.colorTextHint, // استخدام Extension
                  fontSize: fontSize,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              MouseRegion(
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
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? context.colorPrimaryPale
                                .withOpacity(0.3) // استخدام Extension
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                      ),
                      child: Text(
                        SignupStrings.termsText,
                        style: TextStyle(
                          color: context.colorPrimaryDark, // استخدام Extension
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          fontFamily: 'SYMBIOAR+LT',
                          decoration: _isHovered
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          decorationColor:
                              context.colorPrimaryLight, // استخدام Extension
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
