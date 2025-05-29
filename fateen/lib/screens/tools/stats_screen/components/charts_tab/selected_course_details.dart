// components/charts_tab/selected_course_details.dart

import 'package:flutter/material.dart';
import '../../constants/stats_colors.dart';
import '../../constants/stats_strings.dart';
import '../../../../../models/course_model.dart';
import '../courses_tab/course_stats_grid.dart';
import '../courses_tab/grade_list_item.dart';

class SelectedCourseDetails extends StatelessWidget {
  final Course course;

  const SelectedCourseDetails({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE3E0F8),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: StatsColors.kDarkPurple.withOpacity(0.1),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: StatsColors.kDarkPurple,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${StatsStrings.courseDetails} ${course.courseName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // إحصائيات الدرجات
          CourseStatsGrid(course: course),

          // قائمة الدرجات
          if (course.grades.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              StatsStrings.topAndBottom,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 8),

            // الدرجات مرتبة
            ...course.grades.entries
                .toList()
                .sorted((a, b) => b.value.compareTo(a.value))
                .take(2)
                .map((entry) {
              final assignmentName = entry.key;
              final score = entry.value;

              // استخدام الدرجة القصوى من قاعدة البيانات
              double maxScore = 100.0; // قيمة افتراضية في حالة عدم وجود بيانات

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
            }).toList(),

            if (course.grades.length > 2) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '+ ${course.grades.length - 2} ${StatsStrings.moreGrades}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
