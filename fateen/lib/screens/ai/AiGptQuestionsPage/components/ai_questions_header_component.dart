import 'package:flutter/material.dart';
import '../controllers/ai_questions_controller.dart';
import '../services/ai_questions_api_service.dart';

class AiQuestionsHeaderComponent extends StatelessWidget
    implements PreferredSizeWidget {
  final AiQuestionsController controller;
  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback? onResetPressed;

  const AiQuestionsHeaderComponent({
    Key? key,
    required this.controller,
    required this.title,
    required this.onBackPressed,
    this.onResetPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام نفس قياسات الهيدر بالضبط
    final titleSize = 20.0;
    final padding = 20.0;
    final buttonSize = 45.0;

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

                    // زر إعادة الضبط (يظهر فقط عند وجود أسئلة)
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
              "جاري التحقق من الاتصال...\nقد يستغرق الأمر وقتاً إذا كانت الخدمة في وضع السكون",
              textAlign: TextAlign.center,
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

    // محاولة إيقاظ الخدمة أولاً
    try {
      await AiQuestionsApiService.wakeUpService();
    } catch (e) {
      // تجاهل الخطأ إذا لم تكن الدالة موجودة
    }

    // ثم اختبار الاتصال
    bool isConnected = await AiQuestionsApiService.testConnection();

    // إغلاق مؤشر التحميل
    Navigator.of(context, rootNavigator: true).pop();

    // عرض نتيجة اختبار الاتصال
    _showConnectionResult(context, isConnected);
  }

  // عرض نتيجة اختبار الاتصال
  void _showConnectionResult(BuildContext context, bool isConnected) {
    final serverInfo = AiQuestionsApiService.serverInfo;
    final serverMessage = AiQuestionsApiService.lastServerMessage;

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
                  ? serverMessage.isNotEmpty
                      ? serverMessage
                      : "تم الاتصال بخادم API بنجاح. يمكنك الآن توليد الأسئلة."
                  : "تعذر الاتصال بخادم API. الأسباب المحتملة:\n- الخدمة في وضع السكون (حاول مرة أخرى بعد قليل)\n- مشكلة في الاتصال بالإنترنت\n- عنوان الخادم غير صحيح",
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
              onPressed: () {
                Navigator.pop(context);
                controller.toggleTestMode(); // تفعيل وضع الاختبار
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("تم تفعيل وضع الاختبار (بدون اتصال بالخادم)"),
                    backgroundColor: Color(0xFF4338CA),
                  ),
                );
              },
              child: const Text(
                "استخدام وضع الاختبار",
                style: TextStyle(
                  color: Color(0xFF4338CA),
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
            child: Text(
              isConnected ? "حسناً" : "أغلق",
              style: const TextStyle(
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
