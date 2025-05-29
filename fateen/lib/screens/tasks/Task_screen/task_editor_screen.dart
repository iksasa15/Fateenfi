// lib/features/task_editor/screens/task_editor_screen.dart

import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../models/course.dart';
import '../controllers/task_editor_controller.dart';
import '../components/Editor/task_editor_header.dart';
import '../components/Editor/task_editor_field.dart';
import '../components/Editor/task_editor_description_field.dart';
import '../components/Editor/task_editor_date_picker.dart';
import '../components/Editor/task_editor_priority_selector.dart';
import '../components/Editor/task_editor_course_selector.dart';
import '../components/Editor/task_editor_reminder_section.dart';
import '../components/Editor/task_editor_tags_section.dart';
import '../components/Editor/task_editor_button.dart';
import '../constants/editor_strings.dart';

class TaskEditorScreen extends StatefulWidget {
  final Task? task;
  final List<String> categories;
  final Course? selectedCourse;
  final Function(bool) onSaveComplete;

  const TaskEditorScreen({
    Key? key,
    this.task,
    required this.categories,
    this.selectedCourse,
    required this.onSaveComplete,
  }) : super(key: key);

  @override
  _TaskEditorScreenState createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  late TaskEditorController _controller;
  String? _selectedCourseId;

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

  void _updateSelectedCourse(Course? course) {
    setState(() {
      _selectedCourseId = course?.id;
      _controller.setSelectedCourse(course);
    });
  }

  Future<void> _saveTask() async {
    final success = await _controller.saveTask();

    if (success) {
      if (mounted) {
        print(
            "Task saved successfully with course: ${_controller.selectedCourse?.courseName ?? 'None'}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              EditorStrings.saveSuccess,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _controller.titleError ?? EditorStrings.saveError,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                // Header with close button and title
                TaskEditorHeader(
                  title: widget.task == null
                      ? EditorStrings.addTask
                      : EditorStrings.editTask,
                  onClose: () => Navigator.pop(context),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        TaskEditorField(
                          controller: _controller.titleController,
                          labelText: EditorStrings.taskTitle,
                          errorText: _controller.titleError,
                          hintText: EditorStrings.enterTaskTitle,
                        ),

                        const SizedBox(height: 16),

                        // Description field
                        TaskEditorDescriptionField(
                          controller: _controller.descriptionController,
                          labelText: EditorStrings.taskDescription,
                          hintText: EditorStrings.taskDescriptionHint,
                        ),

                        const SizedBox(height: 20),

                        // Date & Time picker
                        TaskEditorDatePicker(
                          dueDate: _controller.dueDate,
                          dueTime: _controller.dueTime,
                          onDateChanged: _controller.setDueDate,
                          onTimeChanged: _controller.setDueTime,
                        ),

                        const SizedBox(height: 20),

                        // Priority selector
                        TaskEditorPrioritySelector(
                          selectedPriority: _controller.priority,
                          onPriorityChanged: _controller.setPriority,
                        ),

                        const SizedBox(height: 20),

                        // Course selector (if available)
                        if (_controller.availableCourses.isNotEmpty)
                          TaskEditorCourseSelector(
                            availableCourses: _controller.availableCourses,
                            selectedCourseId: _selectedCourseId,
                            selectedCourse: _controller.selectedCourse,
                            onCourseSelected: _updateSelectedCourse,
                          ),

                        const SizedBox(height: 20),

                        // Reminder section
                        TaskEditorReminderSection(
                          hasReminder: _controller.hasReminder,
                          reminderDateTime: _controller.reminderDateTime,
                          dueDate: _controller.dueDate,
                          onReminderToggled: _controller.toggleReminder,
                          onReminderDateTimeChanged:
                              _controller.setReminderDateTime,
                        ),

                        const SizedBox(height: 20),

                        // Tags section
                        TaskEditorTagsSection(
                          tags: _controller.tags,
                          onTagAdded: _controller.addTag,
                          onTagRemoved: _controller.removeTag,
                        ),

                        const SizedBox(height: 28),

                        // Save button
                        TaskEditorButton(
                          text: widget.task == null
                              ? EditorStrings.add
                              : EditorStrings.save,
                          isLoading: _controller.isLoading,
                          onPressed: _saveTask,
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
  }
}
