import 'package:flutter/material.dart';
import '../../../../models/service_item.dart';

class ServicesController with ChangeNotifier {
  // متغير لتخزين البطاقة التي يتم الضغط عليها حالياً
  String? _currentPressedCard;
  String? get currentPressedCard => _currentPressedCard;

  // animation controller
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  // تهيئة المتحكم بالتحكم في التأثير
  void initAnimation(TickerProvider vsync) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  // الحصول على تأثير التصغير
  Animation<double>? get scaleAnimation => _scaleAnimation;

  // بدء تأثير الضغط
  void onCardPressed(String title) {
    _currentPressedCard = title;
    _animationController?.forward();
    notifyListeners();
  }

  // إيقاف تأثير الضغط
  void onCardReleased() {
    _currentPressedCard = null;
    _animationController?.reverse();
    notifyListeners();
  }

  // التنظيف عند الانتهاء
  void dispose() {
    _animationController?.dispose();
  }
}
