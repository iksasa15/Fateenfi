import 'package:flutter/material.dart';
import '../constants/ai_explainer_colors.dart';
import '../constants/ai_explainer_strings.dart';
import '../controllers/ai_explainer_controller.dart';

class AiExplainerInputComponent extends StatelessWidget {
  final AiExplainerController controller;
  final bool isLoading;
  final VoidCallback onSendPressed;
  final VoidCallback onAttachPressed;

  const AiExplainerInputComponent({
    Key? key,
    required this.controller,
    required this.isLoading,
    required this.onSendPressed,
    required this.onAttachPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          // زر إرفاق ملف/صورة
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.attach_file, size: 20),
              onPressed: isLoading ? null : onAttachPressed,
              color: const Color(0xFF4338CA),
            ),
          ),

          // حقل إدخال الرسالة
          Expanded(
            child: Container(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE3E0F8),
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: TextField(
                  controller: controller.userMessageController,
                  decoration: const InputDecoration(
                    hintText: AiExplainerStrings.typingHint,
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.multiline,
                  maxLines: 1,
                  onSubmitted: (value) {
                    if (!isLoading && value.trim().isNotEmpty) {
                      onSendPressed();
                    }
                  },
                ),
              ),
            ),
          ),

          // زر إرسال الرسالة
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF4338CA),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4338CA).withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, size: 20),
              onPressed: isLoading ? null : onSendPressed,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
