import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // تهيئة الإشعارات
  Future<void> initialize() async {
    if (kIsWeb) return; // لا إشعارات على الويب

    try {
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings iosInitSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(initSettings);
    } catch (e) {
      debugPrint('خطأ في تهيئة الإشعارات: $e');
    }
  }

  // عرض إشعار
  Future<void> showNotification({
    required String title,
    required String body,
    String channelId = 'translation_channel',
    String channelName = 'Translation Notifications',
  }) async {
    if (kIsWeb) return; // لا إشعارات على الويب

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'translation_channel',
        'Translation Notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        0, // رقم الإشعار
        title,
        body,
        details,
      );
    } catch (e) {
      debugPrint('خطأ في إظهار الإشعار: $e');
    }
  }
}
