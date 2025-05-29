import 'package:flutter/material.dart';
import '../../../../models/translation_mode.dart';

class ModeController extends ChangeNotifier {
  // وضع الترجمة الحالي (نص أو ملف)
  TranslationMode _currentMode = TranslationMode.text;

  // الوصول للحالة
  TranslationMode get currentMode => _currentMode;
  bool get isTextMode => _currentMode == TranslationMode.text;
  bool get isFileMode => _currentMode == TranslationMode.file;

  // إعادة تعريف getter لجعله يعيد دائمًا false للتوافق مع الكود الأخرى
  bool get useDeeplFormatting => false;

  // تعيين وضع الترجمة
  void setMode(TranslationMode mode) {
    _currentMode = mode;
    notifyListeners();
  }
}
