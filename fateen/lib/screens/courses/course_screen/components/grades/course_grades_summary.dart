// course_grades_summary.dart

import 'package:flutter/material.dart';
import '../../../../../models/course.dart';
import '../../constants/grades/course_grades_colors.dart';
import '../../controllers/course_grades_controller.dart';
import '../../../../../core/constants/appColor.dart';
import '../../../../../core/constants/app_dimensions.dart';

class CourseGradesSummary extends StatelessWidget {
  final Course course;
  final CourseGradesController controller;

  const CourseGradesSummary({
    Key? key,
    required this.context,
    required this.course,
    required this.controller,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    // حساب متوسط الدرجات
    final averageInfo = _calculateAverageGrade();
    final double averagePercentage = averageInfo['percentage']!;
    final Color gradeColor = _getGradeColor(averagePercentage);

    // عدد التقييمات
    final int totalAssignments = course.grades.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.colorShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade700.withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        child: Row(
          children: [
            // عرض الدرجة الدائري
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // الدائرة الخارجية
                  CircularProgressIndicator(
                    value: averagePercentage / 100,
                    strokeWidth: 5,
                    backgroundColor: context.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                  ),
                  // الدائرة الداخلية
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: context.colorSurface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.colorShadowColor,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(
                        color: context.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${averagePercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: gradeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 18),

            // تفاصيل التقدم
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // عنوان المتوسط
                  Text(
                    'متوسط الدرجات',
                    style: TextStyle(
                      color: context.colorTextPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),

                  const SizedBox(height: 10),

                  // عدد التقييمات
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: context.colorPrimaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.assignment_outlined,
                          color: context.colorPrimaryDark,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'عدد التقييمات: $totalAssignments',
                        style: TextStyle(
                          color: context.colorTextSecondary,
                          fontSize: 13,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // وصف الأداء
            _buildPerformanceTag(averagePercentage),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTag(double percentage) {
    final String performanceText = _getPerformanceText(percentage);
    final Color performanceColor = _getGradeColor(percentage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: performanceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: performanceColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        performanceText,
        style: TextStyle(
          color: performanceColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
    );
  }

  // حساب متوسط الدرجات ونسبتها المئوية
  Map<String, double> _calculateAverageGrade() {
    if (course.grades.isEmpty) {
      return {'percentage': 0.0, 'points': 0.0};
    }

    double totalPercentage = 0.0;
    int validGradesCount = 0;

    course.grades.forEach((assignment, grade) {
      final maxGrade = course.maxGrades[assignment] ?? 100.0;
      if (maxGrade > 0) {
        final percentage = (grade / maxGrade) * 100;
        totalPercentage += percentage;
        validGradesCount++;
      }
    });

    final averagePercentage =
        validGradesCount > 0 ? totalPercentage / validGradesCount : 0.0;

    // تحويل النسبة المئوية إلى نقاط GPA (مقياس من 0 إلى 4)
    final gpaPoints = _percentageToGPA(averagePercentage);

    return {
      'percentage': averagePercentage,
      'points': gpaPoints,
    };
  }

  // تحويل النسبة المئوية إلى GPA
  double _percentageToGPA(double percentage) {
    if (percentage >= 95) return 4.0;
    if (percentage >= 90) return 3.7;
    if (percentage >= 85) return 3.3;
    if (percentage >= 80) return 3.0;
    if (percentage >= 75) return 2.7;
    if (percentage >= 70) return 2.3;
    if (percentage >= 65) return 2.0;
    if (percentage >= 60) return 1.7;
    if (percentage >= 55) return 1.3;
    if (percentage >= 50) return 1.0;
    return 0.0;
  }

  // الحصول على لون الدرجة بناءً على النسبة المئوية
  Color _getGradeColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.amber;
    if (percentage >= 60) return Colors.orange;
    return Colors.redAccent;
  }

  // الحصول على وصف مستوى الأداء
  String _getPerformanceText(double percentage) {
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 80) return 'جيد جداً';
    if (percentage >= 70) return 'جيد';
    if (percentage >= 60) return 'مقبول';
    return 'ضعيف';
  }
}
