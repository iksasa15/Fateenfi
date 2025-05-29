// components/course_section_component.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
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
    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE3E0F8),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // العنوان في سطر منفصل
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF4338CA).withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.book_outlined,
                          color: Color(0xFF6366F1),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        GPACalculatorStrings.currentTermCourses,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // الأزرار في سطر منفصل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // زر إضافة مقرر
                      InkWell(
                        onTap: onAddCourse,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                size: 16,
                                color: Color(0xFF6366F1),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                GPACalculatorStrings.addCourse,
                                style: const TextStyle(
                                  color: Color(0xFF6366F1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // زر استيراد المقررات
                      InkWell(
                        onTap: loadCoursesFromFirestore ??
                            () => _importCourses(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.file_download_outlined,
                                size: 16,
                                color: Color(0xFF6366F1),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                GPACalculatorStrings.importCourses,
                                style: const TextStyle(
                                  color: Color(0xFF6366F1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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
              color: const Color(0xFFE3E0F8),
            ),

            // عناوين الأعمدة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // مساحة لزر الحذف
                  const SizedBox(width: 30),

                  // التقدير
                  Expanded(
                    flex: 3,
                    child: Text(
                      GPACalculatorStrings.grade,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
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
                color: const Color(0xFFE3E0F8).withOpacity(0.5),
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
    try {
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF4338CA),
                ),
                const SizedBox(height: 15),
                Text(
                  GPACalculatorStrings.importingCourses,
                  style: const TextStyle(
                    color: Color(0xFF374151),
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
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(12),
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
          backgroundColor: const Color(0xFFEC4899),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
