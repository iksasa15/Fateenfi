// lib/features/task_editor/controllers/task_editor_controller.dart

import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../models/course.dart';
import '../services/tasks_firebase_service.dart';
import '../constants/editor_strings.dart';
import '../services/notifications_service.dart';

class TaskEditorController {
  final TasksFirebaseService _service = TasksFirebaseService();
  final NotificationsService _notificationsService = NotificationsService();

  // Input controllers
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  // Editor state
  bool isLoading = false;
  String? titleError;
  Task? existingTask;

  // Task data
  String priority = EditorStrings.mediumPriority;
  DateTime dueDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay dueTime = TimeOfDay.now();
  bool hasReminder = false;
  DateTime? reminderDateTime;
  List<String> tags = [];
  Course? selectedCourse;
  List<Course> availableCourses = [];

  // State change notifier
  final ValueNotifier<bool> stateChanged = ValueNotifier<bool>(false);

  // Initialize the controller
  Future<void> init(Task? task, Course? initialCourse) async {
    existingTask = task;

    // Initialize text controllers
    titleController = TextEditingController(text: task?.name ?? '');
    descriptionController =
        TextEditingController(text: task?.description ?? '');

    // Set initial data
    priority = task?.priority ?? EditorStrings.mediumPriority;

    if (task != null) {
      dueDate = task.dueDate;
      dueTime = TimeOfDay(hour: task.dueDate.hour, minute: task.dueDate.minute);
      reminderDateTime = task.reminderTime;
      hasReminder = reminderDateTime != null;
      tags = List<String>.from(task.tags);
      selectedCourse = task.course;
    } else {
      // لتأكيد أن المهمة الجديدة لا تكون في الماضي
      final now = DateTime.now();
      if (dueDate.isBefore(now)) {
        dueDate =
            DateTime(now.year, now.month, now.day, now.hour + 1, now.minute);
        dueTime = TimeOfDay(hour: now.hour + 1, minute: now.minute);
      }
    }

    // التأكد من تهيئة خدمة الإشعارات
    await _notificationsService.init();

    // Load available courses
    try {
      availableCourses = await _service.getCourses();

      // If no course is selected but there is an initial course, use it
      if (selectedCourse == null && initialCourse != null) {
        selectedCourse = initialCourse;
      }

      // Ensure selected course exists in available courses
      if (selectedCourse != null) {
        final exists = availableCourses.any((c) => c.id == selectedCourse!.id);
        if (!exists) {
          selectedCourse = null;
        }
      }

      _updateState();
    } catch (e) {
      print('Error loading courses: $e');
    }
  }

  // Clean up resources
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }

  // Set priority
  void setPriority(String newPriority) {
    priority = newPriority;
    _updateState();
  }

  // Set due date
  void setDueDate(DateTime date) {
    dueDate = DateTime(
      date.year,
      date.month,
      date.day,
      dueTime.hour,
      dueTime.minute,
    );

    // إذا كان هناك تذكير، تأكد من أنه ليس بعد وقت التسليم الجديد
    if (hasReminder && reminderDateTime != null) {
      if (reminderDateTime!.isAfter(dueDate)) {
        // تعيين وقت التذكير إلى ساعة قبل تاريخ التسليم الجديد
        reminderDateTime = dueDate.subtract(Duration(hours: 1));
      }
    }

    _updateState();
  }

  // Set due time
  void setDueTime(TimeOfDay time) {
    dueTime = time;
    dueDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      time.hour,
      time.minute,
    );

    // إذا كان هناك تذكير، تأكد من أنه ليس بعد وقت التسليم الجديد
    if (hasReminder && reminderDateTime != null) {
      if (reminderDateTime!.isAfter(dueDate)) {
        // تعيين وقت التذكير إلى ساعة قبل تاريخ التسليم الجديد
        reminderDateTime = dueDate.subtract(Duration(hours: 1));
      }
    }

    _updateState();
  }

  // Toggle reminder
  void toggleReminder(bool value) {
    hasReminder = value;
    if (value && reminderDateTime == null) {
      // Set default reminder time 1 hour before due date
      reminderDateTime = dueDate.subtract(Duration(hours: 1));

      // تأكد من أن وقت التذكير ليس في الماضي
      final now = DateTime.now();
      if (reminderDateTime!.isBefore(now)) {
        // إذا كان في الماضي، اضبطه إلى 5 دقائق من الآن
        reminderDateTime = now.add(Duration(minutes: 5));
      }
    }
    _updateState();
  }

  // Set reminder date and time
  void setReminderDateTime(DateTime dateTime) {
    reminderDateTime = dateTime;
    _updateState();
  }

  // Set selected course
  void setSelectedCourse(Course? course) {
    print(
        'Setting selected course: ${course?.courseName ?? "None"} [ID: ${course?.id ?? "null"}]');
    selectedCourse = course;
    _updateState();
  }

  // Add tag
  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
      _updateState();
    }
  }

  // Remove tag
  void removeTag(String tag) {
    tags.remove(tag);
    _updateState();
  }

  // Validate task data
  bool _validateTaskData() {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      titleError = EditorStrings.emptyTitleError;
      _updateState();
      return false;
    }

    // التحقق من أن تاريخ التسليم ليس في الماضي للمهام الجديدة
    if (existingTask == null) {
      final now = DateTime.now();
      if (dueDate.isBefore(now)) {
        titleError = "لا يمكن تحديد تاريخ تسليم في الماضي";
        _updateState();
        return false;
      }
    }

    // التحقق من أن وقت التذكير قبل وقت التسليم
    if (hasReminder && reminderDateTime != null) {
      if (reminderDateTime!.isAfter(dueDate)) {
        titleError = "وقت التذكير يجب أن يكون قبل وقت التسليم";
        _updateState();
        return false;
      }

      // التحقق من أن وقت التذكير ليس في الماضي
      final now = DateTime.now();
      if (reminderDateTime!.isBefore(now)) {
        titleError = "لا يمكن تحديد وقت تذكير في الماضي";
        _updateState();
        return false;
      }
    }

    titleError = null;
    return true;
  }

  // Save task
  Future<bool> saveTask() async {
    // Validate data
    if (!_validateTaskData()) {
      return false;
    }

    isLoading = true;
    _updateState();

    try {
      // Prepare due date
      final finalDueDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        dueTime.hour,
        dueTime.minute,
      );

      // Save selected course and its ID before updating
      final Course? courseBeforeSaving = selectedCourse;
      final String? newCourseId = selectedCourse?.id;

      print(
          'Saving task with course: ${selectedCourse?.courseName ?? "None"} [ID: ${newCourseId ?? "null"}]');

      if (existingTask == null) {
        // Create new task
        final Task newTask = await Task.createNewTask(
          name: titleController.text.trim(),
          description: descriptionController.text.trim(),
          dueDate: finalDueDate,
          course: selectedCourse,
          reminderTime: hasReminder ? reminderDateTime : null,
          status: EditorStrings.statusInProgress,
          priority: priority,
          tags: tags,
        );

        // جدولة التذكير إذا كان مفعلاً
        if (hasReminder && reminderDateTime != null) {
          print('Scheduling reminder for new task at: $reminderDateTime');
          await newTask.scheduleReminder();
        }
      } else {
        // Log changes for debugging
        final String oldCourseId = existingTask!.courseId ?? "null";
        print(
            'Updating task - Old courseId: $oldCourseId, New courseId: ${newCourseId ?? "null"}');

        // تذكر حالة التذكير القديمة
        final bool hadReminderBefore = existingTask!.reminderTime != null;
        final DateTime? oldReminderTime = existingTask!.reminderTime;

        // Update existing task
        await existingTask!.updateTask(
          newName: titleController.text.trim(),
          newDescription: descriptionController.text.trim(),
          newDueDate: finalDueDate,
          newReminderTime: hasReminder ? reminderDateTime : null,
          newPriority: priority,
          newTags: tags,
          newCourse: selectedCourse,
        );

        // تحديث التذكير إذا تغير
        if (hasReminder) {
          if (!hadReminderBefore ||
              (reminderDateTime != null &&
                  oldReminderTime != reminderDateTime)) {
            print(
                'Updated reminder: scheduling new reminder at $reminderDateTime');
            await existingTask!.scheduleReminder();
          }
        } else if (hadReminderBefore) {
          print('Reminder disabled: cancelling old reminder');
          await existingTask!.cancelReminder();
        }

        // Ensure courseId is updated directly if changed
        if (oldCourseId != (newCourseId ?? "null")) {
          print('Course ID changed, updating directly in database');

          if (selectedCourse != null) {
            await existingTask!.assignToCourse(selectedCourse!);
            print('Assigned task to course: ${selectedCourse!.courseName}');
          } else {
            await existingTask!.removeFromCourse();
            print('Removed task from course');
          }
        }
      }

      isLoading = false;
      _updateState();
      return true;
    } catch (e) {
      print('Error saving task: $e');
      isLoading = false;
      _updateState();
      return false;
    }
  }

  // Notify listeners of state changes
  void _updateState() {
    stateChanged.value = !stateChanged.value;
  }
}
