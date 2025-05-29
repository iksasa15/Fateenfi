import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../models/summary_model.dart';

class AiSummaryApiService {
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
    return "http://$_serverAddress:$_serverPort/generate-summary";
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

  /// استدعاء خدمة API لإنشاء الملخص
  static Future<SummaryModel> generateSummary({
    required String text,
    required int pointsCount,
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
              "points_count": pointsCount,
              "clear_history": clearHistory,
              "language": language,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        return SummaryModel.fromJson(responseJson);
      } else {
        final errorMessage =
            jsonDecode(response.body)['detail'] ?? "حدث خطأ غير معروف";
        throw Exception("فشل إنشاء الملخص: $errorMessage");
      }
    } catch (e) {
      debugPrint("استثناء أثناء استدعاء خدمة توليد الملخص: $e");
      throw Exception("خطأ أثناء الاتصال بخدمة توليد الملخص: $e");
    }
  }
}
