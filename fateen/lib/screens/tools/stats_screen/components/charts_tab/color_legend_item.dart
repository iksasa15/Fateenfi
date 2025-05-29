// components/charts_tab/color_legend_item.dart

import 'package:flutter/material.dart';
import '../../constants/stats_colors.dart';

class ColorLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const ColorLegendItem({
    Key? key,
    required this.color,
    required this.label,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF374151),
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }
}
