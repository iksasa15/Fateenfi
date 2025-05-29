// lib/screens/tasks/components/task_options_menu.dart

import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../constants/tasks_colors.dart';
import '../constants/tasks_strings.dart';
import '../constants/tasks_icons.dart';

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
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        _buildOptionItem(
          TasksStrings.editTaskOption,
          TasksIcons.edit,
          TasksColors.kMediumPurple,
          onEdit,
        ),
        _buildOptionItem(
          isCompleted
              ? TasksStrings.markAsIncompleteOption
              : TasksStrings.markAsCompleteOption,
          isCompleted ? TasksIcons.taskOutlined : TasksIcons.taskCompleted,
          isCompleted ? Colors.orange : Colors.green,
          onToggleComplete,
        ),
        _buildOptionItem(
          TasksStrings.duplicateTask,
          TasksIcons.copy,
          Colors.blue,
          onDuplicate,
        ),
        Divider(),
        _buildOptionItem(
          TasksStrings.deleteTask,
          TasksIcons.delete,
          TasksColors.kAccentColor,
          onDelete,
          isDestructive: true,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOptionItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: isDestructive
                    ? TasksColors.kAccentColor
                    : Colors.grey.shade800,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
