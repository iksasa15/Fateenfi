import 'package:flutter/material.dart';
import '../constants/course_files_constants.dart';
import '../../../../models/app_file.dart';
import '../../../../models/course.dart';
import '../../../editors/pdf_editor_screen/pdf_editor_screen.dart';
import '../../../editors/image_editor_screen/image_editor_screen.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class CourseFilesComponents {
  // عرض القائمة الفارغة للملفات
  static Widget buildEmptyFilesView(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Icon(
          Icons.folder_outlined,
          size: 60,
          color: context.colorPrimaryLight,
        ),
        const SizedBox(height: 16),
        Text(
          CourseFilesConstants.noFilesMessage,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.colorPrimaryDark,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          CourseFilesConstants.addFilesHint,
          style: TextStyle(
            fontSize: 14,
            color: context.colorTextSecondary,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // بناء بطاقة ملف
  static Widget buildFileCard(
    BuildContext context,
    AppFile file,
    VoidCallback onView,
    VoidCallback? onEdit,
    VoidCallback onDelete,
  ) {
    // تحديد الأيقونة المناسبة للملف
    IconData fileIcon;
    bool isEditable = false;

    if (file.fileType.contains('PDF')) {
      fileIcon = Icons.picture_as_pdf_outlined;
      isEditable = true;
    } else if (file.fileType.contains('DOC')) {
      fileIcon = Icons.description_outlined;
      isEditable = false;
    } else if (file.fileType.contains('JPG') ||
        file.fileType.contains('PNG') ||
        file.fileType.contains('IMAGE')) {
      fileIcon = Icons.image_outlined;
      isEditable = true;
    } else {
      fileIcon = Icons.insert_drive_file_outlined;
      isEditable = false;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: context.colorPrimaryPale,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.isDarkMode
                    ? context.colorPrimaryLight.withOpacity(0.3)
                    : const Color(0xFFD8D2FF),
              ),
            ),
            child: Center(
              child: Icon(
                fileIcon,
                size: 20,
                color: context.colorPrimaryDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SYMBIOAR+LT',
                    color: context.colorTextPrimary,
                  ),
                ),
                Text(
                  '${file.fileType} · ${file.fileSize} KB',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colorTextSecondary,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          ),
          // زر عرض الملف
          IconButton(
            onPressed: onView,
            icon: Icon(
              Icons.visibility_outlined,
              color: context.colorPrimaryDark,
              size: 20,
            ),
            padding: EdgeInsets.zero,
          ),
          // زر الكتابة على المستند
          IconButton(
            onPressed: isEditable ? onEdit : null,
            icon: Icon(
              Icons.edit_note,
              color: isEditable
                  ? context.colorPrimaryDark
                  : context.isDarkMode
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
              size: 20,
            ),
            tooltip: 'الكتابة على المستند',
            padding: EdgeInsets.zero,
          ),
          // زر حذف الملف
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              color: context.colorAccent,
              size: 20,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // بناء شريط أدوات مخصص
  static Widget buildToolbar({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onBackPressed,
  }) {
    return Row(
      children: [
        // زر الرجوع
        buildBackButton(context, onBackPressed),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: context.colorTextSecondary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // بناء زر الرجوع
  static Widget buildBackButton(BuildContext context, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: context.colorPrimaryPale,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.arrow_back_ios,
          color: context.colorPrimaryDark,
          size: 18,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  // بناء علامة السحب
  static Widget buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color:
              context.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // بناء زر رئيسي
  static Widget buildPrimaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorPrimaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
