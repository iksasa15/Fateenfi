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

  // متغير للتحكم في الحركة الانتقالية
  bool _isAnimating = false;

  /// تغيير المؤشر النشط
  void changeIndex(int index) {
    // تجنب معالجة النقرات أثناء الحركة الانتقالية
    if (_isAnimating) return;

    // إذا تم النقر على نفس التبويب النشط
    if (index == _selectedIndex) {
      // إذا كان التبويب الرئيسي، قم بتحديثه
      if (index == 0) {
        _refreshHomePage();
      }
    } else {
      _isAnimating = true;

      // تأخير قصير لإعطاء وقت للرسوم المتحركة
      Future.delayed(const Duration(milliseconds: 200), () {
        _selectedIndex = index;

        // إذا كان التبويب الرئيسي، قم بتحديثه
        if (index == 0) {
          _refreshHomePage();
        }

        notifyListeners();

        // إنهاء الحركة الانتقالية
        _isAnimating = false;
      });
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
    // فقط إذا لم نكن بالفعل في الصفحة الرئيسية
    if (_selectedIndex != 0) {
      _selectedIndex = 0;
      _refreshHomePage();
      notifyListeners();
    } else {
      // إذا كنا بالفعل في الرئيسية، فقط نقوم بالتحديث
      _refreshHomePage();
    }
  }

  /// العودة إلى الصفحة السابقة إذا لم نكن في الرئيسية
  bool handleBackPress() {
    if (_selectedIndex != 0) {
      resetToHome();
      return true; // تمت معالجة زر الرجوع
    }
    return false; // لم تتم معالجة زر الرجوع (اترك النظام يتعامل معه)
  }
}
