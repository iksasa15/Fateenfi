// components/whiteboard_action_component.dart

import 'package:fateen/models/sticker_model.dart';
import 'package:flutter/material.dart';
import '../constants/whiteboard_colors.dart';
import '../constants/whiteboard_values.dart';
import 'drawing_tools_component.dart';
import 'sticker_tools_component.dart';
import 'sticker_controls_component.dart';

class WhiteboardActionComponent extends StatelessWidget {
  final bool isStickerMode;
  final int? selectedStickerIndex;
  final List<Sticker> stickers;
  final bool isStickerPanelOpen;
  final Color selectedColor;
  final double strokeWidth;
  final StrokeCap strokeCap;

  final Function() onToggleStickerPanel;
  final Function() onEnlargeSticker;
  final Function() onShrinkSticker;
  final Function() onRotateLeft;
  final Function() onRotateRight;
  final Function() onDeleteSticker;
  final Function(Color) onColorChanged;
  final Function(double) onStrokeWidthChanged;
  final Function(StrokeCap) onStrokeCapChanged;

  const WhiteboardActionComponent({
    Key? key,
    required this.isStickerMode,
    required this.selectedStickerIndex,
    required this.stickers,
    required this.isStickerPanelOpen,
    required this.selectedColor,
    required this.strokeWidth,
    required this.strokeCap,
    required this.onToggleStickerPanel,
    required this.onEnlargeSticker,
    required this.onShrinkSticker,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onDeleteSticker,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    required this.onStrokeCapChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: isStickerMode
          ? (selectedStickerIndex != null
              ? StickerToolsComponent(
                  onEnlarge: onEnlargeSticker,
                  onShrink: onShrinkSticker,
                  onRotateLeft: onRotateLeft,
                  onRotateRight: onRotateRight,
                  onDelete: onDeleteSticker,
                )
              : StickerControlsComponent(
                  stickersCount: stickers.length,
                  isStickerPanelOpen: isStickerPanelOpen,
                  onToggleStickerPanel: onToggleStickerPanel,
                ))
          : DrawingToolsComponent(
              selectedColor: selectedColor,
              strokeWidth: strokeWidth,
              strokeCap: strokeCap,
              onColorChanged: onColorChanged,
              onStrokeWidthChanged: onStrokeWidthChanged,
              onStrokeCapChanged: onStrokeCapChanged,
            ),
    );
  }
}
