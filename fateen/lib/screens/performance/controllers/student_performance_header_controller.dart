import 'package:flutter/material.dart';
import '../services/student_performance_service.dart';

class StudentPerformanceHeaderController {
  // اختبار اتصال API
  Future<void> testApiConnection(BuildContext context) async {
    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
            ),
            const SizedBox(height: 20),
            const Text(
              "جاري التحقق من الاتصال...",
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );

    // اختبار الاتصال
    bool isConnected = await StudentPerformanceService.checkApiConnection();

    // إغلاق مؤشر التحميل
    Navigator.of(context, rootNavigator: true).pop();

    // عرض نتيجة الاختبار
    showConnectionResult(context, isConnected);
  }

  // عرض نتيجة اختبار الاتصال
  void showConnectionResult(BuildContext context, bool isConnected) {
    final serverInfo = "${StudentPerformanceService.getServerInfo()}";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              isConnected ? Icons.check_circle : Icons.error_outline,
              color: isConnected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE53935),
            ),
            const SizedBox(width: 10),
            Text(
              isConnected ? "تم الاتصال بنجاح" : "فشل الاتصال",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isConnected
                  ? "تم الاتصال بخادم API بنجاح"
                  : "تعذر الاتصال بخادم API. تأكد من تشغيل الخادم ووجود اتصال صحيح.",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "عنوان الخادم: $serverInfo",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
        actions: [
          if (!isConnected)
            TextButton(
              onPressed: () => showServerConfigDialog(context),
              child: const Text(
                "تغيير عنوان الخادم",
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "حسناً",
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // عرض مربع حوار لتغيير إعدادات الخادم
  void showServerConfigDialog(BuildContext context) {
    final serverInfo = StudentPerformanceService.getServerInfo().split(':');
    final ipController = TextEditingController(text: serverInfo[0]);
    final portController = TextEditingController(
        text: serverInfo.length > 1 ? serverInfo[1] : '8000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.settings_ethernet, color: Color(0xFF4338CA)),
            SizedBox(width: 10),
            Text(
              "إعدادات الخادم",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ipController,
              style: const TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
              decoration: InputDecoration(
                labelText: "عنوان IP",
                hintText: "مثال: 127.0.0.1",
                labelStyle: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                ),
                hintStyle: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4338CA),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
              decoration: InputDecoration(
                labelText: "المنفذ",
                hintText: "مثال: 8000",
                labelStyle: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                ),
                hintStyle: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4338CA),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "إلغاء",
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final ip = ipController.text.trim();
              final port = int.tryParse(portController.text.trim()) ?? 8000;

              if (ip.isNotEmpty) {
                StudentPerformanceService.setServerAddress(ip, port);
                Navigator.pop(context);

                // إعادة اختبار الاتصال بعد تغيير الإعدادات
                testApiConnection(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "حفظ وإعادة الاختبار",
              style: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
