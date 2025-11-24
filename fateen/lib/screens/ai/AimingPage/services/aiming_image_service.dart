import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class AimingImageService {
  /// التقاط صورة من الكاميرا أو معرض الصور
  static Future<Map<String, dynamic>> pickImage(ImageSource source) async {
    try {
      // استدعاء طريقة اختيار الصورة
      final ImagePicker picker = ImagePicker();

      // إضافة مهلة لمنع التعليق
      final XFile? pickedFile = await picker
          .pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              "انتهى وقت الانتظار أثناء محاولة التقاط الصورة");
        },
      );

      if (pickedFile == null) {
        return {'success': false, 'error': 'لم يتم اختيار صورة'};
      }

      // الحصول على مسار الصورة
      final imagePath = pickedFile.path;

      // تحويل الصورة إلى Base64
      String? imageBase64;
      try {
        if (kIsWeb) {
          // في الويب، نحصل على البيانات كـ bytes
          final bytes = await pickedFile.readAsBytes();
          imageBase64 = base64Encode(bytes);
        } else {
          // في التطبيقات الأصلية، نقرأ الملف كـ bytes
          final bytes = await File(imagePath).readAsBytes();
          imageBase64 = base64Encode(bytes);
        }
      } catch (e) {
        debugPrint("خطأ عند قراءة الصورة: $e");
        return {'success': false, 'error': 'فشل قراءة بيانات الصورة: $e'};
      }

      return {
        'success': true,
        'imagePath': imagePath,
        'imageBase64': imageBase64,
      };
    } catch (e) {
      debugPrint("خطأ في التقاط الصورة: $e");
      return {'success': false, 'error': 'حدث خطأ أثناء التقاط الصورة: $e'};
    }
  }

  /// ضغط الصورة وتحويلها لحجم مناسب
  static Future<Map<String, dynamic>> compressImage(String imagePath) async {
    try {
      // هنا يمكن إضافة منطق ضغط الصورة باستخدام مكتبة مثل flutter_image_compress
      // لتبسيط المثال، سنفترض أن الصورة تم ضغطها بالفعل عند التقاطها

      // قراءة الصورة كـ bytes وتحويلها إلى Base64
      final bytes = await File(imagePath).readAsBytes();
      final imageBase64 = base64Encode(bytes);

      return {
        'success': true,
        'imagePath': imagePath,
        'imageBase64': imageBase64,
      };
    } catch (e) {
      debugPrint("خطأ في ضغط الصورة: $e");
      return {'success': false, 'error': 'حدث خطأ أثناء ضغط الصورة: $e'};
    }
  }
}
