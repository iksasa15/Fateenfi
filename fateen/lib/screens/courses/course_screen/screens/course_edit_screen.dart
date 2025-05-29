// course_edit_screen.dart

import 'package:flutter/material.dart';
import '../../../../models/course.dart';
import '../components/course_edit_components.dart';
import '../controllers/course_edit_controller.dart';
import '../constants/course_edit_constants.dart';

class CourseEditScreen extends StatefulWidget {
  final Course course;
  final Function onCourseUpdated;

  const CourseEditScreen({
    Key? key,
    required this.course,
    required this.onCourseUpdated,
  }) : super(key: key);

  @override
  _CourseEditScreenState createState() => _CourseEditScreenState();
}

class _CourseEditScreenState extends State<CourseEditScreen> {
  late CourseEditController _controller;

  // إنشاء متحكمات النصوص
  late TextEditingController _nameController;
  late TextEditingController _creditController;
  late TextEditingController _classroomController;

  // متغيرات الاختيار
  late List<String> _selectedDays;
  String? _selectedTimeString;

  // متغيرات الأخطاء
  String? _nameError;
  String? _creditError;
  String? _daysError;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    _controller = CourseEditController();

    // تهيئة المتحكمات بقيم المقرر الحالية
    _nameController = TextEditingController(text: widget.course.courseName);
    _creditController =
        TextEditingController(text: widget.course.creditHours.toString());
    _classroomController = TextEditingController(text: widget.course.classroom);

    // تهيئة الأيام المحددة
    _selectedDays = List<String>.from(widget.course.days);

    // تهيئة وقت المحاضرة
    _selectedTimeString = widget.course.lectureTime;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // استدعاء بناء شريط الأدوات مع العنوان
                    CourseEditComponents.buildToolbar(
                      title: CourseEditConstants.editCourseTitle,
                      onBackPressed: () => Navigator.pop(context),
                    ),

                    // استدعاء بناء حقول الاسم والساعات
                    CourseEditComponents.buildRowFields(
                      mainController: _nameController,
                      mainLabel: CourseEditConstants.courseNameLabel,
                      mainError: _nameError,
                      mainIcon: Icons.book_outlined,
                      secondaryController: _creditController,
                      secondaryLabel: CourseEditConstants.creditHoursLabel,
                      secondaryError: _creditError,
                      secondaryKeyboardType: TextInputType.number,
                      secondaryIcon: Icons.timer_outlined,
                    ),

                    // استدعاء بناء حقل القاعة
                    CourseEditComponents.buildTextField(
                      controller: _classroomController,
                      labelText: CourseEditConstants.classroomLabel,
                      icon: Icons.location_on_outlined,
                    ),

                    // استدعاء بناء قسم أيام المحاضرة مع عرض رسالة الخطأ
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // قسم أيام المحاضرة
                        CourseEditComponents.buildDaysSection(
                          selectedDays: _selectedDays,
                          onDaySelected: (day, selected) {
                            setState(() {
                              if (selected) {
                                _selectedDays.add(day);
                                _daysError = null; // إزالة الخطأ عند اختيار يوم
                              } else {
                                _selectedDays.remove(day);
                                // إضافة الخطأ إذا أصبحت القائمة فارغة
                                if (_selectedDays.isEmpty) {
                                  _daysError =
                                      CourseEditConstants.daysErrorEmpty;
                                }
                              }
                            });
                          },
                        ),

                        // عرض رسالة خطأ الأيام إذا وجدت
                        if (_daysError != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 4, right: 4, bottom: 8),
                            child: Text(
                              _daysError!,
                              style: const TextStyle(
                                color: CourseEditConstants.kAccentColor,
                                fontSize: 12,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // استدعاء بناء منتقي الوقت مع عرض رسالة الخطأ
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CourseEditComponents.buildTimePicker(
                          selectedTime: _selectedTimeString,
                          onTap: () async {
                            // استدعاء عرض منتقي الوقت
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: _selectedTimeString != null
                                  ? TimeOfDay(
                                      hour: int.parse(
                                          _selectedTimeString!.split(':')[0]),
                                      minute: int.parse(
                                          _selectedTimeString!.split(':')[1]),
                                    )
                                  : TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: CourseEditConstants.kDarkPurple,
                                      onPrimary: Colors.white,
                                      onSurface: Color(0xFF374151),
                                      surface: Colors.white,
                                    ),
                                    timePickerTheme: TimePickerThemeData(
                                      hourMinuteTextColor: Colors.white,
                                      hourMinuteColor:
                                          CourseEditConstants.kDarkPurple,
                                      dayPeriodTextColor: Color(0xFF374151),
                                      dayPeriodColor:
                                          CourseEditConstants.kLightPurple,
                                      dialBackgroundColor: Colors.white,
                                      dialHandColor:
                                          CourseEditConstants.kDarkPurple,
                                      dialTextColor: Color(0xFF374151),
                                      entryModeIconColor:
                                          CourseEditConstants.kDarkPurple,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                CourseEditConstants
                                                    .kDarkPurple),
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedTime != null) {
                              final hour =
                                  pickedTime.hour.toString().padLeft(2, '0');
                              final minute =
                                  pickedTime.minute.toString().padLeft(2, '0');
                              setState(() {
                                _selectedTimeString = '$hour:$minute';
                                _timeError = null; // إزالة الخطأ عند اختيار وقت
                              });
                            }
                          },
                        ),

                        // عرض رسالة خطأ الوقت إذا وجدت
                        if (_timeError != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 4, right: 4, bottom: 8),
                            child: Text(
                              _timeError!,
                              style: const TextStyle(
                                color: CourseEditConstants.kAccentColor,
                                fontSize: 12,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // زر حفظ التغييرات
                    CourseEditComponents.buildPrimaryButton(
                      text: CourseEditConstants.saveButton,
                      icon: Icons.save,
                      isLoading: _controller.isLoading,
                      onPressed: _saveCourse,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _saveCourse() async {
    if (_controller.isLoading) {
      return;
    }

    // التحقق من صحة البيانات
    final errors = _controller.validateCourseData(
      _nameController.text.trim(),
      _creditController.text.trim(),
      _selectedDays,
      _selectedTimeString,
    );

    setState(() {
      _nameError = errors['nameError'];
      _creditError = errors['creditError'];
      _daysError = errors['daysError'];
      _timeError = errors['timeError'];
    });

    // إذا كان هناك أخطاء، لا نكمل
    if (_nameError != null ||
        _creditError != null ||
        _daysError != null ||
        _timeError != null) {
      return;
    }

    setState(() {
      _controller.isLoading = true;
    });

    // إنشاء نسخة محدثة من المقرر
    final updatedCourse = Course(
      id: widget.course.id,
      courseName: _nameController.text.trim(),
      creditHours: int.parse(_creditController.text.trim()),
      classroom: _classroomController.text.trim(),
      days: _selectedDays,
      lectureTime: _selectedTimeString,
      grades: widget.course.grades, // الحفاظ على الدرجات الحالية
      files: widget.course.files, // الحفاظ على الملفات الحالية
      tasks: widget.course.tasks, // الحفاظ على المهام الحالية
      reminders: widget.course.reminders, // الحفاظ على التذكيرات الحالية
    );

    // حفظ التغييرات
    final success = await _controller.updateCourse(updatedCourse);

    setState(() {
      _controller.isLoading = false;
    });

    if (success && mounted) {
      // إخطار الشاشة الأصلية بالتحديث
      widget.onCourseUpdated();

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم تحديث المقرر بنجاح',
            style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // العودة للشاشة السابقة
      Navigator.pop(context);
    } else if (mounted) {
      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'حدث خطأ أثناء تحديث المقرر',
            style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
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

  @override
  void dispose() {
    _nameController.dispose();
    _creditController.dispose();
    _classroomController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
