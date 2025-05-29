// ai_flashcards_strings.dart
class AiFlashcardsStrings {
  // العناوين الرئيسية
  static const String pageTitle = 'إنشاء بطاقات تعليمية';
  static const String instructionsText =
      'أدخل نصًا أو اختر ملفًا لتوليد بطاقات تعليمية';

  // عناوين الأقسام
  static const String sourceTextTitle = 'النص المصدر';
  static const String selectFileText = 'اختيار ملف';
  static const String frontSideText = 'الوجه الأمامي';
  static const String backSideText = 'الوجه الخلفي';

  // أزرار ولافتات
  static const String generateButtonText = 'توليد البطاقات';
  static const String showAnswerText = 'عرض الإجابة';
  static const String hideAnswerText = 'إخفاء الإجابة';
  static const String nextFlashcardText = 'البطاقة التالية';
  static const String previousFlashcardText = 'البطاقة السابقة';
  static const String knownText = 'أعرفها';
  static const String unknownText = 'لا أعرفها';
  static const String reviewFlashcardsText = 'مراجعة البطاقات';

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
  static const String invalidFlashcardsCountError = 'عدد البطاقات غير صالح!';
  static const String generatingFlashcardsText =
      'جاري توليد البطاقات التعليمية...';
  static const String generatingFlashcardCountText =
      'جاري إنشاء البطاقة %d من %d...';
  static const String waitMomentText = 'قد يستغرق الأمر بضع ثوانٍ';
  static const String generationSuccessText =
      'تم إنشاء %d بطاقات تعليمية بنجاح';
  static const String completeText = 'أنهيت المراجعة';
  static const String studyText = 'لقد راجعت %d من أصل %d بطاقات';

  // رسائل تحفيزية
  static const String greatJobMessage = 'عمل رائع! استمر في المراجعة.';
  static const String keepGoingMessage = 'واصل التقدم! أنت تفعل ذلك بشكل جيد.';
  static const String almostDoneMessage = 'أنت تقترب من النهاية، استمر!';

  // أخطاء
  static const String connectionError =
      'خطأ أثناء الاتصال بخدمة توليد البطاقات التعليمية!';
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
