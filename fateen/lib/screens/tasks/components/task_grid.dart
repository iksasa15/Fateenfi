// lib/screens/tasks/components/task_grid.dart

import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../constants/tasks_strings.dart';
import '../../../core/constants/appColor.dart';
import '../../../core/constants/app_dimensions.dart';
import 'task_card.dart';

class TaskGrid extends StatelessWidget {
  final List<Task> tasks;
  final bool isSearching;
  final Function(Task) onTaskTap;
  final Function(Task) onTaskLongPress;
  final Function(Task) onTaskComplete;

  const TaskGrid({
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
                fontSize: AppDimensions.subtitleFontSize,
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            SizedBox(height: AppDimensions.smallSpacing + 4),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppDimensions.defaultSpacing - 1,
                mainAxisSpacing: AppDimensions.defaultSpacing - 1,
                childAspectRatio: 0.85,
              ),
              itemCount: urgentTasks.length,
              itemBuilder: (context, index) {
                return TaskCard(
                  task: urgentTasks[index],
                  onTap: () => onTaskTap(urgentTasks[index]),
                  onLongPress: () => onTaskLongPress(urgentTasks[index]),
                  onComplete: () => onTaskComplete(urgentTasks[index]),
                  isGridView: true,
                );
              },
            ),
          ],

          // المسافة بين المهام العاجلة والعادية
          if (hasUrgent && hasRegular && !isSearching)
            SizedBox(height: AppDimensions.largeSpacing),

          // عنوان للمهام العادية
          if (hasRegular && hasUrgent && !isSearching) ...[
            Text(
              TasksStrings.importantTasks,
              style: TextStyle(
                fontSize: AppDimensions.subtitleFontSize,
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            SizedBox(height: AppDimensions.smallSpacing + 4),
          ],

          // عرض المهام العادية
          if (hasRegular)
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppDimensions.defaultSpacing - 1,
                mainAxisSpacing: AppDimensions.defaultSpacing - 1,
                childAspectRatio: 0.85,
              ),
              itemCount: regularTasks.length,
              itemBuilder: (context, index) {
                return TaskCard(
                  task: regularTasks[index],
                  onTap: () => onTaskTap(regularTasks[index]),
                  onLongPress: () => onTaskLongPress(regularTasks[index]),
                  onComplete: () => onTaskComplete(regularTasks[index]),
                  isGridView: true,
                );
              },
            ),

          // المسافة بين المهام العادية والمكتملة
          if (hasCompleted && (hasUrgent || hasRegular) && !isSearching)
            SizedBox(height: AppDimensions.largeSpacing),

          // عنوان للمهام المكتملة
          if (hasCompleted && !isSearching) ...[
            Text(
              TasksStrings.completedTasks,
              style: TextStyle(
                fontSize: AppDimensions.subtitleFontSize,
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            SizedBox(height: AppDimensions.smallSpacing + 4),
          ],

          // عرض المهام المكتملة
          if (hasCompleted && !isSearching)
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppDimensions.defaultSpacing - 1,
                mainAxisSpacing: AppDimensions.defaultSpacing - 1,
                childAspectRatio: 0.85,
              ),
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                return TaskCard(
                  task: completedTasks[index],
                  onTap: () => onTaskTap(completedTasks[index]),
                  onLongPress: () => onTaskLongPress(completedTasks[index]),
                  onComplete: () => onTaskComplete(completedTasks[index]),
                  isGridView: true,
                );
              },
            ),

          // إضافة مساحة في النهاية للتمرير
          SizedBox(height: AppDimensions.extraLargeSpacing * 2.5),
        ],
      ),
    );
  }
}
