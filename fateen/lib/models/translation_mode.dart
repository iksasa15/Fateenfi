/// تعريف أوضاع الترجمة المتاحة في التطبيق
enum TranslationMode {
  /// وضع ترجمة النصوص المكتوبة
  text,

  /// وضع ترجمة الملفات
  file,
}

/// امتدادات للتعامل مع أوضاع الترجمة
extension TranslationModeExtension on TranslationMode {
  /// الحصول على اسم الوضع
  String get name {
    switch (this) {
      case TranslationMode.text:
        return 'نص';
      case TranslationMode.file:
        return 'ملف';
    }
  }

  /// التحقق إذا كان وضع ترجمة النصوص
  bool get isText => this == TranslationMode.text;

  /// التحقق إذا كان وضع ترجمة الملفات
  bool get isFile => this == TranslationMode.file;
}
