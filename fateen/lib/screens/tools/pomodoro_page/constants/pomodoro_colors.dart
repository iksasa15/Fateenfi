import 'package:flutter/material.dart';

class PomodoroColors {
  // ألوان متماشية مع تصميم صفحة المقررات
  static const Color kDarkPurple = Color(0xFF221291);
  static const Color kMediumPurple = Color(0xFF4338CA);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kAccentColor = Color(0xFFFF6B6B);
  static const Color kGreenColor = Color(0xFF4CAF50);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);
  static const Color kDividerColor = Color(0xFFEEEEF0);

  // تعيين لون للمؤقت بناءً على النوع
  static Color getTimerColor(
      {required bool isBreakTime, bool isLongBreak = false}) {
    if (isBreakTime) {
      return isLongBreak ? kGreenColor : kDarkPurple;
    } else {
      return kAccentColor;
    }
  }

  // الألوان حسب حالة الدرجة
  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF121212) : kBackgroundColor;
  }

  static Color getCardBackgroundColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  }

  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : kDarkPurple;
  }

  static Color? getSubTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white70 : Colors.grey[600];
  }

  static Color getDarkBackgroundColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey[850]! : kLightPurple.withOpacity(0.1);
  }

  static Color getBorderColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey[800]! : kLightPurple;
  }
}
