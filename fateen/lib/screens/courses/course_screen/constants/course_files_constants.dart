import 'package:flutter/material.dart';

class CourseFilesConstants {
  // ألوان التطبيق الموحدة
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kAccentColor = Color(0xFFEC4899);
  static const Color kBackgroundColor = Color(0xFFFDFDFF);

  // ثوابت النصوص
  static const String filesTabTitle = 'ملفات المقرر';
  static const String noFilesMessage = 'لا توجد ملفات لهذا المقرر بعد';
  static const String addFilesHint =
      'قم بإضافة ملفات للمقرر من خلال الزر أدناه';
  static const String addFileButton = 'إضافة ملف';
  static const String noPathError = 'لا يوجد مسار لهذا الملف!';
  static const String unsupportedFileError =
      'هذا النوع من الملفات لا يدعم التعديل!';
  static const String editSavedSuccess = 'تم حفظ التعديلات بنجاح';
  static const String fileAddedSuccess = 'تم إضافة الملف "%s"';
}
