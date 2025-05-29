import 'package:flutter/material.dart';

/// ثوابت مكون الهيدر
class HeaderConstants {
  // الألوان
  static const Color purpleColor = Color(0xFF4A25AA);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color moonColor = Color(0xFF3F51B5);

  // النصوص
  static const String wishText = 'نتمنى لك يوماً سعيداً!';
  static const String defaultUserName = 'مستخدم';
  static const String defaultUserMajor = 'غير محدد';

  // قيم SharedPreferences
  static const String prefUserNameKey = 'user_name';
  static const String prefUserMajorKey = 'user_major';
  static const String prefUserIdKey = 'logged_user_id';

  // قيم Firebase
  static const String usersCollection = 'users';
  static const String nameField = 'name';
  static const String majorField = 'major';

  // أسماء أيام الأسبوع بالعربية
  static const Map<int, String> arabicDays = {
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
    7: 'الأحد',
  };

  // أسماء الشهور بالعربية
  static const Map<int, String> arabicMonths = {
    1: 'يناير',
    2: 'فبراير',
    3: 'مارس',
    4: 'أبريل',
    5: 'مايو',
    6: 'يونيو',
    7: 'يوليو',
    8: 'أغسطس',
    9: 'سبتمبر',
    10: 'أكتوبر',
    11: 'نوفمبر',
    12: 'ديسمبر',
  };
}
