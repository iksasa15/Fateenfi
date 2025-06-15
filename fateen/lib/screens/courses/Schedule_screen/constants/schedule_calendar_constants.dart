import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class ScheduleCalendarConstants {
  // ثوابت الأحجام
  static const double timeColumnWidth = 60.0;
  static const double rowHeight = 80.0;

  // ثابت خط التطبيق
  static const String fontFamily = 'SYMBIOAR+LT';

  // مصفوفة من الألوان للمواد (ألوان فاتحة)
  static const List<Color> courseColorPalette = [
    Color(0xFFE3F2FD), // أزرق فاتح
    Color(0xFFF3E5F5), // بنفسجي فاتح
    Color(0xFFE8F5E9), // أخضر فاتح
    Color(0xFFFFF3E0), // برتقالي فاتح
    Color(0xFFFFEBEE), // أحمر فاتح
    Color(0xFFE0F7FA), // سماوي فاتح
    Color(0xFFF8E1), // أصفر فاتح
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

  // نصوص الواجهة
  static const String weeklyScheduleTitle = 'جدول المحاضرات الأسبوعي';
  static const String noCoursesMessage = 'لا توجد محاضرات مضافة';
  static const String addCoursesHint = 'قم بإضافة محاضراتك لعرضها في الجدول';
  static const String noTimesMessage = 'لا توجد مواعيد محاضرات محددة';
  static const String undefinedRoom = 'غير محدد';
  static const String undefinedTime = 'وقت غير محدد';
  static const String timeHeaderLabel = 'الوقت/\nاليوم';

  // أسماء عناصر واجهة التفاصيل
  static const String roomTitle = 'القاعة';
  static const String daysTitle = 'أيام المحاضرة';
  static const String creditHoursTitle = 'الساعات المعتمدة';
  static const String creditHoursSuffix = 'ساعات';

  // ثوابت الأنميشن
  static const Duration animationDuration = Duration(milliseconds: 300);

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

  // الأوقات الافتراضية
  static const List<String> defaultTimeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];
}
