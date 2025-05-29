import 'dart:typed_data';

class TranslationResult {
  final bool isSuccess;
  final String originalText;
  final String translatedText;
  final String? errorMessage;
  final String? filePath;
  final Uint8List? fileBytes;
  final String? fileName;
  final bool needsDownload;

  TranslationResult({
    required this.isSuccess,
    required this.originalText,
    required this.translatedText,
    this.errorMessage,
    this.filePath,
    this.fileBytes,
    this.fileName,
    this.needsDownload = false,
  });

  factory TranslationResult.success({
    required String originalText,
    required String translatedText,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    bool needsDownload = false,
  }) {
    return TranslationResult(
      isSuccess: true,
      originalText: originalText,
      translatedText: translatedText,
      filePath: filePath,
      fileBytes: fileBytes,
      fileName: fileName,
      needsDownload: needsDownload,
    );
  }

  factory TranslationResult.error({
    required String originalText,
    required String errorMessage,
  }) {
    return TranslationResult(
      isSuccess: false,
      originalText: originalText,
      translatedText: originalText,
      errorMessage: errorMessage,
      needsDownload: false,
    );
  }

  bool? get isSuccessful => null;

  @override
  String toString() {
    if (isSuccess) {
      return 'Translation Success: $translatedText';
    } else {
      return 'Translation Error: $errorMessage';
    }
  }
}
