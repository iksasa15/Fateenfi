// lib/features/task_editor/constants/editor_colors.dart

import 'package:flutter/material.dart';

class EditorColors {
  // Main colors
  static const Color primary = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color divider = Color(0xFFE3E0F8);
  static const Color backgroundLight = Color(0xFFF5F3FF);

  // Text colors
  static const Color textDark = Color(0xFF374151);
  static const Color textMedium = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Status colors
  static const Color error = Color(0xFFEC4899);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);

  // Priority colors
  static const Color highPriority = Color(0xFFFF5252);
  static const Color mediumPriority = Color(0xFFFFB74D);
  static const Color lowPriority = Color(0xFF66BB6A);

  // Get color for priority
  static Color getPriorityColor(String priority) {
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
