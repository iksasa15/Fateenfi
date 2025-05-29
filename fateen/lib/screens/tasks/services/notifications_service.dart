// lib/services/notifications_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import '../../../../models/task.dart';
import 'package:flutter/material.dart';

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  factory NotificationsService() {
    return _instance;
  }

  NotificationsService._internal();

  // تهيئة خدمة الإشعارات
  Future<void> init() async {
    // تفادي تهيئة الخدمة أكثر من مرة
    if (_isInitialized) {
      return;
    }

    try {
      // تهيئة منطقة التوقيت
      tz.initializeTimeZones();

      // استخدام المنطقة الزمنية المحلية للجهاز
      // في بيئة حقيقية، يفضل استخدام مكتبة flutter_native_timezone
      tz.setLocalLocation(tz.getLocation('UTC'));

      // تهيئة الإشعارات لنظام أندرويد
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // تهيئة الإشعارات لنظام iOS
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      // دمج الإعدادات
      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // تهيئة المكوّن مع التعامل مع الضغط على الإشعار
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // طلب أذونات الإشعار
      await _requestPermissions();

      _isInitialized = true;
      debugPrint('تم تهيئة خدمة الإشعارات بنجاح');
    } catch (e) {
      debugPrint('خطأ أثناء تهيئة خدمة الإشعارات: $e');
    }
  }

  // معالجة الضغط على الإشعار
  void _onNotificationTap(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null && payload.isNotEmpty) {
      debugPrint('تم الضغط على إشعار مع Payload: $payload');
      // يمكنك توجيه المستخدم إلى شاشة المهمة هنا
      // مثال: navigateToTaskDetails(payload);
    }
  }

  // طلب أذونات الإشعارات
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      // استخدام الطريقة المدعومة في الإصدار الحالي
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    }
  }

  // جدولة إشعار لمهمة
  Future<void> scheduleTaskReminder(Task task) async {
    // التأكد من أن الخدمة مهيأة قبل جدولة الإشعارات
    if (!_isInitialized) {
      await init();
    }

    if (task.reminderTime == null) {
      debugPrint('لا يوجد وقت تذكير محدد للمهمة.');
      return;
    }

    // تحقق من أن وقت التذكير في المستقبل
    final now = DateTime.now();
    if (task.reminderTime!.isBefore(now)) {
      debugPrint('وقت التذكير في الماضي ولن يتم جدولته: ${task.reminderTime}');
      return;
    }

    try {
      debugPrint(
          'جدولة تذكير للمهمة: ${task.name} في الوقت: ${task.reminderTime}');

      // حذف أي إشعارات موجودة للمهمة نفسها
      await cancelTaskReminder(task.id);

      // إنشاء تفاصيل الإشعار لنظام أندرويد
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'task_reminders',
        'تذكيرات المهام',
        channelDescription: 'قناة لإشعارات تذكير المهام',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        color: const Color(0xFF4338CA),
        icon: '@mipmap/ic_launcher',
      );

      // إنشاء تفاصيل الإشعار لنظام iOS
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // دمج تفاصيل المنصتين
      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // تحويل وقت التذكير إلى كائن TZDateTime للجدولة
      final tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        task.reminderTime!.year,
        task.reminderTime!.month,
        task.reminderTime!.day,
        task.reminderTime!.hour,
        task.reminderTime!.minute,
      );

      // جدولة الإشعار
      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id.hashCode, // استخدام هاش معرف المهمة كمعرف للإشعار
        'تذكير بمهمة: ${task.name}',
        task.description.isNotEmpty
            ? task.description
            : 'موعد تسليم المهمة: ${_formatDate(task.dueDate)}',
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id, // تمرير معرف المهمة كـ payload
      );

      debugPrint('تم جدولة الإشعار بنجاح للوقت: $scheduledDate');
    } catch (e) {
      debugPrint('خطأ أثناء جدولة الإشعار: $e');
    }
  }

  // إلغاء إشعار تذكير لمهمة
  Future<void> cancelTaskReminder(String taskId) async {
    // التأكد من أن الخدمة مهيأة قبل إلغاء الإشعارات
    if (!_isInitialized) {
      await init();
    }

    try {
      await flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
      debugPrint('تم إلغاء إشعار المهمة: $taskId');
    } catch (e) {
      debugPrint('خطأ أثناء إلغاء إشعار المهمة: $e');
    }
  }

  // إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    // التأكد من أن الخدمة مهيأة قبل إلغاء الإشعارات
    if (!_isInitialized) {
      await init();
    }

    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('تم إلغاء جميع الإشعارات');
    } catch (e) {
      debugPrint('خطأ أثناء إلغاء جميع الإشعارات: $e');
    }
  }

  // تنسيق التاريخ للعرض في الإشعار
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // إظهار إشعار فوري (للاختبار)
  Future<void> showInstantNotification(String title, String body) async {
    // التأكد من أن الخدمة مهيأة قبل عرض الإشعارات
    if (!_isInitialized) {
      await init();
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'task_instant',
        'إشعارات فورية',
        channelDescription: 'قناة للإشعارات الفورية',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: 'instant_notification',
      );

      debugPrint('تم عرض الإشعار الفوري بنجاح');
    } catch (e) {
      debugPrint('خطأ أثناء عرض الإشعار الفوري: $e');
    }
  }
}
