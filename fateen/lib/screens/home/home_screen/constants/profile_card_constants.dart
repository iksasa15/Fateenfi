import 'package:flutter/material.dart';

/// ثوابت بطاقة الملف الشخصي
class ProfileCardConstants {
  // الألوان
  static const Color gradientStartColor = Color(0xFF8B5CF6);
  static const Color gradientEndColor = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFF7E22CE);
  static const Color textColor = Colors.white;
  static const Color iconBackgroundColor = Colors.white;

  // النصوص
  static const String morningGreeting = 'صباح الخير';
  static const String eveningGreeting = 'مساء الخير';
  static const String defaultUserName = 'مستخدم';
  static const String defaultUserMajor = 'غير محدد';
  static const String unknownCharacter = '؟';

  // الخط المستخدم
  static const String fontFamily = 'SYMBIOAR+LT';

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
