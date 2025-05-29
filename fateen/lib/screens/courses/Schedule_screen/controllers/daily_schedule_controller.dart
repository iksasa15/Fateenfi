// daily_schedule_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../models/course.dart';
import '../constants/daily_schedule_constants.dart';

class DailyScheduleController extends ChangeNotifier {
  User? currentUser;
  List<Course> allCourses = [];
  bool isLoading = true;
  int selectedDayIndex = 0; // اليوم المحدد افتراضيًا

  // قاموس لتخزين ألوان المواد
  Map<String, Color> courseColors = {};

  // قاموس لتخزين ألوان الحدود المقابلة للمواد
  Map<String, Color> courseBorderColors = {};

  // مصفوفة الأيام التي سنعرضها في الجدول
  List<String> get allDays => DailyScheduleConstants.arabicDays;

  // مصفوفة الأيام بالإنجليزية للتحقق من اليوم الحالي
  List<String> get englishDays => DailyScheduleConstants.englishDays;

  // الحصول على اليوم الحالي بالإنجليزية
  String get todayEnglish => DateFormat('EEEE').format(DateTime.now());

  DailyScheduleController() {
    currentUser = FirebaseAuth.instance.currentUser;
    _initializeSelectedDay();
  }

  // تعيين اليوم الحالي كيوم مختار افتراضي
  void _initializeSelectedDay() {
    final today = todayEnglish;
    final foundIndex = englishDays.indexOf(today);
    if (foundIndex != -1) {
      selectedDayIndex = foundIndex;
    }
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
          colorIndex % DailyScheduleConstants.courseColorPalette.length;

      courseColors[course.id] =
          DailyScheduleConstants.courseColorPalette[colorIndex];
      courseBorderColors[course.id] =
          DailyScheduleConstants.courseBorderColorPalette[colorIndex];

      colorIndex++;
    }
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

  // الحصول على قائمة المحاضرات لليوم المحدد حاليًا
  List<Course> getCoursesForCurrentSelectedDay() {
    final selectedDay = allDays[selectedDayIndex];
    return getCoursesForDaySorted(selectedDay);
  }

  // تعيين اليوم المحدد
  void setSelectedDayIndex(int index) {
    if (index >= 0 && index < allDays.length) {
      selectedDayIndex = index;
      notifyListeners();
    }
  }

  // التحقق من اليوم الحالي
  bool isCurrentDay(String day) {
    final today = todayEnglish;
    final dayIndex = allDays.indexOf(day);
    return dayIndex >= 0 && englishDays[dayIndex] == today;
  }
}
