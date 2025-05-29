// lib/screens/tasks/controllers/tasks_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../models/course.dart';
import '../services/tasks_firebase_service.dart';
import '../constants/tasks_strings.dart';
import '../constants/tasks_colors.dart';
import '../constants/tasks_icons.dart';
import '../services/notifications_service.dart';

class TasksController {
  final TasksFirebaseService _service = TasksFirebaseService();

  // الحالة
  bool isLoading = true;
  bool isSearching = false;
  bool isGridView = true;
  bool isSyncing = false;
  String searchText = '';
  String selectedFilter = TasksStrings.allTasks;
  List<Task> tasks = [];
  List<String> categories = [];
  List<String> filters = [];
  Course? selectedCourse;
  String? selectedCourseName;
  List<Course> availableCourses = [];

  // مستمع Stream
  StreamSubscription<List<Task>>? _tasksSubscription;

  // مراقبون للتغييرات
  final ValueNotifier<bool> tasksChanged = ValueNotifier<bool>(false);

  // تهيئة المتحكم
  Future<void> init(String? courseName) async {
    selectedCourseName = courseName;
    _initFilters();

    // تحميل الكورسات المتاحة
    try {
      availableCourses = await _service.getCourses();

      // تحديد الكورس المحدد إذا كان موجوداً
      if (selectedCourseName != null) {
        selectedCourse = availableCourses.firstWhere(
          (course) => course.courseName == selectedCourseName,
          orElse: () => throw Exception('الكورس غير موجود'),
        );
      }
    } catch (e) {
      print('Error loading courses: $e');
      availableCourses = [];
    }

    await loadTasks();
  }

  // تهيئة الفلاتر
  void _initFilters() {
    filters = [
      TasksStrings.allTasks,
      TasksStrings.todayTasks,
      TasksStrings.upcomingTasks,
      TasksStrings.overdueTasks,
      TasksStrings.completedTasks,
    ];
  }

  // تحميل المهام
  Future<void> loadTasks() async {
    isLoading = true;
    _updateState();

    try {
      // إلغاء أي اشتراك سابق
      await _tasksSubscription?.cancel();

      // إنشاء مستمع للتغييرات في المهام
      _tasksSubscription = _service
          .getTasksStream(courseId: selectedCourse?.id)
          .listen((loadedTasks) {
        tasks = loadedTasks;

        isLoading = false;
        isSyncing = false;
        _updateState();
      }, onError: (error) {
        print('Error in tasks stream: $error');
        tasks = [];
        isLoading = false;
        isSyncing = false;
        _updateState();
      });
    } catch (e) {
      print('Error loading tasks: $e');
      tasks = [];
      isLoading = false;
      isSyncing = false;
      _updateState();
    }
  }

  // تصفية المهام
  List<Task> getFilteredTasks() {
    // أولاً نطبق الفلتر الأساسي
    List<Task> filteredTasks = [];

    switch (selectedFilter) {
      case TasksStrings.todayTasks:
        filteredTasks = tasks.where((task) => task.isDueToday()).toList();
        break;
      case TasksStrings.upcomingTasks:
        filteredTasks = tasks
            .where((task) =>
                !task.isDueToday() &&
                task.dueDate.isAfter(DateTime.now()) &&
                task.status != 'مكتملة')
            .toList();
        break;
      case TasksStrings.overdueTasks:
        filteredTasks = tasks.where((task) => task.isOverdue()).toList();
        break;
      case TasksStrings.completedTasks:
        filteredTasks = tasks.where((task) => task.status == 'مكتملة').toList();
        break;
      case TasksStrings.allTasks:
      default:
        filteredTasks = tasks;
    }

    // ثم نطبق البحث إن وجد
    if (searchText.isNotEmpty) {
      String query = searchText.toLowerCase();
      return filteredTasks.where((task) {
        return task.name.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query) ||
            (task.course?.courseName.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filteredTasks;
  }

  // تغيير وضع العرض (قائمة/شبكة)
  void toggleViewMode() {
    isGridView = !isGridView;
    _updateState();
  }

  // تغيير حالة البحث
  void toggleSearch() {
    isSearching = !isSearching;
    if (!isSearching) {
      searchText = '';
    }
    _updateState();
  }

  // تغيير نص البحث
  void setSearchText(String text) {
    searchText = text;
    _updateState();
  }

  // تغيير الفلتر المحدد
  void setSelectedFilter(String filter) {
    selectedFilter = filter;
    _updateState();
  }

  // تبديل حالة إكمال المهمة
  Future<void> toggleTaskCompletion(Task task) async {
    try {
      isSyncing = true;
      _updateState();

      if (task.status == 'مكتملة') {
        // إلغاء إكمال المهمة
        await task.updateTask(newStatus: 'قيد التنفيذ', newProgress: 0.0);

        // إعادة جدولة التذكير إذا كان مفعلاً ولم يمر وقته بعد
        if (task.reminderTime != null &&
            task.reminderTime!.isAfter(DateTime.now())) {
          await task.scheduleReminder();
        }
      } else {
        // إكمال المهمة
        await task.completeAndUpdate();

        // إلغاء التذكير عند إكمال المهمة
        await task.cancelReminder();
      }

      // التحديث سيأتي من مستمع Firebase
    } catch (e) {
      print('Error toggling task completion: $e');
      isSyncing = false;
      _updateState();
      throw Exception('فشل في تحديث حالة المهمة: $e');
    }
  }

  // حذف مهمة
  Future<void> deleteTask(Task task) async {
    try {
      isSyncing = true;
      _updateState();

      // إلغاء التذكير قبل حذف المهمة
      await task.cancelReminder();

      await task.deleteFromFirestore();

      // التحديث سيأتي من مستمع Firebase
    } catch (e) {
      print('Error deleting task: $e');
      isSyncing = false;
      _updateState();
      throw Exception('فشل في حذف المهمة: $e');
    }
  }

  // نسخ مهمة
  Future<void> duplicateTask(Task task) async {
    try {
      isSyncing = true;
      _updateState();

      Task newTask = await Task.createNewTask(
        name: '${task.name}${TasksStrings.copyTitle}',
        description: task.description,
        dueDate: task.dueDate,
        course: task.course,
        reminderTime: task.reminderTime,
        status: 'قيد التنفيذ', // المهمة المنسوخة تكون دائمًا قيد التنفيذ
        priority: task.priority,
        tags: task.tags,
        color: task.color,
      );

      // جدولة التذكير للمهمة المنسوخة إذا كان موجوداً
      if (task.reminderTime != null &&
          task.reminderTime!.isAfter(DateTime.now())) {
        await newTask.scheduleReminder();
      }

      // التحديث سيأتي من مستمع Firebase
    } catch (e) {
      print('Error duplicating task: $e');
      isSyncing = false;
      _updateState();
      throw Exception('فشل في نسخ المهمة: $e');
    }
  }

  // الحصول على الكورس المحدد
  Course? getSelectedCourse() {
    return selectedCourse;
  }

  // الحصول على لون الفلتر
  Color getFilterColor(String filter) {
    switch (filter) {
      case TasksStrings.todayTasks:
        return TasksColors.kYellowColor;
      case TasksStrings.upcomingTasks:
        return TasksColors.kMediumPurple;
      case TasksStrings.overdueTasks:
        return TasksColors.kAccentColor;
      case TasksStrings.completedTasks:
        return TasksColors.kGreenColor;
      case TasksStrings.allTasks:
      default:
        return TasksColors.kDarkPurple;
    }
  }

  // الحصول على أيقونة الفلتر
  IconData getFilterIcon(String filter) {
    switch (filter) {
      case TasksStrings.todayTasks:
        return TasksIcons.today;
      case TasksStrings.upcomingTasks:
        return TasksIcons.upcoming;
      case TasksStrings.overdueTasks:
        return TasksIcons.overdue;
      case TasksStrings.completedTasks:
        return TasksIcons.completed;
      case TasksStrings.allTasks:
      default:
        return TasksIcons.allTasks;
    }
  }

  // الحصول على عدد المهام بحسب الفلتر
  int getTaskCountByFilter(String filter) {
    switch (filter) {
      case TasksStrings.todayTasks:
        return tasks.where((task) => task.isDueToday()).length;
      case TasksStrings.upcomingTasks:
        return tasks
            .where((task) =>
                !task.isDueToday() &&
                task.dueDate.isAfter(DateTime.now()) &&
                task.status != 'مكتملة')
            .length;
      case TasksStrings.overdueTasks:
        return tasks.where((task) => task.isOverdue()).length;
      case TasksStrings.completedTasks:
        return tasks.where((task) => task.status == 'مكتملة').length;
      case TasksStrings.allTasks:
      default:
        return tasks.length;
    }
  }

  // تنظيف عند الإغلاق
  void dispose() {
    _tasksSubscription?.cancel();
  }

  // إخطار المستمعين بالتغييرات
  void _updateState() {
    tasksChanged.value = !tasksChanged.value;
  }
}
