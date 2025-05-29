import 'package:flutter/material.dart';

class DaysTabsConstants {
  // ألوان التطبيق الموحدة
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kAccentColor = Color(0xFFEC4899);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);
  static const Color kTextColor = Color(0xFF374151);
  static const Color kHintColor = Color(0xFF9CA3AF);

  // نصوص الواجهة
  static const String dayLecturesPrefix = 'محاضرات';
  static const String lectureCountSuffix = 'محاضرة';

  // مصفوفة الأيام التي سنعرضها في التقويم
  static const List<String> arabicDays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];

  // مصفوفة الأيام بالإنجليزية للتحقق من اليوم الحالي
  static const List<String> englishDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
  ];

  // ثوابت التباعد والأحجام
  static const double defaultPadding = 20.0;
  static const double smallPadding = 5.0;
  static const double mediumPadding = 15.0;
  static const double largePadding = 30.0;

  // دالة للحصول على حجم متجاوب مع حجم الشاشة
  static double getResponsiveSize(
      BuildContext context, double small, double medium, double large) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) {
      return small;
    } else if (width < 600) {
      return medium;
    } else {
      return large;
    }
  }
}
