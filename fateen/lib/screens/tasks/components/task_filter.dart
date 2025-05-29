// lib/screens/tasks/components/task_filter.dart

import 'package:flutter/material.dart';
import '../constants/tasks_colors.dart';
import '../constants/tasks_strings.dart';
import '../constants/tasks_icons.dart';

class TaskFilter extends StatelessWidget {
  final String selectedFilter;
  final Color filterColor;
  final VoidCallback onFilterCleared;

  const TaskFilter({
    Key? key,
    required this.selectedFilter,
    required this.filterColor,
    required this.onFilterCleared,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE3E0F8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE3E0F8),
                width: 1,
              ),
            ),
            child: Icon(
              TasksIcons.filter,
              color: filterColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${TasksStrings.filterBy}$selectedFilter',
            style: const TextStyle(
              color: Color(0xFF4338CA),
              fontWeight: FontWeight.w500,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onFilterCleared,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 0),
              foregroundColor: const Color(0xFF6366F1),
            ),
            child: const Text(
              TasksStrings.clearFilter,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
