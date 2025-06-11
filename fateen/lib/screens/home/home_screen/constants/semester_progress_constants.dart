import 'package:flutter/material.dart';

class SemesterProgressConstants {
  // ألوان الميزة
  static const Color gradientStartColor = Color(0xFF6366F1);
  static const Color gradientEndColor = Color(0xFF4338CA);
  static const Color textColor = Colors.white;
  static const Color progressBarColor = Colors.white;
  static const Color progressBarBackgroundColor =
      Color(0x4DFFFFFF); // White with opacity 0.3
  static const Color badgeBackgroundColor =
      Color(0x33FFFFFF); // White with opacity 0.2
  static const Color editButtonColor =
      Color(0x3DFFFFFF); // White with opacity 0.24
  static const Color cardShadowColor =
      Color(0x33000000); // Black with opacity 0.2
  static const Color successColor = Color(0xFF10B981); // Success color

  // نصوص الميزة
  static const String title = 'تقدم الفصل الدراسي';
  static const String semesterStartLabel = 'بداية الفصل';
  static const String semesterEndLabel = 'نهاية الفصل';
  static const String semesterStartDate = '١٥ مارس';
  static const String semesterEndDate = '٢٨ يونيو';
  static const String daysRemainingLabel = 'متبقي للنهاية';
  static const String editEndDateButtonLabel = 'تعديل تاريخ النهاية';
  static const String cancelButtonLabel = 'إلغاء';
  static const String saveButtonLabel = 'حفظ';
  static const String dialogTitle = 'تعديل تاريخ انتهاء الفصل الدراسي';
  static const String dateUpdatedMessage = 'تم تحديث التاريخ';
  static const String dateUpdateErrorMessage = 'حدث خطأ أثناء تحديث التاريخ';

  // خصائص أخرى
  static const double progressBarHeight = 8.0;
  static const double progressBarBorderRadius = 4.0;
  static const double cardBorderRadius = 20.0;
  static const double editButtonBorderRadius = 12.0;
  static const String fontFamily = 'SYMBIOAR+LT';
}
