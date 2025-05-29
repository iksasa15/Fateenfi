import 'package:flutter/material.dart';

class NotesColors {
  // ألوان التطبيق الرئيسية
  static const Color kDarkPurple = Color(0xFF221291);
  static const Color kMediumPurple = Color(0xFF6C63FF);
  static const Color kLightPurple = Color(0xFFF6F4FF);
  static const Color kAccentColor = Color(0xFFFF6B6B);
  static const Color kBorderColor = Color(0xFFE3E0F8);

  // ألوان الفئات
  static final Map<String, Color> categoryColors = {
    'برمجة': const Color(0xFF6A5ACD), // أرجواني
    'رياضيات': const Color(0xFF4CAF50), // أخضر
    'مشاريع': const Color(0xFFFFA726), // برتقالي
    'شبكات': const Color(0xFFEC407A), // وردي
    'عام': const Color(0xFF42A5F5), // أزرق
  };

  // ألوان الملاحظات
  static const List<Color> noteColorOptions = [
    Color(0xFFF6F4FF), // بنفسجي فاتح
    Color(0xFFE1F5FE), // أزرق فاتح
    Color(0xFFE8F5E9), // أخضر فاتح
    Color(0xFFFFF9C4), // أصفر فاتح
    Color(0xFFFFCDD2), // أحمر فاتح
    Color(0xFFE1BEE7), // بنفسجي فاتح
    Color(0xFFFFE0B2), // برتقالي فاتح
    Color(0xFFD7CCC8), // بني فاتح
  ];
}
