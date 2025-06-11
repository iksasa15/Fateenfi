import 'package:flutter/material.dart';

class SemesterProgressConstants {
  // ألوان الميزة
  static const Color gradientStartColor = Color(0xFF6366F1);
  static const Color gradientEndColor = Color(0xFF4338CA);
  static const Color textColor = Colors.white;
  static const Color progressBarColor = Colors.white;
  static const Color progressBarBackgroundColor =
      Color(0x4DFFFFFF); // White with opacity 0.3

  // نصوص الميزة
  static const String title = 'تقدم الفصل الدراسي';
  static const String semesterStartLabel = 'بداية الفصل';
  static const String semesterEndLabel = 'نهاية الفصل';
  static const String semesterStartDate = '١٥ مارس';
  static const String semesterEndDate = '٢٨ يونيو';

  // خصائص أخرى
  static const double progressBarHeight = 8.0;
  static const double progressBarBorderRadius = 4.0;
  static const String fontFamily = 'SYMBIOAR+LT';
}
