import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart'; // Updated import
import '../constants/verification_strings.dart';

class VerificationFooterComponent extends StatelessWidget {
  final VoidCallback onLoginPress;

  const VerificationFooterComponent({
    Key? key,
    required this.onLoginPress,
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
      onPressed: onLoginPress,
      icon: Icon(
        Icons.arrow_back,
        color: context.colorPrimaryDark, // استخدام Extension
        size: iconSize,
      ),
      label: Text(
        VerificationStrings.verificationBackToLogin,
        style: TextStyle(
          color: context.colorPrimaryDark, // استخدام Extension
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
