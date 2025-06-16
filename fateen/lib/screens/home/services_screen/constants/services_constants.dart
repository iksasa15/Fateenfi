import 'package:flutter/material.dart';
import '../../../../models/service_item.dart';
import '../../../tools/pomodoro_page/pomodoro_screen.dart';
import '../../../tools/gpa_calculator_screen/gpa_calculator_screen.dart';
import '../../../tools/notes_screen/notes_screen.dart';

class ServicesConstants {
  // الألوان
  static const Color kAccentColor = Color(0xFFFF6B6B);
  static const Color kDarkPurple = Color(0xFF221291);
  static const Color kMediumPurple = Color(0xFF6C63FF);
  static const Color kLightPurple = Color(0xFFF6F4FF);
  static const Color kBackgroundColor = Color(0xFFFAFAFF);
  static const Color kShadowColor = Color(0x0D221291);

  // النصوص
  static const String servicesTitle = 'الخدمات';
  static const String servicesDescription =
      'اكتشف جميع الخدمات التعليمية المتاحة';
  static const String allServicesTitle = 'كل الخدمات';
  static const String loadingText = 'جاري تحميل الخدمات...';

  // قائمة الخدمات - فقط حاسبة المعدل ووقت المذاكرة والملاحظات
  static final List<ServiceItem> services = [
    // حاسبة GPA
    ServiceItem(
      title: 'حاسبة GPA',
      description: 'احسب معدلك الفصلي والتراكمي',
      icon: Icons.calculate_outlined,
      iconColor: const Color(0xFF3949AB), // أزرق داكن
      destination: const GPACalculatorScreen(),
    ),
    // الملاحظات
    ServiceItem(
      title: 'الملاحظات',
      description: 'تنظيم الملاحظات الدراسية',
      icon: Icons.note_alt_outlined,
      iconColor: const Color(0xFFFFCA28), // أصفر
      destination: const NotesScreen(),
    ),
    // وقت المذاكرة
    ServiceItem(
      title: 'وقت المذاكرة',
      description: 'تنظيم الوقت للدراسة بفعالية',
      icon: Icons.timer_outlined,
      iconColor: const Color(0xFFE53935), // أحمر
      destination: PomodoroScreen(),
    ),
  ];
}
