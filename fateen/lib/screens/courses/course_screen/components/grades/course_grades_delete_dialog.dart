import 'package:flutter/material.dart';
import '../../constants/grades/course_grades_constants.dart';
import '../../constants/grades/course_grades_colors.dart';

class CourseGradesDeleteDialog extends StatelessWidget {
  final String assignment;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;

  const CourseGradesDeleteDialog({
    Key? key,
    required this.assignment,
    required this.onConfirm,
    required this.onCancel,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        CourseGradesConstants.deleteConfirmTitle,
        style: TextStyle(
          fontFamily: 'SYMBIOAR+LT',
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            CourseGradesConstants.deleteConfirmMessage
                .replaceAll('%s', assignment),
            style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: CourseGradesColors.darkPurple,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          child: const Text(
            CourseGradesConstants.cancelButton,
            style: TextStyle(
              color: CourseGradesColors.textLightColor,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : onConfirm,
          child: const Text(
            CourseGradesConstants.deleteButton,
            style: TextStyle(
              color: CourseGradesColors.errorColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
