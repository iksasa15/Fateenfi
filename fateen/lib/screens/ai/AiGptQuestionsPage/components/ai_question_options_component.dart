import 'package:flutter/material.dart';
import '../../../../models/generated_question_model.dart';

class AiQuestionOptionsComponent extends StatelessWidget {
  final GeneratedQuestionModel question;
  final bool showAnswers;
  final Function(int) onOptionSelected;

  const AiQuestionOptionsComponent({
    Key? key,
    required this.question,
    required this.showAnswers,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: question.options.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final optionText = question.options[index];
          final isCorrect = (index == question.correctIndex);
          final isUserChoice = (index == question.userAnswerIndex);

          // تحديد حالة الخيار
          Color borderColor = const Color(0xFFE3E0F8);
          Color bgColor = Colors.white;
          Color textColor = const Color(0xFF374151);
          IconData? optionIcon;

          if (showAnswers) {
            // لو المستخدم حدّد هذا الخيار وهو صحيح
            if (isUserChoice && isCorrect) {
              borderColor = const Color(0xFF4CAF50);
              bgColor = const Color(0xFFE8F5E9);
              textColor = const Color(0xFF2E7D32);
              optionIcon = Icons.check_circle;
            }
            // لو المستخدم حدّد هذا الخيار وهو خطأ
            else if (isUserChoice && !isCorrect) {
              borderColor = const Color(0xFFE53935);
              bgColor = const Color(0xFFFFEBEE);
              textColor = const Color(0xFFD32F2F);
              optionIcon = Icons.cancel;
            }
            // لو هذا هو الخيار الصحيح ولكن المستخدم اختار غيره
            else if (isCorrect) {
              borderColor = const Color(0xFF4CAF50);
              bgColor = Colors.white;
              textColor = const Color(0xFF2E7D32);
              optionIcon = Icons.check_circle_outline;
            }
          } else if (isUserChoice) {
            // الخيار المحدد من المستخدم (قبل التحقق)
            borderColor = const Color(0xFF4338CA);
            bgColor = const Color(0xFFF5F3FF);
          }

          return InkWell(
            onTap: showAnswers ? null : () => onOptionSelected(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // رقم الخيار أو أيقونة الإجابة
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isUserChoice
                          ? const Color(0xFF4338CA)
                          : const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4338CA).withOpacity(0.1),
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: showAnswers && optionIcon != null
                          ? Icon(optionIcon, color: textColor, size: 16)
                          : Text(
                              "${index + 1}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isUserChoice
                                    ? Colors.white
                                    : const Color(0xFF6366F1),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // نص الخيار
                  Expanded(
                    child: Text(
                      optionText,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontWeight:
                            isUserChoice ? FontWeight.bold : FontWeight.normal,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      textDirection: _getTextDirection(optionText),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // تحديد اتجاه النص بناءً على المحتوى
  TextDirection _getTextDirection(String text) {
    final RegExp arabicPattern = RegExp(r'^[\u0600-\u06FF]');
    return arabicPattern.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }
}
