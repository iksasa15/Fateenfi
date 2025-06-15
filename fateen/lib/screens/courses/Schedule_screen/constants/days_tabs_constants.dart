import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class DaysTabsConstants {
  // ثابت خط التطبيق
  static const String fontFamily = 'SYMBIOAR+LT';

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

  // ثوابت الأنميشن
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration tabAnimationDuration = Duration(milliseconds: 200);
}
