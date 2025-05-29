import 'package:flutter/material.dart';
import '../../../../models/course.dart';
import '../components/grades/course_grades_add_button.dart';
import '../components/grades/course_grades_dialog.dart';
import '../components/grades/course_grades_empty_view.dart';
import '../components/grades/course_grades_list.dart';
import '../components/grades/course_grades_toolbar.dart';
import '../components/grades/course_grades_delete_dialog.dart';
import '../constants/grades/course_grades_constants.dart';
import '../controllers/course_grades_controller.dart';
import '../services/course_grades_helpers.dart';

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

class _CourseGradesScreenState extends State<CourseGradesScreen> {
  late CourseGradesController _controller;
  bool _isLoading = false;
  String? _currentEditingAssignment;
  double? _currentGradeValue;
  double? _currentMaxGrade;
  bool _isDeleteLoading = false;

  // الحصول على اسم المادة مع التحقق من القيمة null
  String get _courseName => widget.course.courseName ?? 'المقرر';

  @override
  void initState() {
    super.initState();
    _controller = CourseGradesController();
    _resetForm();

    // اختبار تشخيصي
    _runDiagnosticChecks();
  }

  // دالة تشخيص لاختبار تخزين واسترجاع الدرجات
  void _runDiagnosticChecks() {
    print("DEBUG SCREEN: Running diagnostic checks");

    // طباعة الدرجات الحالية
    print("DEBUG SCREEN: Current grades in course: ${widget.course.grades}");
    print(
        "DEBUG SCREEN: Current maxGrades in course: ${widget.course.maxGrades}");

    // فحص وجود مشكلات تحويل
    widget.course.grades.forEach((key, value) {
      double maxGrade = widget.course.maxGrades[key] ?? 100.0;

      // التحقق من وجود مشكلة تحويل محتملة (20 -> 4)
      if (maxGrade == 20.0 && value < 10.0 && value > 0) {
        print(
            "DEBUG SCREEN: Possible grade scaling issue detected: $key has value $value/20.0. Expected ~${value * 5}/20.0");
      }
    });

    // اختبار تخزين درجة محلياً
    // ملاحظة: هذا اختبار فقط ولا يحفظ في قاعدة البيانات
    String testAssignment = "_اختبار_تشخيصي";

    print("DEBUG SCREEN: Testing grade storage with grade 20/20");
    widget.course.createGrade(testAssignment, 20.0, 20.0);

    // التحقق من الدرجة المخزنة
    if (widget.course.grades.containsKey(testAssignment)) {
      double storedGrade = widget.course.grades[testAssignment]!;
      double storedMaxGrade = widget.course.maxGrades[testAssignment]!;

      print("DEBUG SCREEN: Stored grade: $storedGrade/$storedMaxGrade");

      if (storedGrade == 20.0 && storedMaxGrade == 20.0) {
        print("DEBUG SCREEN: Storage test PASSED ✓");
      } else {
        print(
            "DEBUG SCREEN: Storage test FAILED ✗ - Expected 20/20 but got $storedGrade/$storedMaxGrade");
      }
    } else {
      print("DEBUG SCREEN: Storage test FAILED ✗ - Grade not stored");
    }

    // تنظيف بعد الاختبار
    widget.course.deleteGrade(testAssignment);
    print("DEBUG SCREEN: Diagnostic test complete");
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
    print(
        "DEBUG SCREEN: _saveGrade called with $grade/$maxGrade for $newAssignment");

    setState(() {
      _isLoading = true;
    });

    try {
      // حفظ الدرجة القصوى المخصصة
      if (newAssignment.isNotEmpty) {
        _controller.saveCustomMaxGrade(widget.course, newAssignment, maxGrade);
      }

      // CRITICAL FIX: استدعاء الخدمة لحفظ الدرجة الفعلية
      final success = await _controller.saveGrade(
          widget.course,
          oldAssignment,
          newAssignment,
          grade, // الدرجة الفعلية
          maxGrade); // الدرجة القصوى

      print(
          "DEBUG SCREEN: After save, grade=${widget.course.grades[newAssignment]}/${widget.course.maxGrades[newAssignment]}");

      if (success && mounted) {
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
    print(
        "DEBUG SCREEN: _editGrade called with $actualGrade/$maxGrade for $assignment");

    // CRITICAL FIX: استخدام القيم الفعلية مباشرة
    setState(() {
      _currentEditingAssignment = assignment;
      _currentGradeValue = actualGrade; // استخدام الدرجة الفعلية مباشرة
      _currentMaxGrade = maxGrade; // استخدام الدرجة القصوى مباشرة
    });

    _showAddEditGradeDialog(isEdit: true);
  }

  void _deleteGrade(String assignment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return CourseGradesDeleteDialog(
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
          title: isEdit
              ? CourseGradesConstants.editGradeTitle
              : CourseGradesConstants.addGradeTitle,
          description: isEdit
              ? "قم بتعديل بيانات درجة ${_currentEditingAssignment} في ${_courseName}"
              : "قم بإدخال بيانات الدرجة الجديدة في ${_courseName}",
          controller: _controller,
          course: widget.course,
          currentEditingAssignment: _currentEditingAssignment,
          currentGradeValue: _currentGradeValue, // الدرجة الفعلية
          currentMaxGrade: _currentMaxGrade,
          onSave: (oldAssignment, newAssignment, grade, maxGrade) {
            print(
                "DEBUG SCREEN: CourseGradesDialog.onSave called with $grade/$maxGrade");
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
    print(
        "DEBUG SCREEN: Building CourseGradesScreen with ${widget.course.grades.length} grades");

    // استخدام ListenableBuilder للاستماع للتغييرات في المتحكم
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
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

                    // المحتوى الرئيسي
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // شريط العنوان
                            CourseGradesToolbar(
                              title: CourseGradesConstants.gradesTabTitle,
                              subtitle: "قم بإدارة درجات ${_courseName}",
                              onBackPressed: () => Navigator.pop(context),
                            ),

                            // محتوى الدرجات أو رسالة فارغة
                            Expanded(
                              child: widget.course.grades.isEmpty
                                  ? const CourseGradesEmptyView()
                                  : CourseGradesList(
                                      course: widget.course,
                                      controller: _controller,
                                      onEditGrade: _editGrade,
                                      onDeleteGrade: _deleteGrade,
                                    ),
                            ),

                            // زر إضافة درجة جديدة
                            const SizedBox(height: 16),
                            CourseGradesAddButton(
                              text: CourseGradesConstants.addGradeButton,
                              onPressed: () {
                                _resetForm();
                                _showAddEditGradeDialog();
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
          );
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
