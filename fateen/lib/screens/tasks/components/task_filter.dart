// lib/screens/tasks/components/task_filter.dart

import 'package:flutter/material.dart';
import '../constants/tasks_strings.dart';
import '../constants/tasks_icons.dart';
import '../../../core/constants/appColor.dart';
import '../../../core/constants/app_dimensions.dart';

class TaskFilter extends StatelessWidget {
  final String selectedFilter;
  final Color filterColor;
  final VoidCallback onFilterCleared;

  const TaskFilter({
    Key? key,
    required this.selectedFilter,
    required this.filterColor,
    required this.onFilterCleared,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: AppDimensions.defaultSpacing,
        bottom: AppDimensions.smallSpacing,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.smallSpacing + 4,
        vertical: AppDimensions.smallSpacing,
      ),
      decoration: BoxDecoration(
        color: context.colorPrimaryPale,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
        border: Border.all(
          color: context.colorPrimaryExtraLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.smallSpacing - 2),
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
              border: Border.all(
                color: context.colorPrimaryExtraLight,
                width: 1,
              ),
            ),
            child: Icon(
              TasksIcons.filter,
              color: filterColor,
              size: AppDimensions.smallIconSize - 4,
            ),
          ),
          SizedBox(width: AppDimensions.smallSpacing),
          Text(
            '${TasksStrings.filterBy}$selectedFilter',
            style: TextStyle(
              color: context.colorPrimaryDark,
              fontWeight: FontWeight.w500,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onFilterCleared,
            style: TextButton.styleFrom(
              padding:
                  EdgeInsets.symmetric(horizontal: AppDimensions.smallSpacing),
              minimumSize: Size(0, 0),
              foregroundColor: context.colorPrimaryLight,
            ),
            child: Text(
              TasksStrings.clearFilter,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
