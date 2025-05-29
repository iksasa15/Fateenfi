// lib/features/task_editor/components/task_editor_field.dart

import 'package:flutter/material.dart';
import '../../constants/editor_colors.dart';
import '../../constants/editor_icons.dart';

class TaskEditorField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? errorText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool autoFocus;
  final IconData? customIcon;

  const TaskEditorField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.errorText,
    this.hintText,
    this.keyboardType,
    this.autoFocus = false,
    this.customIcon,
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

          // Input field
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? EditorColors.error
                    : EditorColors.primary.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Field icon
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
                  child: Icon(
                    customIcon ?? EditorIcons.textField,
                    color: controller.text.isEmpty
                        ? EditorColors.primaryLight
                        : EditorColors.primary,
                    size: 16,
                  ),
                ),

                // Input field
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    autofocus: autoFocus,
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
                      errorText: null,
                      errorStyle: const TextStyle(
                        height: 0,
                        fontSize: 0,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
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

          // Error message
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: EditorColors.error,
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
