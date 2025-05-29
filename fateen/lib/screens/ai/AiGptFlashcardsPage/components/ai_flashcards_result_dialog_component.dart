import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/ai_flashcards_strings.dart';

class AiFlashcardsResultDialogComponent extends StatelessWidget {
  final int knownCount;
  final int totalCount;

  const AiFlashcardsResultDialogComponent({
    Key? key,
    required this.knownCount,
    required this.totalCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = ((knownCount / totalCount) * 100).toStringAsFixed(0);
    final Color resultColor = _getResultColor(knownCount, totalCount);

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
                            child: const Text(
                              "ملخص المراجعة",
                              style: TextStyle(
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
                                "انتهيت من مراجعة جميع البطاقات التعليمية، إليك ملخص أدائك",
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // دائرة النتيجة
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: resultColor.withOpacity(0.1),
                          border: Border.all(
                            color: resultColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: resultColor.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "$percentage%",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: resultColor,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // نص النتيجة
                      Text(
                        "تعرفت على $knownCount من أصل $totalCount بطاقة",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // رسالة تحفيزية
                      Text(
                        _getMotivationalMessage(knownCount, totalCount),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // تفاصيل النتيجة
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
                            _buildResultRow("البطاقات المعروفة", "$knownCount",
                                Colors.green),
                            Divider(
                                height: 16,
                                color: Colors.grey.withOpacity(0.3)),
                            _buildResultRow("البطاقات غير المعروفة",
                                "${totalCount - knownCount}", Colors.red),
                            Divider(
                                height: 16,
                                color: Colors.grey.withOpacity(0.3)),
                            _buildResultRow("المجموع", "$totalCount",
                                const Color(0xFF4338CA)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // زر إعادة المراجعة
                      Container(
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
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4338CA),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "عودة إلى البطاقات",
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء صف في نتائج المراجعة
  Widget _buildResultRow(String label, String value, Color color) {
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
            color: color,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  // الحصول على رسالة تحفيزية مناسبة للنتيجة
  String _getMotivationalMessage(int known, int total) {
    final percentage = (known / total) * 100;

    if (percentage == 100) {
      return "ممتاز! تعرفت على جميع البطاقات التعليمية.";
    } else if (percentage >= 80) {
      return "أداء رائع! استمر في المراجعة لتثبيت المعلومات.";
    } else if (percentage >= 60) {
      return "أداء جيد، راجع البطاقات غير المعروفة مرة أخرى.";
    } else {
      return "واصل التعلم! يمكنك إعادة مراجعة البطاقات لتحسين أدائك.";
    }
  }

  // الحصول على لون مناسب للنتيجة
  Color _getResultColor(int known, int total) {
    final percentage = (known / total) * 100;

    if (percentage >= 80) {
      return const Color(0xFF4CAF50); // أخضر
    } else if (percentage >= 60) {
      return const Color(0xFFFFA726); // برتقالي
    } else {
      return const Color(0xFFE53935); // أحمر
    }
  }
}
