import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/course.dart';
import '../../../../models/app_file.dart';

class CourseFilesController extends ChangeNotifier {
  User? currentUser = FirebaseAuth.instance.currentUser;

  // إضافة ملف للمقرر
  Future<bool> addFile(Course course, AppFile file) async {
    try {
      course.uploadAndAddFile(file);
      await course.saveToFirestore(currentUser);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('حدث خطأ أثناء إضافة الملف: $e');
      return false;
    }
  }

  // حذف ملف من المقرر
  Future<bool> deleteFile(Course course, AppFile file) async {
    try {
      course.deleteFile(file);
      await course.saveToFirestore(currentUser);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('حدث خطأ أثناء حذف الملف: $e');
      return false;
    }
  }

  // تحديث مسار ملف
  Future<bool> updateFilePath(
      Course course, AppFile file, String newPath) async {
    try {
      final index = course.files.indexWhere((f) => f.id == file.id);
      if (index != -1) {
        file.filePath = newPath;
        course.files[index] = file;
        await course.saveToFirestore(currentUser);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('حدث خطأ أثناء تحديث مسار الملف: $e');
      return false;
    }
  }

  // اختيار ملف من الجهاز
  Future<FilePickerResult?> pickFile() async {
    return await FilePicker.platform.pickFiles();
  }
}
