// lib/features/task_editor/components/task_editor_tags_section.dart

import 'package:flutter/material.dart';
import '../../constants/editor_colors.dart';
import '../../constants/editor_icons.dart';
import '../../constants/editor_strings.dart';

class TaskEditorTagsSection extends StatefulWidget {
  final List<String> tags;
  final Function(String) onTagAdded;
  final Function(String) onTagRemoved;

  const TaskEditorTagsSection({
    Key? key,
    required this.tags,
    required this.onTagAdded,
    required this.onTagRemoved,
  }) : super(key: key);

  @override
  _TaskEditorTagsSectionState createState() => _TaskEditorTagsSectionState();
}

class _TaskEditorTagsSectionState extends State<TaskEditorTagsSection> {
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
              EditorStrings.tags,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: EditorColors.textDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // بطاقة تحوي الوسوم
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.tags.isEmpty)
                  Text(
                    "لم يتم إضافة وسوم بعد",
                    style: TextStyle(
                      fontSize: 14,
                      color: EditorColors.textLight,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    ...widget.tags.map((tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              color: EditorColors.primary,
                              fontSize: 13,
                            ),
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                            color: EditorColors.primaryLight,
                          ),
                          backgroundColor: EditorColors.backgroundLight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          visualDensity: VisualDensity.compact,
                          deleteButtonTooltipMessage: "إزالة",
                          onDeleted: () => widget.onTagRemoved(tag),
                        )),
                    ActionChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add,
                            size: 14,
                            color: EditorColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            EditorStrings.addTag,
                            style: const TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              color: EditorColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: EditorColors.primaryLight,
                        width: 1.0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _showAddTagDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // إظهار حوار إضافة وسم جديد
  void _showAddTagDialog(BuildContext context) {
    final TextEditingController tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EditorStrings.newTag,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: EditorColors.primary,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                const SizedBox(height: 16),
                _buildTagField(
                  controller: tagController,
                  labelText: EditorStrings.addTag,
                  autoFocus: true,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: Text(
                        EditorStrings.cancel,
                        style: const TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (tagController.text.trim().isNotEmpty) {
                          widget.onTagAdded(tagController.text.trim());
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EditorColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        EditorStrings.add,
                        style: const TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // بناء حقل إدخال النص لإضافة وسم
  Widget _buildTagField({
    required TextEditingController controller,
    required String labelText,
    bool autoFocus = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الحقل
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

          // حقل الإدخال
          Container(
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
                // أيقونة حقل الإدخال
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
                    EditorIcons.tag,
                    color: EditorColors.primaryLight,
                    size: 16,
                  ),
                ),

                // حقل الإدخال نفسه
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus: autoFocus,
                    style: const TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: 14,
                      color: EditorColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: "اكتب وسم...",
                      hintStyle: const TextStyle(
                        color: EditorColors.textLight,
                        fontSize: 14,
                        fontFamily: 'SYMBIOAR+LT',
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
        ],
      ),
    );
  }
}
