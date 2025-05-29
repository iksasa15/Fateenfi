// constants/course_header_constants.dart
import 'package:flutter/material.dart';

class CourseHeaderConstants {
  // ألوان التطبيق الموحدة - متطابقة مع باقي الصفحات
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kTextColor = Color(0xFF374151);
  static const Color kHintColor = Color(0xFF9CA3AF);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);
  static const Color kAccentColor = Color(0xFFEC4899);

  // ثوابت التباعد والأحجام
  static const double defaultPadding = 20.0;
  static const double smallPadding = 12.0;

  // أحجام الخطوط
  static const double titleFontSize = 26.0; // تم تعديله ليتطابق مع الجدول
  static const double subtitleFontSize = 14.0;

  // نصوص الواجهة
  static const String screenTitle = 'ادارة المقررات';
  static const String screenSubtitle =
      'يمكنك إدارة مقرراتك الدراسية ومتابعة الدرجات والملفات';
  static const String welcomeFormat =
      'مرحباً %s، يمكنك إدارة مقرراتك الدراسية ومتابعتها';

  // هوامش متجاوبة
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (width < 600) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return EdgeInsets.symmetric(horizontal: width * 0.1); // 10% من عرض الشاشة
    }
  }

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
