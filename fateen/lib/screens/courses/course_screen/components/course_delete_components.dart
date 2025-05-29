import 'package:flutter/material.dart';
import '../constants/course_delete_constants.dart';

class CourseDeleteComponents {
  // بناء مربع حوار حذف المقرر
  static Widget buildDeleteConfirmationDialog({
    required BuildContext context,
    required String courseName,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return AlertDialog(
      title: Text(
        CourseDeleteConstants.confirmDeleteTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
      ),
      content: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontFamily: 'SYMBIOAR+LT',
          ),
          children: [
            const TextSpan(text: 'هل أنت متأكد من حذف مقرر '),
            TextSpan(
              text: courseName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CourseDeleteConstants.kDarkPurple,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const TextSpan(text: '؟'),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            CourseDeleteConstants.cancelButton,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            CourseDeleteConstants.deleteButton,
            style: TextStyle(
              color: CourseDeleteConstants.kAccentColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
      ],
    );
  }

  // بناء زر إجراء في BottomSheet
  static Widget buildActionButton({
    required String text,
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (color ?? CourseDeleteConstants.kDarkPurple).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color ?? CourseDeleteConstants.kDarkPurple,
          size: 20,
        ),
      ),
      title: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontSize: 16,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
      onTap: onTap,
    );
  }
}
