import 'package:flutter/material.dart';
import '../../constants/grades/course_grades_constants.dart';
import '../../constants/grades/course_grades_colors.dart';
import '../../../../../core/constants/appColor.dart';
import '../../../../../core/constants/app_dimensions.dart';

class CourseGradesDeleteDialog extends StatelessWidget {
  final String assignment;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;
  final BuildContext context;

  const CourseGradesDeleteDialog({
    Key? key,
    required this.context,
    required this.assignment,
    required this.onConfirm,
    required this.onCancel,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colorSurface,
      title: Text(
        CourseGradesConstants.deleteConfirmTitle,
        style: TextStyle(
          fontFamily: 'SYMBIOAR+LT',
          fontWeight: FontWeight.bold,
          color: context.colorTextPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            CourseGradesConstants.deleteConfirmMessage
                .replaceAll('%s', assignment),
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              color: context.colorTextPrimary,
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          child: Text(
            CourseGradesConstants.cancelButton,
            style: TextStyle(
              color: context.colorTextSecondary,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : onConfirm,
          child: Text(
            CourseGradesConstants.deleteButton,
            style: TextStyle(
              color: context.colorError,
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
