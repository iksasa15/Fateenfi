// components/empty_view.dart

import 'package:flutter/material.dart';
import '../constants/translation_strings.dart';
import '../../../../models/translation_mode.dart'; // تعديل الاستيراد لاستخدام ملف models بدلاً من controllers

class EmptyView extends StatelessWidget {
  final TranslationMode currentMode;

  const EmptyView({
    Key? key,
    required this.currentMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // مركز الأيقونة في منتصف البطاقة
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              currentMode == TranslationMode.file
                  ? Icons.file_upload_outlined
                  : Icons.text_format,
              color: const Color(0xFF4338CA),
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          currentMode == TranslationMode.file
              ? TranslationStrings.canTranslateFiles
              : TranslationStrings.fastAccurateTranslation,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontFamily: 'SYMBIOAR+LT',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
