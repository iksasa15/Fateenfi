import 'package:flutter/foundation.dart';

class LanguageModel {
  final String name;
  final String code;

  LanguageModel({
    required this.name,
    required this.code,
  });

  static List<LanguageModel> getSupportedLanguages() {
    return [
      LanguageModel(name: 'العربية', code: 'AR'),
      LanguageModel(name: 'الإنجليزية', code: 'EN'),
      LanguageModel(name: 'الفرنسية', code: 'FR'),
      LanguageModel(name: 'الإسبانية', code: 'ES'),
      LanguageModel(name: 'الألمانية', code: 'DE'),
      LanguageModel(name: 'الإيطالية', code: 'IT'),
      LanguageModel(name: 'البرتغالية', code: 'PT'),
      LanguageModel(name: 'الروسية', code: 'RU'),
      LanguageModel(name: 'الصينية', code: 'ZH'),
      LanguageModel(name: 'اليابانية', code: 'JA'),
      LanguageModel(name: 'الكورية', code: 'KO'),
      LanguageModel(name: 'الهندية', code: 'HI'),
    ];
  }

  // إضافة مقارنة المساواة
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageModel && other.code == code && other.name == name;
  }

  // إضافة hashCode
  @override
  int get hashCode => code.hashCode ^ name.hashCode;

  // الحصول على رمز اللغة في صيغة مطابقة لـ DeepL
  String getDeeplCode() {
    switch (code) {
      case 'AR':
        return 'AR';
      case 'EN':
        return 'EN';
      case 'FR':
        return 'FR';
      case 'ES':
        return 'ES';
      case 'DE':
        return 'DE';
      case 'IT':
        return 'IT';
      case 'PT':
        return 'PT';
      case 'RU':
        return 'RU';
      case 'ZH':
        return 'ZH';
      case 'JA':
        return 'JA';
      case 'KO':
        return 'KO';
      case 'HI':
        return 'HI';
      default:
        return 'EN';
    }
  }

  // الحصول على رمز لغة OCR المناسب
  String getOcrCode() {
    switch (code) {
      case 'AR':
        return 'ara';
      case 'EN':
        return 'eng';
      case 'FR':
        return 'fra';
      case 'ES':
        return 'spa';
      case 'DE':
        return 'deu';
      case 'IT':
        return 'ita';
      case 'PT':
        return 'por';
      case 'RU':
        return 'rus';
      case 'ZH':
        return 'chi_sim';
      case 'JA':
        return 'jpn';
      case 'KO':
        return 'kor';
      case 'HI':
        return 'hin';
      default:
        return 'eng';
    }
  }
}
