import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  // استخراج النص من الصورة
  static Future<String> extractTextFromImage(
      File imageFile, String serverIp, String serverPort) async {
    // تحويل الصورة إلى base64
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    final url = 'http://$serverIp:$serverPort/extract_text';

    // إرسال طلب إلى الخادم
    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'image': base64Image}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['text'];
    } else {
      final data = json.decode(response.body);
      throw Exception('حدث خطأ: ${data['error']}');
    }
  }

  // تحليل النص
  static Future<String> analyzeText(
      String text, String serverIp, String serverPort) async {
    final url = 'http://$serverIp:$serverPort/analyze_text';

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'text': text}),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['analysis'];
    } else {
      final data = json.decode(response.body);
      throw Exception('حدث خطأ أثناء التحليل: ${data['error']}');
    }
  }

  // تحليل الصورة
  static Future<String> analyzeImage(
      File imageFile, String serverIp, String serverPort) async {
    // تحويل الصورة إلى base64
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    final url = 'http://$serverIp:$serverPort/analyze_image';

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'image': base64Image}),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['image_analysis'];
    } else {
      final data = json.decode(response.body);
      throw Exception('حدث خطأ أثناء تحليل الصورة: ${data['error']}');
    }
  }

  // تحليل الصورة المباشرة (للكاميرا)
  static Future<String> analyzeLiveImage(
      File imageFile, String serverIp, String serverPort) async {
    // تحويل الصورة إلى base64
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    final url = 'http://$serverIp:$serverPort/analyze_live_image';

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'image': base64Image}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['image_analysis'];
    } else {
      final data = json.decode(response.body);
      throw Exception('حدث خطأ أثناء تحليل الصورة المباشرة: ${data['error']}');
    }
  }

  // تحويل النص إلى صوت
  static Future<Uint8List> textToSpeech(
      String text, String serverIp, String serverPort, String language) async {
    final url = 'http://$serverIp:$serverPort/text_to_speech';

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'text': text,
            'lang': language,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return base64Decode(data['audio']);
    } else {
      final data = json.decode(response.body);
      throw Exception('حدث خطأ أثناء تحويل النص إلى صوت: ${data['error']}');
    }
  }

  // اختبار الاتصال بالخادم
  static Future<Map<String, dynamic>> testConnection(
      String serverIp, String serverPort) async {
    try {
      final response = await http
          .get(
            Uri.parse('http://$serverIp:$serverPort/'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'تم الاتصال بنجاح'
        };
      } else {
        return {
          'success': false,
          'message': 'فشل الاتصال بالخادم: رمز الاستجابة ${response.statusCode}'
        };
      }
    } catch (e) {
      String errorMessage = 'فشل الاتصال: $e';

      if (e is SocketException) {
        errorMessage =
            'فشل الاتصال: تأكد من أن الخادم يعمل على العنوان $serverIp:$serverPort\n'
            'تفاصيل الخطأ: ${e.message}';
      }

      return {'success': false, 'message': errorMessage};
    }
  }

  // إرسال رسالة للمحادثة
  static Future<String> sendChatMessage(
      String message, String userId, String serverIp, String serverPort) async {
    final chatUrl = 'http://$serverIp:$serverPort/chat';

    final response = await http
        .post(
          Uri.parse(chatUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'message': message, 'user_id': userId}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['reply'];
    } else {
      final data = json.decode(response.body);
      throw Exception('حدث خطأ: ${data['error']}');
    }
  }
}
