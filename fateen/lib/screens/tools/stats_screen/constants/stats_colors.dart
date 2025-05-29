// constants/stats_colors.dart

import 'package:flutter/material.dart';

class StatsColors {
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kAccentColor = Color(0xFFEC4899);

  // قائمة ألوان للمخطط الدائري
  static const List<Color> pieChartColors = [
    Color(0xFFFF6B6B), // أحمر
    Color(0xFFFFB36B), // برتقالي
    Color(0xFFFFE66B), // أصفر
    Color(0xFF6BE0A1), // أخضر فاتح
    Color(0xFF6B9FFF), // أزرق
  ];

  // نحصل على لون حالة الدرجة
  static Color getGradeStatusColor(double gradeValue) {
    if (gradeValue >= 90) {
      return Colors.amber; // ذهبي
    } else if (gradeValue >= 80) {
      return Colors.green; // أخضر
    } else if (gradeValue >= 70) {
      return Colors.blue; // أزرق
    } else if (gradeValue >= 60) {
      return Colors.orange; // برتقالي
    } else {
      return Colors.red; // أحمر
    }
  }
}
