import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/ai_questions_colors.dart';
import '../constants/ai_questions_strings.dart';
import '../controllers/ai_questions_controller.dart';
import 'ai_questions_progress_bar_component.dart';
import 'ai_question_options_component.dart';

class AiQuestionsDisplayComponent extends StatelessWidget {
  final AiQuestionsController controller;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const AiQuestionsDisplayComponent({
    Key? key,
    required this.controller,
    required this.fadeAnimation,
    required this.slideAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // إذا لم يوجد أسئلة أو كنا في حالة تحميل
    if (controller.questions.isEmpty || controller.isLoading) {
      return const SizedBox.shrink();
    }

    // هل هذا آخر سؤال؟
    final isLastQuestion =
        controller.currentQuestionIndex == controller.questions.length - 1;

    // جلب السؤال الحالي
    final currentQuestion =
        controller.questions[controller.currentQuestionIndex];

    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          // شريط تقدم الأسئلة
          AiQuestionsProgressBarComponent(
            currentIndex: controller.currentQuestionIndex,
            totalCount: controller.questions.length,
          ),
          const SizedBox(height: 20),

          // حاوية السؤال الرئيسية
          Expanded(
            child: Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رأس القسم
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // أيقونة رقم السؤال
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF4338CA).withOpacity(0.1),
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "${controller.currentQuestionIndex + 1}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "السؤال",
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

                  // محتوى السؤال
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE3E0F8),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        currentQuestion.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                          height: 1.5,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        textDirection:
                            _getTextDirection(currentQuestion.question),
                      ),
                    ),
                  ),

                  // الخيارات
                  Expanded(
                    child: AiQuestionOptionsComponent(
                      question: currentQuestion,
                      showAnswers: controller.showAnswers,
                      onOptionSelected: (int index) {
                        if (!controller.showAnswers) {
                          controller.setUserAnswer(index);
                        }
                      },
                    ),
                  ),

                  // أزرار التنقل والتحقق
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // زر السؤال السابق
                        if (controller.currentQuestionIndex > 0)
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 48,
                              margin: const EdgeInsets.only(left: 8),
                              child: ElevatedButton.icon(
                                onPressed: controller.previousQuestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5F3FF),
                                  foregroundColor: const Color(0xFF4338CA),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text(
                                  "السابق",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // زر التحقق أو التالي
                        Expanded(
                          flex: controller.currentQuestionIndex > 0 ? 1 : 2,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF4338CA).withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed:
                                  isLastQuestion && !controller.showAnswers
                                      ? () => controller.checkAnswers(context)
                                      : controller.nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4338CA),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(
                                isLastQuestion && !controller.showAnswers
                                    ? Icons.check_circle
                                    : Icons.arrow_forward,
                              ),
                              label: Text(
                                isLastQuestion && !controller.showAnswers
                                    ? "تحقق من الإجابات"
                                    : "التالي",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
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
        ],
      ),
    );
  }

  // تحديد اتجاه النص بناءً على المحتوى
  TextDirection _getTextDirection(String text) {
    final RegExp arabicPattern = RegExp(r'^[\u0600-\u06FF]');
    return arabicPattern.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }
}
