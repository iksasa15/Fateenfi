import 'package:flutter/material.dart';
import '../../constants/grades/course_grades_constants.dart';
import '../../constants/grades/course_grades_colors.dart';
import '../../controllers/course_grades_controller.dart';
import '../../../../../models/course.dart';

class CourseGradesForm extends StatefulWidget {
  final CourseGradesController controller;
  final String? currentEditingAssignment;
  final double? currentGradeValue;
  final double? currentMaxGrade;
  final Course course;
  final Function(String?, String, double, double) onSave;
  final VoidCallback onCancel;
  final bool isLoading;

  const CourseGradesForm({
    Key? key,
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

      // التحقق إذا كانت الدرجة الحالية غير موجودة في القائمة المحددة مسبقاً
      if (!widget.controller.predefinedAssignments
          .contains(_selectedAssignmentType)) {
        // إذا كان التقييم غير موجود في القائمة، اعتبره تقييم مخصص
        _isCustomAssignment = true;
        _selectedAssignmentType = 'أخرى';
        _customAssignmentController.text = widget.currentEditingAssignment!;
      }

      // CRITICAL FIX: استخدام الدرجة الفعلية مباشرة بدون تحويل
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
      // إذا كان تقييم مخصص، التحقق من اسم التقييم المخصص
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
      // التحقق من نوع التقييم المحدد مسبقًا
      if (_selectedAssignmentType == null ||
          _selectedAssignmentType!.trim().isEmpty) {
        setState(() {
          _assignmentError = CourseGradesConstants.assignmentEmptyError;
        });
        isValid = false;
      } else {
        // التحقق من وجود تكرار في اسم التقييم عند الإضافة (ليس عند التعديل)
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
    if (!_validateForm()) return;

    try {
      // CRITICAL FIX: استخدام الدرجة الفعلية والقصوى بشكل مباشر
      final double actualGrade = double.parse(_gradeController.text);
      final double maxGrade = double.parse(_maxGradeController.text);

      // تحديد اسم التقييم النهائي
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

      print(
          "DEBUG FORM: Submitting grade $actualGrade/$maxGrade for $finalAssignmentName");

      // تمرير الدرجة الفعلية والقصوى مباشرة
      widget.onSave(
        widget.currentEditingAssignment,
        finalAssignmentName,
        actualGrade,
        maxGrade,
      );
    } catch (e) {
      // تم التعامل مع أخطاء التنسيق في _validateForm
      debugPrint('خطأ في إرسال النموذج: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // قسم نوع الدرجة
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 4),
              child: Text(
                CourseGradesConstants.assignmentTypeLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CourseGradesColors.textColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),

            // قائمة أنواع الدرجات
            _buildAssignmentTypeChips(),

            // حقل إدخال نوع التقييم المخصص (يظهر فقط عند اختيار "أخرى")
            if (_isCustomAssignment)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildCustomAssignmentField(),
              ),

            // عرض رسالة الخطأ
            if (_assignmentError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: Text(
                  _assignmentError!,
                  style: const TextStyle(
                    color: CourseGradesColors.accentColor,
                    fontSize: 12,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // صف الدرجات
        _buildGradeFields(),

        const SizedBox(height: 16),

        // زر الحفظ
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildAssignmentTypeChips() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _assignmentError != null && !_isCustomAssignment
              ? CourseGradesColors.accentColor
              : CourseGradesColors.darkPurple.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.controller.predefinedAssignments.map((type) {
            final bool isSelected = _selectedAssignmentType == type;
            return Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAssignmentType = isSelected ? '' : type;
                      _assignmentError = null;

                      // التحقق ما إذا كان النوع هو "أخرى"
                      _isCustomAssignment = (type == 'أخرى' && !isSelected);

                      // تحديث الدرجة القصوى تلقائياً مع نوع التقييم
                      if (!isSelected && type.isNotEmpty) {
                        _maxGradeController.text = widget.controller
                            .getDefaultMaxGrade(type)
                            .toString();
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: _buildChoiceChip(
                    label: type,
                    isSelected: isSelected,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCustomAssignmentField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _assignmentError != null
              ? CourseGradesColors.accentColor
              : CourseGradesColors.darkPurple.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: _customAssignmentController,
        style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
        decoration: InputDecoration(
          icon: const Icon(
            Icons.edit_outlined,
            color: CourseGradesColors.darkPurple,
            size: 20,
          ),
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontFamily: 'SYMBIOAR+LT',
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        onChanged: (value) {
          // حذف رسالة الخطأ عند الكتابة
          if (_assignmentError != null) {
            setState(() {
              _assignmentError = null;
            });
          }
        },
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'SYMBIOAR+LT',
          color: isSelected ? Colors.white : CourseGradesColors.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: CourseGradesColors.darkPurple,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? CourseGradesColors.darkPurple
              : CourseGradesColors.borderColor,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedAssignmentType = selected ? label : '';
          _assignmentError = null;

          // التحقق ما إذا كان النوع هو "أخرى"
          _isCustomAssignment = (label == 'أخرى' && selected);

          // تحديث الدرجة القصوى تلقائياً
          if (selected) {
            _maxGradeController.text =
                widget.controller.getDefaultMaxGrade(label).toString();
          }
        });
      },
      elevation: isSelected ? 1 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildGradeFields() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الحقل الأول - الدرجة المحصلة
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 4),
                child: Text(
                  CourseGradesConstants.gradeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CourseGradesColors.textColor,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _gradeError != null
                        ? CourseGradesColors.accentColor
                        : CourseGradesColors.darkPurple.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _gradeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.auto_graph,
                      color: CourseGradesColors.darkPurple,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    hintText: CourseGradesConstants.gradeLabel,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              if (_gradeError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(
                    _gradeError!,
                    style: const TextStyle(
                      color: CourseGradesColors.accentColor,
                      fontSize: 12,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // الحقل الثاني - الدرجة الكاملة
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 4),
                child: Text(
                  CourseGradesConstants.maxGradeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CourseGradesColors.textColor,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _maxGradeError != null
                        ? CourseGradesColors.accentColor
                        : CourseGradesColors.darkPurple.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _maxGradeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.assignment_outlined,
                      color: CourseGradesColors.darkPurple,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    hintText: CourseGradesConstants.maxGradeLabel,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              if (_maxGradeError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(
                    _maxGradeError!,
                    style: const TextStyle(
                      color: CourseGradesColors.accentColor,
                      fontSize: 12,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: CourseGradesColors.darkPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor:
              CourseGradesColors.darkPurple.withOpacity(0.6),
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
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_outlined),
                  const SizedBox(width: 8),
                  Text(
                    CourseGradesConstants.saveButton,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
      ),
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
