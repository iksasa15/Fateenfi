import 'package:flutter/material.dart';
import '../constants/whiteboard_colors.dart';
import '../constants/whiteboard_strings.dart';

class StickerControlsComponent extends StatelessWidget {
  final int stickersCount;
  final bool isStickerPanelOpen;
  final Function() onToggleStickerPanel;

  const StickerControlsComponent({
    Key? key,
    required this.stickersCount,
    required this.isStickerPanelOpen,
    required this.onToggleStickerPanel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // زر إضافة ملصق
        ElevatedButton.icon(
          onPressed: onToggleStickerPanel,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode
                ? WhiteboardColors.kMediumPurple
                : WhiteboardColors.kDarkPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: Icon(
            isStickerPanelOpen ? Icons.close : Icons.add,
            size: 20,
          ),
          label: Text(
            isStickerPanelOpen
                ? WhiteboardStrings.closePanel
                : WhiteboardStrings.addSticker,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
        const SizedBox(width: 12),
        // عدد الملصقات المضافة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                isDarkMode ? Colors.grey[800] : WhiteboardColors.kLightPurple,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.photo_library,
                color: isDarkMode
                    ? WhiteboardColors.kMediumPurple
                    : WhiteboardColors.kDarkPurple,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$stickersCount${WhiteboardStrings.stickersCount}',
                style: TextStyle(
                  color:
                      isDarkMode ? Colors.white : WhiteboardColors.kDarkPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // نص توضيحي للاستخدام
        Text(
          WhiteboardStrings.tapToMove,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
            fontSize: 12,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }
}
