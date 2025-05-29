// constants/course_notifications_constants.dart
import 'package:flutter/material.dart';

class CourseNotificationsConstants {
  // ألوان التطبيق الموحدة
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kAccentColor = Color(0xFFEC4899);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);

  // ثوابت النصوص
  static const String notificationsTabTitle = 'خيارات الإشعارات';
  static const String notificationsEnabledText = 'الإشعارات مفعّلة';
  static const String notificationsDisabledText = 'الإشعارات معطّلة';
  static const String notificationsDisabledMessage = 'الإشعارات معطّلة حالياً';
  static const String notificationsDisabledHint =
      'قم بتفعيل الإشعارات لتلقي تذكيرات بمواعيد المحاضرات';
  static const String notificationsReminderTitle = 'إرسال التذكير';
  static const String notificationsTimeAtLecture = 'في وقت المحاضرة';
  static const String notificationsTimeBeforeFormat =
      'قبل المحاضرة بـ %d دقائق';
  static const String confirmRemindersButton = 'تأكيد الإشعارات';
  static const String reminderSetSuccessMessage = 'تم جدولة %d تذكيرات للمقرر';
  static const String noTimeSetWarning = 'لم يتم تحديد وقت للمحاضرة';
  static const String noTimeSetHint =
      'قم بتحديد وقت المحاضرة في إعدادات المقرر أولاً';
}
