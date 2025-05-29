import 'package:flutter/material.dart';
import '../controllers/student_performance_controller.dart';
import '../services/student_performance_service.dart';

/// مكون رأس صفحة أداء الطالب
/// يعرض عنوان الصفحة وأزرار التنقل وأزرار الوظائف الإضافية
class StudentPerformanceHeaderComponent extends StatelessWidget
    implements PreferredSizeWidget {
  // الخصائص الأساسية
  final StudentPerformanceController controller;
  final String title;
  final VoidCallback onBackPressed;

  const StudentPerformanceHeaderComponent({
    Key? key,
    required this.controller,
    required this.title,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    // القيم الثابتة للتصميم
    final titleSize = 20.0;
    final padding = 20.0;
    final buttonSize = 45.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // الجزء الرئيسي للهيدر
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // زر الرجوع (في الجهة اليمنى - اتجاه RTL)
              Positioned(
                right: 0,
                child: _buildNavigationButton(
                  onPressed: onBackPressed,
                  icon: Icons.arrow_back,
                  buttonSize: buttonSize,
                ),
              ),

              // عنوان الصفحة (في المنتصف)
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),

              // أزرار الوظائف الإضافية (في الجهة اليسرى - اتجاه RTL)
              Positioned(
                left: 0,
                child: Row(
                  children: [
                    // زر التحقق من اتصال الخادم
                    _buildNavigationButton(
                      onPressed: () => _testApiConnection(context),
                      icon: Icons.cloud_sync,
                      buttonSize: buttonSize,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // خط فاصل أسفل الهيدر
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

  /// إنشاء زر تنقل موحد التصميم
  Widget _buildNavigationButton({
    required VoidCallback onPressed,
    required IconData icon,
    required double buttonSize,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4338CA),
          size: 20,
        ),
      ),
    );
  }

  //////////////////////////
  /// وظائف اتصال الخادم ///
  //////////////////////////

  /// اختبار اتصال API
  Future<void> _testApiConnection(BuildContext context) async {
    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          _buildLoadingDialog(context, "جاري التحقق من الاتصال..."),
    );

    // اختبار الاتصال
    bool isConnected = await StudentPerformanceService.checkApiConnection();

    // إغلاق مؤشر التحميل
    Navigator.of(context, rootNavigator: true).pop();

    // عرض نتيجة الاختبار
    _showConnectionResult(context, isConnected);
  }

  /// بناء مربع حوار التحميل
  Widget _buildLoadingDialog(BuildContext context, String message) {
    return AlertDialog(
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
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: 14,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  /// عرض نتيجة اختبار الاتصال
  void _showConnectionResult(BuildContext context, bool isConnected) {
    final serverInfo = "${StudentPerformanceService.getServerInfo()}";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            // أيقونة الحالة (نجاح أو فشل)
            Icon(
              isConnected ? Icons.check_circle : Icons.error_outline,
              color: isConnected
                  ? const Color(0xFF4CAF50) // لون النجاح
                  : const Color(0xFFE53935), // لون الخطأ
            ),
            const SizedBox(width: 10),
            // عنوان الحالة
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
            // وصف الحالة
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
            // تفاصيل الخادم
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
          // إظهار زر تغيير إعدادات الخادم فقط في حالة فشل الاتصال
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
          // زر إغلاق مربع الحوار
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

  /// عرض مربع حوار لتغيير إعدادات الخادم
  void _showServerConfigDialog(BuildContext context) {
    // الحصول على معلومات الخادم الحالية
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
            // حقل إدخال عنوان IP
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
            // حقل إدخال رقم المنفذ
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
          // زر إلغاء العملية
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
          // زر حفظ الإعدادات الجديدة
          ElevatedButton(
            onPressed: () {
              final ip = ipController.text.trim();
              final port = int.tryParse(portController.text.trim()) ?? 8000;

              if (ip.isNotEmpty) {
                // حفظ عنوان الخادم الجديد
                StudentPerformanceService.setServerAddress(ip, port);
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
}
