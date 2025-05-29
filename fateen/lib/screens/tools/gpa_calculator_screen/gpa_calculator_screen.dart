// gpa_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
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
      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء تحميل المقررات: ${e.toString()}',
            style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          backgroundColor: const Color(0xFFEC4899),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
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
    return Directionality(
      textDirection: TextDirection.rtl, // ضبط اتجاه النص من اليمين إلى اليسار
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFF),
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
                    const LinearProgressIndicator(
                      backgroundColor: Color(0xFFE0E7FF),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
                    ),

                  // المحتوى الرئيسي
                  Expanded(
                    child: Stack(
                      children: [
                        // المحتوى الرئيسي
                        ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            const SizedBox(height: 16),

                            // مكون تبديل نظام المعدل
                            GPASystemToggle(controller: _controller),

                            const SizedBox(height: 16),

                            // قسم المعدل السابق (اختياري)
                            PreviousGPAComponent(
                              currentGpaController:
                                  _controller.currentGpaController,
                              completedHoursController:
                                  _controller.completedHoursController,
                            ),

                            const SizedBox(height: 16),

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
                                      backgroundColor: const Color(0xFFEC4899),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.all(10),
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

                            const SizedBox(height: 16),

                            // زر حساب المعدل
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4338CA)
                                        .withOpacity(0.25),
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
                                  backgroundColor: const Color(0xFF4338CA),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.calculate_outlined),
                                label: Text(
                                  GPACalculatorStrings.calculateGPA,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // جدول توضيحي للتقديرات
                            GradeGuideComponent(controller: _controller),

                            // مساحة في الأسفل للتمرير بسهولة
                            const SizedBox(height: 20),
                          ],
                        ),

                        // مؤشر التحميل في حالة استيراد المقررات
                        if (_isLoading)
                          Container(
                            color: Colors.black.withOpacity(0.1),
                            child: const Center(
                              child: CircularProgressIndicator(),
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
