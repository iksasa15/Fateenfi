import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart'; // Updated import
import '../constants/reset_password_strings.dart';

class BackButtonComponent extends StatelessWidget {
  final VoidCallback onPressed;

  const BackButtonComponent({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تحديد أحجام العناصر
    final fontSize = isTablet ? 16.0 : (isSmallScreen ? 13.0 : 14.0);
    final iconSize = isTablet ? 22.0 : (isSmallScreen ? 18.0 : 20.0);

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.arrow_back,
        color: AppColors.primaryDark, // Updated
        size: iconSize,
      ),
      label: Text(
        ResetPasswordStrings.backToLoginText,
        style: TextStyle(
          color: AppColors.primaryDark, // Updated
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
