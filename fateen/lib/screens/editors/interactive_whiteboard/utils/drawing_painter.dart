import 'package:flutter/material.dart';
import '../../../../models/drawn_line_model.dart';

/// رسام الخطوط
class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;

  DrawingPainter({
    required this.lines,
    this.currentLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // رسم الخطوط المحفوظة
    for (final line in lines) {
      _drawLine(canvas, line);
    }

    // رسم الخط الحالي أثناء الرسم
    if (currentLine != null) {
      _drawLine(canvas, currentLine!);
    }
  }

  // دالة مساعدة لرسم خط
  void _drawLine(Canvas canvas, DrawnLine line) {
    if (line.points.isEmpty) return;

    if (line.points.length < 2) {
      // إذا كان الخط يحتوي على نقطة واحدة، نرسم دائرة
      canvas.drawCircle(
        line.points.first,
        line.width / 2,
        Paint()
          ..color = line.color
          ..strokeCap = line.strokeCap
          ..strokeWidth = line.width,
      );
      return;
    }

    // رسم الخط العادي إذا كان هناك أكثر من نقطة
    final paint = Paint()
      ..color = line.color
      ..strokeWidth = line.width
      ..strokeCap = line.strokeCap
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // رسم الخط بشكل مباشر
    final path = Path();
    path.moveTo(line.points.first.dx, line.points.first.dy);

    for (int i = 1; i < line.points.length; i++) {
      path.lineTo(line.points[i].dx, line.points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.lines != lines || oldDelegate.currentLine != currentLine;
  }
}
