import 'package:flutter/material.dart';

/// ثوابت بطاقة الملف الشخصي
class ProfileCardConstants {
  // الألوان
  static const Color gradientStartColor = Color(0xFF8B5CF6);
  static const Color gradientEndColor = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFF7E22CE);
  static const Color textColor = Colors.white;
  static const Color iconBackgroundColor = Colors.white;
  static const Color badgeBackgroundColor =
      Color(0x33FFFFFF); // White with opacity 0.2
  static const Color cardShadowColor =
      Color(0x33000000); // Black with opacity 0.2

  // النصوص
  static const String morningGreeting = 'صباح الخير';
  static const String eveningGreeting = 'مساء الخير';
  static const String defaultUserName = 'مستخدم';
  static const String defaultUserMajor = 'غير محدد';
  static const String unknownCharacter = '؟';

  // خصائص التصميم
  static const String fontFamily = 'SYMBIOAR+LT';
  static const double cardBorderRadius = 20.0;
  static const double avatarSize = 55.0;

  // قائمة أيام الأسبوع بالعربية
  static const List<String> arabicDays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت'
  ];

  // قائمة الشهور بالعربية
  static const List<String> arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'إبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];
}
