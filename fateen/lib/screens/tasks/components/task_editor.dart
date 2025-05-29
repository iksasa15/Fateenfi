// lib/screens/tasks/components/task_editor.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/task.dart';
import '../../../models/course.dart';
import '../controllers/task_editor_controller.dart';
import '../constants/tasks_colors.dart';
import '../constants/tasks_strings.dart';
import '../constants/tasks_icons.dart';

class TaskEditor extends StatefulWidget {
  final Task? task;
  final List<String> categories;
  final Course? selectedCourse;
  final Function(bool) onSaveComplete;

  const TaskEditor({
    Key? key,
    this.task,
    required this.categories,
    this.selectedCourse,
    required this.onSaveComplete,
  }) : super(key: key);

  @override
  _TaskEditorState createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  late TaskEditorController _controller;

  // نضيف متغير لتتبع المادة المختارة
  String? _selectedCourseId;
  // إضافة متغيرات للتحقق من الخطأ
  String? _dueDateError;

  @override
  void initState() {
    super.initState();
    _controller = TaskEditorController();
    _controller.init(widget.task, widget.selectedCourse);

    // تهيئة المادة المختارة
    if (_controller.selectedCourse != null) {
      _selectedCourseId = _controller.selectedCourse!.id;
    }

    _controller.stateChanged.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller.stateChanged.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                  // مقبض السحب
                  _buildDragHandle(),

                  // شريط العنوان
                  _buildToolbar(
                    title: widget.task == null
                        ? TasksStrings.addTask
                        : TasksStrings.editTask,
                    onBackPressed: () => Navigator.pop(context),
                  ),

                  // المحتوى القابل للتمرير
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // حقل العنوان
                          _buildTextField(
                            controller: _controller.titleController,
                            labelText: TasksStrings.taskTitle,
                            errorText: _controller.titleError,
                            icon: TasksIcons.task,
                            hintText: TasksStrings.enterTaskTitle,
                          ),

                          const SizedBox(height: 16),

                          // حقل الوصف
                          _buildDescriptionField(
                            controller: _controller.descriptionController,
                            labelText: TasksStrings.taskDescription,
                            icon: TasksIcons.description,
                            hintText: TasksStrings.taskDescriptionHint,
                          ),

                          const SizedBox(height: 20),

                          // تاريخ ووقت التسليم
                          _buildDueDateTimePicker(),

                          const SizedBox(height: 20),

                          // الأولوية
                          _buildPrioritySection(),

                          const SizedBox(height: 20),

                          // اختيار المادة
                          if (_controller.availableCourses.isNotEmpty)
                            _buildCourseSelector(),

                          const SizedBox(height: 20),

                          // قسم التذكير
                          _buildReminderSection(),

                          const SizedBox(height: 20),

                          // الوسوم
                          _buildTagsSection(),

                          const SizedBox(height: 28),

                          // زر الحفظ
                          _buildPrimaryButton(
                            text: widget.task == null
                                ? TasksStrings.add
                                : TasksStrings.save,
                            onPressed: _validateAndSaveTask,
                            icon: TasksIcons.save,
                            isLoading: _controller.isLoading,
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
      ),
    );
  }

  // التحقق من صحة التاريخ والوقت قبل الحفظ
  void _validateAndSaveTask() {
    // إعادة تعيين الأخطاء السابقة
    setState(() {
      _dueDateError = null;
    });

    // التأكد من أن تاريخ التسليم ليس في الماضي عند إنشاء مهمة جديدة
    if (widget.task == null) {
      final DateTime now = DateTime.now();
      if (_controller.dueDate
          .isBefore(DateTime(now.year, now.month, now.day))) {
        setState(() {
          _dueDateError = "لا يمكن تحديد تاريخ تسليم في الماضي";
        });
        return;
      }
    }

    // التأكد من أن تاريخ التذكير لا يأتي بعد تاريخ التسليم
    if (_controller.hasReminder && _controller.reminderDateTime != null) {
      if (_controller.reminderDateTime!.isAfter(_controller.dueDate)) {
        setState(() {
          _dueDateError = "تاريخ التذكير يجب أن يكون قبل تاريخ التسليم";
        });
        return;
      }
    }

    // إذا كان التحقق ناجحاً، حفظ المهمة
    _saveTask();
  }

  // حفظ المهمة
  Future<void> _saveTask() async {
    final success = await _controller.saveTask();

    if (success) {
      if (mounted) {
        // سجل لأغراض التصحيح
        print(
            "Task saved successfully with course: ${_controller.selectedCourse?.courseName ?? 'None'}");
        print("Task has reminder: ${_controller.hasReminder ? 'Yes' : 'No'}");
        if (_controller.hasReminder && _controller.reminderDateTime != null) {
          print("Reminder time: ${_controller.reminderDateTime}");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              TasksStrings.saveSuccess,
              style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
        widget.onSaveComplete(true);
      }
    } else {
      // إظهار رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _controller.titleError ?? TasksStrings.saveError,
              style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // إضافة وسم جديد
  void _showAddTagDialog(BuildContext context) {
    final TextEditingController tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TasksStrings.newTag,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4338CA),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: tagController,
                  labelText: TasksStrings.addTag,
                  icon: TasksIcons.tag,
                  autoFocus: true,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: Text(
                        TasksStrings.cancel,
                        style: TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (tagController.text.trim().isNotEmpty) {
                          _controller.addTag(tagController.text.trim());
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4338CA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        TasksStrings.add,
                        style: TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // عنصر مقبض السحب
  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
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
    );
  }

  // بناء شريط العنوان
  Widget _buildToolbar({
    required String title,
    required VoidCallback onBackPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الصف الأول: زر الرجوع والعنوان
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر الرجوع
              GestureDetector(
                onTap: onBackPressed,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.0,
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
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
        ),
        const SizedBox(height: 16),

        // وصف مع أيقونة
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF4338CA).withOpacity(0.1),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF4338CA),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "قم بإدخال تفاصيل المهمة وحدد المواعيد والأولويات",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Divider(height: 1, thickness: 1, color: Color(0xFFE3E0F8)),
      ],
    );
  }

  // بناء حقل إدخال
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? errorText,
    IconData? icon,
    String? hintText,
    TextInputType? keyboardType,
    bool autoFocus = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الحقل
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              labelText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // حقل الإدخال
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? const Color(0xFFEC4899)
                    : const Color(0xFF4338CA).withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // أيقونة حقل الإدخال
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
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
                  child: Icon(
                    icon ?? Icons.text_fields,
                    color: controller.text.isEmpty
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF4338CA),
                    size: 16,
                  ),
                ),

                // حقل الإدخال نفسه
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    autofocus: autoFocus,
                    style: const TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      errorText: null,
                      errorStyle: const TextStyle(
                        height: 0,
                        fontSize: 0,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // عرض رسالة الخطأ إن وجدت
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Color(0xFFEC4899),
                  fontSize: 12,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
        ],
      ),
    );
  }

  // بناء حقل الوصف متعدد الأسطر
  Widget _buildDescriptionField({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    String? hintText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الحقل
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              labelText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // حقل الإدخال
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4338CA).withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة حقل الإدخال
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  child: Icon(
                    icon ?? Icons.text_fields,
                    color: controller.text.isEmpty
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF4338CA),
                    size: 16,
                  ),
                ),

                // حقل الإدخال نفسه
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: 5,
                    style: const TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // عداد الكلمات والأحرف
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: Text(
              "${_controller.descriptionController.text.split(' ').where((word) => word.isNotEmpty).length}${TasksStrings.wordCount}"
              "${_controller.descriptionController.text.length}${TasksStrings.charCount}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء منتقي التاريخ والوقت
  Widget _buildDueDateTimePicker() {
    final DateTime now = DateTime.now();
    final bool isDateInPast =
        _controller.dueDate.isBefore(DateTime(now.year, now.month, now.day)) &&
            widget.task == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الحقل
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              TasksStrings.dueDate,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // منتقي التاريخ والوقت
          Row(
            children: [
              // التاريخ
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: widget.task != null
                          ? _controller.dueDate
                          : DateTime.now(),
                      firstDate: widget.task != null
                          ? DateTime.now().subtract(Duration(days: 365))
                          : DateTime
                              .now(), // لا يسمح بتواريخ في الماضي للمهام الجديدة
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: const Color(0xFF4338CA),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() {
                        _dueDateError =
                            null; // إعادة ضبط الخطأ عند تحديد تاريخ جديد
                      });
                      _controller.setDueDate(date);
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _dueDateError != null || isDateInPast
                            ? const Color(0xFFEC4899)
                            : const Color(0xFF4338CA).withOpacity(0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // أيقونة التاريخ
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
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
                          child: Icon(
                            TasksIcons.calendar,
                            color: _dueDateError != null || isDateInPast
                                ? const Color(0xFFEC4899)
                                : const Color(0xFF4338CA),
                            size: 16,
                          ),
                        ),

                        // التاريخ
                        Expanded(
                          child: Text(
                            DateFormat('yyyy-MM-dd')
                                .format(_controller.dueDate),
                            style: TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              fontSize: 14,
                              color: _dueDateError != null || isDateInPast
                                  ? const Color(0xFFEC4899)
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),

                        // أيقونة السهم
                        Container(
                          margin: const EdgeInsets.only(left: 4, right: 8),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF4338CA),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // الوقت
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _controller.dueTime,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: const Color(0xFF4338CA),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      setState(() {
                        _dueDateError =
                            null; // إعادة ضبط الخطأ عند تحديد وقت جديد
                      });
                      _controller.setDueTime(time);
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _dueDateError != null
                            ? const Color(0xFFEC4899)
                            : const Color(0xFF4338CA).withOpacity(0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // أيقونة الوقت
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
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
                          child: Icon(
                            TasksIcons.time,
                            color: _dueDateError != null
                                ? const Color(0xFFEC4899)
                                : const Color(0xFF4338CA),
                            size: 16,
                          ),
                        ),

                        // الوقت
                        Expanded(
                          child: Text(
                            _controller.dueTime.format(context),
                            style: TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              fontSize: 14,
                              color: _dueDateError != null
                                  ? const Color(0xFFEC4899)
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // عرض رسالة الخطأ
          if (_dueDateError != null || isDateInPast)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                _dueDateError ?? "لا يمكن تحديد تاريخ في الماضي",
                style: const TextStyle(
                  color: Color(0xFFEC4899),
                  fontSize: 12,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
        ],
      ),
    );
  }

  // بناء قسم الأولوية
  Widget _buildPrioritySection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              TasksStrings.priority,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // بطاقة تحوي خيارات الأولوية
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4338CA).withOpacity(0.2),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TasksStrings.highPriority,
                  TasksStrings.mediumPriority,
                  TasksStrings.lowPriority,
                ].map((priority) {
                  final isSelected = _controller.priority == priority;
                  final priorityColor = TasksColors.getPriorityColor(priority);
                  final icon = TasksIcons.getPriorityIcon(priority);

                  return Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: _buildChoiceChip(
                      label: priority,
                      icon: icon,
                      isSelected: isSelected,
                      color: priorityColor,
                      onSelected: (selected) {
                        if (selected) {
                          _controller.setPriority(priority);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء قسم اختيار المادة
  Widget _buildCourseSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              TasksStrings.course,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // نستخدم أزرار اختيار بدلاً من القائمة المنسدلة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4338CA).withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة المادة والعنوان
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
                        TasksIcons.course,
                        color: Color(0xFF4338CA),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedCourseId == null
                          ? TasksStrings.selectCourse
                          : "المادة المختارة: ${_controller.selectedCourse?.courseName}",
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedCourseId == null
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF374151),
                        fontWeight: _selectedCourseId != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ],
                ),

                // قائمة الاختيارات
                const SizedBox(height: 10),

                _controller.availableCourses.isEmpty
                    ? Center(
                        child: Text(
                          "لا توجد مقررات متاحة",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // خيار "بدون مادة"
                          _buildCourseChoiceChip(
                            label: TasksStrings.noCourse,
                            isSelected: _selectedCourseId == null,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCourseId = null;
                                  _controller.setSelectedCourse(null);
                                  print("Selected course: none");
                                });
                              }
                            },
                          ),

                          // خيارات المواد المتاحة
                          ..._controller.availableCourses
                              .map((course) => _buildCourseChoiceChip(
                                    label: course.courseName,
                                    isSelected: _selectedCourseId == course.id,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedCourseId = course.id;
                                          _controller.setSelectedCourse(course);
                                          print(
                                              "Selected course: ${course.courseName} (${course.id})");
                                        });
                                      }
                                    },
                                  )),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء رقاقة اختيار المادة
  Widget _buildCourseChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'SYMBIOAR+LT',
          fontSize: 13,
          color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF374151),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFF5F3FF),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onSelected: onSelected,
    );
  }

  // بناء قسم التذكير - تم تحديثه لمعالجة مشكلة التجاوز
  Widget _buildReminderSection() {
    // تحقق من وجود أخطاء في وقت التذكير
    bool hasReminderTimeError = _controller.hasReminder &&
        _controller.reminderDateTime != null &&
        _controller.reminderDateTime!.isAfter(_controller.dueDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              TasksStrings.reminder,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // مفتاح تفعيل التذكير
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4338CA).withOpacity(0.2),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
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
                    TasksIcons.reminder,
                    color: Color(0xFF4338CA),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    TasksStrings.enableReminder,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
                Switch(
                  value: _controller.hasReminder,
                  onChanged: (value) {
                    _controller.toggleReminder(value);
                    if (value) {
                      // إذا تم تفعيل التذكير، نضبط وقت التذكير افتراضيًا إلى ساعة قبل وقت التسليم
                      final reminderTime =
                          _controller.dueDate.subtract(Duration(hours: 1));
                      if (reminderTime.isAfter(DateTime.now())) {
                        _controller.setReminderDateTime(reminderTime);
                      } else {
                        // إذا كان الوقت في الماضي، نضبط التذكير إلى الوقت الحالي
                        _controller.setReminderDateTime(
                            DateTime.now().add(Duration(minutes: 5)));
                      }
                    }
                  },
                  activeColor: const Color(0xFF4338CA),
                ),
              ],
            ),
          ),

          if (_controller.hasReminder) ...[
            const SizedBox(height: 12),
            // إصلاح مشكلة تجاوز المحتوى عبر استخدام محتوى قابل للتمرير
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 70), // تحديد ارتفاع أقصى
              child: GestureDetector(
                onTap: () async {
                  // تحديد التاريخ الأدنى للتذكير (الوقت الحالي)
                  final DateTime now = DateTime.now();

                  // تحديد التاريخ الأقصى للتذكير (وقت التسليم)
                  final DateTime maxDate = _controller.dueDate;

                  // التأكد من أن التاريخ الافتراضي بين الحد الأدنى والأقصى
                  DateTime initialDate = _controller.reminderDateTime ?? now;
                  if (initialDate.isAfter(maxDate)) {
                    initialDate = maxDate;
                  }
                  if (initialDate.isBefore(now)) {
                    initialDate = now;
                  }

                  final date = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: now,
                    lastDate: maxDate,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF4338CA),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (date != null) {
                    // ضمان أن الوقت لا يتجاوز وقت التسليم
                    TimeOfDay initialTimeOfDay;
                    if (date.year == maxDate.year &&
                        date.month == maxDate.month &&
                        date.day == maxDate.day) {
                      // إذا كان نفس اليوم، يجب أن يكون الوقت قبل وقت التسليم
                      initialTimeOfDay = TimeOfDay(
                          hour: maxDate.hour > 0 ? maxDate.hour - 1 : 0,
                          minute: maxDate.minute);
                    } else {
                      // إذا كان يوم مختلف، يمكن اختيار أي وقت
                      initialTimeOfDay = TimeOfDay.fromDateTime(
                          _controller.reminderDateTime ?? now);
                    }

                    final time = await showTimePicker(
                      context: context,
                      initialTime: initialTimeOfDay,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF4338CA),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (time != null) {
                      final reminderDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );

                      // التأكد من أن وقت التذكير قبل وقت التسليم
                      if (reminderDateTime.isBefore(_controller.dueDate)) {
                        _controller.setReminderDateTime(reminderDateTime);
                        // إعادة ضبط الخطأ
                        setState(() {
                          _dueDateError = null;
                        });
                      } else {
                        // تحديث خطأ التذكير
                        setState(() {
                          _dueDateError =
                              "تاريخ التذكير يجب أن يكون قبل تاريخ التسليم";
                        });
                      }
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasReminderTimeError
                          ? const Color(0xFFEC4899)
                          : const Color(0xFF4338CA).withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: hasReminderTimeError
                                ? const Color(0xFFEC4899).withOpacity(0.2)
                                : const Color(0xFF4338CA).withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          TasksIcons.time,
                          color: hasReminderTimeError
                              ? const Color(0xFFEC4899)
                              : const Color(0xFF4338CA),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              TasksStrings.reminderTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _controller.reminderDateTime != null
                                  ? DateFormat('yyyy-MM-dd – HH:mm')
                                      .format(_controller.reminderDateTime!)
                                  : TasksStrings.reminderTime,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: _controller.reminderDateTime != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: hasReminderTimeError
                                    ? const Color(0xFFEC4899)
                                    : _controller.reminderDateTime != null
                                        ? const Color(0xFF4338CA)
                                        : const Color(0xFF9CA3AF),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF4338CA),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // رسالة خطأ وقت التذكير
            if (hasReminderTimeError)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: Text(
                  "تاريخ التذكير يجب أن يكون قبل تاريخ التسليم",
                  style: const TextStyle(
                    color: Color(0xFFEC4899),
                    fontSize: 12,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // بناء قسم الوسوم
  Widget _buildTagsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              TasksStrings.tags,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // بطاقة تحوي الوسوم
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4338CA).withOpacity(0.2),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_controller.tags.isEmpty)
                  Text(
                    "لم يتم إضافة وسوم بعد",
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF9CA3AF),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    ..._controller.tags.map((tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              color: Color(0xFF4338CA),
                              fontSize: 13,
                            ),
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF6366F1),
                          ),
                          backgroundColor: const Color(0xFFF5F3FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          visualDensity: VisualDensity.compact,
                          deleteButtonTooltipMessage: "إزالة",
                          onDeleted: () => _controller.removeTag(tag),
                        )),
                    ActionChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add,
                            size: 14,
                            color: Color(0xFF4338CA),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            TasksStrings.addTag,
                            style: const TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              color: Color(0xFF4338CA),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFF6366F1),
                        width: 1.0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _showAddTagDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء رقاقة اختيار محسنة
  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
    IconData? icon,
    Color? color,
  }) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? const Color(0xFF4338CA)
                  : color ?? const Color(0xFF374151),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: 13,
              color: isSelected
                  ? const Color(0xFF4338CA)
                  : const Color(0xFF374151),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: Colors.white,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onSelected: onSelected,
    );
  }

  // بناء زر رئيسي بتصميم محسّن
  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4338CA),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
