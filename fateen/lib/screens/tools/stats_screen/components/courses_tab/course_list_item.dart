// components/courses_tab/course_list_item.dart

import 'package:flutter/material.dart';
import '../../constants/stats_colors.dart';
import '../../constants/stats_strings.dart';
import '../../../../../models/course_model.dart';
import '../../controllers/stats_controller.dart';
import 'course_stats_grid.dart';
import 'grade_list_item.dart';

class CourseListItem extends StatelessWidget {
  final Course course;
  final StatsController controller;

  const CourseListItem({
    Key? key,
    required this.course,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avg = course.calculateAverage();
    final advice = StatsStrings.getCourseAdvice(avg);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          color: const Color(0xFFE3E0F8),
          width: 1.0,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: const Color(0xFFE3E0F8),
        ),
        child: ExpansionTile(
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: StatsColors.getGradeStatusColor(avg).withOpacity(0.1),
            ),
            child: Icon(
              controller.getGradeIcon(avg),
              color: StatsColors.getGradeStatusColor(avg),
              size: 20,
            ),
          ),
          title: Text(
            course.courseName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "${StatsStrings.courseAverage} ${avg.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 13,
                  color: StatsColors.getGradeStatusColor(avg),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${StatsStrings.evaluationsCount} ${course.grades.length}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            // معلومات إضافية عن المقرر
            CourseStatsGrid(course: course),
            const SizedBox(height: 16),

            // توجيه للمقرر
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: StatsColors.kDarkPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advice['message'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: StatsColors.kDarkPurple,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // قائمة الدرجات
            if (course.grades.isEmpty)
              Center(
                child: Text(
                  StatsStrings.noGradesAdded,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    StatsStrings.gradesDetails,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: course.grades.length,
                    itemBuilder: (context, idx) {
                      final entry = course.grades.entries.elementAt(idx);
                      final assignmentName = entry.key;
                      final score = entry.value;

                      // استخدام الدرجة القصوى من قاعدة البيانات
                      double maxScore =
                          100.0; // قيمة افتراضية في حالة عدم وجود بيانات

                      // التحقق من وجود الدرجة القصوى في البيانات
                      if (course.maxGrades != null &&
                          course.maxGrades.containsKey(assignmentName)) {
                        maxScore = course.maxGrades[assignmentName]!;
                      }

                      return GradeListItem(
                        title: assignmentName,
                        value: score,
                        maxValue: maxScore,
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
