// ai_flashcards_api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../models/generated_flashcard_model.dart';

class AiFlashcardsApiService {
  // عنوان الخادم - يمكن تعديله عند الحاجة
  static String _serverAddress = "127.0.0.1"; // استخدم عنوان IP المحلي
  static int _serverPort = 8000;

  // تعيين عنوان الخادم
  static void setServerAddress(String address, int port) {
    _serverAddress = address;
    _serverPort = port;
  }

  // الحصول على عنوان الخادم الحالي
  static String get serverInfo => "$_serverAddress:$_serverPort";

  // تعديل عنوان الخدمة
  static String get apiEndpoint {
    return "http://$_serverAddress:$_serverPort/generate-flashcards";
  }

  // نقطة نهاية لاختبار الاتصال
  static String get testApiEndpoint {
    return "http://$_serverAddress:$_serverPort/test-api";
  }

  /// اختبار الاتصال بالخادم
  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse(testApiEndpoint))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("خطأ في اختبار الاتصال بالخادم: $e");
      return false;
    }
  }

  /// استدعاء خدمة FastAPI لإنشاء البطاقات التعليمية
  static Future<List<GeneratedFlashcardModel>> generateFlashcards({
    required String text,
    required int flashcardCount,
    required String apiKey,
    required String language,
    bool clearHistory = false,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(apiEndpoint),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "text": text,
              "num_flashcards": flashcardCount,
              "api_key": apiKey, // سيتم تجاهله في الخادم
              "clear_history": clearHistory,
              "language": language,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> flashcardsJson = responseJson['flashcards'];

        List<GeneratedFlashcardModel> flashcards = [];
        for (var flashcardData in flashcardsJson) {
          flashcards.add(GeneratedFlashcardModel.fromJson(flashcardData));
        }

        return flashcards;
      } else {
        final errorMessage =
            jsonDecode(response.body)['detail'] ?? "حدث خطأ غير معروف";
        throw Exception("فشل إنشاء البطاقات التعليمية: $errorMessage");
      }
    } catch (e) {
      debugPrint("استثناء أثناء استدعاء خدمة Python: $e");
      throw Exception("خطأ أثناء الاتصال بخدمة توليد البطاقات التعليمية: $e");
    }
  }
}
