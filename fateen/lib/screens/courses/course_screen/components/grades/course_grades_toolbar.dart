import 'package:flutter/material.dart';
import '../../constants/grades/course_grades_colors.dart';
import '../../../../../core/constants/appColor.dart';
import '../../../../../core/constants/app_dimensions.dart';

class CourseGradesToolbar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBackPressed;
  final BuildContext context;

  const CourseGradesToolbar({
    Key? key,
    required this.context,
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
                  color: context.colorSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  Icons.close,
                  color: context.colorPrimaryDark,
                  size: 18,
                ),
              ),
            ),
            // العنوان
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: context.colorSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade200,
                  width: 1.0,
                ),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.colorPrimaryDark,
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
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.colorPrimaryDark.withOpacity(0.1),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: context.colorPrimaryDark,
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
                    color: context.colorTextPrimary,
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
