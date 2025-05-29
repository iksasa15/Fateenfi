// days_tabs_controller.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/days_tabs_constants.dart';
import '../../../../models/course.dart';

class DaysTabsController extends ChangeNotifier {
  int selectedDayIndex = 0; // اليوم المحدد افتراضيًا
  List<Course> _courses = []; // قائمة المقررات المحملة من Firebase

  // مصفوفة الأيام التي سنعرضها في التقويم
  List<String> get allDays => DaysTabsConstants.arabicDays;

  // مصفوفة الأيام بالإنجليزية للتحقق من اليوم الحالي
  List<String> get englishDays => DaysTabsConstants.englishDays;

  DaysTabsController();

  // تحديث قائمة المقررات
  void updateCourses(List<Course> courses) {
    _courses = courses;
    notifyListeners();
  }

  // تعيين اليوم المحدد
  void setSelectedDayIndex(int index) {
    if (index >= 0 && index < allDays.length) {
      selectedDayIndex = index;
      notifyListeners();
    }
  }

  // الحصول على عدد المحاضرات في يوم معين
  int getCoursesCountForDay(String day) {
    return _courses.where((c) => c.days.contains(day)).length;
  }

  // الحصول على قائمة المحاضرات ليوم معين (مرتبة حسب الوقت)
  List<Course> getCoursesForDaySorted(String day) {
    final courses = _courses.where((c) => c.days.contains(day)).toList();

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

  // التحقق من اليوم الحالي
  bool isCurrentDay(String day) {
    final today = DateFormat('EEEE').format(DateTime.now());
    final dayIndex = allDays.indexOf(day);
    return dayIndex >= 0 && englishDays[dayIndex] == today;
  }

  // تعيين اليوم الحالي كافتراضي إذا كان ضمن أيام الأسبوع
  void setTodayAsDefault() {
    final today = DateFormat('EEEE').format(DateTime.now());
    final foundIndex = englishDays.indexOf(today);
    if (foundIndex != -1) {
      setSelectedDayIndex(foundIndex);
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
}
