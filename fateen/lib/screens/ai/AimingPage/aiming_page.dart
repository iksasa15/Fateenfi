import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AimingPage extends StatefulWidget {
  const AimingPage({Key? key}) : super(key: key);

  @override
  State<AimingPage> createState() => _AimingPageState();
}

class _AimingPageState extends State<AimingPage> {
  final ImagePicker _picker = ImagePicker();

  // مؤشر لعرض رسالة عند فتح الكاميرا
  bool _isCameraOpening = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFF),
        appBar: AppBar(
          title: const Text(
            "التعرف على الصور",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF4338CA),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة الكاميرا
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF5F3FF),
                      border: Border.all(
                        color: const Color(0xFFE3E0F8),
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF4338CA),
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // عنوان
                  const Text(
                    "التقاط صورة",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // نص وصفي
                  Text(
                    "انقر على زر فتح الكاميرا لالتقاط صورة",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // زر فتح الكاميرا
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isCameraOpening ? null : _openCamera,
                      icon: _isCameraOpening
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.camera_alt,
                              color: Colors.white, size: 28),
                      label: Text(
                        _isCameraOpening
                            ? "جاري فتح الكاميرا..."
                            : "فتح الكاميرا",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4338CA),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // فتح الكاميرا بشكل آمن مع معالجة الأخطاء المحتملة
  Future<void> _openCamera() async {
    try {
      // تغيير حالة الزر لمنع النقرات المتعددة
      setState(() {
        _isCameraOpening = true;
      });

      // فتح الكاميرا
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      // تم إغلاق الكاميرا أو التقاط الصورة
      setState(() {
        _isCameraOpening = false;
      });

      // لا نقوم بمعالجة الصورة أو إرسالها إلى أي خدمة
      if (photo != null) {
        // يمكن هنا عرض رسالة بسيطة أن الصورة تم التقاطها
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم التقاط الصورة بنجاح"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // في حالة حدوث خطأ، إعادة الزر إلى حالته الطبيعية
      setState(() {
        _isCameraOpening = false;
      });

      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("حدث خطأ أثناء فتح الكاميرا"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'حاول مرة أخرى',
              textColor: Colors.white,
              onPressed: _openCamera,
            ),
          ),
        );
      }
    }
  }
}
