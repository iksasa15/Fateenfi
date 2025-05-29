// components/result_dialog_component.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/gpa_calculator_strings.dart';
import '../controllers/gpa_calculator_controller.dart';

class ResultDialogComponent extends StatelessWidget {
  final double termGPA;
  final double cumulativeGPA;
  final double totalCredits;
  final double totalPoints;
  final GPACalculatorController controller;

  const ResultDialogComponent({
    Key? key,
    required this.termGPA,
    required this.cumulativeGPA,
    required this.totalCredits,
    required this.totalPoints,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الحصول على نظام المعدل الحالي
    bool isSystem5 = controller.isSystem5;

    // الحد الأقصى للمعدل
    double maxGPA = isSystem5 ? 5.0 : 4.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: FadeIn(
        duration: const Duration(milliseconds: 300),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 10),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),

                // شريط العنوان
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصف الأول: زر الرجوع والعنوان
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // زر الرجوع
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.0,
                                ),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Color(0xFF4338CA),
                                size: 18,
                              ),
                            ),
                          ),
                          // العنوان
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              GPACalculatorStrings.resultTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4338CA),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                          // مساحة فارغة للمحاذاة
                          const SizedBox(width: 36),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // وصف مع أيقونة
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF4338CA).withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF4338CA),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "تم حساب المعدل بنجاح وفقًا للمعلومات المدخلة (نظام $maxGPA)",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE3E0F8),
                    ),
                  ],
                ),

                // المحتوى
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    children: [
                      // معدلات الفصل والتراكمي
                      Row(
                        children: [
                          // معدل الفصل
                          Expanded(
                            child: _buildGPACircle(
                              termGPA,
                              GPACalculatorStrings.termGPA,
                              controller.getGPAColor(termGPA),
                              maxGPA,
                            ),
                          ),

                          // المعدل التراكمي
                          Expanded(
                            child: _buildGPACircle(
                              cumulativeGPA,
                              GPACalculatorStrings.cumulativeGPAResult,
                              controller.getGPAColor(cumulativeGPA),
                              maxGPA,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // تفاصيل إضافية
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE3E0F8),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildResultRow(
                              GPACalculatorStrings.registeredHours,
                              '${totalCredits.toStringAsFixed(0)}',
                            ),
                            Divider(
                              height: 16,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            _buildResultRow(
                              GPACalculatorStrings.earnedPoints,
                              '${totalPoints.toStringAsFixed(2)}',
                            ),
                            Divider(
                              height: 16,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            _buildResultRow(
                              GPACalculatorStrings.gradeLabel,
                              controller.getGPAGrade(cumulativeGPA),
                              color: controller.getGPAColor(cumulativeGPA),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // زر موافق
                      _buildPrimaryButton(
                        text: GPACalculatorStrings.ok,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء دائرة عرض المعدل
  Widget _buildGPACircle(double gpa, String label, Color color, double maxGPA) {
    // للتأكد من عدم تجاوز الحد الأقصى للمعدل في العرض
    double displayGPA = gpa > maxGPA ? maxGPA : gpa;

    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              displayGPA.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  // بناء صف في نتائج الحساب
  Widget _buildResultRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF374151),
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  // بناء زر رئيسي بتصميم محسّن
  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
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
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4338CA),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ),
    );
  }
}
