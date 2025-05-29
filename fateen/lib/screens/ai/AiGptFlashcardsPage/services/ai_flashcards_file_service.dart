// ai_flashcards_file_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class AiFlashcardsFileService {
  /// التقاط ملف وقراءة محتواه
  static Future<Map<String, dynamic>> pickAndReadFile() async {
    try {
      // استدعاء طريقة اختيار الملف
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'docx'],
      );

      if (result == null || result.files.isEmpty) {
        return {'success': false, 'error': 'لم يتم اختيار ملف'};
      }

      // الحصول على مسار الملف
      final file = result.files.first;
      final fileName = file.name;
      final fileExtension = extension(fileName).toLowerCase();

      String content = '';

      // قراءة ملف نصي
      if (fileExtension == '.txt') {
        if (kIsWeb) {
          // في الويب، نقرأ الملف من الذاكرة مباشرة
          if (file.bytes != null) {
            content = String.fromCharCodes(file.bytes!);
          }
        } else {
          // في التطبيقات الأصلية، نقرأ من المسار
          if (file.path != null) {
            final fileContent = await File(file.path!).readAsString();
            content = fileContent;
          }
        }
      }
      // قراءة ملف PDF
      else if (fileExtension == '.pdf') {
        content = await _extractTextFromPdf(file);
      }
      // ملفات أخرى غير مدعومة حاليًا
      else {
        return {
          'success': false,
          'error': 'نوع الملف غير مدعوم. الأنواع المدعومة: txt، pdf'
        };
      }

      // التحقق من محتوى الملف
      if (content.isEmpty) {
        return {'success': false, 'error': 'الملف فارغ أو تعذر قراءته'};
      }

      return {'success': true, 'fileName': fileName, 'content': content};
    } catch (e) {
      debugPrint("خطأ في قراءة الملف: $e");
      return {'success': false, 'error': 'حدث خطأ أثناء قراءة الملف: $e'};
    }
  }

  /// استخراج النص من ملف PDF
  static Future<String> _extractTextFromPdf(PlatformFile file) async {
    try {
      // في الويب، نستخدم البيانات المخزنة في الذاكرة
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception("بيانات الملف فارغة");
        }

        // استخدام مكتبة syncfusion_flutter_pdf لاستخراج النص
        final PdfDocument document = PdfDocument(inputBytes: file.bytes);
        final String text = PdfTextExtractor(document).extractText();
        document.dispose();

        return text;
      }
      // في التطبيقات الأصلية، نحفظ الملف مؤقتًا ثم نستخدم Tesseract OCR أو Syncfusion
      else {
        if (file.path == null) {
          throw Exception("مسار الملف غير متوفر");
        }

        // استخدام مكتبة syncfusion_flutter_pdf لاستخراج النص
        try {
          final PdfDocument document =
              PdfDocument(inputBytes: await File(file.path!).readAsBytes());
          final String text = PdfTextExtractor(document).extractText();
          document.dispose();

          // إذا كان النص فارغًا، جرب Tesseract OCR
          if (text.trim().isEmpty) {
            return await _extractTextWithOCR(file.path!);
          }

          return text;
        } catch (e) {
          debugPrint("فشل استخراج النص باستخدام Syncfusion: $e");
          return await _extractTextWithOCR(file.path!);
        }
      }
    } catch (e) {
      debugPrint("خطأ في استخراج النص من PDF: $e");

      // إعادة سلسلة فارغة بدلاً من رمي استثناء لتجنب انهيار التطبيق
      return "";
    }
  }

  /// استخراج النص من صور الملف PDF باستخدام Tesseract OCR
  static Future<String> _extractTextWithOCR(String filePath) async {
    try {
      // حفظ ملف PDF مؤقتًا لاستخدامه مع Tesseract
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/temp_pdf_image.png';

      // محاولة استخراج النص باستخدام Tesseract OCR
      String recognizedText = await FlutterTesseractOcr.extractText(
        filePath,
        language: 'ara+eng',
        args: {
          "psm": "4",
          "preserve_interword_spaces": "1",
        },
      );

      return recognizedText;
    } catch (e) {
      debugPrint("فشل استخراج النص باستخدام OCR: $e");
      return "";
    }
  }
}
