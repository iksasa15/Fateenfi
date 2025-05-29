// constants/gpa_calculator_constants.dart

import 'package:flutter/material.dart';

class GPACalculatorConstants {
  // ألوان التطبيق الموحدة
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kAccentColor = Color(0xFFEC4899);
  static const Color kGreenColor = Color(0xFF4CAF50);

  // لون حدود البطاقات
  static const Color kBorderColor = Color(0xFFE3E0F8);

  // قائمة الدرجات والنقاط المقابلة لها (نظام 5.0)
  static const Map<String, double> gradePoints5 = {
    'A+': 5.0,
    'A': 4.75,
    'B+': 4.5,
    'B': 4.0,
    'C+': 3.5,
    'C': 3.0,
    'D+': 2.5,
    'D': 2.0,
    'F': 1.0,
  };

  // قائمة الدرجات والنقاط المقابلة لها (نظام 4.0)
  static const Map<String, double> gradePoints4 = {
    'A+': 4.0,
    'A': 4.0,
    'B+': 3.5,
    'B': 3.0,
    'C+': 2.5,
    'C': 2.0,
    'D+': 1.5,
    'D': 1.0,
    'F': 0.0,
  };

  // التقديرات وألوانها
  static const Map<String, Color> gradeColors = {
    'A+': Color(0xFF4CAF50), // أخضر
    'A': Color(0xFF00BFA5), // أخضر فاتح
    'B+': Color(0xFF00BCD4), // أزرق فاتح
    'B': Color(0xFF3F51B5), // أزرق
    'C+': Color(0xFF673AB7), // بنفسجي
    'C': Color(0xFF9C27B0), // أرجواني
    'D+': Color(0xFFFF9800), // برتقالي
    'D': Color(0xFFFF5722), // برتقالي داكن
    'F': Color(0xFFE53935), // أحمر
  };

  // بيانات جدول التقديرات
  static const List<Map<String, dynamic>> gradeTable = [
    {
      'grade': 'A+',
      'points5': '5.00',
      'points4': '4.00',
      'range': '95-100',
      'verbal': 'ممتاز مرتفع'
    },
    {
      'grade': 'A',
      'points5': '4.75',
      'points4': '4.00',
      'range': '90-94',
      'verbal': 'ممتاز'
    },
    {
      'grade': 'B+',
      'points5': '4.50',
      'points4': '3.50',
      'range': '85-89',
      'verbal': 'جيد جداً مرتفع'
    },
    {
      'grade': 'B',
      'points5': '4.00',
      'points4': '3.00',
      'range': '80-84',
      'verbal': 'جيد جداً'
    },
    {
      'grade': 'C+',
      'points5': '3.50',
      'points4': '2.50',
      'range': '75-79',
      'verbal': 'جيد مرتفع'
    },
    {
      'grade': 'C',
      'points5': '3.00',
      'points4': '2.00',
      'range': '70-74',
      'verbal': 'جيد'
    },
    {
      'grade': 'D+',
      'points5': '2.50',
      'points4': '1.50',
      'range': '65-69',
      'verbal': 'مقبول مرتفع'
    },
    {
      'grade': 'D',
      'points5': '2.00',
      'points4': '1.00',
      'range': '60-64',
      'verbal': 'مقبول'
    },
    {
      'grade': 'F',
      'points5': '1.00',
      'points4': '0.00',
      'range': 'أقل من 60',
      'verbal': 'راسب'
    },
  ];
}
