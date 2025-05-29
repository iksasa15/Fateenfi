import 'package:flutter/material.dart';
import '../../constants/grades/course_grades_constants.dart';
import '../../constants/grades/course_grades_colors.dart';
import '../../controllers/course_grades_controller.dart';
import '../../../../../models/course.dart';
import 'course_grades_form.dart';

class CourseGradesDialog extends StatelessWidget {
  final String title;
  final String description;
  final CourseGradesController controller;
  final Course course;
  final String? currentEditingAssignment;
  final double? currentGradeValue;
  final double? currentMaxGrade;
  final Function(String?, String, double, double) onSave;
  final VoidCallback onCancel;
  final bool isLoading;

  const CourseGradesDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.controller,
    required this.course,
    this.currentEditingAssignment,
    this.currentGradeValue,
    this.currentMaxGrade,
    required this.onSave,
    required this.onCancel,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // علامة السحب
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // شريط العنوان
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صف العنوان والزر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر الرجوع
                      GestureDetector(
                        onTap: onCancel,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: CourseGradesColors.borderColor,
                              width: 1.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: CourseGradesColors.darkPurple,
                            size: 18,
                          ),
                        ),
                      ),
                      // العنوان
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: CourseGradesColors.borderColor,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: CourseGradesColors.darkPurple,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      ),
                      // مساحة فارغة للمحاذاة
                      const SizedBox(width: 36),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // وصف مع أيقونة
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: CourseGradesColors.darkPurple.withOpacity(0.1),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: CourseGradesColors.darkPurple,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: CourseGradesColors.textColor,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // محتوى النموذج
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CourseGradesForm(
                controller: controller,
                course: course,
                currentEditingAssignment: currentEditingAssignment,
                currentGradeValue: currentGradeValue,
                currentMaxGrade: currentMaxGrade,
                onSave: onSave,
                onCancel: onCancel,
                isLoading: isLoading,
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
