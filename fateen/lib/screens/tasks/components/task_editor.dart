// lib/screens/tasks/components/task_editor.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/task.dart';
import '../../../models/course.dart';
import '../controllers/task_editor_controller.dart';
import '../constants/tasks_strings.dart';
import '../constants/tasks_icons.dart';
import '../../../core/constants/appColor.dart';
import '../../../core/constants/app_dimensions.dart';
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
  String? _selectedCourseId;
  String? _dueDateError;

  @override
  void initState() {
    super.initState();
    _controller = TaskEditorController();
    _controller.init(widget.task, widget.selectedCourse);

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
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.extraLargeRadius)),
        ),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
              horizontal: AppDimensions.sectionPadding,
              vertical: AppDimensions.extraLargeRadius),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
              boxShadow: [
                BoxShadow(
                  color: context.colorShadowColor,
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
              child: Column(
                children: [
                  _buildDragHandle(),
                  _buildToolbar(
                    title: widget.task == null
                        ? TasksStrings.addTask
                        : TasksStrings.editTask,
                    onBackPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppDimensions.defaultSpacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _controller.titleController,
                            labelText: TasksStrings.taskTitle,
                            errorText: _controller.titleError,
                            icon: TasksIcons.task,
                            hintText: TasksStrings.enterTaskTitle,
                          ),
                          SizedBox(height: AppDimensions.defaultSpacing),
                          _buildDescriptionField(
                            controller: _controller.descriptionController,
                            labelText: TasksStrings.taskDescription,
                            icon: TasksIcons.description,
                            hintText: TasksStrings.taskDescriptionHint,
                          ),
                          SizedBox(height: AppDimensions.largeSpacing),
                          _buildDueDateTimePicker(),
                          SizedBox(height: AppDimensions.largeSpacing),
                          _buildPrioritySection(),
                          SizedBox(height: AppDimensions.largeSpacing),
                          if (_controller.availableCourses.isNotEmpty)
                            _buildCourseSelector(),
                          SizedBox(height: AppDimensions.largeSpacing),
                          _buildReminderSection(),
                          SizedBox(height: AppDimensions.largeSpacing),
                          _buildTagsSection(),
                          SizedBox(height: AppDimensions.extraLargeSpacing - 4),
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
    setState(() {
      _dueDateError = null;
    });

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

    if (_controller.hasReminder && _controller.reminderDateTime != null) {
      if (_controller.reminderDateTime!.isAfter(_controller.dueDate)) {
        setState(() {
          _dueDateError = "تاريخ التذكير يجب أن يكون قبل تاريخ التسليم";
        });
        return;
      }
    }

    _saveTask();
  }

  Future<void> _saveTask() async {
    final success = await _controller.saveTask();

    if (success) {
      if (mounted) {
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.smallRadius)),
            backgroundColor: context.colorSuccess,
          ),
        );

        Navigator.pop(context, true);
        widget.onSaveComplete(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _controller.titleError ?? TasksStrings.saveError,
              style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.smallRadius)),
            backgroundColor: context.colorError,
          ),
        );
      }
    }
  }

  void _showAddTagDialog(BuildContext context) {
    final TextEditingController tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
              horizontal: AppDimensions.sectionPadding,
              vertical: AppDimensions.extraLargeRadius),
          child: Container(
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
              boxShadow: [
                BoxShadow(
                  color: context.colorShadowColor,
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(AppDimensions.sectionPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TasksStrings.newTag,
                  style: TextStyle(
                    fontSize: AppDimensions.subtitleFontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: context.colorPrimaryDark,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                SizedBox(height: AppDimensions.defaultSpacing),
                _buildTextField(
                  controller: tagController,
                  labelText: TasksStrings.addTag,
                  icon: TasksIcons.tag,
                  autoFocus: true,
                ),
                SizedBox(height: AppDimensions.extraLargeSpacing - 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: context.colorTextSecondary,
                      ),
                      child: Text(
                        TasksStrings.cancel,
                        style: TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.smallSpacing),
                    ElevatedButton(
                      onPressed: () {
                        if (tagController.text.trim().isNotEmpty) {
                          _controller.addTag(tagController.text.trim());
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colorPrimaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.smallRadius),
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

  Widget _buildDragHandle() {
    return Padding(
      padding: EdgeInsets.only(
          top: AppDimensions.smallSpacing + 4,
          bottom: AppDimensions.smallSpacing + 2),
      child: Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: context.colorDivider,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar({
    required String title,
    required VoidCallback onBackPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: AppDimensions.defaultSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onBackPressed,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius + 2),
                    border: Border.all(
                      color: context.colorDivider,
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    Icons.close,
                    color: context.colorPrimaryDark,
                    size: 18,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.defaultSpacing - 2,
                    vertical: AppDimensions.smallSpacing - 1),
                decoration: BoxDecoration(
                  color: context.colorSurface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius + 2),
                  border: Border.all(
                    color: context.colorDivider,
                    width: 1.0,
                  ),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppDimensions.smallBodyFontSize + 1,
                    fontWeight: FontWeight.bold,
                    color: context.colorPrimaryDark,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.defaultSpacing),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: AppDimensions.defaultSpacing),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.smallSpacing + 4,
                vertical: AppDimensions.smallSpacing + 2),
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius:
                  BorderRadius.circular(AppDimensions.smallRadius + 2),
              border: Border.all(
                color: context.colorPrimaryDark.withOpacity(0.1),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.colorPrimaryDark,
                  size: 18,
                ),
                SizedBox(width: AppDimensions.smallSpacing),
                Expanded(
                  child: Text(
                    "قم بإدخال تفاصيل المهمة وحدد المواعيد والأولويات",
                    style: TextStyle(
                      fontSize: AppDimensions.smallLabelFontSize,
                      fontWeight: FontWeight.w500,
                      color: context.colorTextPrimary,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppDimensions.defaultSpacing),
        Divider(height: 1, thickness: 1, color: context.colorPrimaryExtraLight),
      ],
    );
  }

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
      margin: EdgeInsets.only(bottom: AppDimensions.defaultSpacing - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              labelText,
              style: TextStyle(
                fontSize: AppDimensions.labelFontSize,
                fontWeight: FontWeight.w600,
                color: context.colorTextPrimary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          Container(
            height: AppDimensions.extraSmallButtonHeight + 2,
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
              border: Border.all(
                color: errorText != null
                    ? context.colorAccent
                    : context.colorPrimaryDark.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppDimensions.smallSpacing + 2),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius + 2),
                    border: Border.all(
                      color: context.colorPrimaryDark.withOpacity(0.1),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    icon ?? Icons.text_fields,
                    color: controller.text.isEmpty
                        ? context.colorPrimaryLight
                        : context.colorPrimaryDark,
                    size: 16,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    autofocus: autoFocus,
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: AppDimensions.smallButtonFontSize - 1,
                      color: context.colorTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: context.colorTextHint,
                        fontSize: AppDimensions.smallButtonFontSize - 1,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      errorText: null,
                      errorStyle: const TextStyle(
                        height: 0,
                        fontSize: 0,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: AppDimensions.defaultSpacing - 2,
                      ),
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: context.colorSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (errorText != null)
            Padding(
              padding: EdgeInsets.only(top: 4, right: 4),
              child: Text(
                errorText,
                style: TextStyle(
                  color: context.colorAccent,
                  fontSize: AppDimensions.smallLabelFontSize - 1,
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
      margin: EdgeInsets.only(bottom: AppDimensions.defaultSpacing - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الحقل
          Padding(
            padding: EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              labelText,
              style: TextStyle(
                fontSize: AppDimensions.labelFontSize,
                fontWeight: FontWeight.w600,
                color: context.colorTextPrimary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // حقل الإدخال
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
              border: Border.all(
                color: context.colorPrimaryDark.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة حقل الإدخال
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppDimensions.smallSpacing + 2,
                      vertical: AppDimensions.smallSpacing + 2),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius + 2),
                    border: Border.all(
                      color: context.colorPrimaryDark.withOpacity(0.1),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    icon ?? Icons.text_fields,
                    color: controller.text.isEmpty
                        ? context.colorPrimaryLight
                        : context.colorPrimaryDark,
                    size: 16,
                  ),
                ),

                // حقل الإدخال نفسه
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: 5,
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: AppDimensions.smallButtonFontSize - 1,
                      color: context.colorTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: context.colorTextHint,
                        fontSize: AppDimensions.smallButtonFontSize - 1,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: AppDimensions.defaultSpacing - 2,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: context.colorSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // عداد الكلمات والأحرف
          Padding(
            padding: EdgeInsets.only(top: 4, right: 4),
            child: Text(
              "${_controller.descriptionController.text.split(' ').where((word) => word.isNotEmpty).length}${TasksStrings.wordCount}"
              "${_controller.descriptionController.text.length}${TasksStrings.charCount}",
              style: TextStyle(
                color: context.colorTextSecondary,
                fontSize: AppDimensions.smallLabelFontSize - 1,
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
      margin: EdgeInsets.only(bottom: AppDimensions.defaultSpacing - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الحقل
          Padding(
            padding: EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              TasksStrings.dueDate,
              style: TextStyle(
                fontSize: AppDimensions.labelFontSize,
                fontWeight: FontWeight.w600,
                color: context.colorTextPrimary,
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
                          : DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: context.colorPrimaryDark,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() {
                        _dueDateError = null;
                      });
                      _controller.setDueDate(date);
                    }
                  },
                  child: Container(
                    height: AppDimensions.extraSmallButtonHeight + 2,
                    decoration: BoxDecoration(
                      color: context.colorSurface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.mediumRadius),
                      border: Border.all(
                        color: _dueDateError != null || isDateInPast
                            ? context.colorAccent
                            : context.colorPrimaryDark.withOpacity(0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // أيقونة التاريخ
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: AppDimensions.smallSpacing + 2),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: context.colorSurface,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.smallRadius + 2),
                            border: Border.all(
                              color: context.colorPrimaryDark.withOpacity(0.1),
                              width: 1.0,
                            ),
                          ),
                          child: Icon(
                            TasksIcons.calendar,
                            color: _dueDateError != null || isDateInPast
                                ? context.colorAccent
                                : context.colorPrimaryDark,
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
                              fontSize: AppDimensions.smallButtonFontSize - 1,
                              color: _dueDateError != null || isDateInPast
                                  ? context.colorAccent
                                  : context.colorTextPrimary,
                            ),
                          ),
                        ),

                        // أيقونة السهم
                        Container(
                          margin: EdgeInsets.only(
                              left: 4, right: AppDimensions.smallSpacing),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: context.colorPrimaryDark,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: AppDimensions.smallSpacing),

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
                              primary: context.colorPrimaryDark,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      setState(() {
                        _dueDateError = null;
                      });
                      _controller.setDueTime(time);
                    }
                  },
                  child: Container(
                    height: AppDimensions.extraSmallButtonHeight + 2,
                    decoration: BoxDecoration(
                      color: context.colorSurface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.mediumRadius),
                      border: Border.all(
                        color: _dueDateError != null
                            ? context.colorAccent
                            : context.colorPrimaryDark.withOpacity(0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // أيقونة الوقت
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: AppDimensions.smallSpacing + 2),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: context.colorSurface,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.smallRadius + 2),
                            border: Border.all(
                              color: context.colorPrimaryDark.withOpacity(0.1),
                              width: 1.0,
                            ),
                          ),
                          child: Icon(
                            TasksIcons.time,
                            color: _dueDateError != null
                                ? context.colorAccent
                                : context.colorPrimaryDark,
                            size: 16,
                          ),
                        ),

                        // الوقت
                        Expanded(
                          child: Text(
                            _controller.dueTime.format(context),
                            style: TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              fontSize: AppDimensions.smallButtonFontSize - 1,
                              color: _dueDateError != null
                                  ? context.colorAccent
                                  : context.colorTextPrimary,
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
              padding: EdgeInsets.only(top: 4, right: 4),
              child: Text(
                _dueDateError ?? "لا يمكن تحديد تاريخ في الماضي",
                style: TextStyle(
                  color: context.colorAccent,
                  fontSize: AppDimensions.smallLabelFontSize - 1,
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
      margin: EdgeInsets.only(bottom: AppDimensions.defaultSpacing - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              TasksStrings.priority,
              style: TextStyle(
                fontSize: AppDimensions.labelFontSize,
                fontWeight: FontWeight.w600,
                color: context.colorTextPrimary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // بطاقة تحوي خيارات الأولوية
          Container(
            width: double.infinity,
            height: AppDimensions.buttonHeight + 4,
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
              border: Border.all(
                color: context.colorPrimaryDark.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.smallSpacing + 2,
                vertical: AppDimensions.smallSpacing),
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
                  final priorityColor = _getPriorityColor(context, priority);
                  final icon = TasksIcons.getPriorityIcon(priority);

                  return Padding(
                    padding: EdgeInsets.only(left: 5),
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
      margin: EdgeInsets.only(bottom: AppDimensions.defaultSpacing - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              TasksStrings.course,
              style: TextStyle(
                fontSize: AppDimensions.labelFontSize,
                fontWeight: FontWeight.w600,
                color: context.colorTextPrimary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // نستخدم أزرار اختيار بدلاً من القائمة المنسدلة
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                vertical: AppDimensions.smallSpacing + 2,
                horizontal: AppDimensions.smallSpacing + 4),
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
              border: Border.all(
                color: context.colorPrimaryDark.withOpacity(0.2),
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
                        color: context.colorSurface,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.smallRadius + 2),
                        border: Border.all(
                          color: context.colorPrimaryDark.withOpacity(0.1),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        TasksIcons.course,
                        color: context.colorPrimaryDark,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: AppDimensions.smallSpacing + 2),
                    Text(
                      _selectedCourseId == null
                          ? TasksStrings.selectCourse
                          : "المادة المختارة: ${_controller.selectedCourse?.courseName}",
                      style: TextStyle(
                        fontSize: AppDimensions.smallButtonFontSize - 1,
                        color: _selectedCourseId == null
                            ? context.colorTextHint
                            : context.colorTextPrimary,
                        fontWeight: _selectedCourseId != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ],
                ),

                // قائمة الاختيارات
                SizedBox(height: AppDimensions.smallSpacing + 2),

                _controller.availableCourses.isEmpty
                    ? Center(
                        child: Text(
                          "لا توجد مقررات متاحة",
                          style: TextStyle(
                            fontSize: AppDimensions.smallButtonFontSize - 1,
                            color: context.colorTextSecondary,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: AppDimensions.smallSpacing,
                        runSpacing: AppDimensions.smallSpacing,
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
          fontSize: AppDimensions.smallLabelFontSize,
          color:
              isSelected ? context.colorPrimaryDark : context.colorTextPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: context.colorPrimaryPale,
      backgroundColor: context.colorSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        side: BorderSide(
          color: isSelected ? context.colorPrimaryLight : context.colorDivider,
          width: 1.0,
        ),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.smallSpacing + 4,
          vertical: AppDimensions.smallSpacing),
      onSelected: onSelected,
    );
  }

  // بناء قسم التذكير
  Widget _buildReminderSection() {
    // تحقق من وجود أخطاء في وقت التذكير
    bool hasReminderTimeError = _controller.hasReminder &&
        _controller.reminderDateTime != null &&
        _controller.reminderDateTime!.isAfter(_controller.dueDate);

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.defaultSpacing - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              TasksStrings.reminder,
              style: TextStyle(
                fontSize: AppDimensions.labelFontSize,
                fontWeight: FontWeight.w600,
                color: context.colorTextPrimary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // مفتاح تفعيل التذكير
          Container(
            width: double.infinity,
            height: AppDimensions.extraSmallButtonHeight + 2,
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
              border: Border.all(
                color: context.colorPrimaryDark.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.smallSpacing + 2),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius + 2),
                    border: Border.all(
                      color: context.colorPrimaryDark.withOpacity(0.1),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    TasksIcons.reminder,
                    color: context.colorPrimaryDark,
                    size: 16,
                  ),
                ),
                SizedBox(width: AppDimensions.smallSpacing + 2),
                Expanded(
                  child: Text(
                    TasksStrings.enableReminder,
                    style: TextStyle(
                      fontSize: AppDimensions.smallButtonFontSize - 1,
                      color: context.colorTextPrimary,
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
                  activeColor: context.colorPrimaryDark,
                ),
              ],
            ),
          ),

          if (_controller.hasReminder) ...[
            SizedBox(height: AppDimensions.smallSpacing + 4),
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
                          colorScheme: ColorScheme.light(
                            primary: context.colorPrimaryDark,
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
                            colorScheme: ColorScheme.light(
                              primary: context.colorPrimaryDark,
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
                    color: context.colorSurface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.mediumRadius),
                    border: Border.all(
                      color: hasReminderTimeError
                          ? context.colorAccent
                          : context.colorPrimaryDark.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  padding: EdgeInsets.all(AppDimensions.smallSpacing + 4),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.colorSurface,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.smallRadius + 2),
                          border: Border.all(
                            color: hasReminderTimeError
                                ? context.colorAccent.withOpacity(0.2)
                                : context.colorPrimaryDark.withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          TasksIcons.time,
                          color: hasReminderTimeError
                              ? context.colorAccent
                              : context.colorPrimaryDark,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: AppDimensions.smallSpacing + 2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              TasksStrings.reminderTime,
                              style: TextStyle(
                                fontSize: AppDimensions.smallLabelFontSize - 1,
                                color: context.colorTextSecondary,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              _controller.reminderDateTime != null
                                  ? DateFormat('yyyy-MM-dd – HH:mm')
                                      .format(_controller.reminderDateTime!)
                                  : TasksStrings.reminderTime,
                              style: TextStyle(
                                fontSize: AppDimensions.smallButtonFontSize - 1,
                                fontWeight: _controller.reminderDateTime != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: hasReminderTimeError
                                    ? context.colorAccent
                                    : _controller.reminderDateTime != null
                                        ? context.colorPrimaryDark
                                        : context.colorTextHint,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.colorPrimaryDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // رسالة خطأ وقت التذكير
            if (hasReminderTimeError)
              Padding(
                padding: EdgeInsets.only(top: 4, right: 4),
                child: Text(
                  "تاريخ التذكير يجب أن يكون قبل تاريخ التسليم",
                  style: TextStyle(
                    color: context.colorAccent,
                    fontSize: AppDimensions.smallLabelFontSize - 1,
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
      margin: EdgeInsets.only(bottom: AppDimensions.defaultSpacing - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              TasksStrings.tags,
              style: TextStyle(
                fontSize: AppDimensions.labelFontSize,
                fontWeight: FontWeight.w600,
                color: context.colorTextPrimary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // بطاقة تحوي الوسوم
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
              border: Border.all(
                color: context.colorPrimaryDark.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            padding: EdgeInsets.all(AppDimensions.smallSpacing + 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_controller.tags.isEmpty)
                  Text(
                    "لم يتم إضافة وسوم بعد",
                    style: TextStyle(
                      fontSize: AppDimensions.smallButtonFontSize - 1,
                      color: context.colorTextHint,
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
                            style: TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              color: context.colorPrimaryDark,
                              fontSize: AppDimensions.smallLabelFontSize,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: context.colorPrimaryLight,
                          ),
                          backgroundColor: context.colorPrimaryPale,
                          padding: EdgeInsets.symmetric(
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
                          Icon(
                            Icons.add,
                            size: 14,
                            color: context.colorPrimaryDark,
                          ),
                          SizedBox(width: 4),
                          Text(
                            TasksStrings.addTag,
                            style: TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              color: context.colorPrimaryDark,
                              fontSize: AppDimensions.smallLabelFontSize,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: context.colorSurface,
                      side: BorderSide(
                        color: context.colorPrimaryLight,
                        width: 1.0,
                      ),
                      padding: EdgeInsets.symmetric(
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
                  ? context.colorPrimaryDark
                  : color ?? context.colorTextPrimary,
            ),
            SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: AppDimensions.smallLabelFontSize,
              color: isSelected
                  ? context.colorPrimaryDark
                  : context.colorTextPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: context.colorSurface,
      backgroundColor: context.colorSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius + 2),
        side: BorderSide(
          color: isSelected ? context.colorPrimaryLight : context.colorDivider,
          width: 1.0,
        ),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.smallSpacing + 4,
          vertical: AppDimensions.smallSpacing),
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
      height: AppDimensions.extraSmallButtonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorPrimaryDark.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorPrimaryDark,
          foregroundColor: Colors.white,
          disabledBackgroundColor: context.colorDisabledState,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
          ),
          padding:
              EdgeInsets.symmetric(horizontal: AppDimensions.defaultSpacing),
        ),
        child: isLoading
            ? SizedBox(
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
                    SizedBox(width: AppDimensions.smallSpacing),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimensions.smallButtonFontSize,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // طريقة مساعدة للحصول على لون الأولوية استناداً إلى نص الأولوية
  Color _getPriorityColor(BuildContext context, String priority) {
    switch (priority) {
      case 'عالية':
        return context.colorError;
      case 'متوسطة':
        return context.colorWarning;
      case 'منخفضة':
        return context.colorSuccess;
      default:
        return context.colorInfo;
    }
  }
}
