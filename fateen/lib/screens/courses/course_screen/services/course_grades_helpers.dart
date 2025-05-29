import 'package:flutter/material.dart';
import '../constants/grades/course_grades_colors.dart';

class CourseGradesHelpers {
  // عرض رسالة
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false, bool isSuccess = false}) {
    Color backgroundColor = Colors.grey.shade800;

    if (isError) {
      backgroundColor = CourseGradesColors.errorColor;
    } else if (isSuccess) {
      backgroundColor = CourseGradesColors.successColor;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // معالج الأخطاء
  static void handleError(BuildContext context, String errorMessage) {
    debugPrint('خطأ: $errorMessage');
    showSnackBar(context, errorMessage, isError: true);
  }

  // تنسيق الدرجة لعرضها
  static String formatGrade(double grade) {
    if (grade == grade.toInt().toDouble()) {
      return grade.toInt().toString();
    }
    return grade.toStringAsFixed(1);
  }

  // التحقق من اسم الاختبار
  static bool isValidAssignmentName(String name) {
    return name.trim().isNotEmpty;
  }

  // التحقق من الدرجة
  static bool isValidGrade(String gradeStr) {
    try {
      final grade = double.parse(gradeStr);
      return grade >= 0;
    } catch (e) {
      return false;
    }
  }

  // التحقق من الدرجة القصوى
  static bool isValidMaxGrade(String maxGradeStr) {
    try {
      final maxGrade = double.parse(maxGradeStr);
      return maxGrade > 0;
    } catch (e) {
      return false;
    }
  }
}
