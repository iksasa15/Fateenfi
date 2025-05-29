import 'package:flutter/material.dart';

class CourseGradesConstants {
  // ألوان التطبيق الموحدة
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kAccentColor = Color(0xFFEC4899);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);

  // ثوابت النصوص
  static const String gradesTabTitle = 'درجات المقرر';
  static const String noGradesMessage = 'لا توجد درجات مسجّلة بعد';
  static const String addGradesHint = 'قم بإضافة درجات لهذا المقرر';
  static const String addGradeButton = 'إضافة درجة';
  static const String addGradeTitle = 'إضافة درجة جديدة';
  static const String editGradeTitle = 'تعديل الدرجة';
  static const String assignmentTypeLabel = 'نوع الاختبار';
  static const String assignmentNameLabel = 'اسم التقييم';
  static const String gradeLabel = 'الدرجة المحصلة';
  static const String maxGradeLabel = 'الدرجة الكاملة';
  static const String cancelButton = 'إلغاء';
  static const String saveButton = 'حفظ';

  // رسائل الخطأ
  static const String assignmentEmptyError =
      'اسم التقييم لا يجب أن يكون فارغًا';
  static const String gradeValueError =
      'الدرجة يجب أن تكون رقمًا موجَبًا أو صفر';
  static const String maxGradeError =
      'الدرجة الكاملة يجب أن تكون رقمًا موجَبًا';
  static const String gradeExceedsMaxError =
      'الدرجة المحصلة لا يمكن أن تتجاوز الدرجة الكاملة';
  static const String addGradeSuccess = 'تم إضافة الدرجة بنجاح';
  static const String editGradeSuccess = 'تم تعديل الدرجة بنجاح';
}
