import 'package:flutter/material.dart';

/// وحدة تحكم شريط التنقل السفلي
class BottomNavController extends ChangeNotifier {
  // المؤشر الحالي
  int _selectedIndex = 0;

  // الحصول على المؤشر الحالي
  int get selectedIndex => _selectedIndex;

  // مؤشرات تحديث صفحات محددة
  int _homePageUpdateCounter = 0;

  // الحصول على مؤشر تحديث الصفحة الرئيسية
  int get homePageUpdateCounter => _homePageUpdateCounter;

  /// تغيير المؤشر النشط
  void changeIndex(int index) {
    // إذا تم النقر على نفس التبويب النشط
    if (index == _selectedIndex) {
      // إذا كان التبويب الرئيسي، قم بتحديثه
      if (index == 0) {
        _refreshHomePage();
      }
    } else {
      _selectedIndex = index;

      // إذا كان التبويب الرئيسي، قم بتحديثه
      if (index == 0) {
        _refreshHomePage();
      }

      notifyListeners();
    }
  }

  /// تحديث الصفحة الرئيسية
  void _refreshHomePage() {
    _homePageUpdateCounter++;
    debugPrint('تحديث الصفحة الرئيسية (${_homePageUpdateCounter})');
    notifyListeners();
  }

  /// إعادة الضبط إلى الصفحة الرئيسية
  void resetToHome() {
    _selectedIndex = 0;
    _refreshHomePage();
    notifyListeners();
  }
}
