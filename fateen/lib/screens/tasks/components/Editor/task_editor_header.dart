// lib/features/task_editor/components/task_editor_header.dart

import 'package:flutter/material.dart';
import '../../constants/editor_colors.dart';
import '../../constants/editor_strings.dart';

class TaskEditorHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const TaskEditorHeader({
    Key? key,
    required this.title,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 10),
          child: Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),

        // Header row: close button, title, spacer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Close button
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: EditorColors.primary,
                    size: 18,
                  ),
                ),
              ),

              // Title
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.0,
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: EditorColors.primary,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),

              // Spacer (for alignment)
              const SizedBox(width: 36),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Description box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: EditorColors.primary.withOpacity(0.1),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: EditorColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    EditorStrings.editorDescription,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Divider
        const Divider(height: 1, thickness: 1, color: EditorColors.divider),
      ],
    );
  }
}
