import 'package:flutter/material.dart';
import '../controllers/ai_explainer_controller.dart';
import '../constants/ai_explainer_colors.dart';
import '../services/ai_explainer_api_service.dart';

class AiExplainerHeaderComponent extends StatelessWidget
    implements PreferredSizeWidget {
  final AiExplainerController controller;
  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback onNewChatPressed;
  final VoidCallback onHistoryPressed;

  const AiExplainerHeaderComponent({
    Key? key,
    required this.controller,
    required this.title,
    required this.onBackPressed,
    required this.onNewChatPressed,
    required this.onHistoryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AiExplainerColors.darkPurple),
        onPressed: onBackPressed,
      ),
      actions: [
        // زر التحقق من الاتصال بـ API
        IconButton(
          icon:
              const Icon(Icons.cloud_sync, color: AiExplainerColors.darkPurple),
          onPressed: () => _testApiConnection(context),
          tooltip: 'التحقق من الاتصال بالخادم',
        ),
        IconButton(
          icon: const Icon(Icons.add_comment,
              color: AiExplainerColors.darkPurple),
          onPressed: onNewChatPressed,
          tooltip: 'محادثة جديدة',
        ),
        IconButton(
          icon: const Icon(Icons.history, color: AiExplainerColors.darkPurple),
          onPressed: onHistoryPressed,
          tooltip: 'سجل المحادثات',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
      ),
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
              valueColor:
                  AlwaysStoppedAnimation<Color>(AiExplainerColors.darkPurple),
            ),
            const SizedBox(height: 20),
            const Text(
              "جاري التحقق من الاتصال...",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );

    // اختبار الاتصال
    bool isConnected = await AiExplainerApiService.testConnection();

    // إغلاق مؤشر التحميل
    Navigator.of(context, rootNavigator: true).pop();

    // عرض نتيجة الاختبار
    _showConnectionResult(context, isConnected);
  }

  // عرض نتيجة اختبار الاتصال
  void _showConnectionResult(BuildContext context, bool isConnected) {
    final serverInfo = AiExplainerApiService.serverInfo;

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
              color: isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(
              isConnected ? "تم الاتصال بنجاح" : "فشل الاتصال",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "عنوان الخادم: $serverInfo",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
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
                  color: AiExplainerColors.darkPurple,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AiExplainerColors.darkPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("حسناً"),
          ),
        ],
      ),
    );
  }

  // عرض مربع حوار لتغيير إعدادات الخادم
  void _showServerConfigDialog(BuildContext context) {
    final serverInfo = AiExplainerApiService.serverInfo.split(':');
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
            Icon(Icons.settings_ethernet, color: AiExplainerColors.darkPurple),
            SizedBox(width: 10),
            Text(
              "إعدادات الخادم",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
              decoration: InputDecoration(
                labelText: "عنوان IP",
                hintText: "مثال: 127.0.0.1",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AiExplainerColors.darkPurple,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "المنفذ",
                hintText: "مثال: 8000",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AiExplainerColors.darkPurple,
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
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final ip = ipController.text.trim();
              final port = int.tryParse(portController.text.trim()) ?? 8000;

              if (ip.isNotEmpty) {
                AiExplainerApiService.setServerAddress(ip, port);
                Navigator.pop(context);

                // إعادة اختبار الاتصال بعد تغيير الإعدادات
                _testApiConnection(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AiExplainerColors.darkPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("حفظ وإعادة الاختبار"),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
