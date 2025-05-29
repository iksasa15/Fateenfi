// lib/screens/tasks/components/task_header.dart

import 'package:flutter/material.dart';
import '../constants/tasks_colors.dart';
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
      color: Colors.white,
      child: Column(
        children: [
          // الصف الأول: زر الرجوع والعنوان
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // عنوان صفحة المهام
                Text(
                  courseName != null
                      ? '${TasksStrings.courseTasks}: $courseName'
                      : TasksStrings.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
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
            color: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}
