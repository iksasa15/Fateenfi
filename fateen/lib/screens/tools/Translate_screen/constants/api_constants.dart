class ApiConstants {
  // API URL DeepL
  static const String deeplApiUrl = 'https://api-free.deepl.com/v2';
  static const String translateEndpoint = '/translate';
  static const String documentsEndpoint = '/document';

  // تخزين المفاتيح
  static const String deeplApiKeyPrefs = 'deepl_api_key';

  // حدود التحميل
  static const int maxUploadSizeMB =
      5; // الحد الأقصى 5 ميجابايت للنسخة المجانية

  // امتدادات الملفات المدعومة
  static const List<String> supportedFileExtensions = ['txt', 'pdf', 'docx'];

  // أنواع MIME
  static const Map<String, String> mimeTypes = {
    'txt': 'text/plain',
    'pdf': 'application/pdf',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  };
}
