// screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'calendar_colors.dart';
import 'calendar_header_component.dart';

// تعريف نموذج المواعيد
class CountdownModel {
  final int id;
  final String title;
  final DateTime targetDate;
  final bool hasNotification;

  CountdownModel({
    required this.id,
    required this.title,
    required this.targetDate,
    this.hasNotification = false,
  });

  // حساب عدد الأيام المتبقية
  int get daysLeft {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }

  // تحويل النموذج إلى Map لتخزينه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetDate': targetDate.toIso8601String(),
      'hasNotification': hasNotification,
    };
  }

  // إنشاء نموذج من Map مستخرج من التخزين
  factory CountdownModel.fromMap(Map<String, dynamic> map) {
    return CountdownModel(
      id: map['id'],
      title: map['title'],
      targetDate: DateTime.parse(map['targetDate']),
      hasNotification: map['hasNotification'] ?? false,
    );
  }

  // إنشاء نموذج من Firestore
  factory CountdownModel.fromFirestore(Map<String, dynamic> map) {
    return CountdownModel(
      id: map['id'],
      title: map['title'],
      targetDate: (map['targetDate'] is Timestamp)
          ? (map['targetDate'] as Timestamp).toDate()
          : DateTime.parse(map['targetDate']),
      hasNotification: map['hasNotification'] ?? false,
    );
  }

  // إنشاء نسخة معدلة من النموذج
  CountdownModel copyWith({
    int? id,
    String? title,
    DateTime? targetDate,
    bool? hasNotification,
  }) {
    return CountdownModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      hasNotification: hasNotification ?? this.hasNotification,
    );
  }
}

// متغير عام للإشعارات
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// جدولة إشعار للعد التنازلي
Future<void> scheduleNotification(CountdownModel countdown) async {
  // تحديد وقت الإشعار (قبل الموعد بيوم)
  final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
    countdown.targetDate.subtract(const Duration(days: 1)),
    tz.local,
  );

  // التأكد من أن الوقت لم يمر بعد
  if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
    // تفاصيل الإشعار لنظام Android
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'countdown_channel', // معرف القناة
      'عدادات تنازلية', // اسم القناة
      channelDescription: 'إشعارات لتذكيرك بمواعيد العد التنازلي', // وصف القناة
      importance: Importance.max,
      priority: Priority.high,
    );

    // تفاصيل الإشعار لنظام iOS
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails();

    // تفاصيل الإشعار المشتركة
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // جدولة الإشعار
    await flutterLocalNotificationsPlugin.zonedSchedule(
      countdown.id, // معرف فريد للإشعار
      'تذكير: ${countdown.title}', // عنوان الإشعار
      'متبقي يوم واحد على ${countdown.title} (${countdown.targetDate.day}/${countdown.targetDate.month}/${countdown.targetDate.year})', // محتوى الإشعار
      scheduledDate, // وقت الإشعار
      notificationDetails, // تفاصيل الإشعار
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // يسمح بالإشعار حتى إذا كان الجهاز في وضع السكون
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime, // تفسير وقت الإشعار
    );
  }
}

// إلغاء إشعار محدد
Future<void> cancelNotification(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

// مكون قسم مع عنوان
class CalendarSection extends StatelessWidget {
  final String title;
  final Widget child;

  const CalendarSection({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: CalendarColors.kCardBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: CalendarColors.kDarkPurple.withOpacity(0.1),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: CalendarColors.kDarkPurple,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CalendarColors.kTextColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(
            height: 1,
            thickness: 1,
            color: CalendarColors.kCardBorder,
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// مكون حالة التحميل
class CalendarLoadingState extends StatelessWidget {
  const CalendarLoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CalendarColors.kBackgroundColor,
      body: Column(
        children: [
          const CalendarHeaderComponent(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CalendarColors.kDarkPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'جاري تحميل البيانات...',
                    style: TextStyle(
                      color: CalendarColors.kTextColor,
                      fontSize: 16,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// مكون حالة فارغة
class CalendarEmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const CalendarEmptyState({
    Key? key,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CalendarColors.kLightPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note,
              size: 40,
              color: CalendarColors.kLightPurple,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد مواعيد بعد',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CalendarColors.kTextColor,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'أضف موعداً جديداً باستخدام الزر أدناه',
            style: TextStyle(
              fontSize: 14,
              color: CalendarColors.kLightTextColor,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: const Text('إضافة موعد جديد'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              backgroundColor: CalendarColors.kDarkPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Firebase المراجع
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<CountdownModel>> _events;
  List<CountdownModel> countdowns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadCountdowns();
    _loadPreferences();
  }

  // التحقق من تسجيل دخول المستخدم
  bool get isUserLoggedIn => _auth.currentUser != null;

  // الحصول على معرف المستخدم الحالي
  String? get userId => _auth.currentUser?.uid;

  // مرجع لمجموعة المواعيد في Firestore
  CollectionReference<Map<String, dynamic>> get _countdownsCollection {
    if (!isUserLoggedIn) {
      throw Exception('المستخدم غير مسجل دخول');
    }
    return _firestore.collection('users').doc(userId).collection('countdowns');
  }

  // تحميل المواعيد من Firebase أو التخزين المحلي
  Future<void> _loadCountdowns() async {
    setState(() {
      _isLoading = true; // بدء تحميل البيانات
    });

    try {
      if (isUserLoggedIn) {
        // تحميل المواعيد من Firebase
        final snapshot = await _countdownsCollection.get();
        setState(() {
          countdowns = snapshot.docs.map((doc) {
            return CountdownModel.fromFirestore(doc.data());
          }).toList();
        });
      } else {
        // تحميل المواعيد من التخزين المحلي إذا لم يكن المستخدم مسجل دخول
        final prefs = await SharedPreferences.getInstance();
        final String? countdownsJson = prefs.getString('countdowns');

        if (countdownsJson != null) {
          final List<dynamic> decodedList = jsonDecode(countdownsJson);
          setState(() {
            countdowns = decodedList
                .map((item) => CountdownModel.fromMap(item))
                .toList();
          });
        }
      }

      _initializeEvents();
      setState(() {
        _isLoading = false; // انتهاء تحميل البيانات
      });
    } catch (e) {
      print('خطأ في تحميل المواعيد: $e');
      setState(() {
        _isLoading = false; // انتهاء تحميل البيانات (حدث خطأ)
      });
    }
  }

  // حفظ المواعيد (محلياً أو في Firestore)
  Future<void> _saveCountdowns() async {
    try {
      if (isUserLoggedIn) {
        // لا نحتاج لحفظ الكل، كل إضافة/تعديل/حذف يتم بشكل منفصل
      } else {
        // حفظ في التخزين المحلي إذا لم يكن المستخدم مسجل دخول
        final prefs = await SharedPreferences.getInstance();
        final String countdownsJson = jsonEncode(
          countdowns.map((e) => e.toMap()).toList(),
        );
        await prefs.setString('countdowns', countdownsJson);
      }
    } catch (e) {
      print('خطأ في حفظ المواعيد: $e');
    }
  }

  // تحميل التفضيلات المحفوظة
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? formatString = prefs.getString('calendar_format');
      final String? focusedDayString = prefs.getString('focused_day');

      if (formatString != null) {
        setState(() {
          _calendarFormat = CalendarFormat.values.firstWhere(
            (format) => format.toString() == formatString,
            orElse: () => CalendarFormat.month,
          );
        });
      }

      if (focusedDayString != null) {
        setState(() {
          _focusedDay = DateTime.parse(focusedDayString);
        });
      }
    } catch (e) {
      print('خطأ في تحميل تفضيلات التقويم: $e');
    }
  }

  // حفظ التفضيلات
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('calendar_format', _calendarFormat.toString());
      await prefs.setString('focused_day', _focusedDay.toIso8601String());
    } catch (e) {
      print('خطأ في حفظ تفضيلات التقويم: $e');
    }
  }

  // تهيئة الأحداث من المواعيد
  void _initializeEvents() {
    _events = {};
    for (var countdown in countdowns) {
      final date = DateTime(
        countdown.targetDate.year,
        countdown.targetDate.month,
        countdown.targetDate.day,
      );

      if (_events[date] != null) {
        _events[date]!.add(countdown);
      } else {
        _events[date] = [countdown];
      }
    }
  }

  // الحصول على أحداث اليوم المحدد
  List<CountdownModel> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  // إضافة موعد جديد
  Future<void> _addCountdown(CountdownModel countdown) async {
    if (isUserLoggedIn) {
      // إضافة إلى Firebase
      await _countdownsCollection
          .doc(countdown.id.toString())
          .set(countdown.toMap());
    }

    setState(() {
      countdowns.add(countdown);
    });

    await _saveCountdowns();
    _initializeEvents();

    // جدولة إشعار إذا كان مطلوبًا
    if (countdown.hasNotification) {
      await scheduleNotification(countdown);
    }
  }

  // تحديث موعد موجود
  Future<void> _updateCountdown(
    int index,
    CountdownModel updatedCountdown,
  ) async {
    final oldCountdown = countdowns[index];

    if (isUserLoggedIn) {
      // تحديث في Firebase
      await _countdownsCollection
          .doc(updatedCountdown.id.toString())
          .update(updatedCountdown.toMap());
    }

    setState(() {
      countdowns[index] = updatedCountdown;
    });

    await _saveCountdowns();
    _initializeEvents();

    // إلغاء الإشعار القديم
    await cancelNotification(oldCountdown.id);

    // جدولة إشعار جديد إذا كان مطلوبًا
    if (updatedCountdown.hasNotification) {
      await scheduleNotification(updatedCountdown);
    }
  }

  // حذف موعد
  Future<void> _deleteCountdown(int index) async {
    // إلغاء الإشعار المرتبط بهذا الموعد
    final countdown = countdowns[index];
    await cancelNotification(countdown.id);

    if (isUserLoggedIn) {
      // حذف من Firebase
      await _countdownsCollection.doc(countdown.id.toString()).delete();
    }

    setState(() {
      countdowns.removeAt(index);
    });

    await _saveCountdowns();
    _initializeEvents();
  }

  // عرض نافذة إضافة أو تعديل موعد
  void _showAddEditCountdownDialog(
      {CountdownModel? existingCountdown, int? index}) {
    final bool isEditing = existingCountdown != null;
    final titleController = TextEditingController(
      text: isEditing ? existingCountdown.title : '',
    );

    DateTime targetDate =
        isEditing ? existingCountdown.targetDate : _selectedDay;

    bool enableNotification =
        isEditing ? existingCountdown.hasNotification : true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'تعديل الموعد' : 'إضافة موعد جديد',
                style: const TextStyle(
                  color: CalendarColors.kDarkPurple,
                  fontFamily: 'SYMBIOAR+LT',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'اسم الموعد',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: CalendarColors.kCardBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: CalendarColors.kDarkPurple,
                          ),
                        ),
                        labelStyle: const TextStyle(
                          color: CalendarColors.kLightTextColor,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: CalendarColors.kBackgroundColor,
                        border: Border.all(
                          color: CalendarColors.kCardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    CalendarColors.kDarkPurple.withOpacity(0.1),
                              ),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: CalendarColors.kDarkPurple,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'تاريخ الموعد',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CalendarColors.kLightTextColor,
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: targetDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                              primary:
                                                  CalendarColors.kDarkPurple,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface:
                                                  CalendarColors.kTextColor,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (picked != null) {
                                      setState(() {
                                        targetDate = picked;
                                      });
                                    }
                                  },
                                  child: Text(
                                    _formatDate(targetDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: CalendarColors.kTextColor,
                                      fontFamily: 'SYMBIOAR+LT',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_calendar,
                              color: CalendarColors.kDarkPurple,
                            ),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: targetDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: CalendarColors.kDarkPurple,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: CalendarColors.kTextColor,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (picked != null) {
                                setState(() {
                                  targetDate = picked;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: CalendarColors.kBackgroundColor,
                        border: Border.all(
                          color: CalendarColors.kCardBorder,
                        ),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'تفعيل الإشعارات',
                          style: TextStyle(
                            color: CalendarColors.kTextColor,
                            fontFamily: 'SYMBIOAR+LT',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'تذكير قبل الموعد بيوم واحد',
                          style: TextStyle(
                            color: CalendarColors.kLightTextColor,
                            fontFamily: 'SYMBIOAR+LT',
                            fontSize: 12,
                          ),
                        ),
                        value: enableNotification,
                        activeColor: CalendarColors.kDarkPurple,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            enableNotification = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      color: CalendarColors.kLightTextColor,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      if (isEditing) {
                        final updatedCountdown = existingCountdown.copyWith(
                          title: titleController.text,
                          targetDate: targetDate,
                          hasNotification: enableNotification,
                        );
                        _updateCountdown(index!, updatedCountdown);
                      } else {
                        final newId = DateTime.now().millisecondsSinceEpoch;
                        final newCountdown = CountdownModel(
                          id: newId,
                          title: titleController.text,
                          targetDate: targetDate,
                          hasNotification: enableNotification,
                        );
                        _addCountdown(newCountdown);
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CalendarColors.kDarkPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    isEditing ? 'تحديث' : 'إضافة',
                    style: const TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
            );
          },
        );
      },
    );
  }

  // عرض نافذة تأكيد الحذف
  void _showDeleteConfirmation(int index, CountdownModel countdown) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأكيد الحذف',
          style: TextStyle(
            color: CalendarColors.kDarkPurple,
            fontFamily: 'SYMBIOAR+LT',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${countdown.title}"؟',
          style: const TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            color: CalendarColors.kTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: CalendarColors.kLightTextColor,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCountdown(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CalendarColors.kRedColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            child: const Text(
              'حذف',
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CalendarLoadingState();
    }

    return Scaffold(
      backgroundColor: CalendarColors.kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CalendarHeaderComponent(),
            Expanded(
              child: RefreshIndicator(
                color: CalendarColors.kDarkPurple,
                onRefresh: _loadCountdowns,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CalendarSection(
                        title: 'التقويم',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            border: Border.all(
                              color: CalendarColors.kCardBorder,
                            ),
                          ),
                          child: Column(
                            children: [
                              // قسم خيارات التقويم
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _focusedDay = DateTime.now();
                                          _selectedDay = DateTime.now();
                                        });
                                        _savePreferences();
                                      },
                                      icon: const Icon(
                                        Icons.today,
                                        size: 16,
                                        color: CalendarColors.kDarkPurple,
                                      ),
                                      label: const Text(
                                        'اليوم',
                                        style: TextStyle(
                                          color: CalendarColors.kDarkPurple,
                                          fontFamily: 'SYMBIOAR+LT',
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: CalendarColors
                                            .kDarkPurple
                                            .withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    DropdownButton<CalendarFormat>(
                                      value: _calendarFormat,
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: CalendarColors.kDarkPurple,
                                      ),
                                      underline: Container(
                                        height: 0,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: CalendarFormat.month,
                                          child: Text(
                                            'شهري',
                                            style: TextStyle(
                                              fontFamily: 'SYMBIOAR+LT',
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: CalendarFormat.twoWeeks,
                                          child: Text(
                                            'أسبوعين',
                                            style: TextStyle(
                                              fontFamily: 'SYMBIOAR+LT',
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: CalendarFormat.week,
                                          child: Text(
                                            'أسبوعي',
                                            style: TextStyle(
                                              fontFamily: 'SYMBIOAR+LT',
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged: (format) {
                                        if (format != null) {
                                          setState(() {
                                            _calendarFormat = format;
                                          });
                                          _savePreferences();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // التقويم
                              TableCalendar(
                                locale: 'ar_SA',
                                firstDay: DateTime.now()
                                    .subtract(const Duration(days: 365)),
                                lastDay: DateTime.now()
                                    .add(const Duration(days: 3650)),
                                focusedDay: _focusedDay,
                                calendarFormat: _calendarFormat,
                                eventLoader: _getEventsForDay,
                                selectedDayPredicate: (day) {
                                  return isSameDay(_selectedDay, day);
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                  _savePreferences();
                                },
                                onFormatChanged: (format) {
                                  setState(() {
                                    _calendarFormat = format;
                                  });
                                  _savePreferences();
                                },
                                onPageChanged: (focusedDay) {
                                  _focusedDay = focusedDay;
                                  _savePreferences();
                                },
                                headerStyle: const HeaderStyle(
                                  titleCentered: true,
                                  formatButtonVisible: false,
                                  titleTextStyle: TextStyle(
                                    color: CalendarColors.kDarkPurple,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                  leftChevronIcon: Icon(
                                    Icons.chevron_left,
                                    color: CalendarColors.kDarkPurple,
                                  ),
                                  rightChevronIcon: Icon(
                                    Icons.chevron_right,
                                    color: CalendarColors.kDarkPurple,
                                  ),
                                ),
                                calendarStyle: CalendarStyle(
                                  markersMaxCount: 3,
                                  markersAlignment: Alignment.bottomCenter,
                                  markerDecoration: const BoxDecoration(
                                    color: CalendarColors.kMediumPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: CalendarColors.kAccentColor
                                        .withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: CalendarColors.kDarkPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  weekendTextStyle: const TextStyle(
                                    color: CalendarColors.kDarkPurple,
                                  ),
                                  holidayTextStyle: const TextStyle(
                                    color: CalendarColors.kDarkPurple,
                                  ),
                                  outsideTextStyle: TextStyle(
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  defaultTextStyle: const TextStyle(
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                  weekendDecoration: BoxDecoration(
                                    color: CalendarColors.kLightPurple
                                        .withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                daysOfWeekStyle: const DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(
                                    color: CalendarColors.kLightTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                  weekendStyle: TextStyle(
                                    color: CalendarColors.kLightTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  // تخصيص شكل اليوم مع المواعيد
                                  markerBuilder: (context, date, events) {
                                    if (events.isEmpty) return null;

                                    // تلوين العلامات حسب مدة الموعد
                                    return Positioned(
                                      bottom: 1,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: events.take(3).map((event) {
                                          // حساب لون المؤشر
                                          CountdownModel countdown =
                                              event as CountdownModel;
                                          Color dotColor;
                                          if (countdown.daysLeft <= 1) {
                                            dotColor = CalendarColors.kRedColor;
                                          } else if (countdown.daysLeft <= 3) {
                                            dotColor =
                                                CalendarColors.kOrangeColor;
                                          } else if (countdown.daysLeft <= 7) {
                                            dotColor =
                                                CalendarColors.kAccentColor;
                                          } else {
                                            dotColor =
                                                CalendarColors.kGreenColor;
                                          }

                                          return Container(
                                            margin: const EdgeInsets.all(1),
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: dotColor,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // قسم المواعيد المحددة
                      CalendarSection(
                        title: 'مواعيد ${_formatDate(_selectedDay)}',
                        child: _buildSelectedDayEvents(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCountdownDialog(),
        backgroundColor: CalendarColors.kDarkPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'إضافة موعد جديد',
      ),
    );
  }

  // بناء قائمة المواعيد لليوم المحدد
  Widget _buildSelectedDayEvents() {
    final events = _getEventsForDay(_selectedDay);

    if (events.isEmpty) {
      return CalendarEmptyState(
        onAddPressed: () => _showAddEditCountdownDialog(),
      );
    }

    return Column(
      children: events.map((countdown) {
        // البحث عن الفهرس في القائمة الأصلية
        final originalIndex =
            countdowns.indexWhere((c) => c.id == countdown.id);

        // اختيار لون البطاقة حسب عدد الأيام المتبقية
        Color cardColor;
        if (countdown.daysLeft <= 1) {
          cardColor = CalendarColors.kRedColor;
        } else if (countdown.daysLeft <= 3) {
          cardColor = CalendarColors.kOrangeColor;
        } else if (countdown.daysLeft <= 7) {
          cardColor = CalendarColors.kAccentColor;
        } else {
          cardColor = CalendarColors.kGreenColor;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(
              color: cardColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showAddEditCountdownDialog(
                existingCountdown: countdown,
                index: originalIndex,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.event_note,
                            color: cardColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                countdown.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CalendarColors.kTextColor,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: CalendarColors.kLightTextColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(countdown.targetDate),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: CalendarColors.kLightTextColor,
                                      fontFamily: 'SYMBIOAR+LT',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                color: cardColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${countdown.daysLeft} يوم",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: cardColor,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (countdown.hasNotification) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: CalendarColors.kBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: CalendarColors.kCardBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.notifications_active,
                              color: CalendarColors.kDarkPurple,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'تنبيه قبل الموعد بيوم',
                              style: TextStyle(
                                fontSize: 12,
                                color: CalendarColors.kDarkPurple,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: CalendarColors.kRedColor.withOpacity(0.8),
                          size: 20,
                        ),
                        onPressed: () =>
                            _showDeleteConfirmation(originalIndex, countdown),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'حذف الموعد',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // تنسيق التاريخ لعرضه بشكل أنيق مع اسم اليوم
  String _formatDate(DateTime date) {
    String dayName = _getDayName(date.weekday);
    return "$dayName ${date.day}/${date.month}/${date.year}";
  }

  // تحويل رقم اليوم في الأسبوع إلى اسمه بالعربية
  String _getDayName(int weekday) {
    const Map<int, String> dayNames = {
      1: 'الاثنين',
      2: 'الثلاثاء',
      3: 'الأربعاء',
      4: 'الخميس',
      5: 'الجمعة',
      6: 'السبت',
      7: 'الأحد',
    };
    return dayNames[weekday] ?? '';
  }
}
