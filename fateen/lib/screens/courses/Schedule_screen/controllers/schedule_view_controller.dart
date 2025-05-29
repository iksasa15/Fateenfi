import 'package:flutter/material.dart';

/// وحدة تحكم لإدارة عرض الجدول (يومي/أسبوعي)
class ScheduleViewController extends ChangeNotifier {
  // متغير للتبديل بين العرضين
  bool _showCalendarView = false;

  // جعل المتغير للقراءة فقط من الخارج
  bool get showCalendarView => _showCalendarView;

  /// تبديل طريقة العرض (قائمة/جدول)
  void toggleViewMode() {
    _showCalendarView = !_showCalendarView;
    notifyListeners();
  }

  /// تعيين طريقة العرض مباشرة
  void setViewMode(bool calendarView) {
    if (_showCalendarView != calendarView) {
      _showCalendarView = calendarView;
      notifyListeners();
    }
  }

  /// الحصول على نوع العرض الحالي كنص
  String getCurrentViewModeText() {
    return _showCalendarView ? 'أسبوعي' : 'يومي';
  }
}
