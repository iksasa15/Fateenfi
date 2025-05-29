import 'package:flutter/material.dart';

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;
  final StrokeCap strokeCap;

  DrawnLine({
    required this.points,
    required this.color,
    required this.width,
    required this.strokeCap,
  });

  /// نسخ مع تغيير القيم المطلوبة
  DrawnLine copyWith({
    List<Offset>? points,
    Color? color,
    double? width,
    StrokeCap? strokeCap,
  }) {
    return DrawnLine(
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
      strokeCap: strokeCap ?? this.strokeCap,
    );
  }

  /// تحويل الخط إلى تنسيق JSON
  Map<String, dynamic> toJson() {
    return {
      'color': color.value,
      'width': width,
      'strokeCap': strokeCap.index,
      'points': points
          .map((point) => {
                'x': point.dx,
                'y': point.dy,
              })
          .toList(),
    };
  }

  /// إنشاء خط من بيانات JSON
  factory DrawnLine.fromJson(Map<String, dynamic> json) {
    List<dynamic> pointsData = json['points'] ?? [];
    List<Offset> points = pointsData.map<Offset>((pointData) {
      return Offset(
        pointData['x'] as double,
        pointData['y'] as double,
      );
    }).toList();

    return DrawnLine(
      points: points,
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
      strokeCap: StrokeCap.values[json['strokeCap'] as int],
    );
  }
}
