// constants/translation_colors.dart

import 'package:flutter/material.dart';

class TranslationColors {
  // تغيير الألوان لتتطابق مع تصميم وقت المذاكرة
  static const Color kDarkPurple = Color(0xFF221291);
  static const Color kMediumPurple = Color(0xFF4338CA);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kAccentColor = Color(0xFF4338CA);
  static const Color kGreenColor = Color(0xFF4CAF50);
  static const Color kBorderColor = Color(0xFFE3E0F8);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);
  static const Color kCardBackgroundColor = Colors.white;
  static const Color kErrorColor = Color(0xFFFF6B6B);
  static const Color kSuccessColor = Color(0xFF4CAF50);

  // تظليل للألوان
  static Color kLightPurpleShade = kLightPurple.withOpacity(0.5);
  static Color kLightPurpleShade2 = kLightPurple.withOpacity(0.3);
  static Color kBorderShade = kBorderColor.withOpacity(0.8);
  static Color kErrorShade = kErrorColor.withOpacity(0.1);

  static BoxShadow kShadow = BoxShadow(
    color: Colors.black.withOpacity(0.06),
    spreadRadius: 1,
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
}
