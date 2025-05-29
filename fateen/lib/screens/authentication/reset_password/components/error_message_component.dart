import 'package:flutter/material.dart';
import '../constants/reset_password_colors.dart';

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

    // تحديد أحجام العناصر
    final fontSize = isTablet ? 14.0 : (isSmallScreen ? 12.0 : 13.0);
    final iconSize = isTablet ? 20.0 : (isSmallScreen ? 16.0 : 18.0);
    final padding = isTablet ? 16.0 : (isSmallScreen ? 10.0 : 12.0);

    return Container(
      padding: EdgeInsets.all(padding),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ResetPasswordColors.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: ResetPasswordColors.accentColor,
            size: iconSize,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: ResetPasswordColors.accentColor,
                fontSize: fontSize,
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
