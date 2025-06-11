import 'package:flutter/material.dart';
import '../services/firebaseServices/performance_indicators_service.dart';
import '../constants/performance_indicators_constants.dart';

class PerformanceIndicator {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String description;

  PerformanceIndicator({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class PerformanceIndicatorsController extends ChangeNotifier {
  final PerformanceIndicatorsService _service = PerformanceIndicatorsService();
  bool _isLoading = true;
  String? _errorMessage;
  List<PerformanceIndicator> _indicators = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PerformanceIndicator> get indicators => _indicators;

  // تهيئة البيانات
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // جلب البيانات من Firebase
      final data = await _service.getPerformanceData();

      // معالجة البيانات
      _processData(data);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
      _indicators =
          _getDefaultIndicators(); // استخدام البيانات الافتراضية في حالة الخطأ
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // معالجة البيانات القادمة من Firebase
  void _processData(Map<String, dynamic> data) {
    if (data.isEmpty) {
      _indicators = _getDefaultIndicators();
      return;
    }

    final List<PerformanceIndicator> indicators = [];

    // الحضور
    if (data.containsKey('attendance')) {
      indicators.add(
        PerformanceIndicator(
          title: PerformanceIndicatorsConstants.attendanceTitle,
          value: '${data['attendance']}%',
          icon: Icons.people,
          color: _getColorForValue(data['attendance']),
          description: _getDescriptionForValue(data['attendance']),
        ),
      );
    }

    // إنجاز المهام
    if (data.containsKey('tasksCompletion')) {
      indicators.add(
        PerformanceIndicator(
          title: PerformanceIndicatorsConstants.tasksCompletionTitle,
          value: '${data['tasksCompletion']}%',
          icon: Icons.assignment_turned_in,
          color: _getColorForValue(data['tasksCompletion']),
          description: _getDescriptionForValue(data['tasksCompletion']),
        ),
      );
    }

    // معدل الدرجات
    if (data.containsKey('gradesAverage')) {
      indicators.add(
        PerformanceIndicator(
          title: PerformanceIndicatorsConstants.gradesAverageTitle,
          value: '${data['gradesAverage']}%',
          icon: Icons.grade,
          color: _getColorForValue(data['gradesAverage']),
          description: _getDescriptionForValue(data['gradesAverage']),
        ),
      );
    }

    // الأنشطة
    if (data.containsKey('activities')) {
      indicators.add(
        PerformanceIndicator(
          title: PerformanceIndicatorsConstants.activitiesTitle,
          value: '${data['activities']}%',
          icon: Icons.stars,
          color: _getColorForValue(data['activities']),
          description: _getDescriptionForValue(data['activities']),
        ),
      );
    }

    _indicators = indicators;

    // إذا لم تكن هناك مؤشرات، استخدم البيانات الافتراضية
    if (_indicators.isEmpty) {
      _indicators = _getDefaultIndicators();
    }
  }

  // الحصول على الوصف المناسب بناءً على القيمة
  String _getDescriptionForValue(int value) {
    if (value >= 90) {
      return PerformanceIndicatorsConstants.excellentDescription;
    } else if (value >= 80) {
      return PerformanceIndicatorsConstants.veryGoodDescription;
    } else if (value >= 70) {
      return PerformanceIndicatorsConstants.needsImprovementDescription;
    } else {
      return PerformanceIndicatorsConstants.poorDescription;
    }
  }

  // الحصول على اللون المناسب بناءً على القيمة
  Color _getColorForValue(int value) {
    if (value >= 90) {
      return PerformanceIndicatorsConstants.greenColor;
    } else if (value >= 80) {
      return PerformanceIndicatorsConstants.purpleColor;
    } else if (value >= 70) {
      return PerformanceIndicatorsConstants.orangeColor;
    } else {
      return PerformanceIndicatorsConstants.redColor;
    }
  }

  // مؤشرات أداء افتراضية للعرض في حالة عدم وجود بيانات أو حدوث خطأ
  List<PerformanceIndicator> _getDefaultIndicators() {
    return [
      PerformanceIndicator(
        title: PerformanceIndicatorsConstants.attendanceTitle,
        value: '92%',
        icon: Icons.people,
        color: PerformanceIndicatorsConstants.greenColor,
        description: PerformanceIndicatorsConstants.excellentDescription,
      ),
      PerformanceIndicator(
        title: PerformanceIndicatorsConstants.tasksCompletionTitle,
        value: '85%',
        icon: Icons.assignment_turned_in,
        color: PerformanceIndicatorsConstants.purpleColor,
        description: PerformanceIndicatorsConstants.veryGoodDescription,
      ),
      PerformanceIndicator(
        title: PerformanceIndicatorsConstants.gradesAverageTitle,
        value: '78%',
        icon: Icons.grade,
        color: PerformanceIndicatorsConstants.orangeColor,
        description: PerformanceIndicatorsConstants.needsImprovementDescription,
      ),
      PerformanceIndicator(
        title: PerformanceIndicatorsConstants.activitiesTitle,
        value: '60%',
        icon: Icons.stars,
        color: PerformanceIndicatorsConstants.redColor,
        description: PerformanceIndicatorsConstants.poorDescription,
      ),
    ];
  }

  // تحديث البيانات
  Future<void> refresh() async {
    await initialize();
  }

  @override
  void dispose() {
    // تنظيف الموارد إذا لزم الأمر
    super.dispose();
  }
}
