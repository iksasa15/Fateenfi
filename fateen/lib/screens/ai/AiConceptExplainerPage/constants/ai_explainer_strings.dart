// ai_explainer_strings.dart
class AiExplainerStrings {
  // العناوين الرئيسية
  static const String pageTitle = 'المساعد التعليمي';
  static const String welcomeMessage =
      'مرحباً! أنا المساعد التعليمي الخاص بك. كيف يمكنني مساعدتك اليوم؟ يمكنك تحميل ملف نصي أو طرح أي سؤال تعليمي.';

  // المواضيع
  static const String generalTopic = 'عام';
  static const String mathTopic = 'رياضيات';
  static const String scienceTopic = 'علوم';
  static const String historyTopic = 'تاريخ';
  static const String literatureTopic = 'أدب';
  static const String computerScienceTopic = 'علوم الحاسب';
  static const String languagesTopic = 'لغات';

  // رسائل المحادثة
  static const String typingHint = 'اكتب رسالتك هنا...';
  static const String sendButtonLabel = 'إرسال';
  static const String currentFileText = 'الملف الحالي';
  static const String fileUploadedMessage = 'لقد قمت بتحميل الملف: %s';
  static const String imageUploadedMessage = 'لقد قمت بإرفاق صورة';
  static const String linkSharedMessage = 'أرغب في تحليل الرابط: %s';
  static const String analyzeFileRequest =
      'هل يمكنك تحليل وشرح محتوى هذا الملف بطريقة مبسطة؟';
  static const String analyzeImageRequest =
      'هل يمكنك وصف هذه الصورة ومساعدتي في فهم محتواها؟';
  static const String analyzeLinkRequest =
      'هل يمكنك تحليل محتوى هذا الرابط: %s';
  static const String topicChangedMessage =
      'تم تغيير الموضوع إلى %s. بماذا تود أن أساعدك في هذا المجال؟';
  static const String errorResponseMessage =
      'عذراً، حدث خطأ أثناء معالجة طلبك. هل يمكنك المحاولة مرة أخرى؟';

  // خيارات الإرفاق
  static const String attachmentOptionsTitle = 'إرفاق محتوى';
  static const String uploadFileOption = 'تحميل ملف';
  static const String addLinkOption = 'إضافة رابط';
  static const String uploadImageOption = 'إرفاق صورة';
  static const String addLinkDialogTitle = 'إضافة رابط';
  static const String linkHint = 'أدخل الرابط هنا...';

  // أزرار ولافتات
  static const String startNewChatText = 'محادثة جديدة';
  static const String viewHistoryText = 'سجل المحادثات';
  static const String addText = 'إضافة';
  static const String cancelText = 'إلغاء';
  static const String closeText = 'إغلاق';
  static const String confirmText = 'تأكيد';

  // مربعات الحوار
  static const String newChatDialogTitle = 'بدء محادثة جديدة';
  static const String newChatDialogContent =
      'هل أنت متأكد من رغبتك في بدء محادثة جديدة؟ ستفقد المحادثة الحالية إذا لم تكن محفوظة.';
  static const String chatHistoryTitle = 'سجل المحادثات';
  static const String noHistoryText = 'لا توجد محادثات سابقة.';

  // أخطاء
  static const String connectionError = 'خطأ أثناء الاتصال بالخدمة!';
  static const String filePickError = 'حدث خطأ أثناء اختيار الملف: ';
  static const String fileReadError = 'حدث خطأ أثناء قراءة الملف.';
  static const String emptyFileError =
      'الملف فارغ أو لا يحتوي على نص قابل للاستخراج.';
  static const String imagePickError = 'حدث خطأ أثناء اختيار الصورة: ';
  static const String linkProcessingError = 'حدث خطأ أثناء معالجة الرابط: ';
}
