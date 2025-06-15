// lib/screens/tasks/components/task_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/task.dart';
import '../constants/tasks_icons.dart';
import '../../../core/constants/appColor.dart';
import '../../../core/constants/app_dimensions.dart';
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
    final Color priorityColor = _getPriorityColor(context, task.priority);
    final bool isCompleted = task.status == 'مكتملة';
    final bool isOverdue = task.isOverdue();

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.smallSpacing + 4),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: EdgeInsets.all(AppDimensions.defaultSpacing),
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
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.smallSpacing,
                                vertical: 4,
                              ),
                              margin: EdgeInsets.only(
                                  top: 1, left: AppDimensions.smallSpacing),
                              decoration: BoxDecoration(
                                color: context.colorPrimaryPale,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.smallRadius),
                                border: Border.all(
                                  color: context.colorPrimaryExtraLight,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                task.course!.courseName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: context.colorPrimaryDark,
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
                                fontSize: AppDimensions.bodyFontSize,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? context.colorTextSecondary
                                    : context.colorPrimaryDark,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.smallSpacing,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? context.colorSuccess.withOpacity(0.1)
                              : isOverdue
                                  ? context.colorAccent.withOpacity(0.1)
                                  : context.colorPrimaryPale,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.smallRadius + 2),
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
                                  ? context.colorSuccess
                                  : isOverdue
                                      ? context.colorAccent
                                      : context.colorPrimaryLight,
                            ),
                            SizedBox(width: 4),
                            Text(
                              isCompleted
                                  ? "مكتملة"
                                  : isOverdue
                                      ? "متأخرة"
                                      : "قيد التنفيذ",
                              style: TextStyle(
                                fontSize: AppDimensions.smallLabelFontSize - 1,
                                fontWeight: FontWeight.w500,
                                color: isCompleted
                                    ? context.colorSuccess
                                    : isOverdue
                                        ? context.colorAccent
                                        : context.colorPrimaryLight,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppDimensions.smallSpacing + 4),

                // وصف المهمة مختصر
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: AppDimensions.smallBodyFontSize,
                      color: isCompleted
                          ? context.colorTextHint
                          : context.colorTextPrimary,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                if (task.description.isNotEmpty)
                  SizedBox(height: AppDimensions.smallSpacing + 4),

                Divider(height: 1, thickness: 1, color: context.colorDivider),
                SizedBox(height: AppDimensions.smallSpacing + 4),

                // تفاصيل المهمة (التاريخ والأولوية)
                Row(
                  children: [
                    // التاريخ
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: context.colorPrimaryPale,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.smallRadius),
                            ),
                            child: Icon(
                              TasksIcons.calendar,
                              size: 16,
                              color: context.colorPrimaryLight,
                            ),
                          ),
                          SizedBox(width: AppDimensions.smallSpacing),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "التاريخ",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.colorTextHint,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                              Text(
                                formatter.format(task.dueDate),
                                style: TextStyle(
                                  fontSize:
                                      AppDimensions.smallLabelFontSize - 1,
                                  fontWeight: FontWeight.w500,
                                  color: isOverdue && !isCompleted
                                      ? context.colorAccent
                                      : context.colorTextPrimary,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: AppDimensions.smallSpacing + 4),

                    // الأولوية
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.smallRadius),
                            ),
                            child: Icon(
                              TasksIcons.getPriorityIcon(task.priority),
                              size: 16,
                              color: priorityColor,
                            ),
                          ),
                          SizedBox(width: AppDimensions.smallSpacing),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "الأولوية",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.colorTextHint,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                              Text(
                                task.priority,
                                style: TextStyle(
                                  fontSize:
                                      AppDimensions.smallLabelFontSize - 1,
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
    final Color priorityColor = _getPriorityColor(context, task.priority);
    final bool isCompleted = task.status == 'مكتملة';
    final bool isOverdue = task.isOverdue();

    return Container(
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: EdgeInsets.all(AppDimensions.defaultSpacing),
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
                              ? context.colorSuccess.withOpacity(0.1)
                              : isOverdue
                                  ? context.colorAccent.withOpacity(0.1)
                                  : context.colorPrimaryPale,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.smallRadius),
                        ),
                        child: Icon(
                          isCompleted
                              ? TasksIcons.taskCompleted
                              : isOverdue
                                  ? TasksIcons.overdue
                                  : TasksIcons.taskOutlined,
                          color: isCompleted
                              ? context.colorSuccess
                              : isOverdue
                                  ? context.colorAccent
                                  : context.colorPrimaryLight,
                          size: 16,
                        ),
                      ),
                    ),

                    // عرض المادة إذا كانت متوفرة
                    if (task.course != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.smallSpacing,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorPrimaryPale,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.smallRadius),
                          border: Border.all(
                            color: context.colorPrimaryExtraLight,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          task.course!.courseName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: context.colorPrimaryDark,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: AppDimensions.smallSpacing + 4),

                // عنوان المهمة
                Text(
                  task.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimensions.bodyFontSize,
                    color: isCompleted
                        ? context.colorTextSecondary
                        : context.colorPrimaryDark,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: AppDimensions.smallSpacing),

                // وصف المهمة
                Expanded(
                  child: Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isCompleted
                          ? context.colorTextHint
                          : context.colorTextPrimary,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(height: AppDimensions.smallSpacing),

                // معلومات في أسفل البطاقة
                Row(
                  children: [
                    // الأولوية
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                          SizedBox(width: 2),
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
                    SizedBox(width: 4),

                    // تاريخ التسليم
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.colorPrimaryPale,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            TasksIcons.calendar,
                            size: 10,
                            color: context.colorPrimaryLight,
                          ),
                          SizedBox(width: 2),
                          Text(
                            formatter.format(task.dueDate),
                            style: TextStyle(
                              fontSize: 10,
                              color: context.colorPrimaryLight,
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

  // طريقة مساعدة للحصول على لون الأولوية استناداً إلى نص الأولوية
  Color _getPriorityColor(BuildContext context, String priority) {
    switch (priority) {
      case 'عالية':
        return context.colorError;
      case 'متوسطة':
        return context.colorWarning;
      case 'منخفضة':
        return context.colorSuccess;
      default:
        return context.colorInfo;
    }
  }
}
