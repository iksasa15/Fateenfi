// lib/screens/tasks/constants/tasks_icons.dart

import 'package:flutter/material.dart';

class TasksIcons {
  // الأيقونات العامة
  static const IconData add = Icons.add;
  static const IconData back = Icons.arrow_back_ios;
  static const IconData search = Icons.search;
  static const IconData clear = Icons.clear;
  static const IconData listView = Icons.view_list;
  static const IconData gridView = Icons.grid_view;
  static const IconData filter = Icons.filter_list;
  static const IconData check = Icons.check;
  static const IconData edit = Icons.edit_outlined;
  static const IconData copy = Icons.copy_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData save = Icons.save_outlined;
  static const IconData forward = Icons.arrow_forward_ios;

  // أيقونات المهام
  static const IconData task = Icons.task_alt;
  static const IconData taskOutlined = Icons.check_box_outline_blank;
  static const IconData taskCompleted = Icons.check_box;
  static const IconData calendar = Icons.calendar_today;
  static const IconData time = Icons.access_time;
  static const IconData reminder = Icons.notification_important;
  static const IconData description = Icons.description;
  static const IconData tag = Icons.label_outline;
  static const IconData course = Icons.book;

  // أيقونات الفلاتر
  static const IconData allTasks = Icons.list_alt;
  static const IconData today = Icons.today;
  static const IconData upcoming = Icons.update;
  static const IconData overdue = Icons.timer_off;
  static const IconData completed = Icons.check_circle;

  // أيقونات الأولويات
  static const IconData highPriority = Icons.priority_high;
  static const IconData mediumPriority = Icons.drag_handle;
  static const IconData lowPriority = Icons.arrow_downward;

  // أيقونات الحالات
  static const IconData inProgress = Icons.pending_actions;
  static const IconData completedStatus = Icons.check_circle;

  // الحصول على أيقونة الأولوية
  static IconData getPriorityIcon(String priority) {
    switch (priority) {
      case 'عالية':
        return highPriority;
      case 'متوسطة':
        return mediumPriority;
      case 'منخفضة':
        return lowPriority;
      default:
        return mediumPriority;
    }
  }

  // الحصول على أيقونة الحالة
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'مكتملة':
        return completedStatus;
      case 'قيد التنفيذ':
        return inProgress;
      default:
        return inProgress;
    }
  }
}
