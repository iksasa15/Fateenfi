// lib/screens/tasks/components/task_options_menu.dart

import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../constants/tasks_strings.dart';
import '../constants/tasks_icons.dart';
import '../../../core/constants/appColor.dart';
import '../../../core/constants/app_dimensions.dart';
class TaskOptionsMenu extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onToggleComplete;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const TaskOptionsMenu({
    Key? key,
    required this.task,
    required this.onEdit,
    required this.onToggleComplete,
    required this.onDuplicate,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = task.status == 'مكتملة';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          margin: EdgeInsets.symmetric(vertical: AppDimensions.smallSpacing),
          decoration: BoxDecoration(
            color: context.colorDivider,
            borderRadius: BorderRadius.circular(AppDimensions.smallRadius / 4),
          ),
        ),
        _buildOptionItem(
          context,
          TasksStrings.editTaskOption,
          TasksIcons.edit,
          context.colorMediumPurple,
          onEdit,
        ),
        _buildOptionItem(
          context,
          isCompleted
              ? TasksStrings.markAsIncompleteOption
              : TasksStrings.markAsCompleteOption,
          isCompleted ? TasksIcons.taskOutlined : TasksIcons.taskCompleted,
          isCompleted ? context.colorWarning : context.colorSuccess,
          onToggleComplete,
        ),
        _buildOptionItem(
          context,
          TasksStrings.duplicateTask,
          TasksIcons.copy,
          context.colorInfo,
          onDuplicate,
        ),
        Divider(color: context.colorDivider),
        _buildOptionItem(
          context,
          TasksStrings.deleteTask,
          TasksIcons.delete,
          context.colorAccent,
          onDelete,
          isDestructive: true,
        ),
        SizedBox(height: AppDimensions.largeSpacing),
      ],
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.sectionPadding,
          vertical: AppDimensions.smallSpacing + 4,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
              ),
              child: Icon(
                icon,
                color: color,
                size: AppDimensions.smallIconSize,
              ),
            ),
            SizedBox(width: AppDimensions.defaultSpacing),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: AppDimensions.bodyFontSize,
                color: isDestructive
                    ? context.colorAccent
                    : context.colorTextPrimary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
