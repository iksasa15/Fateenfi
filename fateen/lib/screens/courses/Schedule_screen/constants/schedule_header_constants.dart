import 'package:flutter/material.dart';

class ScheduleHeaderConstants {
  // ألوان التطبيق الموحدة
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kTextColor = Color(0xFF374151);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);
  static const Color kAccentColor = Color(0xFFEC4899);
  static const Color kBorderColor = Color(0xFFE5E7EB);
  static const Color kShadowColor = Color(0x0F000000);

  // نصوص الواجهة
  static const String screenTitle = 'الجدول الدراسي';
  static const String calendarViewTooltip = 'عرض الجدول الأسبوعي';
  static const String listViewTooltip = 'عرض القائمة اليومية';
  static const String weeklyScheduleTitle = 'جدول المحاضرات الأسبوعي';
  static const String refreshTooltip = 'تحديث الجدول';

  // ثوابت التباعد والأحجام
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double headerPadding = 20.0;
  static const double buttonSize = 45.0;

  // ثابت خط التطبيق
  static const String fontFamily = 'SYMBIOAR+LT';

  // ثوابت الأنميشن
  static const Duration animationDuration = Duration(milliseconds: 300);

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

  /// دالة لحساب التباعد العمودي النسبي
  static double getVerticalPadding(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage / 100;
  }

  /// دالة لحساب التباعد الأفقي النسبي
  static double getHorizontalPadding(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage / 100;
  }

  /// دالة لإنشاء ظل موحد
  static List<BoxShadow> getUnifiedShadow() {
    return [
      BoxShadow(
        color: kShadowColor,
        blurRadius: 10,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ];
  }
}
