// lib/features/task_editor/constants/editor_icons.dart

import 'package:flutter/material.dart';

class EditorIcons {
  // Input fields
  static const IconData textField = Icons.text_fields;
  static const IconData description = Icons.description;

  // Date & Time
  static const IconData calendar = Icons.calendar_today;
  static const IconData time = Icons.access_time;

  // Priorities
  static const IconData highPriority = Icons.priority_high;
  static const IconData mediumPriority = Icons.drag_handle;
  static const IconData lowPriority = Icons.arrow_downward;

  // Other icons
  static const IconData course = Icons.book;
  static const IconData reminder = Icons.notification_important;
  static const IconData tag = Icons.label_outline;
  static const IconData save = Icons.save_outlined;
  static const IconData add = Icons.add;

  // Get icon for priority
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
}
