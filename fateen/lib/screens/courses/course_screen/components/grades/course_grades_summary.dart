// course_grades_summary.dart

import 'package:flutter/material.dart';
import '../../../../../models/course.dart';
import '../../constants/grades/course_grades_colors.dart';
import '../../controllers/course_grades_controller.dart';

class CourseGradesSummary extends StatelessWidget {
  final Course course;
  final CourseGradesController controller;

  const CourseGradesSummary({
    Key? key,
    required this.course,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // حساب متوسط الدرجات والدرجة الكلية فوراً
    final averageInfo = _calculateAverageGrade();
    final double averagePercentage = averageInfo['percentage']!;
    final double averagePoints = averageInfo['points']!;
    final String letterGrade = _getLetterGrade(averagePercentage);
    final Color gradeColor = _getGradeColor(averagePercentage);

    // حساب معلومات التقدم
    final int totalAssignments = course.grades.length;
    final int passedAssignments = _getPassedAssignmentsCount();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CourseGradesColors.darkPurple.withOpacity(0.8),
            CourseGradesColors.mediumPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CourseGradesColors.darkPurple.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            const Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'ملخص الأداء',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // معلومات الدرجات
            Row(
              children: [
                // عرض الدرجة الدائري
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: averagePercentage / 100,
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${averagePercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          Text(
                            letterGrade,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // تفاصيل التقدم
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // عدد التقييمات
                      Row(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'التقييمات: $totalAssignments',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // عدد التقييمات الناجحة
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'النجاح: $passedAssignments/$totalAssignments',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // المعدل
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'المعدل: ${averagePoints.toStringAsFixed(2)} نقطة',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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

  // تحويل النسبة المئوية إلى تقدير حرفي
  String _getLetterGrade(double percentage) {
    if (percentage >= 95) return 'A+';
    if (percentage >= 90) return 'A';
    if (percentage >= 85) return 'B+';
    if (percentage >= 80) return 'B';
    if (percentage >= 75) return 'C+';
    if (percentage >= 70) return 'C';
    if (percentage >= 65) return 'D+';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  // الحصول على لون الدرجة بناءً على النسبة المئوية
  Color _getGradeColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.amber;
    if (percentage >= 60) return Colors.orange;
    return Colors.redAccent;
  }

  // حساب عدد التقييمات الناجحة (60% فأعلى)
  int _getPassedAssignmentsCount() {
    int count = 0;
    course.grades.forEach((assignment, grade) {
      final maxGrade = course.maxGrades[assignment] ?? 100.0;
      if (maxGrade > 0) {
        final percentage = (grade / maxGrade) * 100;
        if (percentage >= 60) {
          count++;
        }
      }
    });
    return count;
  }
}
