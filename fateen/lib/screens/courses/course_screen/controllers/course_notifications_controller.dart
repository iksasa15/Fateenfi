// controllers/course_notifications_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models/course.dart';

class CourseNotificationsController extends ChangeNotifier {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool notificationsEnabled = false;
  String? displayName;
  bool _timeZoneInitialized = false;

  CourseNotificationsController(
      {required this.flutterLocalNotificationsPlugin}) {
    _initializeTimeZone();
    _loadSettings();
  }

  // تهيئة المنطقة الزمنية
  Future<void> _initializeTimeZone() async {
    try {
      if (!_timeZoneInitialized) {
        tz_data.initializeTimeZones();
        tz.setLocalLocation(
            tz.getLocation('Africa/Cairo')); // أو المنطقة الزمنية المناسبة
        _timeZoneInitialized = true;
        debugPrint('تم تهيئة المنطقة الزمنية بنجاح');
      }
    } catch (e) {
      debugPrint('خطأ في تهيئة المنطقة الزمنية: $e');
    }
  }

  // تحميل الإعدادات
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    displayName = prefs.getString('user_name');
    notifyListeners();
  }

  // التبديل بين تفعيل وتعطيل الإشعارات
  Future<void> toggleNotifications() async {
    notificationsEnabled = !notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', notificationsEnabled);
    notifyListeners();
  }

  // جدولة إشعار في وقت المحاضرة
  Future<bool> scheduleLectureNotification(Course course,
      {bool isImmediate = false}) async {
    if (!notificationsEnabled) {
      return false;
    }

    if (isImmediate) {
      return await sendReminderNotification(course,
          minutesBefore: 0, immediate: true);
    }

    if (course.lectureTime == null) {
      return false;
    }

    final split = course.lectureTime!.split(':');
    if (split.length != 2) {
      return false;
    }

    final hour = int.tryParse(split[0]) ?? 0;
    final minute = int.tryParse(split[1]) ?? 0;

    final now = DateTime.now();
    DateTime scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduleTime.isBefore(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    return await sendReminderNotification(
      course,
      scheduledTime: scheduleTime,
      minutesBefore: 0,
    );
  }

  // جدولة إشعار قبل المحاضرة
  Future<bool> scheduleBeforeTime(Course course, int minutesBefore) async {
    if (!notificationsEnabled) {
      return false;
    }

    if (course.lectureTime == null) {
      return false;
    }

    final split = course.lectureTime!.split(':');
    if (split.length != 2) {
      return false;
    }

    final hour = int.tryParse(split[0]) ?? 0;
    final minute = int.tryParse(split[1]) ?? 0;

    final now = DateTime.now();
    DateTime lectureDatetime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    lectureDatetime = fixDateIfPassed(lectureDatetime);
    final reminderTime =
        lectureDatetime.subtract(Duration(minutes: minutesBefore));

    return await sendReminderNotification(
      course,
      scheduledTime: reminderTime,
      minutesBefore: minutesBefore,
    );
  }

  // إرسال إشعار تذكير
  Future<bool> sendReminderNotification(
    Course course, {
    DateTime? scheduledTime,
    int minutesBefore = 0,
    bool immediate = false,
  }) async {
    // تأكد من تهيئة المنطقة الزمنية
    if (!_timeZoneInitialized) {
      await _initializeTimeZone();
    }

    final now = DateTime.now();
    final greeting = (now.hour < 12) ? "صباح الخير" : "مساء الخير";

    // استخدام الاسم الحقيقي للمستخدم
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? displayName ?? "مستخدم";

    final extraText = (minutesBefore == 0 && !immediate)
        ? "الآن"
        : (minutesBefore > 0)
            ? "بعد $minutesBefore دقائق"
            : "الآن";

    final notifTitle = "$greeting $userName";
    final notifBody =
        "محاضرة (${course.courseName}) ستبدأ $extraText في قاعة (${course.classroom})";

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'my_channel_id',
      'Reminders',
      channelDescription: 'قناة خاصة بالتذكيرات',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      if (scheduledTime != null && !immediate) {
        final id =
            DateTime.now().millisecondsSinceEpoch ~/ 1000 + minutesBefore;

        // استخدام try/catch منفصل لتحويل التاريخ للمنطقة الزمنية
        try {
          final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

          await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            notifTitle,
            notifBody,
            scheduledDate,
            notificationDetails,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (e) {
          debugPrint('خطأ في تحويل التاريخ للمنطقة الزمنية: $e');
          // في حالة الفشل، نستخدم الإشعار الفوري كبديل
          await flutterLocalNotificationsPlugin.show(
            id,
            notifTitle,
            notifBody,
            notificationDetails,
          );
        }
      } else {
        await flutterLocalNotificationsPlugin.show(
          DateTime.now().microsecond,
          notifTitle,
          notifBody,
          notificationDetails,
        );
      }
      return true;
    } catch (e) {
      debugPrint('خطأ في جدولة الإشعار: $e');
      return false;
    }
  }

  // تصحيح التاريخ إذا كان مضى
  DateTime fixDateIfPassed(DateTime lectureTime) {
    final now = DateTime.now();
    if (lectureTime.isBefore(now)) {
      return lectureTime.add(const Duration(days: 1));
    }
    return lectureTime;
  }

  // تحويل DateTime إلى TZDateTime - طريقة بديلة
  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }
}
