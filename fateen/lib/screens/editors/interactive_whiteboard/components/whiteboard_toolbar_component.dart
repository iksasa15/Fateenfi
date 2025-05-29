// components/whiteboard_toolbar_component.dart

import 'package:flutter/material.dart';
import '../constants/whiteboard_colors.dart';
import '../constants/whiteboard_strings.dart';

class WhiteboardToolbarComponent extends StatelessWidget {
  final bool canUndo;
  final bool canRedo;
  final bool hasContent;
  final Function() onUndo;
  final Function() onRedo;
  final Function() onClear;
  final Function() onToggleTools;
  final bool isToolsOpen;
  final Function(String) onMenuItemSelected;

  const WhiteboardToolbarComponent({
    Key? key,
    required this.canUndo,
    required this.canRedo,
    required this.hasContent,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.onToggleTools,
    required this.isToolsOpen,
    required this.onMenuItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: WhiteboardColors.kShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر فتح/إغلاق الأدوات
          IconButton(
            icon: Icon(
              isToolsOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
            ),
            onPressed: onToggleTools,
            tooltip: isToolsOpen
                ? WhiteboardStrings.hideTools
                : WhiteboardStrings.showTools,
          ),

          // زر التراجع
          IconButton(
            icon: Icon(
              Icons.undo,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
            ),
            onPressed: canUndo ? onUndo : null,
            tooltip: WhiteboardStrings.undo,
          ),

          // زر الإعادة
          IconButton(
            icon: Icon(
              Icons.redo,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
            ),
            onPressed: canRedo ? onRedo : null,
            tooltip: WhiteboardStrings.redo,
          ),

          // زر المسح
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: WhiteboardColors.kAccentColor),
            onPressed: hasContent ? onClear : null,
            tooltip: WhiteboardStrings.clear,
          ),

          // القائمة الرئيسية (خيارات الملف)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
            ),
            onSelected: onMenuItemSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.create_new_folder_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(WhiteboardStrings.newFile),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_outlined, size: 20),
                    SizedBox(width: 8),
                    Text("نسخ الرسمة الحالية"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(WhiteboardStrings.save),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(WhiteboardStrings.share),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(WhiteboardStrings.rename),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'files',
                child: Row(
                  children: [
                    Icon(Icons.folder_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(WhiteboardStrings.savedFiles),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'deletePage',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 20),
                    SizedBox(width: 8),
                    Text("حذف الصفحة الحالية"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
