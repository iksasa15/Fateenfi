import 'package:flutter/material.dart';
import '../services/firebaseServices/semester_progress_service.dart';

class SemesterProgressController extends ChangeNotifier {
  int _totalDays = 105; // إجمالي أيام الفصل الدراسي
  int _passedDays = 65; // الأيام التي مرت
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;
  String? _errorMessage;

  // حقن خدمة Firebase
  final SemesterProgressService _service = SemesterProgressService();

  // الحصول على القيم
  int get totalDays => _totalDays;
  int get passedDays => _passedDays;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // حساب نسبة التقدم
  double get progressPercentage => _passedDays / _totalDays;

  // تهيئة البيانات
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // الحصول على البيانات من Firebase
      final data = await _service.getSemesterData();

      _totalDays = data['totalDays'] ?? 105;
      _passedDays = data['passedDays'] ?? 65;

      if (data['startDate'] != null) {
        _startDate = DateTime.parse(data['startDate']);
      }

      if (data['endDate'] != null) {
        _endDate = DateTime.parse(data['endDate']);
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تعيين بيانات التقدم مباشرة (للاختبار أو التعيين المحلي)
  void setSemesterProgress(int totalDays, int passedDays) {
    _totalDays = totalDays;
    _passedDays = passedDays;
    notifyListeners();
  }

  // تحديث البيانات
  Future<void> refresh() async {
    await initialize();
  }

  // تنسيق النسبة المئوية للعرض
  String getFormattedPercentage() {
    return '${(progressPercentage * 100).toInt()}%';
  }

  @override
  void dispose() {
    // تنظيف الموارد إذا لزم الأمر
    super.dispose();
  }
}
