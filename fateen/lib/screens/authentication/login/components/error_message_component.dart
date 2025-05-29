import 'package:flutter/material.dart';
import '../constants/login_colors.dart';
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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام والهوامش حسب حجم الشاشة
    final horizontalPadding = isSmallScreen ? 24.0 : 32.0;
    final fontSize = isTablet ? 15.0 : (isSmallScreen ? 12.0 : 14.0);
    final iconSize = isTablet ? 22.0 : (isSmallScreen ? 18.0 : 20.0);
    final padding = isTablet ? 14.0 : (isSmallScreen ? 10.0 : 12.0);

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        ).animate(_animation),
        child: Container(
          margin:
              EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: LoginColors.accentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: LoginColors.accentColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: LoginColors.accentColor.withOpacity(0.05),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: LoginColors.accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: LoginColors.accentColor,
                  size: iconSize,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.errorMessage,
                  style: TextStyle(
                    color: LoginColors.accentColor,
                    fontSize: fontSize,
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
    );
  }
}
