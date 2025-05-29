import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/whiteboard_colors.dart';
import '../constants/whiteboard_strings.dart';
import '../constants/whiteboard_values.dart';

class StickersPanelComponent extends StatelessWidget {
  final Function(String) onStickerSelected;

  const StickersPanelComponent({
    Key? key,
    required this.onStickerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeIn(
      duration: WhiteboardValues.animationDuration,
      child: Container(
        height: WhiteboardValues.stickerPanelHeight,
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : WhiteboardColors.kLightPurple,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode
                ? WhiteboardColors.kMediumPurple.withOpacity(0.3)
                : WhiteboardColors.kDarkPurple.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: WhiteboardColors.kShadowColor,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: WhiteboardValues.availableStickers.map((stickerPath) {
            return _buildStickerItem(context, stickerPath, isDarkMode);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStickerItem(
      BuildContext context, String stickerPath, bool isDarkMode) {
    return GestureDetector(
      onTap: () => onStickerSelected(stickerPath),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                stickerPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            FadeIn(
              child: Icon(
                Icons.add_circle,
                color: isDarkMode
                    ? WhiteboardColors.kMediumPurple
                    : WhiteboardColors.kDarkPurple,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
