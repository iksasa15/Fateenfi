// constants/course_card_constants.dart
import 'package:flutter/material.dart';

class CourseCardConstants {
  // ألوان التطبيق الموحدة - متطابقة مع باقي الصفحات
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kAccentColor = Color(0xFFEC4899);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);
  static const Color kShadowColor = Color(0x0D221291);
  static const Color kTextColor = Color(0xFF374151);
  static const Color kHintColor = Color(0xFF9CA3AF);

  // مصفوفة من الألوان للمواد (ألوان فاتحة)
  static const List<Color> courseColorPalette = [
    Color(0xFFE3F2FD), // أزرق فاتح
    Color(0xFFF3E5F5), // بنفسجي فاتح
    Color(0xFFE8F5E9), // أخضر فاتح
    Color(0xFFFFF3E0), // برتقالي فاتح
    Color(0xFFFFEBEE), // أحمر فاتح
    Color(0xFFE0F7FA), // سماوي فاتح
    Color(0xFFFFF8E1), // أصفر فاتح
    Color(0xFFF1F8E9), // أخضر ليموني فاتح
    Color(0xFFE1F5FE), // أزرق فاتح آخر
    Color(0xFFFCE4EC), // وردي فاتح
  ];

  // مصفوفة من ألوان الحدود المقابلة (ألوان غامقة)
  static const List<Color> courseBorderColorPalette = [
    Color(0xFF90CAF9), // أزرق
    Color(0xFFCE93D8), // بنفسجي
    Color(0xFFA5D6A7), // أخضر
    Color(0xFFFFCC80), // برتقالي
    Color(0xFFEF9A9A), // أحمر
    Color(0xFF80DEEA), // سماوي
    Color(0xFFFFE082), // أصفر
    Color(0xFFC5E1A5), // أخضر ليموني
    Color(0xFF81D4FA), // أزرق آخر
    Color(0xFFF48FB1), // وردي
  ];

  // نصوص العناوين في بطاقة المقرر
  static const String daysLabel = "الأيام";
  static const String timeLabel = "الوقت";
  static const String roomLabel = "القاعة";
  static const String creditHoursPrefix = "عدد الساعات";
  static const String undefinedLabel = "غير محدد";
  static const String undefinedRoomLabel = "غير محددة";

  // رسائل الحالة للمقررات
  static const String noCoursesMessage = 'لا توجد مقررات متاحة';
  static const String addCoursesHint = 'قم بإضافة مقرراتك من خلال الزر +';

  // ثوابت تصميم البطاقة
  static const double cardElevation = 0.0;
  static const double cardCornerRadius = 16.0;
  static const double borderWidth = 1.5;
  static const double verticalPadding = 20.0;
  static const double horizontalPadding = 20.0;
  static const double titleFontSize = 18.0;
  static const double detailLabelFontSize = 12.0;
  static const double detailValueFontSize = 14.0;
  static const double iconSize = 18.0;
  static const double infoIconSize = 16.0;

  // حجم أيقونة المعلومات ومحتوياتها
  static const double infoIconContainerSize = 36.0;
  static const double infoIconContainerRadius = 10.0;
}
