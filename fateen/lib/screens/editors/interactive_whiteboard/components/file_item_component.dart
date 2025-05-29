import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/drawing_file_model.dart';
import '../constants/whiteboard_colors.dart';

class FileItemComponent extends StatelessWidget {
  final DrawingFile file;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const FileItemComponent({
    Key? key,
    required this.file,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: WhiteboardColors.kShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المعاينة
          Expanded(
            child: GestureDetector(
              onTap: onOpen,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: _buildThumbnail(isDarkMode),
              ),
            ),
          ),

          // معلومات الملف
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : WhiteboardColors.kDarkPurple,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy/MM/dd HH:mm').format(file.lastModified),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // زر الحذف
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: WhiteboardColors.kAccentColor,
                        size: 20,
                      ),
                      onPressed: onDelete,
                      tooltip: 'حذف الملف',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    // زر المشاركة
                    IconButton(
                      icon: Icon(
                        Icons.share_outlined,
                        color: isDarkMode
                            ? WhiteboardColors.kMediumPurple
                            : WhiteboardColors.kDarkPurple,
                        size: 20,
                      ),
                      onPressed: onShare,
                      tooltip: 'مشاركة',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(bool isDarkMode) {
    if (file.thumbnailPath == null) {
      return _buildPlaceholder(isDarkMode);
    }

    // إصلاح عرض الصور المصغرة على iOS
    return Builder(
      builder: (context) {
        try {
          // التحقق من وجود الملف بشكل متزامن
          final fileExists = File(file.thumbnailPath!).existsSync();
          print(
              'مسار الصورة المصغرة: ${file.thumbnailPath}, موجود: $fileExists');

          if (!fileExists) {
            return _buildPlaceholder(isDarkMode);
          }

          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.file(
              File(file.thumbnailPath!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('خطأ في تحميل الصورة المصغرة: $error');
                return _buildPlaceholder(isDarkMode);
              },
            ),
          );
        } catch (e) {
          print('استثناء في تحميل الصورة المصغرة: $e');
          return _buildPlaceholder(isDarkMode);
        }
      },
    );
  }

  Widget _buildPlaceholder(bool isDarkMode) {
    return Center(
      child: Icon(
        Icons.image,
        size: 48,
        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
      ),
    );
  }
}
