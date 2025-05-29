// schedule_calendar_view_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../models/course.dart';
import '../constants/schedule_calendar_constants.dart';

class ScheduleCalendarViewController extends ChangeNotifier {
  User? currentUser;
  List<Course> allCourses = [];
  bool isLoading = true;

  // قاموس لتخزين ألوان المواد
  Map<String, Color> courseColors = {};

  // قاموس لتخزين ألوان الحدود المقابلة للمواد
  Map<String, Color> courseBorderColors = {};

  // مصفوفة الأيام التي سنعرضها في التقويم
  List<String> get allDays => ScheduleCalendarConstants.arabicDays;

  // مصفوفة الأيام بالإنجليزية للتحقق من اليوم الحالي
  List<String> get englishDays => ScheduleCalendarConstants.englishDays;

  // سنجمع أوقات المحاضرات ديناميكيًا
  List<String> timeSlots = [];

  ScheduleCalendarViewController() {
    currentUser = FirebaseAuth.instance.currentUser;
  }

  /// دالة لجلب المواد من فايرستور
  Future<void> fetchCoursesFromFirestore() async {
    setLoading(true);
    if (currentUser == null) {
      setLoading(false);
      return;
    }

    try {
      final userId = currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      final List<Course> loadedCourses = snapshot.docs.map((doc) {
        final data = doc.data();
        return Course.fromMap(data, doc.id);
      }).toList();

      allCourses = loadedCourses;
      _assignCourseColors(); // تخصيص ألوان للمواد
      _generateDynamicTimeSlots(); // توليد أوقات المحاضرات بناءً على المواد
      setLoading(false);
    } catch (e) {
      debugPrint('حدث خطأ أثناء جلب المقررات من فايرستور: $e');
      setLoading(false);
    }
  }

  // دالة للاستماع للتغييرات في المقررات في الوقت الحقيقي
  Stream<List<Course>> listenToCourses() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    final userId = currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('courses')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Course.fromMap(data, doc.id);
      }).toList();
    });
  }

  // دالة لتحديث المقررات عند تلقي بيانات جديدة
  void updateCourses(List<Course> courses) {
    allCourses = courses;
    _assignCourseColors();
    _generateDynamicTimeSlots();
    notifyListeners();
  }

  // تعيين حالة التحميل
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // تخصيص لون لكل مادة
  void _assignCourseColors() {
    courseColors.clear();
    courseBorderColors.clear();

    // تخصيص لون فريد لكل مادة
    int colorIndex = 0;
    for (final course in allCourses) {
      // إذا كان لدينا أكثر من 10 مواد، سنعيد استخدام الألوان
      colorIndex =
          colorIndex % ScheduleCalendarConstants.courseColorPalette.length;

      courseColors[course.id] =
          ScheduleCalendarConstants.courseColorPalette[colorIndex];
      courseBorderColors[course.id] =
          ScheduleCalendarConstants.courseBorderColorPalette[colorIndex];

      colorIndex++;
    }
  }

  // توليد أوقات المحاضرات ديناميكيًا
  void _generateDynamicTimeSlots() {
    Set<String> uniqueTimes = {};

    // جمع كل أوقات المحاضرات من جميع المواد
    for (final course in allCourses) {
      if (course.lectureTime != null && course.lectureTime!.isNotEmpty) {
        uniqueTimes.add(course.lectureTime!);
      }
    }

    // إذا لم توجد أوقات، استخدم الأوقات الافتراضية
    if (uniqueTimes.isEmpty) {
      timeSlots = List.from(ScheduleCalendarConstants.defaultTimeSlots);
      return;
    }

    // تحويل إلى قائمة وترتيبها
    timeSlots = uniqueTimes.toList();
    timeSlots.sort((a, b) {
      final timeA = _extractTime(a);
      final timeB = _extractTime(b);

      if (timeA['hour'] != timeB['hour']) {
        return timeA['hour']!.compareTo(timeB['hour']!);
      }
      return timeA['minute']!.compareTo(timeB['minute']!);
    });
  }

  // استخراج ساعات ودقائق من وقت المحاضرة
  Map<String, int> _extractTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return {'hour': 0, 'minute': 0};
    }

    final parts = timeString.split(':');
    if (parts.length != 2) {
      return {'hour': 0, 'minute': 0};
    }

    return {
      'hour': int.tryParse(parts[0]) ?? 0,
      'minute': int.tryParse(parts[1]) ?? 0,
    };
  }

  // فرز المحاضرات حسب وقتها
  List<Course> getCoursesForDaySorted(String day) {
    final courses = allCourses.where((c) => c.days.contains(day)).toList();

    // ترتيب المقررات حسب وقت المحاضرة
    courses.sort((a, b) {
      final timeA = _extractTime(a.lectureTime);
      final timeB = _extractTime(b.lectureTime);

      if (timeA['hour'] != timeB['hour']) {
        return timeA['hour']!.compareTo(timeB['hour']!);
      }
      return timeA['minute']!.compareTo(timeB['minute']!);
    });

    return courses;
  }

  // التحقق إذا كان هناك محاضرة في وقت معين وليوم معين
  Course? getCourseAtTimeSlot(String day, String timeSlot) {
    final courses = getCoursesForDaySorted(day);

    for (final course in courses) {
      if (course.lectureTime == null) continue;

      // نتحقق من تطابق الوقت تمامًا
      if (course.lectureTime == timeSlot) {
        return course;
      }
    }
    return null;
  }

  // التحقق من الوقت الحالي مقارنة بوقت المحاضرة
  bool isCurrentTime(String timeSlot) {
    final now = DateTime.now();
    final timeData = _extractTime(timeSlot);
    return timeData['hour'] == now.hour;
  }

  // التحقق من اليوم الحالي
  bool isCurrentDay(String day) {
    final today = DateFormat('EEEE').format(DateTime.now());
    final dayIndex = allDays.indexOf(day);
    return dayIndex >= 0 && englishDays[dayIndex] == today;
  }
}
