import 'package:flutter/material.dart';
import '../../constants/grades/course_grades_colors.dart';

class CourseGradesToolbar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBackPressed;

  const CourseGradesToolbar({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الصف الأول: زر الرجوع والعنوان
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // زر الرجوع
            GestureDetector(
              onTap: onBackPressed,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  subtitle,
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
        const SizedBox(height: 12),
      ],
    );
  }
}
