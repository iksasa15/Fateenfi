import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Badge extends StatelessWidget {
  final String text;
  final double size;
  final Color borderColor;

  const Badge(
    this.text, {
    Key? key,
    required this.size,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: Center(
        child: Text(
          text.split(' ')[0],
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: borderColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
