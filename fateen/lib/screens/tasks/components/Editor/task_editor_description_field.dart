// lib/features/task_editor/components/task_editor_description_field.dart

import 'package:flutter/material.dart';
import '../../constants/editor_colors.dart';
import '../../constants/editor_icons.dart';
import '../../constants/editor_strings.dart';

class TaskEditorDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;

  const TaskEditorDescriptionField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field label
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              labelText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: EditorColors.textDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // Description field
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: EditorColors.primary.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field icon
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  child: Icon(
                    EditorIcons.description,
                    color: controller.text.isEmpty
                        ? EditorColors.primaryLight
                        : EditorColors.primary,
                    size: 16,
                  ),
                ),

                // Text area
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: 5,
                    style: const TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: 14,
                      color: EditorColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        color: EditorColors.textLight,
                        fontSize: 14,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Word & character count
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: Text(
              "${controller.text.split(' ').where((word) => word.isNotEmpty).length}${EditorStrings.wordCount}"
              "${controller.text.length}${EditorStrings.charCount}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
