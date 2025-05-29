// ai_summary_strings.dart
class AiSummaryStrings {
  // العناوين الرئيسية
  static const String pageTitle = 'ملخص الفصل';
  static const String instructionsText =
      'اختر ملفًا لتوليد ملخص شامل بأهم النقاط الرئيسية';

  // عناوين الأقسام
  static const String sourceTextTitle = 'النص المصدر';
  static const String selectFileText = 'اختيار ملف';
  static const String mainIdeaTitle = 'الفكرة الرئيسية';
  static const String keyPointsTitle = 'النقاط الرئيسية';
  static const String conclusionTitle = 'الخلاصة';

  // أزرار ولافتات
  static const String generateButtonText = 'توليد الملخص';
  static const String shareText = 'مشاركة';
  static const String saveText = 'حفظ';

  // رسائل
  static const String noInputError = 'لم يتم اختيار ملف نصّي!';
  static const String invalidPointsCountError = 'عدد النقاط غير صالح!';
  static const String generatingSummaryText = 'جاري توليد الملخص...';
  static const String waitMomentText = 'قد يستغرق الأمر بضع ثوانٍ';
  static const String generationSuccessText = 'تم إنشاء الملخص بنجاح';

  // أخطاء
  static const String connectionError = 'خطأ أثناء الاتصال بخدمة توليد الملخص!';
  static const String filePickError = 'حدث خطأ أثناء اختيار الملف: ';
  static const String pdfExtractionError =
      'لم يتم استخراج نص من ملف PDF. قد يكون الملف مصوراً أو لا يحتوي على نص قابل للاستخراج.';
  static const String ocrError =
      'حدث خطأ أثناء محاولة استخراج النص من ملف PDF. يرجى المحاولة مرة أخرى أو استخدام ملف نصي بدلاً من ذلك.';
  static const String fileReadError = 'حدث خطأ أثناء قراءة الملف: ';
  static const String fileTypeError =
      'الملف ليس نصياً أو لا يمكن قراءته. قد تحتاج لمكتبة إضافية لاستخراج النص.';
}
