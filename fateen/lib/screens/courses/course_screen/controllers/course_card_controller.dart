// controllers/course_card_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/course.dart';
import '../constants/(course_card_constants.dart';

class CourseCardController extends ChangeNotifier {
  User? currentUser;
  List<Course> courses = [];
  bool isLoading = true;

  // قاموس لتخزين ألوان المواد
  Map<String, Color> courseColors = {};

  // قاموس لتخزين ألوان الحدود المقابلة للمواد
  Map<String, Color> courseBorderColors = {};

  // قائمة أيام الأسبوع العربية
  final List<String> arabicDays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];

  CourseCardController() {
    currentUser = FirebaseAuth.instance.currentUser;
    init();
  }

  void init() async {
    await fetchCoursesFromFirestore();
  }

  // جلب المقررات من فايرستور
  Future<void> fetchCoursesFromFirestore() async {
    isLoading = true;
    notifyListeners();

    if (currentUser == null) {
      isLoading = false;
      notifyListeners();
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

      courses = loadedCourses;
      _assignCourseColors(); // تخصيص ألوان للمواد
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('حدث خطأ أثناء جلب المقررات: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  // تخصيص لون لكل مادة
  void _assignCourseColors() {
    courseColors.clear();
    courseBorderColors.clear();

    // تخصيص لون فريد لكل مادة
    int colorIndex = 0;
    for (final course in courses) {
      // إذا كان لدينا أكثر من 10 مواد، سنعيد استخدام الألوان
      colorIndex = colorIndex % CourseCardConstants.courseColorPalette.length;

      courseColors[course.id] =
          CourseCardConstants.courseColorPalette[colorIndex];
      courseBorderColors[course.id] =
          CourseCardConstants.courseBorderColorPalette[colorIndex];

      colorIndex++;
    }
  }

  // البحث عن مقرر
  List<Course> searchCourses(String query) {
    if (query.isEmpty) return courses;

    final lowerCaseQuery = query.toLowerCase();
    return courses.where((course) {
      return course.courseName.toLowerCase().contains(lowerCaseQuery) ||
          course.classroom.toLowerCase().contains(lowerCaseQuery) ||
          course.days.any((day) => day.toLowerCase().contains(lowerCaseQuery));
    }).toList();
  }

  // فرز المقررات
  void sortCourses(String sortBy) {
    switch (sortBy) {
      case 'name':
        courses.sort((a, b) => a.courseName.compareTo(b.courseName));
        break;
      case 'creditHours':
        courses
            .sort((a, b) => (a.creditHours ?? 0).compareTo(b.creditHours ?? 0));
        break;
      case 'day':
        courses.sort((a, b) {
          if (a.days.isEmpty && b.days.isEmpty) return 0;
          if (a.days.isEmpty) return 1;
          if (b.days.isEmpty) return -1;
          return a.days.first.compareTo(b.days.first);
        });
        break;
      default:
        // لا تفعل شيء
        break;
    }
    notifyListeners();
  }

  // حساب مجموع الساعات المعتمدة
  int getTotalCreditHours() {
    return courses.fold(0, (sum, course) => sum + (course.creditHours ?? 0));
  }

  // حساب عدد المواد في كل يوم
  Map<String, int> getCoursesPerDay() {
    Map<String, int> result = {};

    for (final day in arabicDays) {
      result[day] = 0;
    }

    for (final course in courses) {
      for (final day in course.days) {
        if (result.containsKey(day)) {
          result[day] = (result[day] ?? 0) + 1;
        }
      }
    }

    return result;
  }

  // الحصول على ألوان البطاقة للمقرر بناءً على الفهرس
  Map<String, Color> getCourseCardColors(int index) {
    final colorPaletteIndex =
        index % CourseCardConstants.courseColorPalette.length;
    final bgColor = CourseCardConstants.courseColorPalette[colorPaletteIndex];
    final borderColor =
        CourseCardConstants.courseBorderColorPalette[colorPaletteIndex];

    return {
      'background': bgColor,
      'border': borderColor,
    };
  }

  Future<void> removeCourse(String id) async {}
}
