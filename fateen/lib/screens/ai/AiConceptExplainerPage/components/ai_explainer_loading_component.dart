import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../controllers/ai_explainer_controller.dart';

class AiExplainerLoadingComponent extends StatelessWidget {
  final AiExplainerController controller;
  final AnimationController loadingController;

  const AiExplainerLoadingComponent({
    Key? key,
    required this.controller,
    required this.loadingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
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
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة التحميل
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5F3FF),
                border: Border.all(
                  color: const Color(0xFFE3E0F8),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(loadingController),
                  child: const Icon(
                    Icons.psychology,
                    color: Color(0xFF4338CA),
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // رسالة التحميل
            const Text(
              "جاري التفكير...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // رسالة الانتظار
            Text(
              controller.isProcessingFile
                  ? "جاري معالجة الملف ومراجعة المحتوى..."
                  : "قد يستغرق الأمر بضع ثوانٍ لإعداد إجابة شاملة...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // مؤشر خطي
            LinearProgressIndicator(
              backgroundColor: const Color(0xFFF5F3FF),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }
}
