class AppStrings {
  // العناوين الرئيسية
  static const String appTitle = 'التعرف علي الصور  ';
  static const String textExtractorTitle = 'استخراج وتحليل النص من الصور';
  static const String chatTitle = 'المحادثة مع البوت';
  static const String liveCameraTitle = 'الكاميرا المباشرة';
  static const String settingsTitle = 'الإعدادات';

  // رسائل المستخدم
  static const String welcomeMessage = 'مرحباً بك! كيف يمكنني مساعدتك اليوم؟';
  static const String noImageSelected = 'لم يتم اختيار صورة بعد';
  static const String emptyChat = 'ابدأ المحادثة مع البوت!';
  static const String analysisInProgress = 'جاري التحليل...';
  static const String audioPlaying = 'جاري تشغيل الصوت...';
  static const String connectionSuccess = 'تم الاتصال بالخادم بنجاح';
  static const String connectionError = 'فشل الاتصال بالخادم';

  // الأزرار
  static const String selectImageText = 'اختيار صورة';
  static const String captureImageText = 'التقاط صورة';
  static const String extractTextText = 'استخراج النص';
  static const String analyzeImageText = 'شرح الصورة';
  static const String analyzeTextText = 'تحليل النص';
  static const String copyText = 'نسخ النص';
  static const String saveSettings = 'حفظ الإعدادات';
  static const String testConnection = 'اختبار الاتصال';
  static const String startContinuous = 'بدء التحليل المستمر';
  static const String stopContinuous = 'إيقاف التحليل المستمر';

  // الإعدادات
  static const String serverSettings = 'إعدادات الخادم';
  static const String ipAddress = 'عنوان IP';
  static const String port = 'البورت';




  // أخطاء
  static const String noImageError = 'يرجى اختيار صورة أولاً';
  static const String noTextError = 'يجب استخراج النص أولاً قبل تحليله';
  static const String connectionTestError = 'فشل الاتصال';
  static const String noTextToSpeech = 'لا يوجد نص للتحويل إلى صوت';

  // رسائل تحليل الصور
  static const String extractedText = 'النص المستخرج:';
  static const String analyzedText = 'تحليل النص:';
  static const String imageAnalysis = 'شرح الصورة:';
  static const String analyzing = 'جاري التحليل...';
  static const String copyAnalysis = 'نسخ التحليل';
  static const String copyImageAnalysis = 'نسخ الشرح';
  static const String copySuccess = 'تم نسخ النص إلى الحافظة';
  static const String copyAnalysisSuccess = 'تم نسخ التحليل إلى الحافظة';
  static const String copyImageAnalysisSuccess =
      'تم نسخ شرح الصورة إلى الحافظة';

  // للكاميرا المباشرة
  static const String liveCameraError = 'لم يتم العثور على كاميرات متاحة';
  static const String continuousAnalysis = 'تحليل تلقائي';
  static const String autoAudioOn = 'الشرح الصوتي مفعل';
  static const String autoAudioOff = 'الشرح الصوتي معطل';
  static const String autoAudioEnabled = 'تم تفعيل الشرح الصوتي التلقائي';
  static const String autoAudioDisabled = 'تم تعطيل الشرح الصوتي التلقائي';
  static const String analysisResult = 'نتيجة التحليل:';
  static const String captureHint = 'التقط صورة للحصول على تحليل';
}
