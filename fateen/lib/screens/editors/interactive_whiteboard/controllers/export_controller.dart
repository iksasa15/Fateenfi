import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExportController {
  /// تصدير محتوى Widget كصورة
  static Future<Uint8List?> exportWidgetToImage(
      GlobalKey widgetKey, double pixelRatio) async {
    try {
      final RenderRepaintBoundary boundary =
          widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // تحويل الـ widget إلى صورة
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

      // تحويل الصورة إلى بيانات
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }

      return null;
    } catch (e) {
      print('خطأ في تصدير الصورة: $e');
      return null;
    }
  }

  /// حساب حجم العرض المناسب للتصدير
  static double calculateExportScale(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // تقييد جودة التصدير على الأجهزة الضعيفة
    if (screenWidth < 400) {
      return 2.0; // تصدير بجودة أقل على الأجهزة الصغيرة
    } else {
      return 3.0; // تصدير بجودة عالية على الأجهزة القياسية
    }
  }
}
