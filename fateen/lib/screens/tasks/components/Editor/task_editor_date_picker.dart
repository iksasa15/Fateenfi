// lib/features/task_editor/components/task_editor_date_picker.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/editor_colors.dart';
import '../../constants/editor_icons.dart';
import '../../constants/editor_strings.dart';

class TaskEditorDatePicker extends StatelessWidget {
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final Function(DateTime) onDateChanged;
  final Function(TimeOfDay) onTimeChanged;

  const TaskEditorDatePicker({
    Key? key,
    required this.dueDate,
    required this.dueTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              EditorStrings.dueDate,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: EditorColors.textDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // Date and time pickers
          Row(
            children: [
              // Date picker
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: EditorColors.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      onDateChanged(date);
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: EditorColors.primary.withOpacity(0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Calendar icon
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: EditorColors.primary.withOpacity(0.1),
                              width: 1.0,
                            ),
                          ),
                          child: const Icon(
                            EditorIcons.calendar,
                            color: EditorColors.primary,
                            size: 16,
                          ),
                        ),

                        // Date display
                        Expanded(
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(dueDate),
                            style: const TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              fontSize: 14,
                              color: EditorColors.textDark,
                            ),
                          ),
                        ),

                        // Dropdown arrow
                        Container(
                          margin: const EdgeInsets.only(left: 4, right: 8),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: EditorColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Time picker
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: dueTime,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: EditorColors.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      onTimeChanged(time);
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: EditorColors.primary.withOpacity(0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Clock icon
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: EditorColors.primary.withOpacity(0.1),
                              width: 1.0,
                            ),
                          ),
                          child: const Icon(
                            EditorIcons.time,
                            color: EditorColors.primary,
                            size: 16,
                          ),
                        ),

                        // Time display
                        Expanded(
                          child: Text(
                            dueTime.format(context),
                            style: const TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              fontSize: 14,
                              color: EditorColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
