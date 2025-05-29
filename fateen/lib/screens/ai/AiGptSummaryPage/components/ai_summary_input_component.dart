import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/ai_summary_strings.dart';
import '../controllers/ai_summary_controller.dart';

class AiSummaryInputComponent extends StatelessWidget {
  final AiSummaryController controller;
  final bool isLoading;
  final VoidCallback onGeneratePressed;

  const AiSummaryInputComponent({
    Key? key,
    required this.controller,
    required this.isLoading,
    required this.onGeneratePressed,
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
                  // حاوية اختيار الملف
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
                                  Icons.file_copy,
                                  color: Color(0xFF6366F1),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "اختيار ملف",
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
                                "اختر ملفًا لتوليد ملخص من محتواه",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                              const SizedBox(height: 16),

                              // اختيار ملف + عدد النقاط
                              Row(
                                children: [
                                  // زر اختيار ملف
                                  Expanded(
                                    flex: 4,
                                    child: InkWell(
                                      onTap: () => controller
                                          .pickFileAndReadContent(context),
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
                                          children: [
                                            const Icon(Icons.upload_file,
                                                color: Color(0xFF6366F1)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                controller.selectedFileName
                                                        .isEmpty
                                                    ? "اختيار ملف"
                                                    : controller
                                                        .selectedFileName,
                                                style: const TextStyle(
                                                  color: Color(0xFF4338CA),
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'SYMBIOAR+LT',
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // مربع عدد النقاط
                                  Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F3FF),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF4338CA)
                                            .withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller:
                                          controller.pointsCountController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        hintText: "عدد النقاط",
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 14),
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF9CA3AF),
                                          fontFamily: 'SYMBIOAR+LT',
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'SYMBIOAR+LT',
                                        fontSize: 14,
                                        color: Color(0xFF374151),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "مطلوب";
                                        }
                                        final count = int.tryParse(value);
                                        if (count == null || count < 1) {
                                          return "غير صالح";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // أنواع الملفات المدعومة
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
                                        Icons.description,
                                        color: Color(0xFF6366F1),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        "الصيغ المدعومة: TXT, PDF",
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

          // زر توليد الملخص
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
              onPressed: isLoading ? null : onGeneratePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4338CA),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: Text(
                AiSummaryStrings.generateButtonText,
                style: const TextStyle(
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
}
