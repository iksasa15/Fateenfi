// components/translation_result.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import '../constants/translation_strings.dart';

class TranslationResultWidget extends StatelessWidget {
  final String translatedText;
  final bool isTranslationSuccessful;
  final bool isFileMode;
  final bool hasTranslatedFile;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onDownload;

  const TranslationResultWidget({
    Key? key,
    required this.translatedText,
    required this.isTranslationSuccessful,
    required this.isFileMode,
    required this.hasTranslatedFile,
    required this.onCopy,
    required this.onShare,
    this.onDownload,
  }) : super(key: key);

  // دالة إصلاح الترميز للنصوص العربية
  String _fixArabicEncoding(String text) {
    if (text.contains('Ø') || text.contains('£') || text.contains('ØÙ')) {
      try {
        // محاولة إصلاح الترميز - طريقة 1
        final decoded = utf8.decode(latin1.encode(text));
        return decoded;
      } catch (e) {
        try {
          // محاولة إصلاح الترميز - طريقة 2
          return utf8.decode(text.codeUnits);
        } catch (e2) {
          // إرجاع النص الأصلي إذا فشلت جميع المحاولات
          return text;
        }
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    // معالجة النص قبل عرضه لإصلاح مشكلة الترميز
    final String displayText = _fixArabicEncoding(translatedText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // محتوى النص - ارتفاع ثابت والتمرير داخل المربع
        Container(
          width: double.infinity,
          height: 240, // ارتفاع مناسب أكثر للتوافق مع التصميم
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE3E0F8),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Text(
              displayText, // استخدام النص المعالج
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),

        // أزرار التحميل والمشاركة للملفات
        if (isTranslationSuccessful) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              // زر التحميل (للملفات فقط)
              if (isFileMode && hasTranslatedFile && onDownload != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.download, size: 16),
                    label: Text(
                      TranslationStrings.download,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),
                ),

              if (isFileMode && hasTranslatedFile && onDownload != null)
                const SizedBox(width: 12),

              // زر المشاركة
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4338CA),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.share, size: 16),
                  label: Text(
                    TranslationStrings.share,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
