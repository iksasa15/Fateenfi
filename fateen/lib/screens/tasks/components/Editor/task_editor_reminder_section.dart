// lib/features/task_editor/components/task_editor_reminder_section.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/editor_colors.dart';
import '../../constants/editor_icons.dart';
import '../../constants/editor_strings.dart';

class TaskEditorReminderSection extends StatelessWidget {
  final bool hasReminder;
  final DateTime? reminderDateTime;
  final DateTime dueDate;
  final Function(bool) onReminderToggled;
  final Function(DateTime) onReminderDateTimeChanged;

  const TaskEditorReminderSection({
    Key? key,
    required this.hasReminder,
    required this.reminderDateTime,
    required this.dueDate,
    required this.onReminderToggled,
    required this.onReminderDateTimeChanged,
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
              EditorStrings.reminder,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: EditorColors.textDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // مفتاح تفعيل التذكير
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: EditorColors.primary.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Container(
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
                    EditorIcons.reminder,
                    color: EditorColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    EditorStrings.enableReminder,
                    style: const TextStyle(
                      fontSize: 14,
                      color: EditorColors.textDark,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
                Switch(
                  value: hasReminder,
                  onChanged: onReminderToggled,
                  activeColor: EditorColors.primary,
                ),
              ],
            ),
          ),

          if (hasReminder) ...[
            const SizedBox(height: 12),
            // إصلاح مشكلة تجاوز المحتوى عبر استخدام محتوى قابل للتمرير
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 70), // تحديد ارتفاع أقصى
              child: GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: reminderDateTime ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: dueDate,
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
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          reminderDateTime ?? DateTime.now()),
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
                      onReminderDateTimeChanged(DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      ));
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: EditorColors.primary.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              EditorStrings.reminderTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reminderDateTime != null
                                  ? DateFormat('yyyy-MM-dd – HH:mm')
                                      .format(reminderDateTime!)
                                  : EditorStrings.reminderTime,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: reminderDateTime != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: reminderDateTime != null
                                    ? EditorColors.primary
                                    : EditorColors.textLight,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: EditorColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
