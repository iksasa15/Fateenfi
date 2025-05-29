import 'package:flutter/material.dart';
import '../constants/whiteboard_colors.dart';
import '../constants/whiteboard_strings.dart';

class StickerToolsComponent extends StatelessWidget {
  final Function() onEnlarge;
  final Function() onShrink;
  final Function() onRotateLeft;
  final Function() onRotateRight;
  final Function() onDelete;

  const StickerToolsComponent({
    Key? key,
    required this.onEnlarge,
    required this.onShrink,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : WhiteboardColors.kLightPurple,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: WhiteboardColors.kShadowColor,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // نص توضيحي
          Text(
            WhiteboardStrings.editSticker,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : WhiteboardColors.kDarkPurple,
              fontSize: 14,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),

          Row(
            children: [
              // زر تكبير
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: isDarkMode
                      ? WhiteboardColors.kMediumPurple
                      : WhiteboardColors.kDarkPurple,
                ),
                onPressed: onEnlarge,
                tooltip: 'تكبير',
              ),
              // زر تصغير
              IconButton(
                icon: Icon(
                  Icons.remove_circle,
                  color: isDarkMode
                      ? WhiteboardColors.kMediumPurple
                      : WhiteboardColors.kDarkPurple,
                ),
                onPressed: onShrink,
                tooltip: 'تصغير',
              ),
              // زر تدوير لليسار
              IconButton(
                icon: Icon(
                  Icons.rotate_left,
                  color: isDarkMode
                      ? WhiteboardColors.kMediumPurple
                      : WhiteboardColors.kDarkPurple,
                ),
                onPressed: onRotateLeft,
                tooltip: 'تدوير لليسار',
              ),
              // زر تدوير لليمين
              IconButton(
                icon: Icon(
                  Icons.rotate_right,
                  color: isDarkMode
                      ? WhiteboardColors.kMediumPurple
                      : WhiteboardColors.kDarkPurple,
                ),
                onPressed: onRotateRight,
                tooltip: 'تدوير لليمين',
              ),
              // زر حذف
              IconButton(
                icon: const Icon(Icons.delete,
                    color: WhiteboardColors.kAccentColor),
                onPressed: onDelete,
                tooltip: 'حذف',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
