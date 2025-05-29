import 'package:flutter/material.dart';
import '../../../models/course.dart';
import '../../../models/app_file.dart';

/// وحدة التحكم بإحصائيات الملفات الدراسية
/// مسؤولة عن حساب وإدارة إحصائيات الملفات الخاصة بالطالب
class FilesStatisticsController extends ChangeNotifier {
  //
  // ============ متغيرات الحالة ============
  //

  // إحصائيات الملفات - فقط عدد الملفات الإجمالي
  int _totalFiles = 0;

  //
  // ============ الواجهة العامة (Getters) ============
  //

  // معلومات الملفات
  int get totalFiles => _totalFiles;

  //
  // ============ دورة حياة وحدة التحكم ============
  //

  /// المنشئ
  FilesStatisticsController();

  //
  // ============ وظائف تحديث البيانات ============
  //

  /// حساب إحصائيات الملفات لمجموعة من المقررات
  void calculateFilesStatistics(List<Course> courses) {
    _totalFiles = 0;

    // حساب العدد الإجمالي للملفات فقط
    for (var course in courses) {
      _totalFiles += course.files.length;
    }

    notifyListeners();
  }

  /// إعادة تعيين إحصائيات الملفات
  void resetStatistics() {
    _totalFiles = 0;
    notifyListeners();
  }
}
