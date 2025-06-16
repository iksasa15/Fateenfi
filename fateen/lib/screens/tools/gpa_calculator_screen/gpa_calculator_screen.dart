// gpa_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
import 'controllers/gpa_calculator_controller.dart';
import 'constants/gpa_calculator_constants.dart';
import 'constants/gpa_calculator_strings.dart';
import 'components/previous_gpa_component.dart';
import 'components/course_section_component.dart';
import 'components/grade_guide_component.dart';
import 'components/result_dialog_component.dart';
import 'components/gpa_header_component.dart';
import 'components/gpa_system_toggle.dart';
import '../gpa_calculator_screen/services/firebaseServices/course_service.dart'; // استيراد خدمة المقررات

class GPACalculatorScreen extends StatefulWidget {
  const GPACalculatorScreen({Key? key}) : super(key: key);

  @override
  _GPACalculatorScreenState createState() => _GPACalculatorScreenState();
}

class _GPACalculatorScreenState extends State<GPACalculatorScreen>
    with SingleTickerProviderStateMixin {
  late GPACalculatorController _controller;
  final CourseService _courseService = CourseService(); // إنشاء خدمة المقررات
  bool _isLoading = false; // متغير لتتبع حالة التحميل

  @override
  void initState() {
    super.initState();
    _controller = GPACalculatorController();
    _controller.init(this);

    // تسجيل مستمع لتحديثات المتحكم
    _controller.setUpdateListener(() {
      setState(() {
        // تحديث الواجهة عند تغيير البيانات
      });
    });

    // لا نقوم بتحميل المقررات تلقائياً عند بدء التطبيق
  }

  // دالة: تحميل المقررات من فايرستور
  Future<void> _loadCoursesFromFirestore() async {
    setState(() {
      _isLoading = true; // بدء التحميل
    });

    try {
      // جلب المقررات من قاعدة البيانات
      final courses = await _courseService.getCourses();

      // تحميل المقررات في حاسبة المعدل
      _controller.loadCoursesFromData(courses);
    } catch (e) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء تحميل المقررات: ${e.toString()}',
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
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // انتهاء التحميل
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // عرض حوار نتائج الحساب
  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => ResultDialogComponent(
        termGPA: _controller.termGPA,
        cumulativeGPA: _controller.cumulativeGPA,
        totalCredits: _controller.totalCredits,
        totalPoints: _controller.totalPoints,
        controller: _controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl, // ضبط اتجاه النص من اليمين إلى اليسار
      child: Scaffold(
        backgroundColor: AppColors.getThemeColor(
          AppColors.background,
          AppColors.darkBackground,
          isDarkMode,
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _controller.fadeAnimation!,
            child: Form(
              key: _controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // هيدر الصفحة
                  const GPAHeaderComponent(),

                  // عرض مؤشر التحميل أثناء استيراد المقررات
                  if (_isLoading)
                    LinearProgressIndicator(
                      backgroundColor: AppColors.getThemeColor(
                        AppColors.primaryPale,
                        AppColors.darkPrimaryPale,
                        isDarkMode,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.getThemeColor(
                          AppColors.primaryDark,
                          AppColors.darkPrimaryDark,
                          isDarkMode,
                        ),
                      ),
                    ),

                  // المحتوى الرئيسي
                  Expanded(
                    child: Stack(
                      children: [
                        // المحتوى الرئيسي
                        ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.defaultSpacing),
                          children: [
                            SizedBox(height: AppDimensions.defaultSpacing),

                            // مكون تبديل نظام المعدل
                            GPASystemToggle(controller: _controller),

                            SizedBox(height: AppDimensions.defaultSpacing),

                            // قسم المعدل السابق (اختياري)
                            PreviousGPAComponent(
                              currentGpaController:
                                  _controller.currentGpaController,
                              completedHoursController:
                                  _controller.completedHoursController,
                            ),

                            SizedBox(height: AppDimensions.defaultSpacing),

                            // قسم إضافة المقررات
                            CourseSectionComponent(
                              courses: _controller.courses,
                              onAddCourse: () {
                                _controller.addCourse();
                              },
                              onRemoveCourse: (index) {
                                final result = _controller.removeCourse(index);
                                if (!result) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        GPACalculatorStrings.minCourseMessage,
                                        style: const TextStyle(
                                            fontFamily: 'SYMBIOAR+LT'),
                                      ),
                                      backgroundColor: AppColors.getThemeColor(
                                        AppColors.accent,
                                        AppColors.darkAccent,
                                        isDarkMode,
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppDimensions.smallRadius),
                                      ),
                                      margin: EdgeInsets.all(
                                          AppDimensions.smallSpacing),
                                    ),
                                  );
                                }
                              },
                              onGradeChanged: (index, grade) {
                                _controller.updateCourseGrade(index, grade);
                              },
                              onImportCourses: (coursesList) {
                                _controller.importCourses(coursesList);
                              },
                              // تمرير دالة تحميل المقررات
                              loadCoursesFromFirestore:
                                  _loadCoursesFromFirestore,
                            ),

                            SizedBox(height: AppDimensions.defaultSpacing),

                            // زر حساب المعدل
                            Container(
                              height: AppDimensions.buttonHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.inputBorderRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.getThemeColor(
                                      AppColors.primaryDark,
                                      AppColors.darkPrimaryDark,
                                      isDarkMode,
                                    ).withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_controller.calculateGPA()) {
                                          _showResultDialog();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.getThemeColor(
                                    AppColors.primaryDark,
                                    AppColors.darkPrimaryDark,
                                    isDarkMode,
                                  ),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.inputBorderRadius),
                                  ),
                                ),
                                icon: const Icon(Icons.calculate_outlined),
                                label: Text(
                                  GPACalculatorStrings.calculateGPA,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppDimensions.bodyFontSize,
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: AppDimensions.defaultSpacing),

                            // جدول توضيحي للتقديرات
                            GradeGuideComponent(controller: _controller),

                            // مساحة في الأسفل للتمرير بسهولة
                            SizedBox(height: AppDimensions.largeSpacing),
                          ],
                        ),

                        // مؤشر التحميل في حالة استيراد المقررات
                        if (_isLoading)
                          Container(
                            color: AppColors.getThemeColor(
                              Colors.black.withOpacity(0.1),
                              Colors.white.withOpacity(0.1),
                              isDarkMode,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.getThemeColor(
                                  AppColors.primaryDark,
                                  AppColors.darkPrimaryDark,
                                  isDarkMode,
                                ),
                              ),
                            ),
                          ),
                      ],
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
}
