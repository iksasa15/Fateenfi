// lib/screens/tasks/components/task_list.dart

import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../constants/tasks_strings.dart';
import '../constants/tasks_colors.dart';
import 'task_card.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final bool isSearching;
  final Function(Task) onTaskTap;
  final Function(Task) onTaskLongPress;
  final Function(Task) onTaskComplete;

  const TaskList({
    Key? key,
    required this.tasks,
    this.isSearching = false,
    required this.onTaskTap,
    required this.onTaskLongPress,
    required this.onTaskComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تقسيم المهام إلى عاجلة وعادية ومكتملة
    final urgentTasks = tasks
        .where((task) => task.priority == 'عالية' && task.status != 'مكتملة')
        .toList();
    final completedTasks =
        tasks.where((task) => task.status == 'مكتملة').toList();
    final regularTasks = tasks
        .where((task) => task.priority != 'عالية' && task.status != 'مكتملة')
        .toList();

    final hasUrgent = urgentTasks.isNotEmpty;
    final hasCompleted = completedTasks.isNotEmpty;
    final hasRegular = regularTasks.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عرض المهام العاجلة أولاً
          if (hasUrgent && !isSearching) ...[
            Text(
              TasksStrings.urgentTasks,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TasksColors.kDarkPurple,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            SizedBox(height: 12),
            ...urgentTasks.map((task) => TaskCard(
                  task: task,
                  onTap: () => onTaskTap(task),
                  onLongPress: () => onTaskLongPress(task),
                  onComplete: () => onTaskComplete(task),
                )),
          ],

          // المسافة بين المهام العاجلة والعادية
          if (hasUrgent && hasRegular && !isSearching) SizedBox(height: 20),

          // عنوان للمهام العادية
          if (hasRegular && (hasUrgent || isSearching)) ...[
            if (!isSearching)
              Text(
                TasksStrings.importantTasks,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TasksColors.kDarkPurple,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            if (!isSearching) SizedBox(height: 12),
          ],

          // عرض المهام العادية
          if (hasRegular) ...[
            ...regularTasks.map((task) => TaskCard(
                  task: task,
                  onTap: () => onTaskTap(task),
                  onLongPress: () => onTaskLongPress(task),
                  onComplete: () => onTaskComplete(task),
                )),
          ],

          // المسافة بين المهام العادية والمكتملة
          if (hasCompleted && (hasUrgent || hasRegular) && !isSearching)
            SizedBox(height: 20),

          // عنوان للمهام المكتملة
          if (hasCompleted && !isSearching) ...[
            Text(
              TasksStrings.completedTasks,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TasksColors.kDarkPurple,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            SizedBox(height: 12),
          ],

          // عرض المهام المكتملة
          if (hasCompleted && !isSearching) ...[
            ...completedTasks.map((task) => TaskCard(
                  task: task,
                  onTap: () => onTaskTap(task),
                  onLongPress: () => onTaskLongPress(task),
                  onComplete: () => onTaskComplete(task),
                )),
          ],

          // إضافة مساحة في النهاية للتمرير
          SizedBox(height: 80),
        ],
      ),
    );
  }
}
