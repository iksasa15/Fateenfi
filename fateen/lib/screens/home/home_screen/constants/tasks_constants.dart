import 'package:flutter/material.dart';

/// ثوابت خاصة بميزة المهام التي تحتاج اهتمام
class TasksConstants {
  // الألوان
  static const Color kOverdueTaskColor =
      Color(0xFFE57373); // أحمر للمهام المتأخرة
  static const Color kTodayTaskColor = Color(0xFF5D9CEC); // أزرق للمهام اليومية
  static const Color kBackgroundColor = Color(0xFFFDFDFF); // خلفية الشاشة

  // النصوص
  static const String tasksNeedAttentionTitle = 'مهام تحتاج اهتمامك';
  static const String todayTasksTitle = 'مهام اليوم';
  static const String overdueTasksTitle = 'مهام متأخرة';
  static const String noTasksTitle = 'لا توجد مهام عاجلة';
  static const String noTasksMessage =
      'ليس لديك مهام يومية أو متأخرة في الوقت الحالي.';
  static const String dueDateLabel = 'موعد التسليم:';
  static const String overdueLabel = 'متأخرة منذ:';

  // وحدات الوقت
  static const String minuteUnit = 'د';
  static const String hourUnit = 'س';
  static const String dayUnit = 'ي';

  // رسائل الأخطاء
  static const String loadingErrorMessage =
      'حدث خطأ أثناء تحميل المهام. حاول مرة أخرى.';
  static const String retryButtonText = 'إعادة المحاولة';

  // أيقونات
  static const IconData todayTaskIcon = Icons.calendar_today_outlined;
  static const IconData overdueTaskIcon = Icons.warning_amber_outlined;
  static const IconData timerIcon = Icons.timer;
  static const IconData timerOffIcon = Icons.timer_off;
  static const IconData emptyTasksIcon = Icons.task_alt;
}
