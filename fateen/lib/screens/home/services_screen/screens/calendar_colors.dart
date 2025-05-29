// constants/calendar_colors.dart

import 'package:flutter/material.dart';

class CalendarColors {
  // الألوان الأساسية
  static const Color kDarkPurple = Color(0xFF6E3CBC);
  static const Color kMediumPurple = Color(0xFF7267CB);
  static const Color kLightPurple = Color(0xFF8566FF);
  static const Color kAccentColor = Color(0xFF5DA3FA);

  // ألوان الخلفية والبطاقات
  static const Color kBackgroundColor = Color(0xFFF8F8FF);
  static const Color kCardBackground = Color(0xFFFEFEFE);
  static const Color kCardBorder = Color(0xFFE3E0F8);

  // ألوان النصوص
  static const Color kTextColor = Color(0xFF374151);
  static const Color kLightTextColor = Color(0xFF7D7D7D);

  // ألوان الحالات
  static const Color kRedColor = Color(0xFFFF6B6B);
  static const Color kOrangeColor = Color(0xFFFF9F69);
  static const Color kGreenColor = Color(0xFF4CAF50);
  static const Color kYellowColor = Color(0xFFFFC107);

  // دالة لاختيار لون حسب عدد الأيام المتبقية
  static Color getCountdownColor(int daysLeft) {
    if (daysLeft <= 1) {
      return kRedColor; // أحمر للمواعيد القريبة جداً
    } else if (daysLeft <= 3) {
      return kOrangeColor; // برتقالي للمواعيد القريبة
    } else if (daysLeft <= 7) {
      return kAccentColor; // أزرق للمواعيد خلال أسبوع
    } else {
      return kGreenColor; // أخضر للمواعيد البعيدة
    }
  }
}
