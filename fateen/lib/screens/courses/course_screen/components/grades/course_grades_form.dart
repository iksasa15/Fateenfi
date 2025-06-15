// course_grades_form.dart - تصميم مع قائمة تمرير أفقية

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/grades/course_grades_constants.dart';
import '../../constants/grades/course_grades_colors.dart';
import '../../controllers/course_grades_controller.dart';
import '../../../../../models/course.dart';
import '../../../../../core/constants/appColor.dart';
import '../../../../../core/constants/app_dimensions.dart';

class CourseGradesForm extends StatefulWidget {
  final CourseGradesController controller;
  final String? currentEditingAssignment;
  final double? currentGradeValue;
  final double? currentMaxGrade;
  final Course course;
  final Function(String?, String, double, double) onSave;
  final VoidCallback onCancel;
  final bool isLoading;
  final BuildContext context;

  const CourseGradesForm({
    Key? key,
    required this.context,
    required this.controller,
    required this.course,
    this.currentEditingAssignment,
    this.currentGradeValue,
    this.currentMaxGrade,
    required this.onSave,
    required this.onCancel,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CourseGradesForm> createState() => _CourseGradesFormState();
}

class _CourseGradesFormState extends State<CourseGradesForm> {
  final TextEditingController _maxGradeController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _customAssignmentController =
      TextEditingController();
  String? _selectedAssignmentType;
  bool _isCustomAssignment = false;

  // أخطاء التحقق
  String? _assignmentError;
  String? _gradeError;
  String? _maxGradeError;

  @override
  void initState() {
    super.initState();
    _initFormValues();
  }

  void _initFormValues() {
    // التحقق من وجود قيم للتعديل
    if (widget.currentEditingAssignment != null) {
      _selectedAssignmentType = widget.currentEditingAssignment;

      if (!widget.controller.predefinedAssignments
          .contains(_selectedAssignmentType)) {
        _isCustomAssignment = true;
        _selectedAssignmentType = 'أخرى';
        _customAssignmentController.text = widget.currentEditingAssignment!;
      }

      if (widget.currentGradeValue != null) {
        _gradeController.text = widget.currentGradeValue!.toString();
      }

      if (widget.currentMaxGrade != null) {
        _maxGradeController.text = widget.currentMaxGrade!.toString();
      } else {
        _maxGradeController.text = '100';
      }
    } else {
      _selectedAssignmentType = '';
      _isCustomAssignment = false;
      _maxGradeController.text = '100';
      _gradeController.text = '';
      _customAssignmentController.text = '';
    }
  }

  bool _validateForm() {
    bool isValid = true;

    // التحقق من اسم التقييم
    if (_isCustomAssignment) {
      if (_customAssignmentController.text.trim().isEmpty) {
        setState(() {
          _assignmentError = CourseGradesConstants.assignmentEmptyError;
        });
        isValid = false;
      } else if (_isAssignmentNameDuplicate(_customAssignmentController.text)) {
        setState(() {
          _assignmentError = CourseGradesConstants.assignmentDuplicateError;
        });
        isValid = false;
      } else {
        setState(() {
          _assignmentError = null;
        });
      }
    } else {
      if (_selectedAssignmentType == null ||
          _selectedAssignmentType!.trim().isEmpty) {
        setState(() {
          _assignmentError = CourseGradesConstants.assignmentEmptyError;
        });
        isValid = false;
      } else {
        if (widget.currentEditingAssignment != _selectedAssignmentType &&
            _isAssignmentNameDuplicate(_selectedAssignmentType!)) {
          setState(() {
            _assignmentError = CourseGradesConstants.assignmentDuplicateError;
          });
          isValid = false;
        } else {
          setState(() {
            _assignmentError = null;
          });
        }
      }
    }

    // التحقق من الدرجة
    try {
      final grade = double.parse(_gradeController.text);
      if (grade < 0) {
        setState(() {
          _gradeError = CourseGradesConstants.gradeValueError;
        });
        isValid = false;
      } else {
        setState(() {
          _gradeError = null;
        });
      }
    } catch (e) {
      setState(() {
        _gradeError = CourseGradesConstants.gradeValueError;
      });
      isValid = false;
    }

    // التحقق من الدرجة القصوى
    try {
      final maxGrade = double.parse(_maxGradeController.text);
      if (maxGrade <= 0) {
        setState(() {
          _maxGradeError = CourseGradesConstants.maxGradeError;
        });
        isValid = false;
      } else {
        setState(() {
          _maxGradeError = null;
        });
      }
    } catch (e) {
      setState(() {
        _maxGradeError = CourseGradesConstants.maxGradeError;
      });
      isValid = false;
    }

    // التحقق من أن الدرجة لا تتجاوز الدرجة الكاملة
    if (_gradeError == null && _maxGradeError == null) {
      try {
        final grade = double.parse(_gradeController.text);
        final maxGrade = double.parse(_maxGradeController.text);
        if (grade > maxGrade) {
          setState(() {
            _gradeError = CourseGradesConstants.gradeExceedsMaxError;
          });
          isValid = false;
        }
      } catch (e) {
        // تم معالجة أخطاء التنسيق في التحققات السابقة
      }
    }

    return isValid;
  }

  bool _isAssignmentNameDuplicate(String assignmentName) {
    return widget.course.grades.keys.any((existing) =>
        existing.trim().toLowerCase() == assignmentName.trim().toLowerCase() &&
        existing != widget.currentEditingAssignment);
  }

  void _submitForm() {
    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    if (!_validateForm()) {
      return;
    }

    try {
      final double actualGrade = double.parse(_gradeController.text);
      final double maxGrade = double.parse(_maxGradeController.text);

      String finalAssignmentName;
      if (_isCustomAssignment) {
        finalAssignmentName = _customAssignmentController.text.trim();
      } else if (_selectedAssignmentType != null &&
          _selectedAssignmentType!.isNotEmpty) {
        finalAssignmentName = _selectedAssignmentType!;
      } else {
        setState(() {
          _assignmentError = CourseGradesConstants.assignmentEmptyError;
        });
        return;
      }

      widget.onSave(
        widget.currentEditingAssignment,
        finalAssignmentName,
        actualGrade,
        maxGrade,
      );
    } catch (e) {
      debugPrint('خطأ في إرسال النموذج: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: widget.context.colorSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          _buildHeader(),

          const SizedBox(height: 20),

          // قائمة تمرير أفقية لأنواع التقييم
          _buildAssignmentTypeScroller(),

          // رسالة خطأ لنوع التقييم
          if (_assignmentError != null && !_isCustomAssignment)
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 4),
              child: Text(
                _assignmentError!,
                style: TextStyle(
                  color: widget.context.colorError,
                  fontSize: 12,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),

          // حقل التقييم المخصص
          if (_isCustomAssignment) ...[
            const SizedBox(height: 16),
            _buildCustomAssignmentField(),
          ],

          const SizedBox(height: 20),

          // قسم إدخال الدرجات
          _buildGradeFields(),

          const SizedBox(height: 24),

          // أزرار الإجراءات
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.context.colorPrimaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.grade_outlined,
            color: widget.context.colorPrimaryDark,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          widget.currentEditingAssignment != null
              ? 'تعديل درجة'
              : 'إضافة درجة جديدة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.context.colorTextPrimary,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentTypeScroller() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع التقييم',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.context.colorTextPrimary,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),

        const SizedBox(height: 12),

        // قائمة تمرير أفقية
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: widget.context.isDarkMode
                ? widget.context.colorSurface
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _assignmentError != null && !_isCustomAssignment
                  ? widget.context.colorError
                  : widget.context.isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade200,
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.controller.predefinedAssignments.length,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemBuilder: (context, index) {
              final type = widget.controller.predefinedAssignments[index];
              final bool isSelected = _selectedAssignmentType == type;

              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAssignmentType = isSelected ? '' : type;
                      _assignmentError = null;
                      _isCustomAssignment = (type == 'أخرى' && !isSelected);

                      // تحديث الدرجة القصوى تلقائياً
                      if (!isSelected && type.isNotEmpty && type != 'أخرى') {
                        _maxGradeController.text = widget.controller
                            .getDefaultMaxGrade(type)
                            .toString();
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.context.colorPrimaryDark
                          : widget.context.colorSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? widget.context.colorPrimaryDark
                            : widget.context.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: widget.context.colorPrimaryDark
                                    .withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getAssignmentIcon(type),
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : widget.context.colorPrimaryDark,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type,
                          style: TextStyle(
                            fontFamily: 'SYMBIOAR+LT',
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : widget.context.colorTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getAssignmentIcon(String type) {
    if (type.contains('اختبار') || type.contains('امتحان')) {
      return Icons.quiz_outlined;
    } else if (type.contains('مشروع')) {
      return Icons.engineering_outlined;
    } else if (type.contains('واجب') || type.contains('منزلي')) {
      return Icons.home_work_outlined;
    } else if (type.contains('حضور') || type.contains('مشاركة')) {
      return Icons.people_outline;
    } else if (type.contains('أخرى')) {
      return Icons.create_outlined;
    }
    return Icons.assignment_outlined;
  }

  Widget _buildCustomAssignmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اسم التقييم المخصص',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.context.colorTextPrimary,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _customAssignmentController,
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontSize: 15,
            color: widget.context.colorTextPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.context.isDarkMode
                ? widget.context.colorSurface
                : Colors.grey.shade50,
            hintText: 'أدخل اسم التقييم',
            hintStyle: TextStyle(
              color: widget.context.colorTextSecondary,
              fontFamily: 'SYMBIOAR+LT',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _assignmentError != null
                    ? widget.context.colorError
                    : widget.context.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _assignmentError != null
                    ? widget.context.colorError
                    : widget.context.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.context.colorPrimaryDark,
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Icon(
              Icons.create_outlined,
              color: widget.context.colorPrimaryDark,
              size: 20,
            ),
          ),
          onChanged: (value) {
            if (_assignmentError != null) {
              setState(() {
                _assignmentError = null;
              });
            }
          },
        ),

        // رسالة الخطأ
        if (_assignmentError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 4),
            child: Text(
              _assignmentError!,
              style: TextStyle(
                color: widget.context.colorError,
                fontSize: 12,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGradeFields() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الدرجة المحصلة
        Expanded(
          child: _buildGradeField(
            label: 'الدرجة المحصلة',
            controller: _gradeController,
            error: _gradeError,
            icon: Icons.auto_graph,
          ),
        ),

        const SizedBox(width: 12),

        // الدرجة الكاملة
        Expanded(
          child: _buildGradeField(
            label: 'الدرجة الكاملة',
            controller: _maxGradeController,
            error: _maxGradeError,
            icon: Icons.assignment_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeField({
    required String label,
    required TextEditingController controller,
    required String? error,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.context.colorTextPrimary,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontSize: 15,
            color: widget.context.colorTextPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.context.isDarkMode
                ? widget.context.colorSurface
                : Colors.grey.shade50,
            hintText: 'أدخل الدرجة',
            hintStyle: TextStyle(
              color: widget.context.colorTextSecondary,
              fontFamily: 'SYMBIOAR+LT',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null
                    ? widget.context.colorError
                    : widget.context.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null
                    ? widget.context.colorError
                    : widget.context.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.context.colorPrimaryDark,
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Icon(
              icon,
              color: widget.context.colorPrimaryDark,
              size: 20,
            ),
          ),
          onChanged: (value) {
            setState(() {
              if (label == 'الدرجة المحصلة') {
                _gradeError = null;
              } else {
                _maxGradeError = null;
              }
            });
          },
        ),

        // رسالة الخطأ
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 4),
            child: Text(
              error,
              style: TextStyle(
                color: widget.context.colorError,
                fontSize: 12,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // زر الإلغاء
        Expanded(
          child: OutlinedButton(
            onPressed: widget.isLoading ? null : widget.onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: widget.context.colorPrimaryDark,
              side: BorderSide(color: widget.context.colorPrimaryDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // زر الحفظ
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.context.colorPrimaryDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              disabledBackgroundColor:
                  widget.context.colorPrimaryDark.withOpacity(0.6),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_outlined),
                      const SizedBox(width: 8),
                      const Text(
                        'حفظ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _maxGradeController.dispose();
    _gradeController.dispose();
    _customAssignmentController.dispose();
    super.dispose();
  }
}
