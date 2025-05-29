import 'package:flutter/material.dart';
import '../../../../../models/course.dart';
import '../../constants/grades/course_grades_colors.dart';
import '../../controllers/course_grades_controller.dart';

class CourseGradesList extends StatelessWidget {
  final Course course;
  final CourseGradesController controller;
  final Function(String, double, double) onEditGrade;
  final Function(String) onDeleteGrade;

  const CourseGradesList({
    Key? key,
    required this.course,
    required this.controller,
    required this.onEditGrade,
    required this.onDeleteGrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(
        "DEBUG LIST: Building course grades list with ${course.grades.length} grades");

    if (course.grades.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      itemCount: course.grades.length,
      itemBuilder: (context, index) {
        final entry = course.grades.entries.elementAt(index);
        final assignment = entry.key;
        final actualGrade = entry.value; // الدرجة الفعلية مباشرة

        // الحصول على الدرجة القصوى
        final maxGrade = course.maxGrades.containsKey(assignment)
            ? course.maxGrades[assignment]!
            : controller.getCustomMaxGrade(course, assignment);

        print(
            "DEBUG LIST: Displaying grade for $assignment: $actualGrade/$maxGrade");

        return buildGradeCard(
          assignment: assignment,
          actualGrade: actualGrade,
          maxGrade: maxGrade,
        );
      },
    );
  }

  Widget buildGradeCard({
    required String assignment,
    required double actualGrade,
    required double maxGrade,
  }) {
    // تحديد لون الدرجة باستخدام الدرجة الفعلية والقصوى
    final gradeColor = controller.getGradeColor(actualGrade, maxGrade);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CourseGradesColors.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CourseGradesColors.lightPurple,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CourseGradesColors.borderLightPurple,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.assignment_outlined,
                size: 20,
                color: CourseGradesColors.darkPurple,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                Text(
                  '${actualGrade.toStringAsFixed(1)} / ${maxGrade.toStringAsFixed(1)}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: CourseGradesColors.textLightColor,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          ),
          // زر التعديل
          IconButton(
            onPressed: () => onEditGrade(assignment, actualGrade, maxGrade),
            icon: const Icon(
              Icons.edit_outlined,
              color: CourseGradesColors.darkPurple,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            tooltip: 'تعديل',
          ),
          // زر الحذف
          IconButton(
            onPressed: () => onDeleteGrade(assignment),
            icon: const Icon(
              Icons.delete_outline,
              color: CourseGradesColors.accentColor,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }
}
