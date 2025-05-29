import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../models/language_model.dart';

class FileService {
  // نسخ النص إلى الحافظة
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // مشاركة ملف أو نص
  Future<void> shareFile(String filePath, {String? text}) async {
    if (filePath.isNotEmpty) {
      await Share.shareXFiles([XFile(filePath)], text: text);
    } else if (text != null && text.isNotEmpty) {
      await Share.share(text);
    }
  }

  // قراءة ملف نصي
  Future<String> readTextFile(File file) async {
    try {
      final content = await file.readAsString();
      return content;
    } catch (e) {
      debugPrint('خطأ في قراءة الملف النصي: $e');

      // محاولة قراءة الملف مع تحديد الترميز
      try {
        final bytes = await file.readAsBytes();
        try {
          return utf8.decode(bytes);
        } catch (_) {
          try {
            return latin1.decode(bytes);
          } catch (_) {
            try {
              // محاولة تحديد الترميز تلقائياً
              final content = await compute(_decodeFileWithDetection, bytes);
              if (content.isNotEmpty) {
                return content;
              }
            } catch (_) {}
          }
        }
      } catch (e2) {
        debugPrint('خطأ في قراءة بايتات الملف: $e2');
      }

      throw Exception('فشل في قراءة الملف: غير قادر على تحديد ترميز الملف');
    }
  }

  // دالة مساعدة لتحديد ترميز الملف
  static String _decodeFileWithDetection(Uint8List bytes) {
    final encodings = [utf8, latin1, ascii];

    for (final encoding in encodings) {
      try {
        final decoded = encoding.decode(bytes);
        if (decoded.isNotEmpty) {
          return decoded;
        }
      } catch (_) {}
    }

    // محاولة أخيرة: استخدام UTF-16
    try {
      if (bytes.length >= 2) {
        // التحقق من BOM
        if (bytes[0] == 0xFE && bytes[1] == 0xFF) {
          return String.fromCharCodes(bytes);
        }
      }
    } catch (_) {}

    return '';
  }

  // استخراج النص من ملف PDF
  Future<String> extractTextFromPdf(
      File file, LanguageModel sourceLanguage) async {
    try {
      // استخدام syncfusion_flutter_pdf فقط (تم إزالة pdf_text)
      try {
        final bytes = await file.readAsBytes();
        final document = PdfDocument(inputBytes: bytes);
        final extractor = PdfTextExtractor(document);

        // استخراج النص من جميع الصفحات باستخدام syncfusion
        String text = '';
        try {
          text = extractor.extractText();
        } catch (e) {
          // إذا فشلت طريقة استخراج النص الكامل، جرب صفحة صفحة
          debugPrint('فشل استخراج النص الكامل، جاري المحاولة صفحة بصفحة: $e');
          final buffer = StringBuffer();
          for (int i = 0; i < document.pages.count; i++) {
            try {
              final pageText =
                  extractor.extractText(startPageIndex: i, endPageIndex: i);
              buffer.write(pageText);
              buffer.write('\n');
            } catch (pageError) {
              debugPrint('فشل استخراج النص من الصفحة ${i + 1}: $pageError');
            }
          }
          text = buffer.toString();
        }

        document.dispose();

        if (text.isNotEmpty) {
          debugPrint('تم استخراج النص من PDF بنجاح (Syncfusion)');
          return text;
        }
      } catch (e) {
        debugPrint('فشل استخراج النص باستخدام Syncfusion: $e');
      }

      // إذا وصلنا إلى هنا، فقد فشلت محاولات استخراج النص المباشر
      debugPrint('فشلت محاولات استخراج النص المباشر، سيتم تجربة OCR');

      // استخدام OCR كحل أخير
      return await extractTextFromPdfWithOCR(file, sourceLanguage);
    } catch (e) {
      debugPrint('خطأ عام في استخراج النص من PDF: $e');
      throw Exception(
          'تعذر استخراج النص من المستند. يرجى التأكد من أن المستند يحتوي على نص قابل للتعرف عليه.');
    }
  }

  // استخراج النص من PDF باستخدام OCR
  Future<String> extractTextFromPdfWithOCR(
      File file, LanguageModel sourceLanguage) async {
    debugPrint('بدء استخراج النص من PDF باستخدام OCR');

    try {
      // تحويل PDF إلى صور
      final pages = await _convertPdfToImages(file);
      if (pages.isEmpty) {
        throw Exception('فشل تحويل PDF إلى صور');
      }

      debugPrint('تم تحويل PDF إلى ${pages.length} صفحة/صور');

      // استخدام OCR للتعرف على النص
      // تحديد النص المناسب بناءً على لغة المصدر
      TextRecognitionScript script = TextRecognitionScript.latin;
      if (sourceLanguage.code.toUpperCase() == 'AR') {
        script = TextRecognitionScript
            .latin; // Replace with the correct script if available
      } else if (sourceLanguage.code.toUpperCase() == 'ZH' ||
          sourceLanguage.code.toUpperCase() == 'JA' ||
          sourceLanguage.code.toUpperCase() == 'KO') {
        script = TextRecognitionScript.chinese;
      }

      final textRecognizer = TextRecognizer(script: script);
      final fullText = StringBuffer();

      for (int i = 0; i < pages.length; i++) {
        debugPrint('معالجة الصفحة ${i + 1} من ${pages.length}');
        final imagePath = pages[i];
        final inputImage = InputImage.fromFilePath(imagePath);

        try {
          final recognizedText = await textRecognizer.processImage(inputImage);
          fullText.writeln(recognizedText.text);
          debugPrint(
              'تم التعرف على ${recognizedText.text.length} حرف في الصفحة ${i + 1}');
        } catch (e) {
          debugPrint('فشل التعرف على النص في الصفحة ${i + 1}: $e');
        }
      }

      textRecognizer.close();

      if (fullText.isEmpty) {
        throw Exception('تعذر استخراج أي نص من الصور المحولة');
      }

      debugPrint('تم استخراج ${fullText.length} حرف من PDF باستخدام OCR');
      return fullText.toString();
    } catch (e) {
      debugPrint('خطأ في استخراج النص من PDF باستخدام OCR: $e');
      throw Exception('تعذر استخراج النص من ملف PDF باستخدام OCR: $e');
    }
  }

  // تحويل PDF إلى صور
  Future<List<String>> _convertPdfToImages(File pdfFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputDir = Directory('${tempDir.path}/pdf_images');

      // إنشاء مجلد مؤقت أو تنظيفه إذا كان موجوداً
      if (await outputDir.exists()) {
        await outputDir.delete(recursive: true);
      }
      await outputDir.create(recursive: true);

      // استخدام Syncfusion لتحويل صفحات PDF إلى صور
      final bytes = await pdfFile.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final pageCount = document.pages.count;
      final imagesPaths = <String>[];

      debugPrint('تحويل $pageCount صفحة من PDF إلى صور');

      // تحديد عدد الصفحات للتحويل (إذا كان عدد الصفحات كبيراً، نأخذ الصفحات الأولى فقط)
      int pagesToConvert = pageCount;
      if (pageCount > 50) {
        pagesToConvert = 50; // الحد لتجنب استهلاك موارد كثيرة
        debugPrint('الملف كبير جداً، سيتم تحويل أول $pagesToConvert صفحة فقط');
      }

      for (int i = 0; i < pagesToConvert; i++) {
        final page = document.pages[i];

        // زيادة الدقة للحصول على نتائج أفضل، مع مراعاة الحجم المناسب
        int width = (page.size.width * 2).toInt();
        int height = (page.size.height * 2).toInt();

        // للصفحات الكبيرة جداً، نقلل الدقة
        if (width > 3000 || height > 3000) {
          width = (width * 0.7).toInt();
          height = (height * 0.7).toInt();
        }

        // تحويل الصفحة إلى صورة
        final image = await page.toImage(
          width: width,
          height: height,
        );

        // حفظ الصورة
        final imagePath = '${outputDir.path}/page_${i + 1}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image!.bytes!);

        // ضغط الصورة لتحسين أداء OCR
        final compressedPath = await _compressImage(imagePath);
        imagesPaths.add(compressedPath ?? imagePath);

        debugPrint('تم تحويل الصفحة ${i + 1} إلى صورة');
      }

      document.dispose();
      return imagesPaths;
    } catch (e) {
      debugPrint('خطأ في تحويل PDF إلى صور: $e');
      return [];
    }
  }

  // ضغط الصورة
  Future<String?> _compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final compressedPath = imagePath.replaceFirst('.png', '_compressed.jpg');

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        compressedPath,
        quality: 90,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        return result.path;
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في ضغط الصورة: $e');
      return null;
    }
  }

  // تحسين الصورة للتعرف على النص (يمكن إضافة خيار استخدامها)
  Future<String?> _enhanceImageForOCR(String imagePath) async {
    try {
      final File inputFile = File(imagePath);
      if (!await inputFile.exists()) return null;

      // قراءة الصورة
      final Uint8List bytes = await inputFile.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      // تحسين الصورة
      img.Image enhancedImage = img.adjustColor(
        image,
        contrast: 1.5,
        brightness: 0,
        exposure: 0.5,
      );

      // تحويل الصورة إلى أبيض وأسود للحصول على نتائج أفضل في OCR
      enhancedImage = img.grayscale(enhancedImage);

      // حفظ الصورة المحسنة
      final enhancedPath = imagePath.replaceFirst('.png', '_enhanced.png');
      final enhancedFile = File(enhancedPath);
      await enhancedFile.writeAsBytes(img.encodePng(enhancedImage));

      return enhancedPath;
    } catch (e) {
      debugPrint('خطأ في تحسين الصورة: $e');
      return null;
    }
  }

  // حفظ النص المترجم في ملف
  Future<String> saveTranslatedText(
      String text, String originalFileName) async {
    try {
      final dir =
          await getDownloadsDirectory() ?? await getExternalStorageDirectory();

      if (dir == null) {
        throw Exception('فشل الوصول إلى مجلد التنزيلات');
      }

      // إنشاء مجلد للملفات المترجمة
      final translatedDir = Directory('${dir.path}/translated_files');
      if (!await translatedDir.exists()) {
        await translatedDir.create(recursive: true);
      }

      // استخراج اسم الملف الأصلي بدون امتداد
      final baseName = path.basenameWithoutExtension(originalFileName);

      // إنشاء اسم ملف فريد
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath =
          '${translatedDir.path}/${baseName}_translated_$timestamp.txt';

      // حفظ النص في الملف
      final file = File(filePath);
      await file.writeAsString(text, flush: true);

      debugPrint('تم حفظ النص المترجم في: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('خطأ في حفظ النص المترجم: $e');
      throw Exception('فشل حفظ النص المترجم: $e');
    }
  }
}

extension on PdfPage {
  toImage({required int width, required int height}) {}
}
