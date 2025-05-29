import 'package:flutter/material.dart';
import '../../../../models/language_model.dart'; // تصحيح مسار الاستيراد

class LanguageController extends ChangeNotifier {
  // القيم الافتراضية للغتين
  LanguageModel _selectedSourceLanguage =
      LanguageModel(name: 'الإنجليزية', code: 'EN');
  LanguageModel _selectedTargetLanguage =
      LanguageModel(name: 'العربية', code: 'AR');

  // الحصول على اللغات المحددة
  LanguageModel get selectedSourceLanguage => _selectedSourceLanguage;
  LanguageModel get selectedTargetLanguage => _selectedTargetLanguage;

  // قائمة اللغات المتاحة
  List<LanguageModel> get availableLanguages =>
      LanguageModel.getSupportedLanguages();

  // تعيين لغة المصدر
  void setSourceLanguage(LanguageModel language) {
    if (_selectedSourceLanguage.code != language.code) {
      _selectedSourceLanguage = language;
      notifyListeners();
    }
  }

  // تعيين لغة الهدف
  void setTargetLanguage(LanguageModel language) {
    if (_selectedTargetLanguage.code != language.code) {
      _selectedTargetLanguage = language;
      notifyListeners();
    }
  }

  // تبديل اللغات
  void swapLanguages() {
    final temp = _selectedSourceLanguage;
    _selectedSourceLanguage = _selectedTargetLanguage;
    _selectedTargetLanguage = temp;
    notifyListeners();
  }

  // البحث عن لغة بالرمز
  LanguageModel findLanguageByCode(String code) {
    return availableLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => code == 'EN'
          ? LanguageModel(name: 'الإنجليزية', code: 'EN')
          : LanguageModel(name: 'العربية', code: 'AR'),
    );
  }
}
