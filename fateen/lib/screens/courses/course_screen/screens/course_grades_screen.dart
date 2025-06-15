// course_grades_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/course.dart';
import '../components/grades/course_grades_add_button.dart';
import '../components/grades/course_grades_dialog.dart';
import '../components/grades/course_grades_empty_view.dart';
import '../components/grades/course_grades_list.dart';
import '../components/grades/course_grades_toolbar.dart';
import '../components/grades/course_grades_delete_dialog.dart';
import '../components/grades/course_grades_summary.dart';
import '../constants/grades/course_grades_constants.dart';
import '../constants/grades/course_grades_colors.dart';
import '../controllers/course_grades_controller.dart';
import '../services/course_grades_helpers.dart';
// استيراد نظام الألوان
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class CourseGradesScreen extends StatefulWidget {
  final Course course;
  final VoidCallback? onGradesUpdated;

  const CourseGradesScreen({
    Key? key,
    required this.course,
    this.onGradesUpdated,
  }) : super(key: key);

  @override
  _CourseGradesScreenState createState() => _CourseGradesScreenState();
}

class _CourseGradesScreenState extends State<CourseGradesScreen>
    with SingleTickerProviderStateMixin {
  late CourseGradesController _controller;
  bool _isLoading = false;
  String? _currentEditingAssignment;
  double? _currentGradeValue;
  double? _currentMaxGrade;
  bool _isDeleteLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // الحصول على اسم المادة مع التحقق من القيمة null
  String get _courseName => widget.course.courseName ?? 'المقرر';

  @override
  void initState() {
    super.initState();
    _controller = CourseGradesController();
    _resetForm();

    // إعداد التحريكات
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // بدء التحريك
    _animationController.forward();

    // إعداد تأثير اهتزاز خفيف عند العرض
    HapticFeedback.lightImpact();
  }

  void _resetForm() {
    setState(() {
      _currentEditingAssignment = null;
      _currentGradeValue = null;
      _currentMaxGrade = null;
      _isLoading = false;
    });
  }

  Future<void> _saveGrade(String? oldAssignment, String newAssignment,
      double grade, double maxGrade) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // حفظ الدرجة القصوى المخصصة
      if (newAssignment.isNotEmpty) {
        _controller.saveCustomMaxGrade(widget.course, newAssignment, maxGrade);
      }

      final success = await _controller.saveGrade(
          widget.course, oldAssignment, newAssignment, grade, maxGrade);

      if (success && mounted) {
        // تأثير اهتزاز عند النجاح
        HapticFeedback.mediumImpact();

        CourseGradesHelpers.showSnackBar(
          context,
          oldAssignment == null
              ? CourseGradesConstants.addGradeSuccess
              : CourseGradesConstants.editGradeSuccess,
          isSuccess: true,
        );

        _resetForm();

        // تحديث واجهة المستخدم فوراً
        setState(() {});

        if (widget.onGradesUpdated != null) {
          widget.onGradesUpdated!();
        }
      } else if (mounted && _controller.errorMessage != null) {
        CourseGradesHelpers.handleError(context, _controller.errorMessage!);
      }
    } catch (e) {
      if (mounted) {
        CourseGradesHelpers.handleError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _editGrade(String assignment, double actualGrade, double maxGrade) {
    setState(() {
      _currentEditingAssignment = assignment;
      _currentGradeValue = actualGrade;
      _currentMaxGrade = maxGrade;
    });

    _showAddEditGradeDialog(isEdit: true);
  }

  void _deleteGrade(String assignment) {
    // تأثير اهتزاز خفيف عند محاولة الحذف
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return CourseGradesDeleteDialog(
          context: context, // إضافة السياق
          assignment: assignment,
          isLoading: _isDeleteLoading,
          onConfirm: () async {
            setDialogState(() {
              _isDeleteLoading = true;
            });

            try {
              final success =
                  await _controller.deleteGrade(widget.course, assignment);

              if (mounted) {
                Navigator.of(context).pop();

                if (success) {
                  // تأثير اهتزاز عند نجاح الحذف
                  HapticFeedback.mediumImpact();

                  // تحديث واجهة المستخدم فوراً بعد حذف الدرجة
                  setState(() {});

                  CourseGradesHelpers.showSnackBar(
                    context,
                    CourseGradesConstants.deleteSuccessMessage,
                    isSuccess: true,
                  );

                  if (widget.onGradesUpdated != null) {
                    widget.onGradesUpdated!();
                  }
                } else if (_controller.errorMessage != null) {
                  CourseGradesHelpers.handleError(
                      context, _controller.errorMessage!);
                }
              }
            } catch (e) {
              if (mounted) {
                Navigator.of(context).pop();
                CourseGradesHelpers.handleError(context, e.toString());
              }
            } finally {
              if (mounted) {
                setDialogState(() {
                  _isDeleteLoading = false;
                });
              }
            }
          },
          onCancel: () => Navigator.of(context).pop(),
        );
      }),
    );
  }

  void _showAddEditGradeDialog({bool isEdit = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: CourseGradesDialog(
          context: context, // إضافة السياق
          title: isEdit
              ? CourseGradesConstants.editGradeTitle
              : CourseGradesConstants.addGradeTitle,
          description: isEdit
              ? "قم بتعديل بيانات درجة ${_currentEditingAssignment} في ${_courseName}"
              : "قم بإدخال بيانات الدرجة الجديدة في ${_courseName}",
          controller: _controller,
          course: widget.course,
          currentEditingAssignment: _currentEditingAssignment,
          currentGradeValue: _currentGradeValue,
          currentMaxGrade: _currentMaxGrade,
          onSave: (oldAssignment, newAssignment, grade, maxGrade) {
            Navigator.of(context).pop();
            _saveGrade(oldAssignment, newAssignment, grade, maxGrade);
          },
          onCancel: () {
            Navigator.of(context).pop();
            _resetForm();
          },
          isLoading: _isLoading,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                decoration: BoxDecoration(
                  color: context.colorSurface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorShadowColor,
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      // علامة السحب المحسنة
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        decoration: BoxDecoration(
                          color: context.colorSurface,
                          boxShadow: [
                            BoxShadow(
                              color: context.colorShadowColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: context.isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),

                      // المحتوى الرئيسي
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // شريط العنوان المحسن (تم إزالة زر إظهار/إخفاء الملخص)
                              CourseGradesToolbar(
                                context: context, // إضافة السياق
                                title: CourseGradesConstants.gradesTabTitle,
                                subtitle: "قم بإدارة درجات ${_courseName}",
                                onBackPressed: () => Navigator.pop(context),
                              ),

                              // قسم ملخص الدرجات - يظهر دائماً إذا كانت هناك درجات
                              if (widget.course.grades.isNotEmpty)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 120,
                                  margin: const EdgeInsets.only(top: 12),
                                  child: CourseGradesSummary(
                                    context: context, // إضافة السياق
                                    course: widget.course,
                                    controller: _controller,
                                  ),
                                ),

                              // محتوى الدرجات أو رسالة فارغة
                              Expanded(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: widget.course.grades.isEmpty
                                      ? CourseGradesEmptyView(
                                          context: context, // إضافة السياق
                                        )
                                      : CourseGradesList(
                                          context: context, // إضافة السياق
                                          course: widget.course,
                                          controller: _controller,
                                          onEditGrade: _editGrade,
                                          onDeleteGrade: _deleteGrade,
                                        ),
                                ),
                              ),

                              // زر إضافة درجة جديدة
                              const SizedBox(height: 16),
                              CourseGradesAddButton(
                                context: context, // إضافة السياق
                                text: CourseGradesConstants.addGradeButton,
                                onPressed: () {
                                  _resetForm();
                                  _showAddEditGradeDialog();

                                  // تأثير اهتزاز خفيف عند الضغط على زر الإضافة
                                  HapticFeedback.selectionClick();
                                },
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
