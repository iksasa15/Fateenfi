import 'package:flutter/material.dart';

class Sticker {
  final String id;
  final String imagePath;
  final Offset offset;
  final double scale;
  final double rotation;

  Sticker({
    required this.id,
    required this.imagePath,
    required this.offset,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  /// نسخ مع تغيير القيم المطلوبة
  Sticker copyWith({
    String? id,
    String? imagePath,
    Offset? offset,
    double? scale,
    double? rotation,
  }) {
    return Sticker(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  /// تحويل الملصق إلى تنسيق JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'offsetX': offset.dx,
      'offsetY': offset.dy,
      'scale': scale,
      'rotation': rotation,
    };
  }

  /// إنشاء ملصق من بيانات JSON
  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      offset: Offset(
        (json['offsetX'] as num).toDouble(),
        (json['offsetY'] as num).toDouble(),
      ),
      scale: (json['scale'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
    );
  }
}
