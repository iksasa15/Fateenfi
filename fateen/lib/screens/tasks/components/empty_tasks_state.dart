// lib/screens/tasks/components/empty_tasks_state.dart

import 'package:flutter/material.dart';
import '../constants/tasks_strings.dart';
import '../constants/tasks_icons.dart';
 import '../../../core/constants/appColor.dart';
import '../../../core/constants/app_dimensions.dart';
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
        padding: EdgeInsets.all(AppDimensions.extraLargeSpacing - 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: context.colorPrimaryPale,
                borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
              ),
              child: Icon(
                TasksIcons.task,
                size: 60,
                color: context.colorPrimaryLight,
              ),
            ),
            SizedBox(height: AppDimensions.extraLargeSpacing - 8),
            Text(
              title,
              style: TextStyle(
                fontSize: AppDimensions.subtitleFontSize + 2,
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            SizedBox(height: AppDimensions.smallSpacing),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.extraLargeSpacing),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: AppDimensions.labelFontSize,
                  color: context.colorTextHint,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
