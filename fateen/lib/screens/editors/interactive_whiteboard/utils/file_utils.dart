import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/drawing_file_model.dart';

class FileUtils {
  /// طلب أذونات التخزين
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        if (Platform.isAndroid) Permission.manageExternalStorage,
        if (Platform.isIOS) Permission.photos,
      ].request();

      return Platform.isIOS
          ? statuses[Permission.photos]?.isGranted == true
          : statuses[Permission.storage]?.isGranted == true;
    }
    return true; // على منصات أخرى غير أندرويد وآيفون
  }

  /// الحصول على مجلد الرسومات، إنشاءه إذا لم يكن موجوداً
  static Future<Directory> getDrawingsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final drawingsDir = Directory('${appDir.path}/drawings');

    if (!await drawingsDir.exists()) {
      await drawingsDir.create(recursive: true);
    }

    // إضافة معلومات تصحيح للتعرف على المسار على مختلف المنصات
    print('نظام التشغيل: ${Platform.operatingSystem}');
    print('مسار مجلد الرسومات: ${drawingsDir.path}');
    return drawingsDir;
  }

  /// حفظ بيانات JSON إلى ملف
  static Future<void> saveJsonToFile(
      String filePath, Map<String, dynamic> data) async {
    try {
      final file = File(filePath);
      await file.writeAsString(jsonEncode(data));
      // إضافة معلومات تصحيح
      print('تم حفظ الملف JSON في: $filePath');
    } catch (e) {
      print('خطأ في حفظ البيانات: $e');
      throw Exception('فشل في حفظ ملف JSON: $e');
    }
  }

  /// قراءة بيانات JSON من ملف
  static Future<Map<String, dynamic>> readJsonFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('الملف غير موجود: $filePath');
        throw Exception('الملف غير موجود: $filePath');
      }
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      print('خطأ في قراءة الملف: $e');
      throw Exception('فشل في قراءة ملف JSON: $e');
    }
  }

  /// حفظ صورة إلى ملف
  static Future<String> saveImageToFile(
      Uint8List imageData, String directory, String fileName) async {
    try {
      final file = File('$directory/$fileName');
      await file.writeAsBytes(imageData);
      print('تم حفظ الصورة في: ${file.path}');
      return file.path;
    } catch (e) {
      print('خطأ في حفظ الصورة: $e');
      throw Exception('فشل في حفظ الصورة: $e');
    }
  }

  /// إنشاء مسار مؤقت لمشاركة الملفات
  static Future<String> createTempFileForSharing(
      Uint8List imageData, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile =
          File('${tempDir.path}/${fileName.replaceAll(' ', '_')}.png');
      await tempFile.writeAsBytes(imageData);
      return tempFile.path;
    } catch (e) {
      print('خطأ في إنشاء ملف مؤقت: $e');
      throw Exception('فشل في إنشاء ملف مؤقت للمشاركة: $e');
    }
  }

  /// إنشاء معرف فريد
  static String generateUniqueId() {
    return const Uuid().v4();
  }

  /// حذف ملف
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('تم حذف الملف: $filePath');
        return true;
      }
      print('الملف غير موجود للحذف: $filePath');
      return false;
    } catch (e) {
      print('خطأ في حذف الملف: $e');
      return false;
    }
  }

  /// التحقق من وجود ملف
  static Future<bool> fileExists(String filePath) async {
    try {
      return File(filePath).exists();
    } catch (e) {
      print('خطأ في التحقق من وجود الملف: $e');
      return false;
    }
  }

  /// تحميل قائمة الملفات المحفوظة
  static Future<List<DrawingFile>> loadSavedDrawingFiles() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String drawingsDirPath = '${appDir.path}/drawings';
      final Directory drawingsDir = Directory(drawingsDirPath);

      print('جاري فحص مجلد الرسومات: $drawingsDirPath');

      // إنشاء المجلد إذا لم يكن موجودا
      if (!await drawingsDir.exists()) {
        print('مجلد الرسومات غير موجود، جاري إنشاؤه...');
        await drawingsDir.create(recursive: true);
        return []; // المجلد جديد، لا توجد ملفات بعد
      }

      // قراءة قائمة الملفات
      print('جاري قراءة محتويات مجلد الرسومات...');
      List<FileSystemEntity> files = await drawingsDir.list().toList();
      print('تم العثور على ${files.length} ملف في المجلد');

      List<DrawingFile> drawingFiles = [];

      for (var file in files) {
        if (file.path.endsWith('.json')) {
          try {
            print('جاري معالجة الملف: ${file.path}');
            final jsonFile = File(file.path);
            final String content = await jsonFile.readAsString();
            final Map<String, dynamic> drawingData =
                jsonDecode(content) as Map<String, dynamic>;

            // التحقق من وجود جميع البيانات المطلوبة
            if (drawingData.containsKey('id') &&
                drawingData.containsKey('name') &&
                drawingData.containsKey('creationDate')) {
              // بناء كائن معلومات الملف
              DrawingFile drawingFile = DrawingFile(
                id: drawingData['id'],
                name: drawingData['name'],
                creationDate: DateTime.parse(drawingData['creationDate']),
                lastModified: DateTime.parse(
                    drawingData['lastModified'] ?? drawingData['creationDate']),
                thumbnailPath: drawingData['thumbnailPath'],
                filePath: file.path,
              );

              // التحقق من وجود الصورة المصغرة
              if (drawingFile.thumbnailPath != null) {
                print(
                    'التحقق من وجود الصورة المصغرة: ${drawingFile.thumbnailPath}');
                final thumbnailFile = File(drawingFile.thumbnailPath!);
                if (!await thumbnailFile.exists()) {
                  print(
                      'الصورة المصغرة غير موجودة: ${drawingFile.thumbnailPath}');
                  continue; // تخطي هذا الملف إذا كانت الصورة المصغرة مفقودة
                }
              }

              print('تمت إضافة الملف بنجاح: ${drawingFile.name}');
              drawingFiles.add(drawingFile);
            } else {
              print('الملف يفتقد إلى البيانات المطلوبة: ${file.path}');
            }
          } catch (e) {
            print('خطأ في قراءة ملف: ${file.path}: $e');
            // تخطي الملفات التالفة
          }
        }
      }

      // ترتيب الملفات حسب آخر تعديل
      drawingFiles.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      print('تم تحميل ${drawingFiles.length} ملف رسم بنجاح');

      return drawingFiles;
    } catch (e) {
      print('خطأ في تحميل الملفات: $e');
      return [];
    }
  }
}
