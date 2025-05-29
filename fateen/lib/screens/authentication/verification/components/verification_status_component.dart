import 'package:flutter/material.dart';
import '../constants/verification_colors.dart';
import '../constants/verification_strings.dart';

class VerificationStatusComponent extends StatelessWidget {
  final bool isVerified;

  const VerificationStatusComponent({
    Key? key,
    required this.isVerified,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل حجم الخط حسب حجم الشاشة
    final titleSize = isTablet ? 24.0 : (isSmallScreen ? 20.0 : 22.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          isVerified
              ? VerificationStrings.verificationComplete
              : VerificationStrings.verificationSent,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: VerificationColors.darkPurple,
            fontFamily: 'SYMBIOAR+LT',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
