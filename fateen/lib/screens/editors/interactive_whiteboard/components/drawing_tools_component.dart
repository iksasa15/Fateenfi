import 'package:flutter/material.dart';
import '../constants/whiteboard_colors.dart';
import '../constants/whiteboard_strings.dart';
import '../constants/whiteboard_values.dart';

class DrawingToolsComponent extends StatelessWidget {
  final Color selectedColor;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final Function(Color) onColorChanged;
  final Function(double) onStrokeWidthChanged;
  final Function(StrokeCap) onStrokeCapChanged;

  const DrawingToolsComponent({
    Key? key,
    required this.selectedColor,
    required this.strokeWidth,
    required this.strokeCap,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    required this.onStrokeCapChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WhiteboardColors.getSecondaryBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: WhiteboardColors.kShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الألوان
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: WhiteboardColors.drawingColors.map((color) {
                return _buildColorButton(color, isDarkMode);
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // أنماط الخط
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStrokeCapButton(
                  StrokeCap.round, Icons.lens_outlined, isDarkMode),
              const SizedBox(width: 8),
              _buildStrokeCapButton(
                  StrokeCap.square, Icons.crop_square_outlined, isDarkMode),
              const SizedBox(width: 8),
              _buildStrokeCapButton(
                  StrokeCap.butt, Icons.horizontal_rule, isDarkMode),
            ],
          ),

          const SizedBox(height: 12),

          // سماكة القلم
          Row(
            children: [
              Text(
                WhiteboardStrings.strokeWidth,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'SYMBIOAR+LT',
                  color: WhiteboardColors.getTextColor(isDarkMode),
                ),
              ),
              Expanded(
                child: Slider(
                  value: strokeWidth,
                  min: WhiteboardValues.minStrokeWidth,
                  max: WhiteboardValues.maxStrokeWidth,
                  divisions: 9,
                  activeColor: isDarkMode
                      ? WhiteboardColors.kMediumPurple
                      : WhiteboardColors.kDarkPurple,
                  inactiveColor: isDarkMode
                      ? WhiteboardColors.kMediumPurple.withOpacity(0.3)
                      : WhiteboardColors.kDarkPurple.withOpacity(0.3),
                  onChanged: onStrokeWidthChanged,
                ),
              ),
              Container(
                width: strokeWidth * 2,
                height: strokeWidth * 2,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: WhiteboardColors.kShadowColor,
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء زر لون
  Widget _buildColorButton(Color color, bool isDarkMode) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => onColorChanged(color),
      child: AnimatedContainer(
        duration: WhiteboardValues.animationDuration,
        width: isSelected ? 34 : 30,
        height: isSelected ? 34 : 30,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? isDarkMode
                    ? WhiteboardColors.kMediumPurple
                    : WhiteboardColors.kDarkPurple
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: isDarkMode
                    ? WhiteboardColors.kMediumPurple.withOpacity(0.4)
                    : WhiteboardColors.kDarkPurple.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
      ),
    );
  }

  /// بناء زر نمط القلم
  Widget _buildStrokeCapButton(StrokeCap cap, IconData icon, bool isDarkMode) {
    final bool isSelected = cap == strokeCap;

    return GestureDetector(
      onTap: () => onStrokeCapChanged(cap),
      child: AnimatedContainer(
        duration: WhiteboardValues.animationDuration,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple
              : isDarkMode
                  ? Colors.grey[800]
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode
                ? WhiteboardColors.kMediumPurple
                : WhiteboardColors.kDarkPurple,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: isDarkMode
                        ? WhiteboardColors.kMediumPurple.withOpacity(0.3)
                        : WhiteboardColors.kDarkPurple.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : isDarkMode
                    ? WhiteboardColors.kMediumPurple
                    : WhiteboardColors.kDarkPurple,
            size: 24,
          ),
        ),
      ),
    );
  }
}
