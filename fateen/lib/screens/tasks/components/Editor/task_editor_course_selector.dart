// lib/features/task_editor/components/task_editor_course_selector.dart

import 'package:flutter/material.dart';
import '../../../../models/course.dart';
import '../../constants/editor_colors.dart';
import '../../constants/editor_icons.dart';
import '../../constants/editor_strings.dart';

class TaskEditorCourseSelector extends StatelessWidget {
  final List<Course> availableCourses;
  final String? selectedCourseId;
  final Course? selectedCourse;
  final Function(Course?) onCourseSelected;

  const TaskEditorCourseSelector({
    Key? key,
    required this.availableCourses,
    required this.selectedCourseId,
    required this.selectedCourse,
    required this.onCourseSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              EditorStrings.course,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: EditorColors.textDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // نستخدم أزرار اختيار بدلاً من القائمة المنسدلة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: EditorColors.primary.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة المادة والعنوان
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: EditorColors.primary.withOpacity(0.1),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        EditorIcons.course,
                        color: EditorColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      selectedCourseId == null
                          ? EditorStrings.selectCourse
                          : "المادة المختارة: ${selectedCourse?.courseName}",
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedCourseId == null
                            ? EditorColors.textLight
                            : EditorColors.textDark,
                        fontWeight: selectedCourseId != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ],
                ),

                // قائمة الاختيارات
                const SizedBox(height: 10),

                availableCourses.isEmpty
                    ? Center(
                        child: Text(
                          "لا توجد مقررات متاحة",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // خيار "بدون مادة"
                          _buildCourseChoiceChip(
                            label: EditorStrings.noCourse,
                            isSelected: selectedCourseId == null,
                            onSelected: (selected) {
                              if (selected) {
                                onCourseSelected(null);
                                print("Selected course: none");
                              }
                            },
                          ),

                          // خيارات المواد المتاحة
                          ...availableCourses
                              .map((course) => _buildCourseChoiceChip(
                                    label: course.courseName,
                                    isSelected: selectedCourseId == course.id,
                                    onSelected: (selected) {
                                      if (selected) {
                                        onCourseSelected(course);
                                        print(
                                            "Selected course: ${course.courseName} (${course.id})");
                                      }
                                    },
                                  )),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء رقاقة اختيار المادة
  Widget _buildCourseChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'SYMBIOAR+LT',
          fontSize: 13,
          color: isSelected ? EditorColors.primary : EditorColors.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: EditorColors.backgroundLight,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? EditorColors.primaryLight : Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onSelected: onSelected,
    );
  }
}
