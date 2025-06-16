// components/course_section_component.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
import '../constants/gpa_calculator_strings.dart';
import '../../../../models/course_item.dart';
import '../services/firebaseServices/course_service.dart';
import 'course_item_component.dart';

class CourseSectionComponent extends StatelessWidget {
  final List<CourseItem> courses;
  final Function() onAddCourse;
  final Function(int) onRemoveCourse;
  final Function(int, String) onGradeChanged;
  final Function(List<Map<String, dynamic>>) onImportCourses;

  // جعل معامل loadCoursesFromFirestore اختياريًا لتجنب مشاكل التوافق مع الاستخدامات السابقة
  final Function()? loadCoursesFromFirestore;

  const CourseSectionComponent({
    Key? key,
    required this.courses,
    required this.onAddCourse,
    required this.onRemoveCourse,
    required this.onGradeChanged,
    required this.onImportCourses,
    this.loadCoursesFromFirestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getThemeColor(
            AppColors.surface,
            AppColors.darkSurface,
            isDarkMode,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
          border: Border.all(
            color: AppColors.getThemeColor(
              AppColors.divider,
              AppColors.darkDivider,
              isDarkMode,
            ),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.getThemeColor(
                AppColors.shadow,
                AppColors.darkShadow,
                isDarkMode,
              ),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // رأس القسم مع الأزرار
            Padding(
              padding: EdgeInsets.all(AppDimensions.defaultSpacing),
              child: Column(
                children: [
                  // العنوان في سطر منفصل
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.getThemeColor(
                            AppColors.surface,
                            AppColors.darkSurface,
                            isDarkMode,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.smallRadius),
                          border: Border.all(
                            color: AppColors.getThemeColor(
                              AppColors.primaryDark,
                              AppColors.darkPrimaryDark,
                              isDarkMode,
                            ).withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.book_outlined,
                          color: AppColors.getThemeColor(
                            AppColors.primaryLight,
                            AppColors.darkPrimaryLight,
                            isDarkMode,
                          ),
                          size: AppDimensions.extraSmallIconSize,
                        ),
                      ),
                      SizedBox(width: AppDimensions.smallSpacing),
                      Text(
                        GPACalculatorStrings.currentTermCourses,
                        style: TextStyle(
                          fontSize: AppDimensions.smallBodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getThemeColor(
                            AppColors.textPrimary,
                            AppColors.darkTextPrimary,
                            isDarkMode,
                          ),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppDimensions.smallSpacing),

                  // الأزرار في سطر منفصل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // زر إضافة مقرر
                      InkWell(
                        onTap: onAddCourse,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.smallSpacing,
                            vertical: AppDimensions.smallSpacing - 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.getThemeColor(
                              AppColors.primaryPale,
                              AppColors.darkPrimaryPale,
                              isDarkMode,
                            ),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.smallRadius),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: AppDimensions.extraSmallIconSize,
                                color: AppColors.getThemeColor(
                                  AppColors.primaryLight,
                                  AppColors.darkPrimaryLight,
                                  isDarkMode,
                                ),
                              ),
                              SizedBox(width: AppDimensions.smallSpacing / 2),
                              Text(
                                GPACalculatorStrings.addCourse,
                                style: TextStyle(
                                  color: AppColors.getThemeColor(
                                    AppColors.primaryLight,
                                    AppColors.darkPrimaryLight,
                                    isDarkMode,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppDimensions.smallLabelFontSize,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: AppDimensions.smallSpacing),

                      // زر استيراد المقررات
                      InkWell(
                        onTap: loadCoursesFromFirestore ??
                            () => _importCourses(context),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.smallSpacing,
                            vertical: AppDimensions.smallSpacing - 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.getThemeColor(
                              AppColors.primaryPale,
                              AppColors.darkPrimaryPale,
                              isDarkMode,
                            ),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.smallRadius),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.file_download_outlined,
                                size: AppDimensions.extraSmallIconSize,
                                color: AppColors.getThemeColor(
                                  AppColors.primaryLight,
                                  AppColors.darkPrimaryLight,
                                  isDarkMode,
                                ),
                              ),
                              SizedBox(width: AppDimensions.smallSpacing / 2),
                              Text(
                                GPACalculatorStrings.importCourses,
                                style: TextStyle(
                                  color: AppColors.getThemeColor(
                                    AppColors.primaryLight,
                                    AppColors.darkPrimaryLight,
                                    isDarkMode,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppDimensions.smallLabelFontSize,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // خط فاصل
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.getThemeColor(
                AppColors.divider,
                AppColors.darkDivider,
                isDarkMode,
              ),
            ),

            // عناوين الأعمدة
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.defaultSpacing,
                vertical: AppDimensions.smallSpacing,
              ),
              child: Row(
                children: [
                  // مساحة لزر الحذف
                  SizedBox(width: 30),

                  // التقدير
                  Expanded(
                    flex: 3,
                    child: Text(
                      GPACalculatorStrings.grade,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppDimensions.smallBodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getThemeColor(
                          AppColors.textPrimary,
                          AppColors.darkTextPrimary,
                          isDarkMode,
                        ),
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),

                  // الساعات
                  Expanded(
                    flex: 3,
                    child: Text(
                      GPACalculatorStrings.creditHours,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppDimensions.smallBodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getThemeColor(
                          AppColors.textPrimary,
                          AppColors.darkTextPrimary,
                          isDarkMode,
                        ),
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),

                  // اسم المقرر
                  Expanded(
                    flex: 6,
                    child: Text(
                      GPACalculatorStrings.courseName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppDimensions.smallBodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getThemeColor(
                          AppColors.textPrimary,
                          AppColors.darkTextPrimary,
                          isDarkMode,
                        ),
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // قائمة المقررات
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: courses.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.getThemeColor(
                  AppColors.divider,
                  AppColors.darkDivider,
                  isDarkMode,
                ).withOpacity(0.5),
              ),
              itemBuilder: (context, index) {
                return CourseItemComponent(
                  index: index,
                  course: courses[index],
                  onRemove: onRemoveCourse,
                  onGradeChanged: onGradeChanged,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // استيراد المقررات من الفايربيس - الطريقة السابقة للتوافق
  Future<void> _importCourses(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    try {
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: AppColors.getThemeColor(
            AppColors.surface,
            AppColors.darkSurface,
            isDarkMode,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.defaultSpacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.getThemeColor(
                    AppColors.primaryDark,
                    AppColors.darkPrimaryDark,
                    isDarkMode,
                  ),
                ),
                SizedBox(height: AppDimensions.defaultSpacing - 2),
                Text(
                  GPACalculatorStrings.importingCourses,
                  style: TextStyle(
                    color: AppColors.getThemeColor(
                      AppColors.textPrimary,
                      AppColors.darkTextPrimary,
                      isDarkMode,
                    ),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // جلب المقررات من الخدمة
      final service = CourseService();
      final coursesList = await service.getCoursesForGPA();

      // إغلاق مؤشر التحميل
      Navigator.of(context, rootNavigator: true).pop();

      // تمرير المقررات للمتحكم
      onImportCourses(coursesList);

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            GPACalculatorStrings.importSuccess
                .replaceAll("%d", "${coursesList.length}"),
            style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
          ),
          margin: EdgeInsets.all(AppDimensions.smallSpacing),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة حدوث خطأ
      Navigator.of(context, rootNavigator: true).pop();

      // عرض رسالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${GPACalculatorStrings.importError} ${e.toString()}",
            style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          backgroundColor: AppColors.getThemeColor(
            AppColors.accent,
            AppColors.darkAccent,
            isDarkMode,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
          ),
          margin: EdgeInsets.all(AppDimensions.smallSpacing),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
