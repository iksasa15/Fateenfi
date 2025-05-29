// ai_flashcards_header_component.dart
import 'package:flutter/material.dart';
import '../controllers/ai_flashcards_controller.dart';
import '../services/ai_flashcards_api_service.dart';

class AiFlashcardsHeaderComponent extends StatelessWidget
    implements PreferredSizeWidget {
  final AiFlashcardsController controller;
  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback? onResetPressed;

  const AiFlashcardsHeaderComponent({
    Key? key,
    required this.controller,
    required this.title,
    required this.onBackPressed,
    this.onResetPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام نفس قياسات الجدول الدراسي بالضبط
    final titleSize = 20.0; // تصغير حجم الخط ليناسب المركز
    final padding = 20.0;
    final buttonSize = 45.0; // حجم زر التبديل في هيدر الجدول

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // زر الرجوع في الجهة اليمنى
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: onBackPressed,
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.arrow_back, // سهم الرجوع
                      color: Color(0xFF4338CA),
                      size: 20,
                    ),
                  ),
                ),
              ),

              // عنوان الصفحة (في المنتصف تماماً)
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),

              // أزرار إضافية على اليسار
              Positioned(
                left: 0,
                child: Row(
                  children: [
                    // زر التحقق من الاتصال
                    GestureDetector(
                      onTap: () => _testApiConnection(context),
                      child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.cloud_sync,
                          color: Color(0xFF4338CA),
                          size: 20,
                        ),
                      ),
                    ),

                    // زر إعادة الضبط (يظهر فقط عند وجود بطاقات)
                    if (onResetPressed != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: onResetPressed,
                          child: Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Color(0xFF4338CA),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // خط فاصل
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.grey.shade200,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  // اختبار الاتصال بخادم API
  Future<void> _testApiConnection(BuildContext context) async {
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
    bool isConnected = await AiFlashcardsApiService.testConnection();

    // إغلاق مؤشر التحميل
    Navigator.of(context, rootNavigator: true).pop();

    // عرض نتيجة الاختبار
    _showConnectionResult(context, isConnected);
  }

  // عرض نتيجة اختبار الاتصال
  void _showConnectionResult(BuildContext context, bool isConnected) {
    final serverInfo = AiFlashcardsApiService.serverInfo;

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
              onPressed: () => _showServerConfigDialog(context),
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
  void _showServerConfigDialog(BuildContext context) {
    final serverInfo = AiFlashcardsApiService.serverInfo.split(':');
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
                AiFlashcardsApiService.setServerAddress(ip, port);
                Navigator.pop(context);

                // إعادة اختبار الاتصال بعد تغيير الإعدادات
                _testApiConnection(context);
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

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + 1); // إضافة 1 للخط الفاصل
}
