import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/ai_flashcards_colors.dart';
import '../constants/ai_flashcards_strings.dart';
import '../controllers/ai_flashcards_controller.dart';
import '../components/ai_flashcards_result_dialog_component.dart';
import 'ai_flashcards_progress_bar_component.dart';

class AiFlashcardsDisplayComponent extends StatelessWidget {
  final AiFlashcardsController controller;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const AiFlashcardsDisplayComponent({
    Key? key,
    required this.controller,
    required this.fadeAnimation,
    required this.slideAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // إذا لم يوجد بطاقات أو كنا في حالة تحميل
    if (controller.flashcards.isEmpty || controller.isLoading) {
      return const SizedBox.shrink();
    }

    // هل هذه آخر بطاقة؟
    final isLastFlashcard =
        controller.currentFlashcardIndex == controller.flashcards.length - 1;

    // جلب البطاقة الحالية
    final currentFlashcard =
        controller.flashcards[controller.currentFlashcardIndex];

    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          // شريط تقدم البطاقات
          AiFlashcardsProgressBarComponent(
            currentIndex: controller.currentFlashcardIndex,
            totalCount: controller.flashcards.length,
          ),
          const SizedBox(height: 20),

          // حاوية البطاقة الرئيسية
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
                        // أيقونة رقم البطاقة
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
                              "${controller.currentFlashcardIndex + 1}",
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
                          "البطاقة التعليمية",
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
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE3E0F8),
                  ),

                  // محتوى البطاقة - الوجه الأمامي
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.label,
                                color: Color(0xFF6366F1), size: 16),
                            SizedBox(width: 8),
                            Text(
                              "الوجه الأمامي",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6366F1),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
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
                            currentFlashcard.front,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                              height: 1.5,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                            textDirection:
                                _getTextDirection(currentFlashcard.front),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // محتوى البطاقة - الوجه الخلفي (يظهر فقط إذا ضغط المستخدم على "عرض الإجابة")
                  if (controller.showAnswer)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.question_answer,
                                    color: Color(0xFF4CAF50), size: 16),
                                SizedBox(width: 8),
                                Text(
                                  "الوجه الخلفي",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4CAF50),
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF81C784),
                                    width: 1.0,
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    currentFlashcard.back,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2E7D32),
                                      height: 1.5,
                                      fontFamily: 'SYMBIOAR+LT',
                                    ),
                                    textDirection: _getTextDirection(
                                        currentFlashcard.back),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // أزرار عرض الإجابة أو تمييز المعرفة
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: controller.showAnswer
                        ? _buildKnowledgeButtons(context, isLastFlashcard)
                        : _buildShowAnswerButton(),
                  ),

                  // أزرار التنقل
                  if (!controller.showAnswer)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // زر البطاقة السابقة
                          if (controller.currentFlashcardIndex > 0)
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 48,
                                margin: const EdgeInsets.only(left: 8),
                                child: OutlinedButton.icon(
                                  onPressed: controller.previousFlashcard,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF4338CA),
                                    side: const BorderSide(
                                      color: Color(0xFF4338CA),
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_back, size: 18),
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

                          // زر البطاقة التالية
                          if (!isLastFlashcard)
                            Expanded(
                              flex:
                                  controller.currentFlashcardIndex > 0 ? 1 : 2,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4338CA)
                                          .withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: controller.nextFlashcard,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4338CA),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon:
                                      const Icon(Icons.arrow_forward, size: 18),
                                  label: const Text(
                                    "التالي",
                                    style: TextStyle(
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

  // زر عرض الإجابة
  Widget _buildShowAnswerButton() {
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
      child: ElevatedButton.icon(
        onPressed: controller.toggleAnswer,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4338CA),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.visibility),
        label: const Text(
          "عرض الإجابة",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ),
    );
  }

  // أزرار تمييز المعرفة (أعرفها/لا أعرفها)
  Widget _buildKnowledgeButtons(BuildContext context, bool isLastFlashcard) {
    return Row(
      children: [
        // زر "لا أعرفها"
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              controller.markFlashcard(false);

              // إذا كانت آخر بطاقة، نعرض مربع حوار النتائج
              if (isLastFlashcard) {
                _showResultsDialog(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.close),
            label: const Text(
              "لا أعرفها",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // زر "أعرفها"
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              controller.markFlashcard(true);

              // إذا كانت آخر بطاقة، نعرض مربع حوار النتائج
              if (isLastFlashcard) {
                _showResultsDialog(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.check),
            label: const Text(
              "أعرفها",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // عرض مربع حوار النتائج
  void _showResultsDialog(BuildContext context) {
    int knownCount = 0;
    for (var flashcard in controller.flashcards) {
      if (flashcard.isKnown) {
        knownCount++;
      }
    }

    // انتظر قليلاً قبل عرض النتائج
    Future.delayed(const Duration(milliseconds: 300), () {
      showDialog(
        context: context,
        builder: (ctx) => AiFlashcardsResultDialogComponent(
          knownCount: knownCount,
          totalCount: controller.flashcards.length,
        ),
      );
    });
  }

  // تحديد اتجاه النص بناءً على المحتوى
  TextDirection _getTextDirection(String text) {
    final RegExp arabicPattern = RegExp(r'^[\u0600-\u06FF]');
    return arabicPattern.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }
}
