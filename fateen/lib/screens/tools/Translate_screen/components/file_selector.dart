import 'package:flutter/material.dart';

class FileSelector extends StatelessWidget {
  final bool isLoading;
  final String? fileName;
  final Function() onSelectFile;
  final Function()? onSelectFileWithOCR; // إضافة معالج جديد لـ OCR

  const FileSelector({
    Key? key,
    required this.isLoading,
    required this.fileName,
    required this.onSelectFile,
    this.onSelectFileWithOCR,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // عنوان القسم
        Row(
          children: const [
            Icon(Icons.file_present, color: Color(0xFF221291), size: 16),
            SizedBox(width: 8),
            Text(
              'ملف للترجمة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF221291),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // زر اختيار الملف
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6FE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE3E0F8),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // معلومات الملف
              if (fileName != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconForFile(fileName!),
                      color: const Color(0xFF221291),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName!,
                        style: const TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed:
                          isLoading ? null : () => _handleClearFile(context),
                      color: Colors.red,
                      splashRadius: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // زر اختيار الملف
              ElevatedButton.icon(
                onPressed: isLoading ? null : onSelectFile,
                icon: const Icon(Icons.upload_file),
                label: const Text(
                  'اختيار ملف للترجمة',
                  style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF221291),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // إضافة زر OCR إذا كان متاحاً
              if (onSelectFileWithOCR != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onSelectFileWithOCR,
                  icon:
                      const Icon(Icons.document_scanner, color: Colors.purple),
                  label: const Text(
                    'استخراج النص بـ OCR',
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      color: Colors.purple,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Colors.purple),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'استخدم هذا الخيار إذا كان الملف يحتوي على صور أو كان محمياً',
                  style: TextStyle(
                    fontFamily: 'SYMBIOAR+LT',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // الحصول على أيقونة مناسبة لنوع الملف
  IconData _getIconForFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'txt':
        return Icons.text_snippet;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  // معالج مسح الملف
  void _handleClearFile(BuildContext context) {
    // يجب تنفيذ هذا في الواجهة
  }
}
