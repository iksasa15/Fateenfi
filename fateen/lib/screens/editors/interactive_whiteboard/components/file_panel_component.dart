import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../models/drawing_file_model.dart';
import '../constants/whiteboard_colors.dart';
import '../constants/whiteboard_strings.dart';
import 'file_item_component.dart';

class FilePanelComponent extends StatelessWidget {
  final List<DrawingFile> files;
  final Function() onClose;
  final Function(DrawingFile) onFileOpen;
  final Function(DrawingFile) onFileShare;
  final Function(DrawingFile) onFileDelete;
  final String? errorMessage;

  const FilePanelComponent({
    Key? key,
    required this.files,
    required this.onClose,
    required this.onFileOpen,
    required this.onFileShare,
    required this.onFileDelete,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // إصلاح عرض الشاشة الشفافة على iOS
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: FadeIn(
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: isDarkMode
                ? Colors.black.withOpacity(0.9)
                : Colors.white.withOpacity(0.95),
            child: SafeArea(
              child: Column(
                children: [
                  // رأس القائمة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey[900]
                          : WhiteboardColors.kLightPurple,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: WhiteboardColors.kShadowColor,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          WhiteboardStrings.savedFilesTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : WhiteboardColors.kDarkPurple,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${files.length}${WhiteboardStrings.fileCount}',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClose,
                          color: isDarkMode
                              ? Colors.white
                              : WhiteboardColors.kDarkPurple,
                        ),
                      ],
                    ),
                  ),

                  // عرض رسالة الخطأ إذا وجدت
                  if (errorMessage != null)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: WhiteboardColors.kAccentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: WhiteboardColors.kAccentColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: WhiteboardColors.kAccentColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color: WhiteboardColors.kAccentColor,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // محتوى القائمة
                  Expanded(
                    child: files.isEmpty
                        ? _buildEmptyState(isDarkMode)
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              return FileItemComponent(
                                file: files[index],
                                onOpen: () => onFileOpen(files[index]),
                                onShare: () => onFileShare(files[index]),
                                onDelete: () => onFileDelete(files[index]),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            WhiteboardStrings.noSavedFiles,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : WhiteboardColors.kDarkPurple,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage != null
                ? "يرجى المحاولة مرة أخرى أو إعادة تشغيل التطبيق"
                : WhiteboardStrings.saveFirstDrawing,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ],
      ),
    );
  }
}
