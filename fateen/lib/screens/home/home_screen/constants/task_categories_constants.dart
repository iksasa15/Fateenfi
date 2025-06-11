import 'package:flutter/material.dart';

class TaskCategoriesConstants {
  // العناوين
  static const String sectionTitle = 'فئات المهام';

  // العناوين الخاصة بفئات المهام
  static const String urgentTasksTitle = 'المهام العاجلة';
  static const String upcomingTasksTitle = 'المهام القادمة';
  static const String completedTasksTitle = 'المهام المكتملة';
  static const String allTasksTitle = 'كل المهام';

  // رموز فئات المهام
  static const IconData urgentTasksIcon = Icons.timer;
  static const IconData upcomingTasksIcon = Icons.calendar_today;
  static const IconData completedTasksIcon = Icons.check_circle;
  static const IconData allTasksIcon = Icons.list_alt;

  // ألوان فئات المهام
  static const Color urgentTasksColor = Colors.red;
  static const Color upcomingTasksColor = Colors.blue;
  static const Color completedTasksColor = Colors.green;
  static const Color allTasksColor = Colors.purple;

  // خصائص التصميم
  static const double cardPadding = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double cardIconSize = 24.0;
  static const double badgeBorderRadius = 12.0;
  static const double gridSpacing = 12.0;
  static const double gridChildAspectRatio = 1.5;
  static const int gridColumnCount = 2;

  // تعتيم الألوان للخلفية والحدود
  static const double backgroundOpacity = 0.1;
  static const double borderOpacity = 0.2;
  static const double shadowOpacity = 0.03;

  // خط النصوص
  static const String fontFamily = 'SYMBIOAR+LT';
  static const double titleFontSize = 16.0;
  static const double cardTitleFontSize = 14.0;
  static const double badgeFontSize = 12.0;
}
