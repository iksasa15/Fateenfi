// components/text_input_field.dart

import 'package:flutter/material.dart';
import '../constants/translation_strings.dart';

class TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onTranslate;

  const TextInputField({
    Key? key,
    required this.controller,
    required this.isLoading,
    required this.onTranslate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // حقل إدخال النص للترجمة
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE3E0F8),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Color(0xFF221291),
              fontFamily: 'SYMBIOAR+LT',
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: TranslationStrings.enterText,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontFamily: 'SYMBIOAR+LT',
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // زر الترجمة
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onTranslate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              isLoading ? Icons.hourglass_empty : Icons.translate,
              size: 18,
            ),
            label: Text(
              isLoading
                  ? TranslationStrings.translating
                  : TranslationStrings.translate,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
