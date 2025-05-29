class AiQuestionsStrings {
  // العناوين الرئيسية
  static const String pageTitle = 'إنشاء أسئلة';
  static const String instructionsText =
      'اختر ملفًا لتوليد أسئلة اختيار من متعدد';

  // عناوين الأقسام
  static const String sourceTextTitle = 'النص المصدر';
  static const String selectFileText = 'اختيار ملف';

  // أزرار ولافتات
  static const String generateButtonText = 'توليد الأسئلة';
  static const String checkAnswersText = 'تحقق من الإجابات';
  static const String nextQuestionText = 'السؤال التالي';
  static const String previousQuestionText = 'السؤال السابق';
  static const String reviewQuestionsText = 'مراجعة الأسئلة';

  // مربع حوار API
  static const String apiKeyTitle = 'مفتاح OpenAI API';
  static const String apiKeyHint = 'أدخل مفتاح OpenAI API الخاص بك';
  static const String saveText = 'حفظ';
  static const String cancelText = 'إلغاء';
  static const String verifyKeyText = 'تحقق من المفتاح';
  static const String validatingText = 'جاري التحقق...';

  // رسائل
  static const String keySavedSuccess = 'تم حفظ المفتاح بنجاح';
  static const String enterValidKeyError = 'الرجاء إدخال مفتاح صالح';
  static const String apiKeyRequiredError = 'يجب إدخال مفتاح الـ API أولاً!';
  static const String apiKeyValidSuccess = 'المفتاح صالح';
  static const String apiKeyInvalidError =
      'المفتاح غير صالح، تأكد من المفتاح وإعادة المحاولة';
  static const String noInputError = 'لم يتم إدخال نص يدوي أو اختيار ملف نصّي!';
  static const String invalidQuestionsCountError = 'عدد الأسئلة غير صالح!';
  static const String generatingQuestionsText = 'جاري توليد الأسئلة...';
  static const String generatingQuestionCountText =
      'جاري إنشاء السؤال %d من %d...';
  static const String waitMomentText = 'قد يستغرق الأمر بضع ثوانٍ';
  static const String generationSuccessText = 'تم إنشاء %d أسئلة بنجاح';
  static const String resultTitle = 'النتيجة';
  static const String scoreText = 'أجبت على %d من أصل %d بشكل صحيح';

  // رسائل تحفيزية
  static const String perfectScoreMessage =
      'ممتاز! أجبت على جميع الأسئلة بشكل صحيح.';
  static const String goodScoreMessage = 'أداء جيد جدًا. استمر!';
  static const String averageScoreMessage = 'أداء جيد، يمكنك التحسن أكثر.';
  static const String lowScoreMessage = 'لا بأس، حاول مرة أخرى للتحسن.';

  // أخطاء
  static const String connectionError =
      'خطأ أثناء الاتصال بخدمة توليد الأسئلة!';
  static const String filePickError = 'حدث خطأ أثناء اختيار الملف: ';
  static const String pdfExtractionError =
      'لم يتم استخراج نص من ملف PDF. قد يكون الملف مصوراً أو لا يحتوي على نص قابل للاستخراج.';
  static const String ocrError =
      'حدث خطأ أثناء محاولة استخراج النص من ملف PDF. يرجى المحاولة مرة أخرى أو استخدام ملف نصي بدلاً من ذلك.';
  static const String fileReadError = 'حدث خطأ أثناء قراءة الملف: ';
  static const String fileTypeError =
      'الملف ليس نصياً أو لا يمكن قراءته. قد تحتاج لمكتبة إضافية لاستخراج النص.';

  // SharedPreferences المفتاح
  static const String apiKeyPrefsKey = 'openai_api_key';
}
