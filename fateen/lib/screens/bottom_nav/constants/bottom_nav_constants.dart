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

  // الحصول على تفاصيل التنسيق بناءً على حجم الشاشة
  static double getActiveIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 360 ? 24.0 : 26.0;
  }

  static double getInactiveIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 360 ? 20.0 : 22.0;
  }

  static double getLabelFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 360 ? 11.0 : 13.0;
  }

  static double getIndicatorHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 360 ? 2.5 : 3.0;
  }

  static double getIndicatorWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 360 ? 20.0 : 24.0;
  }

  static double getIndicatorRadius(BuildContext context) {
    return 1.5;
  }

  static double getVerticalPadding(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.0025; // 0.25% من ارتفاع الشاشة
  }

  static double getLabelTopPadding(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.006; // 0.6% من ارتفاع الشاشة
  }

  static double getIndicatorTopMargin(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.005; // 0.5% من ارتفاع الشاشة
  }

  // أرتفاع شريط التنقل (مع تعديله لأجهزة iPhone)
  static double getBarHeight(BuildContext context) {
    final isiPhone = Theme.of(context).platform == TargetPlatform.iOS;
    final screenHeight = MediaQuery.of(context).size.height;

    // استخدام نسبة من ارتفاع الشاشة مع حد أدنى
    final baseHeight = screenHeight * 0.08; // 8% من ارتفاع الشاشة
    final minHeight = isiPhone ? 68.0 : 62.0;

    return baseHeight > minHeight ? baseHeight : minHeight;
  }

  // معرفة ما إذا كان الجهاز به notch (مثل iPhone X وما بعده)
  static bool hasNotch(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return padding.bottom > 0;
  }

  // الحصول على الهامش السفلي المناسب لشريط التنقل
  static EdgeInsets getNavBarPadding(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return EdgeInsets.only(bottom: padding.bottom > 0 ? padding.bottom : 0);
  }
}
