import 'package:flutter/material.dart';
import '../../../models/course.dart';
import '../../../models/app_file.dart';

/// وحدة التحكم ببطاقة المقرر الدراسي
/// مسؤولة عن إدارة حالة بطاقة المقرر وتوفير وظائف معالجة البيانات
class CourseCardController extends ChangeNotifier {
  // ============ متغيرات الحالة ============

  /// المقرر الدراسي المرتبط بوحدة التحكم
  final Course _course;

  /// حالة توسيع البطاقة لعرض المزيد من التفاصيل
  bool _isExpanded = false;

  /// الدرجة القصوى للمقرر (افتراضياً 100)
  final double _maxGrade;

  // ============ الواجهة العامة (Getters) ============

  /// المقرر الدراسي
  Course get course => _course;

  /// حالة توسيع البطاقة
  bool get isExpanded => _isExpanded;

  /// متوسط درجات المقرر (كنسبة مئوية)
  double get courseAverage => _calculateCourseAverage();

  /// متوسط درجات المقرر (كدرجة فعلية)
  double get courseActualAverage => _calculateActualAverage();

  /// توجد درجات في المقرر
  bool get hasGrades => _course.grades.isNotEmpty;

  /// توجد تذكيرات في المقرر
  bool get hasReminders => _course.reminders.isNotEmpty;

  /// توجد ملفات في المقرر
  bool get hasFiles => _course.files.isNotEmpty;

  /// توجد محتويات إضافية للعرض
  bool get hasExpandableContent => hasGrades || hasReminders || hasFiles;

  /// أيام المحاضرات كنص
  String get daysString => _course.days.join(' · ');

  // ============ المُنشئ ============

  /// منشئ وحدة التحكم ببطاقة المقرر
  CourseCardController({
    required Course course,
    double maxGrade = 100,
  })  : _course = course,
        _maxGrade = maxGrade;

  // ============ وظائف تغيير الحالة ============

  /// تبديل حالة توسيع البطاقة
  void toggleExpansion() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  /// توسيع البطاقة
  void expand() {
    if (!_isExpanded) {
      _isExpanded = true;
      notifyListeners();
    }
  }

  /// طي البطاقة
  void collapse() {
    if (_isExpanded) {
      _isExpanded = false;
      notifyListeners();
    }
  }

  // ============ وظائف معالجة البيانات ============

  /// حساب متوسط درجات المقرر (كنسبة مئوية)
  double _calculateCourseAverage() {
    if (_course.grades.isEmpty) {
      return 0.0;
    }

    double totalGrades = 0.0;
    for (var grade in _course.grades.values) {
      totalGrades += grade;
    }
    return totalGrades / _course.grades.length;
  }

  /// حساب متوسط درجات المقرر (كدرجة فعلية)
  double _calculateActualAverage() {
    if (_course.grades.isEmpty) {
      return 0.0;
    }

    double totalGrades = 0.0;
    for (var grade in _course.grades.values) {
      // تحويل النسبة المئوية إلى درجة فعلية
      totalGrades += (grade / 100) * _maxGrade;
    }
    return totalGrades / _course.grades.length;
  }

  /// تحويل نسبة مئوية إلى درجة فعلية
  double percentageToActualGrade(double percentage) {
    return (percentage / 100) * _maxGrade;
  }
}
