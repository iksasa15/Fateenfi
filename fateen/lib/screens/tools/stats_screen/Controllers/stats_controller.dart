// controllers/stats_controller.dart

import 'package:flutter/material.dart';
import '../../../../models/course_model.dart';
import '../constants/stats_strings.dart';

class StatsController extends ChangeNotifier {
  // حالة الفرز
  String _sortOption = 'name'; // name أو average
  int? _touchedIndex; // المؤشر المختار في الرسم البياني
  int _selectedChartIndex = -1; // المقرر المختار في مخطط المتوسطات

  // الحصول على القيم الحالية
  String get sortOption => _sortOption;
  int? get touchedIndex => _touchedIndex;
  int get selectedChartIndex => _selectedChartIndex;

  // تغيير خيار الفرز
  void setSortOption(String value) {
    if (_sortOption != value) {
      _sortOption = value;
      notifyListeners();
    }
  }

  // تعيين المؤشر المحدد في المخطط الدائري
  void setTouchedIndex(int? index) {
    _touchedIndex = index;
    notifyListeners();
  }

  // تعيين المقرر المحدد في مخطط المتوسطات
  void setSelectedChartIndex(int index) {
    if (_selectedChartIndex == index) {
      _selectedChartIndex = -1;
    } else {
      _selectedChartIndex = index;
    }
    notifyListeners();
  }

  // فرز المقررات
  List<Course> sortCourses(List<Course> courses) {
    if (_sortOption == 'average') {
      return List.of(courses)
        ..sort((a, b) => b.calculateAverage().compareTo(a.calculateAverage()));
    } else {
      return List.of(courses)
        ..sort((a, b) => a.courseName.compareTo(b.courseName));
    }
  }

  // الحصول على الدرجة القصوى للتقييم
  double getMaxGradeForAssignment(
      Course course, String assignmentName, double gradeValue) {
    // استخدام الدرجة القصوى من قاعدة البيانات إن وجدت
    if (course.maxGrades != null &&
        course.maxGrades.containsKey(assignmentName)) {
      return course.maxGrades[assignmentName]!;
    }

    // في حالة عدم وجود الدرجة القصوى في قاعدة البيانات،
    // نستخدم الدرجة الفعلية نفسها كدرجة قصوى
    return gradeValue;
  }

  // حساب المتوسط الكلي لجميع المقررات
  double calculateOverallAverage(List<Course> courses) {
    double totalGradesSum = 0.0; // مجموع الدرجات الفعلية
    int totalGradesCount = 0; // عدد الدرجات الكلي

    for (Course c in courses) {
      if (c.grades == null || c.grades.isEmpty) continue;

      try {
        // جمع كل الدرجات الفعلية في المقرر
        c.grades.forEach((assignment, gradeValue) {
          totalGradesSum += gradeValue; // إضافة الدرجة الفعلية فقط للمجموع
          totalGradesCount++; // زيادة عداد الدرجات
        });
      } catch (e) {
        print("خطأ في معالجة درجات المقرر ${c.courseName}: $e");
      }
    }

    // حساب المتوسط: مجموع الدرجات الفعلية مقسوماً على عدد الدرجات
    return totalGradesCount > 0 ? totalGradesSum / totalGradesCount : 0.0;
  }

  // حساب توزيع المقررات حسب مجموع درجاتها - كل مقرر يتم تصنيفه مرة واحدة فقط
  Map<String, int> calculateGradeDistribution(List<Course> courses) {
    final distribution = {
      'أقل من 60': 0,
      '60 - 69': 0,
      '70 - 79': 0,
      '80 - 89': 0,
      '90 - 100': 0,
    };

    for (var course in courses) {
      if (course.grades == null || course.grades.isEmpty) continue;

      try {
        // حساب مجموع الدرجات في المقرر
        double totalGrades = 0.0;
        course.grades.forEach((_, gradeValue) {
          totalGrades += gradeValue;
        });

        // تصنيف المقرر بناءً على مجموع درجاته
        if (totalGrades < 60) {
          distribution['أقل من 60'] = distribution['أقل من 60']! + 1;
        } else if (totalGrades < 70) {
          distribution['60 - 69'] = distribution['60 - 69']! + 1;
        } else if (totalGrades < 80) {
          distribution['70 - 79'] = distribution['70 - 79']! + 1;
        } else if (totalGrades < 90) {
          distribution['80 - 89'] = distribution['80 - 89']! + 1;
        } else {
          distribution['90 - 100'] = distribution['90 - 100']! + 1;
        }
      } catch (e) {
        print("خطأ في حساب توزيع الدرجات للمقرر ${course.courseName}: $e");
      }
    }

    return distribution;
  }

  // استخراج المقررات التي يقع مجموع درجاتها ضمن فئة معينة
  List<Map<String, dynamic>> getGradesInRange(
      String range, List<Course> courses) {
    if (range.isEmpty) {
      return [];
    }

    final selectedCourses = <Map<String, dynamic>>[];

    for (var course in courses) {
      if (course.grades == null || course.grades.isEmpty) continue;

      try {
        // حساب مجموع الدرجات في المقرر
        double totalGrades = 0.0;
        course.grades.forEach((_, gradeValue) {
          totalGrades += gradeValue;
        });

        bool isInRange = false;

        // تحديد الفئة بناءً على مجموع الدرجات
        switch (range) {
          case 'أقل من 60':
            isInRange = totalGrades < 60;
            break;
          case '60 - 69':
            isInRange = totalGrades >= 60 && totalGrades < 70;
            break;
          case '70 - 79':
            isInRange = totalGrades >= 70 && totalGrades < 80;
            break;
          case '80 - 89':
            isInRange = totalGrades >= 80 && totalGrades < 90;
            break;
          case '90 - 100':
            isInRange = totalGrades >= 90;
            break;
          default:
            isInRange = false;
        }

        if (isInRange) {
          // إضافة المقرر كامل مع مجموع درجاته
          selectedCourses.add({
            'courseName': course.courseName,
            'totalGrades': totalGrades,
            'course': course,
          });
        }
      } catch (e) {
        print(
            "خطأ في استخراج المقررات ضمن النطاق $range للمقرر ${course.courseName}: $e");
      }
    }

    return selectedCourses;
  }

  // الحصول على الأيقونة المناسبة للدرجة
  IconData getGradeIcon(double grade) {
    if (grade >= 90) {
      return Icons.emoji_events; // كأس/جائزة
    } else if (grade >= 80) {
      return Icons.star; // نجمة
    } else if (grade >= 70) {
      return Icons.thumb_up; // إعجاب
    } else if (grade >= 60) {
      return Icons.thumbs_up_down; // محايد
    } else {
      return Icons.warning; // تحذير
    }
  }

  // إيجاد أعلى وأدنى مقرر من حيث المتوسط
  Map<String, Course?> getHighestAndLowestCourses(List<Course> courses) {
    if (courses.isEmpty) {
      return {'highest': null, 'lowest': null};
    }

    try {
      courses = List.from(courses);
      courses
          .sort((a, b) => b.calculateAverage().compareTo(a.calculateAverage()));

      return {
        'highest': courses.first,
        'lowest': courses.last,
      };
    } catch (e) {
      print("خطأ في تحديد أعلى وأدنى مقرر: $e");
      return {'highest': null, 'lowest': null};
    }
  }
}
