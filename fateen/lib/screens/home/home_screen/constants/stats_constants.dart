import 'package:flutter/material.dart';

/// ثوابت بطاقات الإحصائيات
class StatsConstants {
  // الألوان الرئيسية
  static const Color kDarkPurple = Color(0xFF221291);
  static const Color kMediumPurple = Color(0xFF6C63FF);
  static const Color kLightPurple = Color(0xFFF6F4FF);
  static const Color kAccentColor = Color(0xFFFF6B6B);

  // لون الخلفية
  static const Color kBackgroundColor = Color(0xFFFDFDFF);

  // ألوان إضافية للبطاقات
  static const Color kTealAccent = Color(0xFF4ECDC4); // لون فيروزي للمقررات
  static const Color kAmberAccent = Color(0xFFFFD166); // لون أصفر ذهبي للمهام
  static const Color kGreenAccent = Color(0xFF06D6A0); // لون أخضر للنجاح
  static const Color kSalmonAccent = Color(0xFFFF9F9F); // لون وردي للمواعيد
  static const Color kBlueAccent = Color(0xFF42A5F5); // لون أزرق للاختبارات
  static const Color kOrangeAccent = Color(0xFFFFA726); // لون برتقالي للمشاريع

  // نصوص العناوين
  static const String statisticsTitle = 'الإحصائيات';
  static const String coursesTitle = 'المواد';
  static const String tasksTitle = 'المهام';
  static const String examsTitle = 'الاختبارات';
  static const String projectsTitle = 'المشاريع';
  static const String attendanceTitle = 'الحضور';
  static const String performanceTitle = 'الأداء';

  // نصوص الوحدات
  static const String hoursUnit = 'ساعة';
  static const String completedTasksText = 'مكتملة';
  static const String attendanceRateText = 'معدل الحضور';
  static const String daysUnit = 'يوم';

  // قيم الإحصائيات الافتراضية
  static const Map<String, dynamic> defaultStats = {
    'courses': {
      'total': 0,
      'creditHours': 0,
    },
    'tasks': {
      'total': 0,
      'completed': 0,
      'overdue': 0,
    },
    'attendance': {
      'total': 0,
      'present': 0,
      'absent': 0,
    },
    'exams': {
      'total': 0,
      'upcoming': 0,
      'completed': 0,
    },
  };

  // الحصول على لون البطاقة بناءً على نوع الإحصائية
  static Color getCardColor(String statsType) {
    switch (statsType) {
      case 'courses':
        return kTealAccent;
      case 'tasks':
        return kAmberAccent;
      case 'attendance':
        return kGreenAccent;
      case 'exams':
        return kBlueAccent;
      case 'projects':
        return kOrangeAccent;
      default:
        return kAccentColor;
    }
  }

  // الحصول على أيقونة البطاقة بناءً على نوع الإحصائية
  static IconData getCardIcon(String statsType) {
    switch (statsType) {
      case 'courses':
        return Icons.menu_book_rounded;
      case 'tasks':
        return Icons.task_alt_rounded;
      case 'attendance':
        return Icons.fact_check_outlined;
      case 'exams':
        return Icons.quiz_outlined;
      case 'projects':
        return Icons.work_outline_rounded;
      default:
        return Icons.insert_chart_outlined;
    }
  }
}
