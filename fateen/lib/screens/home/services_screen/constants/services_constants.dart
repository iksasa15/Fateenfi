import 'package:flutter/material.dart';
import '../../../../models/service_item.dart';
import '../../../editors/interactive_whiteboard/interactive_whiteboard_screen.dart';
import '../../../tools/pomodoro_page/pomodoro_screen.dart';
import '../../../tools/Translate_screen/translate_screen.dart';
import '../../../tools/gpa_calculator_screen/gpa_calculator_screen.dart';
import '../../../tools/notes_screen/notes_screen.dart';
import '../screens/calendar_screen.dart';
// حذف استيرادات صفحات الذكاء الاصطناعي والإحصائيات
// import '../../../ai/AiGptMainPage/ai_gpt_main_screen.dart';
// import '../../../tools/stats_screen/stats_screen.dart';

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

  // قائمة الخدمات - حذف خدمتي الذكاء الاصطناعي والإحصائيات
  static final List<ServiceItem> services = [
    // إضافة حاسبة GPA كأول خدمة (أعلى القائمة)
    ServiceItem(
      title: 'حاسبة GPA',
      description: 'احسب معدلك الفصلي والتراكمي',
      icon: Icons.calculate_outlined,
      iconColor: const Color(0xFF3949AB), // أزرق داكن
      destination: const GPACalculatorScreen(),
    ),
    // إضافة الملاحظات كخدمة ثانية (تحديث الوجهة)
    ServiceItem(
      title: 'الملاحظات',
      description: 'تنظيم الملاحظات الدراسية',
      icon: Icons.note_alt_outlined,
      iconColor: const Color(0xFFFFCA28), // أصفر
      destination: const NotesScreen(), // تغيير إلى صفحة الملاحظات الجديدة
    ),
    // تم حذف خدمة الذكاء الاصطناعي من هنا
    ServiceItem(
      title: 'السبورة التفاعلية',
      description: 'سبورة رقمية للكتابة والرسم',
      icon: Icons.edit_note,
      iconColor: const Color(0xFF4CAF50), // أخضر
      destination: const InteractiveWhiteboardScreen(),
    ),
    ServiceItem(
      title: 'وقت المذاكرة',
      description: 'تنظيم الوقت للدراسة بفعالية',
      icon: Icons.timer_outlined,
      iconColor: const Color(0xFFE53935), // أحمر
      destination: PomodoroScreen(),
    ),
    ServiceItem(
      title: 'الترجمة',
      description: 'ترجمة نصوص بين عدة لغات',
      icon: Icons.translate_outlined,
      iconColor: const Color(0xFF29B6F6), // أزرق فاتح
      destination: const TranslateScreen(),
    ),
    // تم حذف خدمة الإحصائيات من هنا
    ServiceItem(
      title: 'تقويم المواعيد',
      description: 'تنظيم وتذكير بالمواعيد المهمة',
      icon: Icons.calendar_month_outlined,
      iconColor: const Color(0xFF26A69A), // أخضر مزرق
      destination: const CalendarScreen(),
    ),
  ];
}
