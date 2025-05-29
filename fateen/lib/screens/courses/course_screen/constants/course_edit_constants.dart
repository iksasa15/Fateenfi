import 'package:flutter/material.dart';

class CourseEditConstants {
  // ألوان التطبيق الموحدة
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kAccentColor = Color(0xFFEC4899);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);

  // ثوابت النصوص
  static const String editCourseTitle = 'تعديل المقرر';
  static const String editCourseTabTitle = 'تعديل المقرر';
  static const String courseNameLabel = 'اسم المقرر';
  static const String creditHoursLabel = 'عدد الساعات';
  static const String classroomLabel = 'قاعة المحاضرة';
  static const String daysLabel = 'أيام المحاضرة';
  static const String timeLabel = 'وقت المحاضرة';
  static const String selectTimeHint = 'حدد وقت المحاضرة';
  static const String cancelButton = 'إلغاء';
  static const String saveButton = 'حفظ';

  // رسائل الخطأ
  static const String courseNameErrorEmpty = 'اسم المقرر لا يجب أن يكون فارغًا';
  static const String creditHoursErrorInvalid =
      'عدد الساعات يجب أن يكون رقمًا موجَبًا';
  static const String daysErrorEmpty = 'يجب اختيار يوم واحد على الأقل للمحاضرة';
  static const String timeErrorEmpty = 'يجب تحديد وقت المحاضرة';
}
