// lib/screens/tasks/components/task_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/task.dart';
import '../constants/tasks_colors.dart';
import '../constants/tasks_icons.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onComplete;
  final bool isGridView;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onLongPress,
    required this.onComplete,
    this.isGridView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isGridView ? _buildGridCard(context) : _buildListCard(context);
  }

  // بناء بطاقة في عرض القائمة
  Widget _buildListCard(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final priorityColor = TasksColors.getPriorityColor(task.priority);
    final isCompleted = task.status == 'مكتملة';
    final isOverdue = task.isOverdue();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المهمة وحالتها
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // عرض المادة إذا كانت متوفرة
                          if (task.course != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              margin: const EdgeInsets.only(top: 1, left: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE3E0F8),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                task.course!.courseName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4338CA),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          Expanded(
                            child: Text(
                              task.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? Colors.grey
                                    : const Color(0xFF4338CA),
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onComplete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? TasksColors.kGreenColor.withOpacity(0.1)
                              : isOverdue
                                  ? TasksColors.kAccentColor.withOpacity(0.1)
                                  : const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCompleted
                                  ? TasksIcons.taskCompleted
                                  : isOverdue
                                      ? TasksIcons.overdue
                                      : TasksIcons.taskOutlined,
                              size: 14,
                              color: isCompleted
                                  ? TasksColors.kGreenColor
                                  : isOverdue
                                      ? TasksColors.kAccentColor
                                      : const Color(0xFF6366F1),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCompleted
                                  ? "مكتملة"
                                  : isOverdue
                                      ? "متأخرة"
                                      : "قيد التنفيذ",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isCompleted
                                    ? TasksColors.kGreenColor
                                    : isOverdue
                                        ? TasksColors.kAccentColor
                                        : const Color(0xFF6366F1),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // وصف المهمة مختصر
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCompleted
                          ? Colors.grey.shade400
                          : const Color(0xFF374151),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                if (task.description.isNotEmpty) const SizedBox(height: 12),

                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 12),

                // تفاصيل المهمة (التاريخ والأولوية)
                Row(
                  children: [
                    // التاريخ
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              TasksIcons.calendar,
                              size: 16,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "التاريخ",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9CA3AF),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                              Text(
                                formatter.format(task.dueDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isOverdue && !isCompleted
                                      ? TasksColors.kAccentColor
                                      : const Color(0xFF374151),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // الأولوية
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              TasksIcons.getPriorityIcon(task.priority),
                              size: 16,
                              color: priorityColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "الأولوية",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9CA3AF),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                              Text(
                                task.priority,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: priorityColor,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء بطاقة في عرض الشبكة
  Widget _buildGridCard(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final priorityColor = TasksColors.getPriorityColor(task.priority);
    final isCompleted = task.status == 'مكتملة';
    final isOverdue = task.isOverdue();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة الحالة والمادة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onComplete,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? TasksColors.kGreenColor.withOpacity(0.1)
                              : isOverdue
                                  ? TasksColors.kAccentColor.withOpacity(0.1)
                                  : const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isCompleted
                              ? TasksIcons.taskCompleted
                              : isOverdue
                                  ? TasksIcons.overdue
                                  : TasksIcons.taskOutlined,
                          color: isCompleted
                              ? TasksColors.kGreenColor
                              : isOverdue
                                  ? TasksColors.kAccentColor
                                  : const Color(0xFF6366F1),
                          size: 16,
                        ),
                      ),
                    ),

                    // عرض المادة إذا كانت متوفرة
                    if (task.course != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE3E0F8),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          task.course!.courseName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4338CA),
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // عنوان المهمة
                Text(
                  task.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCompleted ? Colors.grey : const Color(0xFF4338CA),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // وصف المهمة
                Expanded(
                  child: Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isCompleted
                          ? Colors.grey.shade400
                          : const Color(0xFF374151),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 8),

                // معلومات في أسفل البطاقة
                Row(
                  children: [
                    // الأولوية
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            TasksIcons.getPriorityIcon(task.priority),
                            size: 10,
                            color: priorityColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            task.priority,
                            style: TextStyle(
                              fontSize: 10,
                              color: priorityColor,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),

                    // تاريخ التسليم
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            TasksIcons.calendar,
                            size: 10,
                            color: Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            formatter.format(task.dueDate),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6366F1),
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
