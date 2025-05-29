import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../constants/whiteboard_colors.dart';
import '../constants/whiteboard_strings.dart';

class FileInfoComponent extends StatelessWidget {
  final String fileName;
  final DateTime creationDate;
  final bool hasUnsavedChanges;
  final int currentPage;
  final int totalPages;

  const FileInfoComponent({
    Key? key,
    required this.fileName,
    required this.creationDate,
    required this.hasUnsavedChanges,
    this.currentPage = 1,
    this.totalPages = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              size: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              fileName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? WhiteboardColors.kMediumPurple
                    : WhiteboardColors.kDarkPurple,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            if (hasUnsavedChanges) ...[
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: WhiteboardColors.kAccentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            if (totalPages > 1) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[800]
                      : WhiteboardColors.kLightPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "صفحة $currentPage من $totalPages",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : WhiteboardColors.kDarkPurple,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
            const Spacer(),
            Text(
              "${WhiteboardStrings.creationDate} ${DateFormat('yyyy/MM/dd').format(creationDate)}",
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
