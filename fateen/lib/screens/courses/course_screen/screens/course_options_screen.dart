// course_options_screen.dart

import 'package:flutter/material.dart';
import '../components/course_options_components.dart';
import '../controllers/course_options_controller.dart';
import '../constants/course_options_constants.dart';
import '../../../../models/course.dart';
import 'course_edit_screen.dart';

class CourseOptionsScreen extends StatefulWidget {
  final Course course;
  final int courseIndex;
  final VoidCallback onCourseDeleted;

  const CourseOptionsScreen({
    Key? key,
    required this.course,
    required this.courseIndex,
    required this.onCourseDeleted,
  }) : super(key: key);

  @override
  _CourseOptionsScreenState createState() => _CourseOptionsScreenState();
}

class _CourseOptionsScreenState extends State<CourseOptionsScreen> {
  late CourseOptionsController _controller;
  final CourseOptionsConstants constants = CourseOptionsConstants();

  @override
  void initState() {
    super.initState();
    _controller = CourseOptionsController();
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => CourseOptionsComponents.buildConfirmationDialog(
        context: context,
        title: constants.deleteConfirmTitle,
        content: constants.deleteConfirmMessage,
        confirmText: constants.confirmDelete,
        cancelText: constants.cancelDelete,
        onConfirm: _deleteCourse,
      ),
    );
  }

  void _deleteCourse() async {
    final success = await _controller.deleteCourse(widget.course.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            constants.deleteSuccess,
            style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      widget.onCourseDeleted();
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            constants.deleteError,
            style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _navigateToEditCourse() {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CourseEditScreen(
          course: widget.course,
          onCourseUpdated: widget.onCourseDeleted,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // علامة السحب
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // شريط العنوان
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // توسيط العناصر
                  children: [
                    // صف العنوان والزر للإغلاق
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر الإغلاق
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF4338CA),
                              size: 18,
                            ),
                          ),
                        ),
                        // العنوان
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.0,
                            ),
                          ),
                          child: const Text(
                            "خيارات المقرر",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4338CA),
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ),
                        // مساحة فارغة للمحاذاة
                        const SizedBox(width: 36),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // معلومات المقرر - مع توسيط النص وخلفية بيضاء
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // توسيط عمودي
                        children: [
                          // اسم المقرر
                          Text(
                            widget.course.courseName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4338CA),
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                            textAlign: TextAlign.center, // توسيط النص
                          ),
                          const SizedBox(height: 8),

                          // معلومات الوقت والمكان
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // توسيط أفقي
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${widget.course.creditHours} ساعات",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.course.classroom.isNotEmpty
                                    ? widget.course.classroom
                                    : "غير محدد",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // خيارات المقرر
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    CourseOptionsComponents.buildModernOptionTile(
                      title: constants.editCourseTitle,
                      subtitle: "تعديل بيانات المقرر الأساسية",
                      icon: Icons.edit_outlined,
                      iconColor: const Color(0xFF4338CA),
                      onTap: _navigateToEditCourse,
                    ),

                    const SizedBox(height: 12),

                    CourseOptionsComponents.buildModernOptionTile(
                      title: constants.filesTitle,
                      subtitle: "إدارة ملفات وواجبات المقرر",
                      icon: Icons.file_copy_outlined,
                      iconColor: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        _controller.navigateToFiles(
                          context,
                          widget.course,
                          widget.onCourseDeleted,
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    CourseOptionsComponents.buildModernOptionTile(
                      title: constants.gradesTitle,
                      subtitle: "إدارة وعرض درجات المقرر",
                      icon: Icons.assessment_outlined,
                      iconColor: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        _controller.navigateToGrades(
                          context,
                          widget.course,
                          widget.onCourseDeleted,
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    CourseOptionsComponents.buildModernOptionTile(
                      title: constants.notificationsTitle,
                      subtitle: "إدارة التنبيهات والإشعارات",
                      icon: Icons.notifications_outlined,
                      iconColor: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        _controller.navigateToNotifications(
                          context,
                          widget.course,
                          widget.onCourseDeleted,
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // زر الحذف
                    CourseOptionsComponents.buildModernDeleteButton(
                      onDelete: _showDeleteConfirmation,
                      text: constants.deleteButtonText,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
