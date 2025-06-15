import 'package:flutter/material.dart';
import '../constants/course_delete_constants.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class CourseDeleteComponents {
  // بناء مربع حوار حذف المقرر
  static Widget buildDeleteConfirmationDialog({
    required BuildContext context,
    required String courseName,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return AlertDialog(
      backgroundColor: context.colorSurface,
      title: Text(
        CourseDeleteConstants.confirmDeleteTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'SYMBIOAR+LT',
          color: context.colorTextPrimary,
        ),
      ),
      content: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: context.colorTextPrimary,
            fontSize: 16,
            fontFamily: 'SYMBIOAR+LT',
          ),
          children: [
            TextSpan(text: 'هل أنت متأكد من حذف مقرر '),
            TextSpan(
              text: courseName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
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
            style: TextStyle(
              color: context.colorTextSecondary,
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
              color: context.colorAccent,
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
    required BuildContext context,
    required String text,
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    final Color actionColor = color ?? context.colorPrimaryDark;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: actionColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: actionColor,
          size: 20,
        ),
      ),
      title: Text(
        text,
        style: TextStyle(
          color: context.colorTextPrimary,
          fontSize: 16,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
      onTap: onTap,
    );
  }
}
