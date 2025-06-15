// lib/screens/tasks/components/task_header.dart

import 'package:flutter/material.dart';
import '../../../core/constants/appColor.dart';
import '../../../core/constants/app_dimensions.dart';
import '../constants/tasks_strings.dart';

class TaskHeader extends StatelessWidget {
  final String? courseName;

  const TaskHeader({
    Key? key,
    this.courseName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.colorSurface,
      child: Column(
        children: [
          // الصف الأول: زر الرجوع والعنوان
          Padding(
            padding: EdgeInsets.all(AppDimensions.sectionPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // عنوان صفحة المهام
                Text(
                  courseName != null
                      ? '${TasksStrings.courseTasks}: $courseName'
                      : TasksStrings.title,
                  style: TextStyle(
                    fontSize: AppDimensions.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: context.colorTextPrimary,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),

                // مساحة فارغة بنفس حجم أيقونة التبديل في هيدر المقررات
                const SizedBox(width: 45, height: 45),
              ],
            ),
          ),

          // خط فاصل
          Container(
            height: 1,
            width: double.infinity,
            color: context.colorDivider,
          ),
        ],
      ),
    );
  }
}
