// screens/course_options_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/course_options_components.dart';
import '../constants/course_options_constants.dart';
import '../../../../models/course.dart';
// استيراد شاشات الخيارات
import '../screens/course_edit_screen.dart';
import '../screens/course_files_screen.dart';
import '../screens/course_grades_screen.dart';
import '../screens/course_notifications_screen.dart';

class CourseOptionsScreen extends StatelessWidget {
  final Course course;
  final int courseIndex;
  final VoidCallback onCourseDeleted;

  // إنشاء كائن من الثوابت
  final CourseOptionsConstants _constants = CourseOptionsConstants();

  CourseOptionsScreen({
    Key? key,
    required this.course,
    required this.courseIndex,
    required this.onCourseDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // الحصول على أبعاد الشاشة
      final screenSize = MediaQuery.of(context).size;
      final screenWidth = screenSize.width;
      final isSmallScreen = screenWidth < 360;
      final isTablet = screenWidth >= 600;
      final isWeb = screenWidth >= 1024;

      // تصغير ارتفاع النافذة بنسبة كبيرة
      final sheetHeight = isWeb
          ? screenSize.height * 0.33 // تم تقليلها من 0.48
          : isTablet
              ? screenSize.height * 0.33 // تم تقليلها من 0.5
              : isSmallScreen
                  ? screenSize.height * 0.47 // تم تقليلها من 0.58
                  : screenSize.height * 0.49; // تم تقليلها من 0.62

      // تكييف المساحة الداخلية - تقليل المساحة العلوية والسفلية
      final contentPadding = isWeb
          ? EdgeInsets.symmetric(horizontal: 16, vertical: 6) // تقليل vertical
          : isTablet
              ? EdgeInsets.symmetric(horizontal: 14, vertical: 4)
              : EdgeInsets.symmetric(horizontal: 12, vertical: 2);

      return Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // رأس البطاقة - تقليل المساحة الداخلية
            Container(
              child:
                  CourseOptionsComponents.buildEnhancedHeader(course, context),
              padding: EdgeInsets.only(bottom: 0), // تقليل padding
            ),

            // قائمة الخيارات وزر الحذف في قائمة واحدة
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                // تقليل padding كثيراً
                padding: EdgeInsets.only(
                  left: contentPadding.horizontal / 2,
                  right: contentPadding.horizontal / 2,
                  top: 4, // تقليل المسافة العلوية
                  bottom: isSmallScreen ? 6 : 8, // تقليل المسافة السفلية
                ),
                children: [
                  // خيار التعديل
                  CourseOptionsComponents.buildEnhancedOptionTile(
                    title: _constants.editCourseTitle,
                    subtitle: _constants.editCourseDescription,
                    icon: Icons.edit_outlined,
                    iconColor: CourseOptionsComponents.optionColors[0],
                    onTap: () {
                      Navigator.pop(context); // إغلاق نافذة الخيارات أولاً

                      // عرض نافذة تعديل المقرر
                      showDialog(
                        context: context,
                        builder: (context) => CourseEditScreen(
                          course: course,
                          onCourseUpdated: () {
                            // يمكن هنا تنفيذ أي منطق تحديث إضافي مطلوب
                          },
                        ),
                      );
                    },
                  ),

                  // خيار الملفات
                  CourseOptionsComponents.buildEnhancedOptionTile(
                    title: _constants.filesTitle,
                    subtitle: _constants.filesDescription,
                    icon: Icons.file_copy_outlined,
                    iconColor: CourseOptionsComponents.optionColors[1],
                    onTap: () {
                      Navigator.pop(context); // إغلاق نافذة الخيارات أولاً

                      // عرض نافذة ملفات المقرر
                      showDialog(
                        context: context,
                        builder: (context) => CourseFilesScreen(
                          course: course,
                          onFilesUpdated: () {
                            // يمكن هنا تنفيذ أي منطق تحديث إضافي مطلوب
                          },
                        ),
                      );
                    },
                  ),

                  // خيار الدرجات
                  CourseOptionsComponents.buildEnhancedOptionTile(
                    title: _constants.gradesTitle,
                    subtitle: _constants.gradesDescription,
                    icon: Icons.grade_outlined,
                    iconColor: CourseOptionsComponents.optionColors[2],
                    onTap: () {
                      Navigator.pop(context); // إغلاق نافذة الخيارات أولاً

                      // عرض نافذة درجات المقرر
                      showDialog(
                        context: context,
                        builder: (context) => CourseGradesScreen(
                          course: course,
                          onGradesUpdated: () {
                            // يمكن هنا تنفيذ أي منطق تحديث إضافي مطلوب
                          },
                        ),
                      );
                    },
                  ),

                  // خيار الإشعارات
                  CourseOptionsComponents.buildEnhancedOptionTile(
                    title: _constants.notificationsTitle,
                    subtitle: _constants.notificationsDescription,
                    icon: Icons.notifications_outlined,
                    iconColor: CourseOptionsComponents.optionColors[3],
                    onTap: () {
                      Navigator.pop(context); // إغلاق نافذة الخيارات أولاً

                      // عرض نافذة إعدادات الإشعارات
                      showDialog(
                        context: context,
                        builder: (context) => CourseNotificationsScreen(
                          course: course,
                          onNotificationsUpdated: () {
                            // يمكن هنا تنفيذ أي منطق تحديث إضافي مطلوب
                          },
                        ),
                      );
                    },
                  ),

                  // زر الحذف مباشرة بعد الإشعارات
                  CourseOptionsComponents.buildEnhancedDeleteButton(
                    text: _constants.deleteButtonText,
                    onDelete: () {
                      // إظهار مربع حوار التأكيد
                      showDialog(
                        context: context,
                        builder: (context) => CourseOptionsComponents
                            .buildEnhancedConfirmationDialog(
                          context: context,
                          title: _constants.deleteConfirmTitle,
                          content: _constants.deleteConfirmMessage,
                          confirmText: _constants.confirmDelete,
                          cancelText: _constants.cancelDelete,
                          onConfirm: () async {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            onCourseDeleted();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
