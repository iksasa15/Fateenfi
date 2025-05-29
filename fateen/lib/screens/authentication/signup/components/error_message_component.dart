import 'package:flutter/material.dart';
import '../constants/signup_colors.dart';

class ErrorMessageComponent extends StatelessWidget {
  final String errorMessage;

  const ErrorMessageComponent({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    final horizontalPadding = isSmallScreen ? 24.0 : 32.0;
    final fontSize = isTablet ? 15.0 : (isSmallScreen ? 12.0 : 14.0);
    final iconSize = isTablet ? 22.0 : (isSmallScreen ? 18.0 : 20.0);
    final padding = isTablet ? 14.0 : (isSmallScreen ? 10.0 : 12.0);

    return Container(
      margin: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: SignupColors.accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SignupColors.accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: SignupColors.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: SignupColors.accentColor,
              size: iconSize,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: SignupColors.accentColor,
                fontSize: fontSize,
                fontFamily: 'SYMBIOAR+LT',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
