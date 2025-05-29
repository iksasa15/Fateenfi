import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fateen/models/task.dart';

/// وحدة تحكم المهام تدير حالة المهام التي تحتاج اهتمام
class TasksController extends ChangeNotifier {
  // حالة المستخدم والبيانات
  User? currentUser;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  // مهام تحتاج اهتمام
  Task? todayTask; // مهمة اليوم للعرض
  Task? overdueTask; // مهمة متأخرة للعرض

  // مستمع للتغييرات على المهام
  StreamSubscription? _tasksSubscription;

  // إحصائيات المهام
  Map<String, int> tasksStats = {
    'total': 0, // إجمالي المهام
    'completed': 0, // المهام المكتملة
    'overdue': 0, // المهام المتأخرة
    'today': 0, // مهام اليوم
    'upcoming': 0, // المهام القادمة
    'highPriority': 0, // المهام ذات الأولوية العالية
  };

  /// إنشاء وحدة التحكم
  TasksController() {
    currentUser = FirebaseAuth.instance.currentUser;
  }

  /// تهيئة البيانات
  Future<void> initialize() async {
    try {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      notifyListeners();

      // تحميل البيانات
      await _loadTasksData();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      hasError = true;
      errorMessage = 'حدث خطأ أثناء تحميل بيانات المهام: $e';
      notifyListeners();
      debugPrint(errorMessage);
    }
  }

  /// تحديث البيانات
  Future<void> refresh() async {
    try {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      notifyListeners();

      // تحميل البيانات
      await _loadTasksData();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      hasError = true;
      errorMessage = 'حدث خطأ أثناء تحديث بيانات المهام: $e';
      notifyListeners();
      debugPrint(errorMessage);
    }
  }

  /// تحميل بيانات المهام
  Future<void> _loadTasksData() async {
    try {
      debugPrint('بدء تحميل بيانات المهام...');

      // تحديث المستخدم الحالي
      currentUser = FirebaseAuth.instance.currentUser;

      // تحميل إحصائيات المهام
      await _loadTasksStatistics();

      // جلب مهام اليوم والمهام المتأخرة
      await _fetchTodayAndOverdueTasks();

      // الاستماع للتغييرات في المهام
      _listenToTasksChanges();

      debugPrint('اكتمل تحميل بيانات المهام بنجاح');
    } catch (e) {
      debugPrint('خطأ في تحميل بيانات المهام: $e');
      throw e;
    }
  }

  /// جلب مهام اليوم والمهام المتأخرة للعرض
  Future<void> _fetchTodayAndOverdueTasks() async {
    try {
      debugPrint('بدء جلب مهام اليوم والمهام المتأخرة...');

      // جلب مهام اليوم
      final todayTasks = await Task.getTodayTasks();
      debugPrint('عدد مهام اليوم المسترجعة: ${todayTasks.length}');

      for (var task in todayTasks) {
        debugPrint(
            'مهمة اليوم: ${task.name}, الموعد: ${task.dueDateFormatted}, الحالة: ${task.status}');
      }

      if (todayTasks.isNotEmpty) {
        todayTask = todayTasks.first;
        debugPrint('تم تعيين مهمة اليوم: ${todayTask?.name}');
      } else {
        todayTask = null;
        debugPrint('لا توجد مهام لليوم');
      }

      // جلب المهام المتأخرة
      final overdueTasks = await Task.getOverdueTasks();
      debugPrint('عدد المهام المتأخرة المسترجعة: ${overdueTasks.length}');

      for (var task in overdueTasks) {
        debugPrint(
            'مهمة متأخرة: ${task.name}, الموعد: ${task.dueDateFormatted}, الحالة: ${task.status}');
      }

      if (overdueTasks.isNotEmpty) {
        overdueTask = overdueTasks.first;
        debugPrint('تم تعيين مهمة متأخرة: ${overdueTask?.name}');
      } else {
        overdueTask = null;
        debugPrint('لا توجد مهام متأخرة');
      }

      // طباعة حالة المهام النهائية
      debugPrint(
          'الحالة النهائية - مهمة اليوم: ${todayTask != null ? "موجودة" : "غير موجودة"}, ' +
              'مهمة متأخرة: ${overdueTask != null ? "موجودة" : "غير موجودة"}');
    } catch (e) {
      debugPrint('خطأ في جلب مهام اليوم والمهام المتأخرة: $e');
      todayTask = null;
      overdueTask = null;
    }
  }

  /// تحميل إحصائيات المهام
  Future<void> _loadTasksStatistics() async {
    if (currentUser == null) return;

    try {
      debugPrint('جاري جلب إحصائيات المهام...');

      // استخدام دالة getTasksStatistics من كلاس Task
      final stats = await Task.getTasksStatistics();
      tasksStats = stats;

      debugPrint('تم جلب إحصائيات المهام بنجاح: $tasksStats');
    } catch (e) {
      debugPrint('حدث خطأ أثناء جلب إحصائيات المهام: $e');
      throw e;
    }
  }

  /// الاستماع للتغييرات في المهام
  void _listenToTasksChanges() {
    if (currentUser == null) return;

    try {
      // إلغاء أي اشتراك سابق
      _tasksSubscription?.cancel();

      debugPrint('بدء الاستماع لتغييرات المهام...');

      // الاستماع لتغييرات المهام في الوقت الفعلي
      _tasksSubscription = Task.listenToAllTasks().listen((tasks) {
        debugPrint('تم استلام تحديث للمهام، عدد المهام: ${tasks.length}');

        // عند تغيير المهام، قم بتحديث الإحصائيات
        _loadTasksStatistics().then((_) {
          // تحديث مهام اليوم والمهام المتأخرة
          _fetchTodayAndOverdueTasks().then((_) {
            debugPrint('تم تحديث بيانات المهام بعد التغيير');
            notifyListeners();
          });
        });
      }, onError: (error) {
        debugPrint('خطأ في مستمع المهام: $error');
      });
    } catch (e) {
      debugPrint('خطأ في إعداد مستمع المهام: $e');
    }
  }

  /// إضافة مهمة اختبارية (للتجريب فقط)
  Future<void> addTestTask() async {
    try {
      if (currentUser == null) {
        debugPrint('لا يوجد مستخدم حالي، لا يمكن إضافة مهام اختبارية');
        return;
      }

      debugPrint('إضافة مهمات اختبارية...');

      // إنشاء مهمة ليوم اليوم
      final now = DateTime.now();
      await Task.createNewTask(
          name: "مهمة اختبارية لليوم",
          description: "هذه مهمة اختبارية للتأكد من عرض مهام اليوم",
          dueDate: now,
          status: "قيد التنفيذ");

      // إنشاء مهمة متأخرة (أمس)
      final yesterday = now.subtract(const Duration(days: 1));
      await Task.createNewTask(
          name: "مهمة اختبارية متأخرة",
          description: "هذه مهمة اختبارية للتأكد من عرض المهام المتأخرة",
          dueDate: yesterday,
          status: "قيد التنفيذ");

      debugPrint('تم إنشاء مهام اختبارية بنجاح');

      // تحديث المهام
      await _fetchTodayAndOverdueTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('فشل في إنشاء المهام الاختبارية: $e');
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
