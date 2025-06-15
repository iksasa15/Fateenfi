// course_grades_list.dart

import 'package:flutter/material.dart';
import '../../../../../models/course.dart';
import '../../constants/grades/course_grades_colors.dart';
import '../../controllers/course_grades_controller.dart';
import '../../../../../core/constants/appColor.dart';
import '../../../../../core/constants/app_dimensions.dart';

class CourseGradesList extends StatelessWidget {
  final Course course;
  final CourseGradesController controller;
  final Function(String, double, double) onEditGrade;
  final Function(String) onDeleteGrade;
  final BuildContext context;

  const CourseGradesList({
    Key? key,
    required this.context,
    required this.course,
    required this.controller,
    required this.onEditGrade,
    required this.onDeleteGrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (course.grades.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(builder: (context, constraints) {
      // تحديد ما إذا كان العرض كافياً لشبكة بدلاً من قائمة
      final isWideScreen = constraints.maxWidth > 600;

      if (isWideScreen) {
        // عرض بتنسيق الشبكة للشاشات الكبيرة
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          padding: const EdgeInsets.only(top: 8),
          physics: const BouncingScrollPhysics(),
          itemCount: course.grades.length,
          itemBuilder: (context, index) {
            final entry = course.grades.entries.elementAt(index);
            final assignment = entry.key;
            final actualGrade = entry.value;
            final maxGrade = course.maxGrades.containsKey(assignment)
                ? course.maxGrades[assignment]!
                : controller.getCustomMaxGrade(course, assignment);

            return buildGradeCard(
              assignment: assignment,
              actualGrade: actualGrade,
              maxGrade: maxGrade,
            );
          },
        );
      } else {
        // عرض بتنسيق القائمة للشاشات الصغيرة
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          physics: const BouncingScrollPhysics(),
          itemCount: course.grades.length,
          itemBuilder: (context, index) {
            final entry = course.grades.entries.elementAt(index);
            final assignment = entry.key;
            final actualGrade = entry.value;
            final maxGrade = course.maxGrades.containsKey(assignment)
                ? course.maxGrades[assignment]!
                : controller.getCustomMaxGrade(course, assignment);

            return buildGradeCard(
              assignment: assignment,
              actualGrade: actualGrade,
              maxGrade: maxGrade,
            );
          },
        );
      }
    });
  }

  Widget buildGradeCard({
    required String assignment,
    required double actualGrade,
    required double maxGrade,
  }) {
    // حساب النسبة المئوية للدرجة
    final percentage = (actualGrade / maxGrade) * 100;
    final gradeColor = controller.getGradeColor(actualGrade, maxGrade);

    // تحديد أيقونة مناسبة بناءً على نوع التقييم
    IconData assignmentIcon = Icons.assignment_outlined;
    if (assignment.contains('اختبار') || assignment.contains('امتحان')) {
      assignmentIcon = Icons.quiz_outlined;
    } else if (assignment.contains('مشروع')) {
      assignmentIcon = Icons.engineering_outlined;
    } else if (assignment.contains('واجب') || assignment.contains('منزلي')) {
      assignmentIcon = Icons.home_work_outlined;
    } else if (assignment.contains('حضور') || assignment.contains('مشاركة')) {
      assignmentIcon = Icons.people_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade700.withOpacity(0.5)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorShadowColor,
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة نوع التقييم
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colorPrimaryLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.isDarkMode
                    ? context.colorPrimary.withOpacity(0.3)
                    : context.colorPrimaryLight.withOpacity(0.7),
              ),
            ),
            child: Center(
              child: Icon(
                assignmentIcon,
                size: 22,
                color: context.colorPrimaryDark,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // تفاصيل الدرجة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SYMBIOAR+LT',
                    color: context.colorTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // نص الدرجة
                    Text(
                      '${actualGrade.toStringAsFixed(1)} / ${maxGrade.toStringAsFixed(1)}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colorTextSecondary,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // شريط تقدم الدرجة
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: context.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // النسبة المئوية
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // أزرار التحكم
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // زر التعديل
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  onPressed: () =>
                      onEditGrade(assignment, actualGrade, maxGrade),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: context.colorPrimaryDark,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: 'تعديل',
                  splashColor: context.colorPrimaryLight,
                ),
              ),

              // زر الحذف
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  onPressed: () => onDeleteGrade(assignment),
                  icon: Icon(
                    Icons.delete_outline,
                    color: context.colorError,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: 'حذف',
                  splashColor: context.colorError.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
