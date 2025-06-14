import 'package:flutter/material.dart';
import '../../../core/constants/appColor.dart';
import '../../../core/constants/app_dimensions.dart';

/// ثوابت شريط التنقل السفلي
class BottomNavConstants {
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

  // الألوان القديمة (للمرجع فقط)
  static const List<Color> _legacySectionColors = [
    Color(0xFF6C63FF), // بنفسجي للرئيسية
    Color(0xFF4ECDC4), // فيروزي للجدول
    Color(0xFF42A5F5), // أزرق للمقررات
    Color(0xFFFFA726), // برتقالي للمهام
    Color(0xFFFF5252), // أحمر للخدمات
    Color(0xFF66BB6A), // أخضر للإعدادات
  ];

  // دالة للحصول على لون القسم المناسب استنادا إلى نظام الألوان الجديد
  static Color getSectionColor(BuildContext context, int index) {
    switch (index) {
      case 0:
        return context.colorPrimaryLight; // الرئيسية
      case 1:
        return context.colorMediumPurple; // الجدول
      case 2:
        return context.colorInfo; // المقررات
      case 3:
        return context.colorWarning; // المهام
      case 4:
        return context.colorError; // الخدمات
      case 5:
        return context.colorSuccess; // الإعدادات
      default:
        return context.colorPrimary;
    }
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
