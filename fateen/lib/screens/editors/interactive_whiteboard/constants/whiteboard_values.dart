import 'package:flutter/material.dart';

class WhiteboardValues {
  // مسارات الملصقات
  static const List<String> availableStickers = [
    'assets/stickers/star.png',
    'assets/stickers/heart.png',
    'assets/stickers/smile.png',
    'assets/stickers/trophy.png',
    'assets/stickers/check.png',
    'assets/stickers/light.png',
    'assets/stickers/idea.png',
    'assets/stickers/note.png',
  ];

  // قيم الحجم والتحجيم
  static const double minStrokeWidth = 1.0;
  static const double maxStrokeWidth = 10.0;
  static const double defaultStrokeWidth = 3.0;
  static const double minStickerScale = 0.5;
  static const double maxStickerScale = 2.0;
  static const double defaultStickerScale = 1.0;

  // قيم التدوير
  static const double rotationIncrement = 0.1;

  // قيم التكبير والتصغير
  static const double scaleUpFactor = 1.2;
  static const double scaleDownFactor = 0.8;

  // ثوابت أنماط القلم
  static const Map<StrokeCap, IconData> strokeCapIcons = {
    StrokeCap.round: Icons.lens_outlined,
    StrokeCap.square: Icons.crop_square_outlined,
    StrokeCap.butt: Icons.horizontal_rule,
  };

  // قيم الرسوم المتحركة
  static const Duration animationDuration = Duration(milliseconds: 300);

  // أبعاد الملصقات
  static const double defaultStickerSize = 60.0;
  static const double stickerPanelHeight = 100.0;

  // كثافة البكسل للتصدير
  static const double exportPixelRatio = 3.0;
}
