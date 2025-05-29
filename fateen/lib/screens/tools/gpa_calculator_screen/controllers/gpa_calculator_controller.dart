import 'package:flutter/material.dart';
import '../../../../models/course_item.dart';
import '../../../../models/course.dart';
import '../constants/gpa_calculator_constants.dart';

class GPACalculatorController extends ChangeNotifier {
  List<CourseItem> courses = [];
  List<Course> actualCourses = [];
  bool isCoursesImported = false;

  final TextEditingController currentGpaController = TextEditingController();
  final TextEditingController completedHoursController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AnimationController? animationController;
  Animation<double>? fadeAnimation;

  bool _isSystem5 = true;

  bool get isSystem5 => _isSystem5;

  void toggleGPASystem(bool useSystem5) {
    _isSystem5 = useSystem5;

    if (actualCourses.isNotEmpty) {
      loadCoursesFromData(actualCourses);
    }

    if (_onUpdateListener != null) {
      _onUpdateListener!();
    }
  }

  double currentGPA = 0.0;
  double termGPA = 0.0;
  double cumulativeGPA = 0.0;
  double totalCredits = 0.0;
  double totalPoints = 0.0;

  Function()? _onUpdateListener;

  void setUpdateListener(Function() listener) {
    _onUpdateListener = listener;
  }

  void init(TickerProvider vsync) {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeOut,
    );

    animationController!.forward();
    addCourse();
  }

  void addCourse() {
    courses.add(CourseItem(
      nameController: TextEditingController(),
      creditsController: TextEditingController(),
      grade: 'A',
    ));

    if (_onUpdateListener != null) {
      _onUpdateListener!();
    }
  }

  bool removeCourse(int index) {
    if (courses.length > 1) {
      CourseItem course = courses[index];
      course.nameController.dispose();
      course.creditsController.dispose();
      courses.removeAt(index);

      if (_onUpdateListener != null) {
        _onUpdateListener!();
      }

      return true;
    }
    return false;
  }

  void updateCourseGrade(int index, String newGrade) {
    courses[index].grade = newGrade;

    if (_onUpdateListener != null) {
      _onUpdateListener!();
    }
  }

  void importCourses(List<Map<String, dynamic>> coursesList) {
    for (var course in courses) {
      course.nameController.dispose();
      course.creditsController.dispose();
    }
    courses.clear();

    for (var courseData in coursesList) {
      final nameController =
          TextEditingController(text: courseData['courseName']);
      final creditsController =
          TextEditingController(text: courseData['creditHours']);
      final grade = courseData['grade'];

      courses.add(CourseItem(
        nameController: nameController,
        creditsController: creditsController,
        grade: grade,
      ));
    }

    if (_onUpdateListener != null) {
      _onUpdateListener!();
    }
  }

  void loadCoursesFromData(List<Course> coursesList) {
    actualCourses = coursesList;
    isCoursesImported = true;

    print("DEBUG: تم استلام ${coursesList.length} مقرر للتحميل");

    for (var course in courses) {
      course.nameController.dispose();
      course.creditsController.dispose();
    }
    courses.clear();

    for (var actualCourse in coursesList) {
      print("DEBUG: معالجة المقرر: ${actualCourse.courseName}");
      print("DEBUG: عدد الدرجات المخزنة: ${actualCourse.grades.length}");

      if (actualCourse.grades.isNotEmpty) {
        String grade = getLetterGradeFromTotalScore(actualCourse);

        final nameController =
            TextEditingController(text: actualCourse.courseName);
        final creditsController =
            TextEditingController(text: actualCourse.creditHours.toString());

        courses.add(CourseItem(
          nameController: nameController,
          creditsController: creditsController,
          grade: grade,
        ));

        print(
            "DEBUG: تمت إضافة المقرر: ${actualCourse.courseName} بتقدير $grade");
      } else {
        print("DEBUG: تجاهل المقرر ${actualCourse.courseName} لعدم وجود درجات");
      }
    }

    if (courses.isEmpty) {
      print("DEBUG: لا توجد مقررات بدرجات، إضافة مقرر افتراضي");
      addCourse();
    }

    print("DEBUG: حساب المعدل تلقائياً");
    calculateGPA();

    if (_onUpdateListener != null) {
      _onUpdateListener!();
    }
  }

  // دالة: حساب التقدير بناءً على مجموع الدرجات فقط
  String getLetterGradeFromTotalScore(Course course) {
    if (course.grades.isEmpty) {
      return 'A';
    }

    double totalScore = 0.0;

    print("DEBUG: حساب مجموع الدرجات للمقرر ${course.courseName}");

    // جمع الدرجات الفعلية فقط
    course.grades.forEach((assignment, actualGrade) {
      print("DEBUG: التقييم: $assignment, الدرجة: $actualGrade");
      totalScore += actualGrade;
    });

    print("DEBUG: مجموع الدرجات الفعلية: $totalScore");

    // تحديد التقدير بناءً على مجموع الدرجات
    String grade = getLetterGradeFromScore(totalScore);
    print("DEBUG: التقدير النهائي: $grade");

    return grade;
  }

  // دالة: تحويل مجموع الدرجات إلى تقدير حرفي
  String getLetterGradeFromScore(double score) {
    if (score >= 95) return 'A+';
    if (score >= 90) return 'A';
    if (score >= 85) return 'B+';
    if (score >= 80) return 'B';
    if (score >= 75) return 'C+';
    if (score >= 70) return 'C';
    if (score >= 65) return 'D+';
    if (score >= 60) return 'D';
    return 'F';
  }

  double getGradePoints(String grade) {
    if (_isSystem5) {
      return GPACalculatorConstants.gradePoints5[grade] ?? 0.0;
    } else {
      return GPACalculatorConstants.gradePoints4[grade] ?? 0.0;
    }
  }

  bool calculateGPA() {
    print("DEBUG: بدء حساب المعدل");

    if (!formKey.currentState!.validate()) {
      print("DEBUG: فشل التحقق من صحة النموذج");
      return false;
    }

    double totalTermCredits = 0.0;
    double totalTermPoints = 0.0;

    for (var course in courses) {
      if (course.creditsController.text.isNotEmpty) {
        double credits = double.parse(course.creditsController.text);
        double gradePoints = getGradePoints(course.grade);
        double points = gradePoints * credits;

        print(
            "DEBUG: المقرر: ${course.nameController.text}, الساعات: $credits, التقدير: ${course.grade}, النقاط: $gradePoints, المجموع: $points");

        totalTermCredits += credits;
        totalTermPoints += points;
      }
    }

    print(
        "DEBUG: إجمالي الساعات: $totalTermCredits, إجمالي النقاط: $totalTermPoints");

    double termGpa =
        totalTermCredits > 0 ? totalTermPoints / totalTermCredits : 0.0;
    print("DEBUG: معدل الفصل: $termGpa");

    double cumulativeGpa = 0.0;
    if (currentGpaController.text.isNotEmpty &&
        completedHoursController.text.isNotEmpty) {
      double previousGpa = double.parse(currentGpaController.text);
      double completedHours = double.parse(completedHoursController.text);

      print(
          "DEBUG: المعدل السابق: $previousGpa, الساعات المنجزة: $completedHours");

      double previousPoints = previousGpa * completedHours;
      double totalPoints = previousPoints + totalTermPoints;
      double totalHours = completedHours + totalTermCredits;

      print(
          "DEBUG: نقاط سابقة: $previousPoints, إجمالي النقاط: $totalPoints, إجمالي الساعات: $totalHours");

      cumulativeGpa = totalHours > 0 ? totalPoints / totalHours : 0.0;
      print("DEBUG: المعدل التراكمي: $cumulativeGpa");
    } else {
      cumulativeGpa = termGpa;
      print(
          "DEBUG: لا يوجد معدل سابق، المعدل التراكمي = معدل الفصل: $cumulativeGpa");
    }

    termGPA = termGpa;
    cumulativeGPA = cumulativeGpa;
    totalCredits = totalTermCredits;
    totalPoints = totalTermPoints;

    if (_onUpdateListener != null) {
      _onUpdateListener!();
    }

    return true;
  }

  Color getGPAColor(double gpa) {
    if (_isSystem5) {
      if (gpa >= 4.5) return GPACalculatorConstants.kGreenColor;
      if (gpa >= 3.75) return const Color(0xFF3F51B5);
      if (gpa >= 2.75) return const Color(0xFFFFA726);
      if (gpa >= 2.0) return const Color(0xFFFF9800);
      return GPACalculatorConstants.kAccentColor;
    } else {
      if (gpa >= 3.5) return GPACalculatorConstants.kGreenColor;
      if (gpa >= 3.0) return const Color(0xFF3F51B5);
      if (gpa >= 2.0) return const Color(0xFFFFA726);
      if (gpa >= 1.0) return const Color(0xFFFF9800);
      return GPACalculatorConstants.kAccentColor;
    }
  }

  String getGPAGrade(double gpa) {
    if (_isSystem5) {
      if (gpa >= 4.5) return 'ممتاز مرتفع';
      if (gpa >= 3.75) return 'ممتاز';
      if (gpa >= 2.75) return 'جيد جداً';
      if (gpa >= 2.0) return 'جيد';
      if (gpa >= 1.0) return 'مقبول';
      return 'راسب';
    } else {
      if (gpa >= 3.5) return 'ممتاز مرتفع';
      if (gpa >= 3.0) return 'ممتاز';
      if (gpa >= 2.0) return 'جيد جداً';
      if (gpa >= 1.0) return 'جيد';
      if (gpa > 0.0) return 'مقبول';
      return 'راسب';
    }
  }

  void dispose() {
    currentGpaController.dispose();
    completedHoursController.dispose();
    animationController?.dispose();

    for (var course in courses) {
      course.nameController.dispose();
      course.creditsController.dispose();
    }
  }
}
