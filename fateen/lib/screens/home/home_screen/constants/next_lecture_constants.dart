import 'package:flutter/material.dart';

/// ثوابت ميزة المحاضرة القادمة
class NextLectureConstants {
  // الألوان الرئيسية
  static const Color kDarkPurple = Color(0xFF221291);
  static const Color kMediumPurple = Color(0xFF6C63FF);
  static const Color cardColor = Color(0xFF5D5FEF);
  static const Color textColor = Colors.white;

  // العناوين المستخدمة
  static const String nextLectureTitle = 'المحاضرة القادمة';
  static const String classroomPrefix = 'القاعة: ';
  static const String minuteAbbreviation = 'د';

  // نصوص الوقت
  static const String startsInText = 'تبدأ خلال';
  static const String hoursUnit = 'ساعة';
  static const String minutesUnit = 'دقيقة';
  static const String andText = 'و';

  // قيم ثابتة أخرى
  static const int maxLectureAdvanceSeconds = 18000; // 5 ساعات بالثواني

  // رسائل الحالة
  static const String noLecturesMessage = 'لا توجد محاضرات قادمة';
  static const String errorLoadingLectures = 'حدث خطأ أثناء تحميل المحاضرات';

  // حقول Firestore
  static const String courseNameField = 'courseName';
  static const String courseOldNameField = 'name';
  static const String lectureTimeField = 'lectureTime';
  static const String classroomField = 'classroom';
  static const String dayOfWeekField = 'dayOfWeek';
  static const String idField = 'id';

  static var hourAbbreviation;
}
