import 'package:flutter/material.dart';

class ScheduleHeaderConstants {
  // ألوان التطبيق الموحدة
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kTextColor = Color(0xFF374151);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);
  static const Color kAccentColor = Color(0xFFEC4899);

  // نصوص الواجهة
  static const String screenTitle = 'الجدول الدراسي';
  static const String calendarViewTooltip = 'عرض الجدول الأسبوعي';
  static const String listViewTooltip = 'عرض القائمة اليومية';
  static const String weeklyScheduleTitle = 'جدول المحاضرات الأسبوعي';

  // ثوابت التباعد والأحجام
  static const double defaultPadding = 20.0;
  static const double headerIconSize = 22.0;
  static const double headerTitleSize = 24.0;

  /// دالة لضبط الحجم حسب حجم الشاشة
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
