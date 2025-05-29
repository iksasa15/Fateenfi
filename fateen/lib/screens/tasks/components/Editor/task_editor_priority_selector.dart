// lib/features/task_editor/components/task_editor_priority_selector.dart

import 'package:flutter/material.dart';
import '../../constants/editor_colors.dart';
import '../../constants/editor_icons.dart';
import '../../constants/editor_strings.dart';

class TaskEditorPrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final Function(String) onPriorityChanged;

  const TaskEditorPrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              EditorStrings.priority,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: EditorColors.textDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // بطاقة تحوي خيارات الأولوية
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: EditorColors.primary.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  EditorStrings.highPriority,
                  EditorStrings.mediumPriority,
                  EditorStrings.lowPriority,
                ].map((priority) {
                  final isSelected = selectedPriority == priority;
                  final priorityColor = EditorColors.getPriorityColor(priority);
                  final icon = EditorIcons.getPriorityIcon(priority);

                  return Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: _buildChoiceChip(
                      label: priority,
                      icon: icon,
                      isSelected: isSelected,
                      color: priorityColor,
                      onSelected: (selected) {
                        if (selected) {
                          onPriorityChanged(priority);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء رقاقة اختيار محسنة
  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
    IconData? icon,
    Color? color,
  }) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? EditorColors.primary
                  : color ?? EditorColors.textDark,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: 13,
              color: isSelected ? EditorColors.primary : EditorColors.textDark,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: Colors.white,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? EditorColors.primaryLight : Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onSelected: onSelected,
    );
  }
}
