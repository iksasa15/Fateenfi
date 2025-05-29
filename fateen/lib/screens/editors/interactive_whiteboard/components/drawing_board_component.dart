import 'package:flutter/material.dart';
import '../../../../models/drawn_line_model.dart';
import '../../../../models/sticker_model.dart';
import '../utils/drawing_painter.dart';
import '../constants/whiteboard_colors.dart';
import '../constants/whiteboard_values.dart';

class DrawingBoardComponent extends StatelessWidget {
  final GlobalKey boardKey;
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;
  final List<Sticker> stickers;
  final int? selectedStickerIndex;
  final bool isStickerMode;
  final Function(Offset) onPanStart;
  final Function(Offset) onPanUpdate;
  final Function() onPanEnd;
  final Function(int) onStickerTap;
  final Function(int, Offset) onStickerMove;
  final Function() onBoardTap;

  const DrawingBoardComponent({
    Key? key,
    required this.boardKey,
    required this.lines,
    this.currentLine,
    required this.stickers,
    this.selectedStickerIndex,
    required this.isStickerMode,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onStickerTap,
    required this.onStickerMove,
    required this.onBoardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white, // السبورة دائمًا بيضاء
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDarkMode
                ? WhiteboardColors.kMediumPurple.withOpacity(0.3)
                : WhiteboardColors.kLightPurple,
            width: 2,
          ),
        ),
        child: RepaintBoundary(
          key: boardKey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: GestureDetector(
              onTap: onBoardTap,
              onPanStart: !isStickerMode
                  ? (details) => onPanStart(details.localPosition)
                  : null,
              onPanUpdate: !isStickerMode
                  ? (details) => onPanUpdate(details.localPosition)
                  : null,
              onPanEnd: !isStickerMode ? (_) => onPanEnd() : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // خلفية بيضاء
                  Container(color: Colors.white),

                  // رسم الخطوط
                  CustomPaint(
                    painter: DrawingPainter(
                      lines: lines,
                      currentLine: currentLine,
                    ),
                    size: Size.infinite,
                  ),

                  // الملصقات
                  if (stickers.isNotEmpty) _buildStickersLayer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // بناء طبقة الملصقات
  Widget _buildStickersLayer() {
    return Stack(
      children: stickers.asMap().entries.map((entry) {
        final index = entry.key;
        final sticker = entry.value;
        final isSelected = selectedStickerIndex == index && isStickerMode;

        return Positioned(
          left: sticker.offset.dx,
          top: sticker.offset.dy,
          child: GestureDetector(
            onTap: isStickerMode ? () => onStickerTap(index) : null,
            onPanUpdate: isStickerMode
                ? (details) => onStickerMove(index, details.delta)
                : null,
            child: Transform.scale(
              scale: sticker.scale,
              child: Transform.rotate(
                angle: sticker.rotation,
                child: _buildStickerItem(sticker, isSelected),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // بناء عنصر الملصق
  Widget _buildStickerItem(Sticker sticker, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        border: isSelected
            ? Border.all(
                color: WhiteboardColors.kAccentColor,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              )
            : null,
        borderRadius: isSelected ? BorderRadius.circular(8) : null,
        boxShadow: (isStickerMode && isSelected)
            ? [
                BoxShadow(
                  color: WhiteboardColors.kAccentColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                ),
              ]
            : (isStickerMode)
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
      ),
      child: Image.asset(
        sticker.imagePath,
        width: WhiteboardValues.defaultStickerSize,
        height: WhiteboardValues.defaultStickerSize,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: WhiteboardValues.defaultStickerSize,
            height: WhiteboardValues.defaultStickerSize,
            color: Colors.grey[300],
            child: Icon(
              Icons.broken_image,
              color: Colors.grey[600],
            ),
          );
        },
      ),
    );
  }
}
