import 'package:flutter/material.dart';

class UpcomingEventsConstants {
  // النصوص الثابتة
  static const String sectionTitle = 'المواعيد القادمة';
  static const String viewAllButtonText = 'عرض الكل';
  static const String urgentText = 'عاجل';

  // الفونت المستخدم
  static const String fontFamily = 'SYMBIOAR+LT';

  // الألوان
  static const Color textColor = Colors.black87;
  static const Color urgentBackgroundColor =
      Color(0x1AEF4444); // حمراء بتعتيم 0.1
  static const Color urgentTextColor = Colors.red;
  static const Color borderColor = Color(0x1A9E9E9E); // رمادي بتعتيم 0.1
  static const Color shadowColor = Color(0x08000000); // أسود بتعتيم 0.03

  // أحجام ومسافات
  static const double cardBorderRadius = 12.0;
  static const double urgentBadgeBorderRadius = 12.0;
  static const double iconSize = 20.0;
  static const double avatarOpacity = 0.2;
  static const double cardElevation = 2.0;

  // أنواع المواعيد وألوانها (استخدام Enum أفضل لكن نبقيها بسيطة)
  static const Map<String, Color> eventTypeColors = {
    'exam': Color(0xFFEF4444), // لون الاختبارات
    'assignment': Color(0xFFF59E0B), // لون الواجبات
    'lecture': Color(0xFF3B82F6), // لون المحاضرات
    'meeting': Color(0xFF10B981), // لون الاجتماعات
    'other': Color(0xFF6366F1), // لون أخرى
  };

  // رموز أنواع المواعيد
  static const Map<String, IconData> eventTypeIcons = {
    'exam': Icons.assignment,
    'assignment': Icons.book,
    'lecture': Icons.event_note,
    'meeting': Icons.people,
    'other': Icons.calendar_today,
  };
}
