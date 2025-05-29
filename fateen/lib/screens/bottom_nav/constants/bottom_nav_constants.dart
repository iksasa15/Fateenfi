import 'package:flutter/material.dart';

/// ثوابت شريط التنقل السفلي
class BottomNavConstants {
  // ألوان الأقسام المختلفة
  static const List<Color> sectionColors = [
    Color(0xFF6C63FF), // بنفسجي للرئيسية
    Color(0xFF4ECDC4), // فيروزي للجدول
    Color(0xFF42A5F5), // أزرق للمقررات
    Color(0xFFFFA726), // برتقالي للمهام
    Color(0xFFFF5252), // أحمر للخدمات
    Color(0xFF66BB6A), // أخضر للإعدادات
  ];

  // عناوين الأقسام
  static const List<String> navigationLabels = [
    'الرئيسية',
    'الجدول',
    'المقررات',
    'المهام',
    'الخدمات',
    'الإعدادات',
  ];

  // أيقونات الأقسام
  static const List<IconData> navigationIcons = [
    Icons.home_rounded,
    Icons.calendar_month_rounded,
    Icons.book_rounded,
    Icons.checklist_rtl_rounded,
    Icons.support_agent_rounded,
    Icons.settings_rounded,
  ];

  // تفاصيل التنسيق
  static const double activeIconSize = 26;
  static const double inactiveIconSize = 22;
  static const double labelFontSize = 13;
  static const double indicatorHeight = 3;
  static const double indicatorWidth = 24;
  static const double indicatorRadius = 1.5;
  static const double verticalPadding = 2;
  static const double labelTopPadding = 5;
  static const double indicatorTopMargin = 4;

  // أرتفاع شريط التنقل (مع تعديله لأجهزة iPhone)
  static double getBarHeight(BuildContext context) {
    final isiPhone = Theme.of(context).platform == TargetPlatform.iOS;
    return isiPhone ? 68.0 : 62.0;
  }
}
