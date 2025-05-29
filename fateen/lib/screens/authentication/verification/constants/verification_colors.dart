import 'package:flutter/material.dart';

class VerificationColors {
  // الألوان الثابتة
  static const Color darkPurple = Color(0xFF4338CA);
  static const Color mediumPurple = Color(0xFF6366F1);
  static const Color lightPurple = Color(0xFFF5F3FF);
  static const Color accentColor = Color(0xFFEC4899);
  static const Color backgroundColor = Color(0xFFFDFDFF);
  static const Color shadowColor = Color(0x0D221291);
  static const Color textColor = Color(0xFF374151);
  static const Color hintColor = Color(0xFF9CA3AF);
  static const Color successColor = Color(0xFF22C55E);

  // الألوان الأساسية
  static const Color primaryColor = Color(0xFF6A2FEC);

  // تدرجات البنفسجي
  static const Color paleViolet = Color(0xFFEEE6FF);

  // ألوان الخلفية
  static const Color surfaceColor = Color(0xFFF8F8F8);

  // ألوان النص
  static const Color textPrimaryColor = Color(0xFF333333);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textTertiaryColor = Color(0xFFAAAAAA);

  // ألوان حالة التحقق
  static const Color verifiedColor = Color(0xFF4CAF50);
  static const Color unverifiedColor = Color(0xFFE64646);
  static const Color pendingColor = Color(0xFFFF9800);

  // ألوان الحدود والفواصل
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFEEEEEE);

  // ألوان الزر
  static const Color buttonTextColor = Colors.white;
  static const Color secondaryButtonTextColor = Color(0xFF6A2FEC);
  static const Color buttonDisabledColor = Color(0xFFDDDDDD);

  // تدرجات البنفسجي للخلفية
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8753F7),
      Color(0xFF6A2FEC),
    ],
  );
}
