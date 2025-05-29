// lib/screens/tasks/constants/tasks_colors.dart

import 'package:flutter/material.dart';

class TasksColors {
  // ألوان التطبيق الرئيسية
  static const Color kDarkPurple = Color(0xFF221291);
  static const Color kMediumPurple = Color(0xFF6C63FF);
  static const Color kLightPurple = Color(0xFFF6F4FF);
  static const Color kAccentColor = Color(0xFFFF6B6B);
  static const Color kBorderColor = Color(0xFFE3E0F8);
  static const Color kGreenColor = Color(0xFF4CAF50);
  static const Color kYellowColor = Color(0xFFFFA726);
  static const Color kOrangeColor = Color(0xFFFF9800);

  // ألوان الأولويات
  static const Color kHighPriorityColor = Color(0xFFFF5252);
  static const Color kMediumPriorityColor = Color(0xFFFFB74D);
  static const Color kLowPriorityColor = Color(0xFF66BB6A);

  // ألوان لبطاقات المهام
  static const List<Color> taskColorOptions = [
    Color(0xFFF6F4FF), // بنفسجي فاتح
    Color(0xFFE1F5FE), // أزرق فاتح
    Color(0xFFE8F5E9), // أخضر فاتح
    Color(0xFFFFF9C4), // أصفر فاتح
    Color(0xFFFFCDD2), // أحمر فاتح
    Color(0xFFE1BEE7), // بنفسجي فاتح
    Color(0xFFFFE0B2), // برتقالي فاتح
    Color(0xFFD7CCC8), // بني فاتح
  ];

  // الحصول على لون الأولوية
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'عالية':
        return kHighPriorityColor;
      case 'متوسطة':
        return kMediumPriorityColor;
      case 'منخفضة':
        return kLowPriorityColor;
      default:
        return kMediumPriorityColor;
    }
  }

  // الحصول على لون الحالة
  static Color getStatusColor(String status) {
    switch (status) {
      case 'مكتملة':
        return kGreenColor;
      case 'قيد التنفيذ':
        return kMediumPurple;
      case 'متأخرة':
        return kAccentColor;
      default:
        return kMediumPurple;
    }
  }
}
