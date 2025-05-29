import 'package:flutter/material.dart';

class WhiteboardColors {
  // الألوان الرئيسية
  static const Color kDarkPurple = Color(0xFF221291);
  static const Color kMediumPurple = Color(0xFF6C63FF);
  static const Color kLightPurple = Color(0xFFF6F4FF);
  static const Color kAccentColor = Color(0xFFFF6B6B);
  static const Color kBackgroundColor = Color(0xFFFAFAFF);
  static const Color kShadowColor = Color(0x0D221291);

  // ألوان الرسم المتاحة
  static const List<Color> drawingColors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  // الحصول على اللون المناسب للوضع الداكن
  static Color getDarkModeColor(
      bool isDarkMode, Color lightModeColor, Color darkModeColor) {
    return isDarkMode ? darkModeColor : lightModeColor;
  }

  // الحصول على لون النص المناسب للوضع الداكن
  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : kDarkPurple;
  }

  // الحصول على لون الخلفية المناسب للوضع الداكن
  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF121212) : kBackgroundColor;
  }

  // الحصول على لون الخلفية الثانوية المناسب للوضع الداكن
  static Color getSecondaryBackgroundColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey[850]! : kLightPurple;
  }
}
