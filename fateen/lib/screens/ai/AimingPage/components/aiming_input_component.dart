import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/aiming_strings.dart';
import '../controllers/aiming_controller.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class AimingInputComponent extends StatelessWidget {
  final AimingController controller;
  final bool isLoading;
  final VoidCallback onImageProcessPressed;

  const AimingInputComponent({
    Key? key,
    required this.controller,
    required this.isLoading,
    required this.onImageProcessPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // حاوية اختيار الصورة
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE3E0F8),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // رأس القسم
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF4338CA)
                                        .withOpacity(0.1),
                                    width: 1.0,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.image,
                                  color: Color(0xFF6366F1),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "اختيار صورة",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // خط فاصل
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: const Color(0xFFE3E0F8),
                        ),

                        // محتوى الإدخال
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // العنوان
                              const Text(
                                "اختر صورة للتعرف على محتواها",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                              const SizedBox(height: 16),

                              // عرض الصورة المختارة إذا كانت موجودة
                              if (controller.imagePath != null)
                                Container(
                                  width: double.infinity,
                                  height: 250,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F3FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF4338CA)
                                          .withOpacity(0.1),
                                      width: 1,
                                    ),
                                    image: DecorationImage(
                                      image: kIsWeb
                                          ? NetworkImage(controller.imagePath!)
                                              as ImageProvider
                                          : FileImage(
                                              File(controller.imagePath!)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                              // أزرار اختيار الصورة
                              Row(
                                children: [
                                  // زر الكاميرا
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _handleCameraPermission(
                                          context, ImageSource.camera),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F3FF),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF4338CA)
                                                .withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.camera_alt,
                                                color: Color(0xFF6366F1)),
                                            SizedBox(width: 8),
                                            Text(
                                              "الكاميرا",
                                              style: TextStyle(
                                                color: Color(0xFF4338CA),
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'SYMBIOAR+LT',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // زر المعرض
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => controller.pickImage(
                                          ImageSource.gallery, context),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F3FF),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF4338CA)
                                                .withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.photo_library,
                                                color: Color(0xFF6366F1)),
                                            SizedBox(width: 8),
                                            Text(
                                              "المعرض",
                                              style: TextStyle(
                                                color: Color(0xFF4338CA),
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'SYMBIOAR+LT',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // ملاحظات الاستخدام
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F3FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE3E0F8),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF4338CA)
                                              .withOpacity(0.1),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.info_outline,
                                        color: Color(0xFF6366F1),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        "التقط صورة واضحة للحصول على نتائج أفضل",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6366F1),
                                          fontFamily: 'SYMBIOAR+LT',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // زر تحليل الصورة
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4338CA).withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: (isLoading || controller.imagePath == null)
                  ? null
                  : onImageProcessPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4338CA),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.image_search),
              label: const Text(
                "تحليل الصورة",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // التعامل مع أذونات الكاميرا بشكل آمن
  void _handleCameraPermission(BuildContext context, ImageSource source) {
    try {
      controller.pickImage(source, context);
    } catch (e) {
      debugPrint("خطأ عند محاولة الوصول إلى الكاميرا: $e");

      // عرض رسالة خطأ مفيدة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "تعذر الوصول إلى الكاميرا. قد تحتاج لمنح الإذن من إعدادات الجهاز",
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'المعرض',
            textColor: Colors.white,
            onPressed: () => controller.pickImage(ImageSource.gallery, context),
          ),
        ),
      );
    }
  }
}
