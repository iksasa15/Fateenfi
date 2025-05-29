import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../models/drawing_file_model.dart';
import '../../../../models/drawn_line_model.dart';
import '../../../../models/sticker_model.dart';
import '../utils/file_utils.dart';
import 'drawing_controller.dart';

class FilesController extends ChangeNotifier {
  /// قائمة الملفات المحفوظة
  List<DrawingFile> _savedFiles = [];
  List<DrawingFile> get savedFiles => _savedFiles;

  /// هل قائمة الملفات مفتوحة؟
  bool _isFilesPanelOpen = false;
  bool get isFilesPanelOpen => _isFilesPanelOpen;

  /// حالة التحميل
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// رسالة الخطأ (إضافة جديدة)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // تبديل حالة قائمة الملفات
  void toggleFilesPanel() {
    _isFilesPanelOpen = !_isFilesPanelOpen;
    _errorMessage = null; // إعادة تعيين رسالة الخطأ

    if (_isFilesPanelOpen) {
      loadSavedFiles();
    }

    notifyListeners();
  }

  // تعيين حالة التحميل
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // تعيين رسالة الخطأ
  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // تحميل الملفات المحفوظة
  Future<void> loadSavedFiles() async {
    setLoading(true);
    setErrorMessage(null);

    try {
      print('جاري تحميل الملفات المحفوظة...');
      final List<DrawingFile> files = await FileUtils.loadSavedDrawingFiles();
      print('تم تحميل ${files.length} ملف');
      _savedFiles = files;
    } catch (e) {
      print('خطأ في تحميل الملفات: $e');
      setErrorMessage('حدث خطأ أثناء تحميل الملفات: $e');
    } finally {
      setLoading(false);
    }
  }

  // حفظ الرسم الحالي - محدثة لدعم الصفحات المتعددة
  Future<bool> saveDrawing({
    required String fileId,
    required String fileName,
    required DateTime creationDate,
    required List<WhiteboardPage> pages,
    required Uint8List imageData,
  }) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      // الحصول على مجلد التطبيق المخصص للتخزين
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String drawingsDirPath = '${appDocDir.path}/drawings';
      print('مسار مجلد الرسومات: $drawingsDirPath');

      // التأكد من وجود المجلد
      final Directory drawingsDir = Directory(drawingsDirPath);
      if (!await drawingsDir.exists()) {
        print('إنشاء مجلد الرسومات لأنه غير موجود');
        await drawingsDir.create(recursive: true);
      }

      // حفظ الصورة المصغرة (صورة الصفحة الأولى)
      final String thumbnailFileName = 'thumbnail_$fileId.png';
      final String thumbnailPath = '$drawingsDirPath/$thumbnailFileName';
      print('حفظ الصورة المصغرة في: $thumbnailPath');

      final File thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(imageData);

      // التحقق من نجاح حفظ الصورة المصغرة
      if (!await thumbnailFile.exists()) {
        throw Exception('فشل في حفظ الصورة المصغرة');
      }

      // تحويل الصفحات إلى تنسيق يمكن تخزينه
      List<Map<String, dynamic>> pagesData = [];
      for (var page in pages) {
        pagesData.add({
          'id': page.id,
          'pageNumber': page.pageNumber,
          'lines': page.lines.map((line) => line.toJson()).toList(),
          'stickers': page.stickers.map((sticker) => sticker.toJson()).toList(),
        });
      }

      // تجهيز بيانات الملف للحفظ
      final now = DateTime.now();
      final Map<String, dynamic> drawingData = {
        'id': fileId,
        'name': fileName,
        'creationDate': creationDate.toIso8601String(),
        'lastModified': now.toIso8601String(),
        'thumbnailPath': thumbnailPath,
        'pages': pagesData,
      };

      // حفظ بيانات الملف
      final String jsonFilePath = '$drawingsDirPath/$fileId.json';
      print('حفظ بيانات الملف في: $jsonFilePath');

      final File jsonFile = File(jsonFilePath);
      final String jsonData = jsonEncode(drawingData);
      await jsonFile.writeAsString(jsonData);

      // التحقق من نجاح حفظ ملف البيانات
      if (!await jsonFile.exists()) {
        throw Exception('فشل في حفظ بيانات الملف');
      }

      // تحديث قائمة الملفات المحفوظة
      await loadSavedFiles();

      setLoading(false);
      return true;
    } catch (e) {
      print('خطأ في حفظ الرسم: $e');
      setErrorMessage('حدث خطأ أثناء حفظ الرسم: $e');
      setLoading(false);
      return false;
    }
  }

  // فتح ملف محفوظ - محدثة لدعم الصفحات المتعددة
  Future<Map<String, dynamic>?> openFile(DrawingFile file) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      print('جاري فتح الملف: ${file.name} (${file.filePath})');

      // التأكد من وجود الملف
      final fileObj = File(file.filePath);
      if (!await fileObj.exists()) {
        print('ملف البيانات غير موجود: ${file.filePath}');
        setLoading(false);
        setErrorMessage('الملف غير موجود');
        return null;
      }

      // قراءة محتوى الملف
      final String jsonString = await fileObj.readAsString();
      final Map<String, dynamic> drawingData =
          jsonDecode(jsonString) as Map<String, dynamic>;

      print('تم قراءة بيانات الملف بنجاح، التحقق من التنسيق...');

      // التحقق من تنسيق الملف (متعدد الصفحات أم لا)
      if (drawingData.containsKey('pages')) {
        print('الملف بتنسيق متعدد الصفحات');
        // ملف متعدد الصفحات
        List<WhiteboardPage> pages = [];
        final pagesData = drawingData['pages'] as List;

        for (var pageData in pagesData) {
          // استخراج خطوط الصفحة
          List<DrawnLine> pageLines = (pageData['lines'] as List)
              .map((lineData) =>
                  DrawnLine.fromJson(lineData as Map<String, dynamic>))
              .toList();

          // استخراج ملصقات الصفحة
          List<Sticker> pageStickers = (pageData['stickers'] as List)
              .map((stickerData) =>
                  Sticker.fromJson(stickerData as Map<String, dynamic>))
              .toList();

          // إنشاء كائن الصفحة
          pages.add(WhiteboardPage(
            id: pageData['id'],
            pageNumber: pageData['pageNumber'],
            lines: pageLines,
            stickers: pageStickers,
          ));
        }

        print('تم تحميل ${pages.length} صفحة من الملف');
        setLoading(false);
        return {
          'fileInfo': file,
          'pages': pages,
        };
      } else {
        print('الملف بتنسيق قديم (صفحة واحدة)');
        // ملف قديم (صفحة واحدة) - للتوافق مع الإصدارات السابقة
        List<dynamic> linesData = drawingData['lines'] ?? [];
        List<dynamic> stickersData = drawingData['stickers'] ?? [];

        // تحويل البيانات إلى كائنات
        List<DrawnLine> lines = linesData
            .map((lineData) =>
                DrawnLine.fromJson(lineData as Map<String, dynamic>))
            .toList();

        List<Sticker> stickers = stickersData
            .map((stickerData) =>
                Sticker.fromJson(stickerData as Map<String, dynamic>))
            .toList();

        print(
            'تم تحميل ${lines.length} خط و ${stickers.length} ملصق من الملف القديم');
        setLoading(false);
        return {
          'fileInfo': file,
          'lines': lines,
          'stickers': stickers,
        };
      }
    } catch (e) {
      print('خطأ في فتح الملف: $e');
      setErrorMessage('حدث خطأ أثناء فتح الملف: $e');
      setLoading(false);
      return null;
    }
  }

  // حذف ملف
  Future<bool> deleteFile(DrawingFile file) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      print('جاري حذف الملف: ${file.name}');

      // حذف ملف الصورة المصغرة
      if (file.thumbnailPath != null) {
        print('حذف الصورة المصغرة: ${file.thumbnailPath}');
        final thumbnailFile = File(file.thumbnailPath!);
        if (await thumbnailFile.exists()) {
          await thumbnailFile.delete();
        }
      }

      // حذف ملف البيانات
      print('حذف ملف البيانات: ${file.filePath}');
      final dataFile = File(file.filePath);
      if (await dataFile.exists()) {
        await dataFile.delete();
      }

      // تحديث القائمة
      await loadSavedFiles();

      setLoading(false);
      return true;
    } catch (e) {
      print('خطأ في حذف الملف: $e');
      setErrorMessage('حدث خطأ أثناء حذف الملف: $e');
      setLoading(false);
      return false;
    }
  }

  // مشاركة ملف
  Future<bool> shareDrawing(DrawingFile file) async {
    if (file.thumbnailPath == null) {
      setErrorMessage('مسار الصورة المصغرة غير متوفر');
      return false;
    }

    try {
      print('مشاركة الملف: ${file.name}');
      final thumbnailFile = File(file.thumbnailPath!);
      if (!await thumbnailFile.exists()) {
        setErrorMessage('الصورة المصغرة غير موجودة');
        return false;
      }

      await Share.shareXFiles(
        [XFile(file.thumbnailPath!)],
        text: 'رسمتي من تطبيق السبورة التفاعلية: ${file.name}',
      );
      return true;
    } catch (e) {
      print('خطأ في مشاركة الملف: $e');
      setErrorMessage('حدث خطأ أثناء مشاركة الملف: $e');
      return false;
    }
  }

  // مشاركة رسم بيانات صورة
  Future<bool> shareDrawingImage(Uint8List imageData, String fileName) async {
    try {
      setLoading(true);
      setErrorMessage(null);

      print('جاري مشاركة الرسم: $fileName');

      // حفظ الملف مؤقتاً
      final Directory tempDir = await getTemporaryDirectory();
      final String tempFileName = '${fileName.replaceAll(' ', '_')}.png';
      final String tempFilePath = '${tempDir.path}/$tempFileName';

      print('إنشاء ملف مؤقت للمشاركة: $tempFilePath');
      final File tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(imageData);

      // مشاركة الملف
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'رسمتي من تطبيق السبورة التفاعلية: $fileName',
      );

      setLoading(false);
      return true;
    } catch (e) {
      print('خطأ في مشاركة الرسم: $e');
      setErrorMessage('حدث خطأ أثناء مشاركة الرسم: $e');
      setLoading(false);
      return false;
    }
  }
}
