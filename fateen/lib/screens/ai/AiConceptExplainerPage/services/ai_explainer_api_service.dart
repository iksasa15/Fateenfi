import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiExplainerApiService {
  // عنوان الخادم - يمكن تعديله عند الحاجة
  static String _serverAddress =
      "https://apii-1-kjff.onrender.com"; // استخدم عنوان IP المحلي
  static int _serverPort = 8000;

  // تعيين عنوان الخادم
  static void setServerAddress(String address, int port) {
    _serverAddress = address;
    _serverPort = port;
  }

  // الحصول على عنوان الخادم الحالي
  static String get serverInfo => "$_serverAddress:$_serverPort";

  // عناوين API
  static String get chatEndpoint => "http://$_serverAddress:$_serverPort/chat";
  static String get chatWithContextEndpoint =>
      "http://$_serverAddress:$_serverPort/chat-with-context";
  static String get titleEndpoint =>
      "http://$_serverAddress:$_serverPort/generate-title";
  static String get testApiEndpoint =>
      "http://$_serverAddress:$_serverPort/test-api";

  // اختبار الاتصال بالخادم
  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse(testApiEndpoint))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error testing connection: $e");
      return false;
    }
  }

  // الحصول على استجابة من الـ AI
  static Future<String> getResponse({
    required String message,
    required String conversation,
    required String topic,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(chatEndpoint),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "message": message,
              "conversation": conversation,
              "topic": topic,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        return responseJson['response'] ?? "عذراً، حدث خطأ في معالجة الطلب.";
      } else {
        final errorMessage =
            jsonDecode(response.body)['detail'] ?? "حدث خطأ غير معروف";
        throw Exception("فشل في الحصول على استجابة: $errorMessage");
      }
    } catch (e) {
      debugPrint("Exception while calling Python service: $e");
      throw Exception("خطأ أثناء الاتصال بخدمة الدردشة: $e");
    }
  }

  // الحصول على استجابة مع سياق إضافي (مثل محتوى ملف)
  static Future<String> getResponseWithContext({
    required String message,
    required String context,
    required String topic,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(chatWithContextEndpoint),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "message": message,
              "context": context,
              "topic": topic,
            }),
          )
          .timeout(const Duration(seconds: 90)); // وقت أطول للملفات الكبيرة

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        return responseJson['response'] ?? "عذراً، حدث خطأ في معالجة الطلب.";
      } else {
        final errorMessage =
            jsonDecode(response.body)['detail'] ?? "حدث خطأ غير معروف";
        throw Exception("فشل في الحصول على استجابة: $errorMessage");
      }
    } catch (e) {
      debugPrint("Exception while calling Python service with context: $e");
      throw Exception("خطأ أثناء الاتصال بخدمة الدردشة: $e");
    }
  }

  // إنشاء عنوان للمحادثة
  static Future<String> generateSessionTitle(String messageContent) async {
    try {
      final response = await http
          .post(
            Uri.parse(titleEndpoint),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "content": messageContent,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        return responseJson['title'] ?? "محادثة جديدة";
      } else {
        return "محادثة جديدة";
      }
    } catch (e) {
      debugPrint("Exception while generating title: $e");
      return "محادثة جديدة";
    }
  }
}
