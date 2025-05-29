// lib/screens/tasks/components/empty_tasks_state.dart

import 'package:flutter/material.dart';
import '../constants/tasks_strings.dart';
import '../constants/tasks_icons.dart';

class EmptyTasksState extends StatelessWidget {
  final bool isFiltering;
  final String? courseName;
  final VoidCallback onAddTask;

  const EmptyTasksState({
    Key? key,
    this.isFiltering = false,
    this.courseName,
    required this.onAddTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title;
    final String message;

    if (isFiltering) {
      title = TasksStrings.noMatchingTasks;
      message = TasksStrings.tryDifferentSearch;
    } else if (courseName != null) {
      title = TasksStrings.noCourseTasksMessage;
      message = TasksStrings.addFirstCourseTask;
    } else {
      title = TasksStrings.noTasks;
      message = TasksStrings.startAddingTasks;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                TasksIcons.task,
                size: 60,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4338CA),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // زر "إضافة مهمة" الكبير تم إزالته من هنا
          ],
        ),
      ),
    );
  }
}
