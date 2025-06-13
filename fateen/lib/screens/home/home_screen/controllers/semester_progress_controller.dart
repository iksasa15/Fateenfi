import 'package:flutter/material.dart';
import '../services/firebaseServices/semester_progress_service.dart';
import '../constants/semester_progress_constants.dart';

class SemesterProgressController extends ChangeNotifier {
  int _totalDays = 105; // إجمالي أيام الفصل الدراسي
  int _passedDays = 65; // الأيام التي مرت
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;
  String? _successMessage;

  // حقن خدمة Firebase
  final SemesterProgressService _service = SemesterProgressService();

  // الحصول على القيم
  int get totalDays => _totalDays;
  int get passedDays => _passedDays;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // حساب نسبة التقدم
  double get progressPercentage =>
      _totalDays > 0 ? _passedDays / _totalDays : 0;

  // حساب عدد الأيام المتبقية حتى نهاية الفصل
  int get daysRemaining => _totalDays - _passedDays;

  // تهيئة البيانات
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
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

  // تنسيق التاريخ باللغة العربية
  String formatDateInArabic(DateTime? date) {
    if (date == null) {
      return '';
    }

    // أسماء الأشهر باللغة العربية
    final List<String> arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    // تحويل الأرقام إلى الأرقام العربية
    String toArabicNumber(int number) {
      const List<String> arabicNumbers = [
        '٠',
        '١',
        '٢',
        '٣',
        '٤',
        '٥',
        '٦',
        '٧',
        '٨',
        '٩'
      ];
      return number
          .toString()
          .split('')
          .map((digit) => arabicNumbers[int.parse(digit)])
          .join();
    }

    // تنسيق التاريخ: اليوم الشهر
    return '${toArabicNumber(date.day)} ${arabicMonths[date.month - 1]}';
  }

  // الحصول على تاريخ نهاية الفصل منسق
  String getFormattedEndDate() {
    if (_endDate != null) {
      return formatDateInArabic(_endDate);
    }
    return SemesterProgressConstants
        .semesterEndDate; // استخدام القيمة الثابتة كقيمة افتراضية
  }

  // الحصول على تاريخ بداية الفصل منسق
  String getFormattedStartDate() {
    if (_startDate != null) {
      return formatDateInArabic(_startDate);
    }
    return SemesterProgressConstants
        .semesterStartDate; // استخدام القيمة الثابتة كقيمة افتراضية
  }

  // الحصول على عدد الأيام المتبقية كنص منسق
  String getFormattedDaysRemaining() {
    final days = daysRemaining;
    if (days <= 0) {
      return 'انتهى الفصل الدراسي';
    } else if (days == 1) {
      return 'يوم واحد متبقي';
    } else if (days == 2) {
      return 'يومان متبقيان';
    } else if (days >= 3 && days <= 10) {
      return '$days أيام متبقية';
    } else {
      return '$days يوم متبقي';
    }
  }

  // تحديث تاريخ بداية الفصل الدراسي
  Future<bool> updateStartDate(DateTime newStartDate) async {
    try {
      _isUpdating = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      // تحديث التاريخ في قاعدة البيانات أو محلياً
      final success = await _service.updateSemesterStartDate(newStartDate);

      if (success) {
        // تحديث البيانات المحلية
        _startDate = newStartDate;

        // إعادة تحميل البيانات للحصول على القيم المحدثة لعدد الأيام الإجمالي والمنقضي
        await initialize();

        // عرض رسالة النجاح البسيطة
        _successMessage = SemesterProgressConstants.dateUpdatedMessage;
        notifyListeners();

        // مسح رسالة النجاح بعد ثوانٍ
        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });

        return true;
      } else {
        _errorMessage = SemesterProgressConstants.dateUpdateErrorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // في حالة أي خطأ، نحاول التحديث محلياً على الأقل
      try {
        // تحديث البيانات المحلية على الرغم من الخطأ
        _startDate = newStartDate;
        await initialize(); // إعادة تحميل البيانات من التخزين المحلي

        // عرض رسالة النجاح البسيطة
        _successMessage = SemesterProgressConstants.dateUpdatedMessage;
        notifyListeners();

        // مسح رسالة النجاح بعد ثوانٍ
        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });

        return true;
      } catch (innerError) {
        _errorMessage = SemesterProgressConstants.dateUpdateErrorMessage;
        notifyListeners();
        return false;
      }
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // تحديث تاريخ نهاية الفصل الدراسي
  Future<bool> updateEndDate(DateTime newEndDate) async {
    try {
      _isUpdating = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      // تحديث التاريخ في قاعدة البيانات أو محلياً
      final success = await _service.updateSemesterEndDate(newEndDate);

      if (success) {
        // تحديث البيانات المحلية
        _endDate = newEndDate;

        // إعادة تحميل البيانات للحصول على القيم المحدثة لعدد الأيام الإجمالي والمنقضي
        await initialize();

        // عرض رسالة النجاح البسيطة
        _successMessage = SemesterProgressConstants.dateUpdatedMessage;
        notifyListeners();

        // مسح رسالة النجاح بعد ثوانٍ
        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });

        return true;
      } else {
        _errorMessage = SemesterProgressConstants.dateUpdateErrorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // في حالة أي خطأ، نحاول التحديث محلياً على الأقل
      try {
        // تحديث البيانات المحلية على الرغم من الخطأ
        _endDate = newEndDate;
        await initialize(); // إعادة تحميل البيانات من التخزين المحلي

        // عرض رسالة النجاح البسيطة
        _successMessage = SemesterProgressConstants.dateUpdatedMessage;
        notifyListeners();

        // مسح رسالة النجاح بعد ثوانٍ
        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });

        return true;
      } catch (innerError) {
        _errorMessage = SemesterProgressConstants.dateUpdateErrorMessage;
        notifyListeners();
        return false;
      }
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // مسح رسائل الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // تنظيف الموارد إذا لزم الأمر
    super.dispose();
  }
}
