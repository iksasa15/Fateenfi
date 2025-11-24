import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../controllers/aiming_controller.dart';

class AimingResultComponent extends StatelessWidget {
  final AimingController controller;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const AimingResultComponent({
    Key? key,
    required this.controller,
    required this.fadeAnimation,
    required this.slideAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // إذا لم توجد نتائج أو كنا في حالة تحميل
    if (controller.recognizedObjects.isEmpty || controller.isLoading) {
      return const SizedBox.shrink();
    }

    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عرض الصورة المحللة
            if (controller.imagePath != null)
              Container(
                width: double.infinity,
                height: 250,
                margin: const EdgeInsets.only(bottom: 16),
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
                  image: DecorationImage(
                    image: kIsWeb
                        ? NetworkImage(controller.imagePath!) as ImageProvider
                        : FileImage(File(controller.imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // رأس قسم النتائج
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4338CA).withOpacity(0.1),
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFF6366F1),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "نتائج التحليل",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "تم التعرف على ${controller.recognizedObjects.length} عنصر",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // قائمة العناصر المتعرف عليها
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recognizedObjects.length,
              itemBuilder: (context, index) {
                final object = controller.recognizedObjects[index];
                // حساب نسبة الثقة كنسبة مئوية
                final confidence = (object.confidence * 100).toStringAsFixed(0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // رأس العنصر مع نسبة الثقة
                        Row(
                          children: [
                            // رقم العنصر
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      const Color(0xFF4338CA).withOpacity(0.1),
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6366F1),
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // اسم العنصر
                            Expanded(
                              child: Text(
                                object.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF374151),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ),
                            // نسبة الثقة
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getConfidenceColor(object.confidence),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$confidence%",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (object.description != null &&
                            object.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12, right: 44),
                            child: Text(
                              object.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // زر التقاط صورة جديدة
            Container(
              width: double.infinity,
              height: 48,
              margin: const EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                onPressed: controller.resetContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F3FF),
                  foregroundColor: const Color(0xFF4338CA),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color(0xFF4338CA).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                icon: const Icon(Icons.camera_alt),
                label: const Text(
                  "التقاط صورة جديدة",
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
      ),
    );
  }

  // تحديد لون مؤشر الثقة بناءً على النسبة
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) {
      return const Color(0xFF4CAF50); // أخضر
    } else if (confidence >= 0.7) {
      return const Color(0xFF2196F3); // أزرق
    } else if (confidence >= 0.5) {
      return const Color(0xFFFFA726); // برتقالي
    } else {
      return const Color(0xFFE53935); // أحمر
    }
  }
}
