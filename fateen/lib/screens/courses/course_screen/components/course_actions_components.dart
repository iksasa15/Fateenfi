import 'package:flutter/material.dart';
import '../constants/course_actions_constants.dart';
import '../../../../models/course.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class CourseActionsComponents {
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

  // بناء علامة السحب
  static Widget buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color:
              context.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // بناء عنوان مع تفاصيل المقرر
  static Widget buildCourseHeader(BuildContext context, Course course) {
    return Column(
      children: [
        // العنوان (اسم المقرر)
        Text(
          course.courseName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.colorPrimaryDark,
            fontFamily: 'SYMBIOAR+LT',
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),
        // تفاصيل الكورس
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 16, color: context.colorPrimaryDark),
            const SizedBox(width: 4),
            Text(
              course.lectureTime ?? 'وقت غير محدد',
              style: TextStyle(
                fontSize: 14,
                color: context.colorTextSecondary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.location_on_outlined,
                size: 16, color: context.colorPrimaryDark),
            const SizedBox(width: 4),
            Text(
              course.classroom,
              style: TextStyle(
                fontSize: 14,
                color: context.colorTextSecondary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
