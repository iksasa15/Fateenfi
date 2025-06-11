// lib/controllers/tasks_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../models/task.dart';
import '../services/firebaseServices/tasks_firebase_service.dart';

/// وحدة تحكم المهام تدير حالة المهام التي تحتاج اهتمام
class TasksController extends ChangeNotifier {
  // الخدمة المسؤولة عن التعامل مع Firebase
  final TasksFirebaseService _service = TasksFirebaseService();

  // حالة البيانات
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  // المهام التي تحتاج اهتمام
  Task? todayTask;
  Task? overdueTask;

  // مستمع للتغييرات
  StreamSubscription? _tasksSubscription;

  // إحصائيات المهام
  Map<String, int> tasksStats = {
    'total': 0,
    'completed': 0,
    'overdue': 0,
    'today': 0,
    'upcoming': 0,
    'highPriority': 0,
  };

  /// تهيئة وحدة التحكم وبدء تحميل البيانات
  Future<void> initialize() async {
    try {
      debugPrint('بدء تهيئة وحدة تحكم المهام...');

      isLoading = true;
      hasError = false;
      errorMessage = '';
      notifyListeners();

      // تهيئة الخدمة
      await _service.initialize();

      // تحميل البيانات
      await _loadData();

      // بدء الاستماع للتغييرات
      _setupTasksListener();

      isLoading = false;
      notifyListeners();

      debugPrint('تمت تهيئة وحدة تحكم المهام بنجاح');
      if (todayTask != null) {
        debugPrint('تم تحميل مهمة اليوم: ${todayTask!.name}');
      } else {
        debugPrint('لا توجد مهمة لليوم');
      }

      if (overdueTask != null) {
        debugPrint('تم تحميل مهمة متأخرة: ${overdueTask!.name}');
      } else {
        debugPrint('لا توجد مهمة متأخرة');
      }
    } catch (e) {
      debugPrint('خطأ في تهيئة وحدة تحكم المهام: $e');
      isLoading = false;
      hasError = true;
      errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
      notifyListeners();
    }
  }

  /// تحميل البيانات بشكل متزامن
  Future<void> _loadData() async {
    try {
      debugPrint('بدء تحميل بيانات المهام...');

      // جلب البيانات بالتوازي لتحسين الأداء
      final results = await Future.wait([
        _service.getTodayTask(),
        _service.getOverdueTask(),
        _service.getTasksStatistics(),
      ]);

      // تعيين البيانات
      todayTask = results[0] as Task?;
      overdueTask = results[1] as Task?;
      tasksStats = results[2] as Map<String, int>;

      debugPrint('تم تحميل بيانات المهام:');
      debugPrint('- مهمة اليوم: ${todayTask?.name ?? "غير موجودة"}');
      debugPrint('- مهمة متأخرة: ${overdueTask?.name ?? "غير موجودة"}');
      debugPrint('- إحصائيات المهام: $tasksStats');
    } catch (e) {
      debugPrint('خطأ في تحميل بيانات المهام: $e');
      throw e;
    }
  }

  /// إعداد مستمع للتغييرات في المهام
  void _setupTasksListener() {
    try {
      debugPrint('بدء الاستماع للتغييرات في المهام...');

      // إلغاء أي مستمع سابق
      _tasksSubscription?.cancel();

      // إنشاء مستمع جديد
      _tasksSubscription = _service.watchTasks().listen((snapshot) async {
        debugPrint('تم استلام تحديث للمهام: ${snapshot.docs.length} مهمة');

        // إعادة تحميل البيانات فوراً
        await _loadData();

        // إخطار المستمعين بالتغييرات
        notifyListeners();
      }, onError: (error) {
        debugPrint('خطأ في مستمع المهام: $error');
      });

      debugPrint('تم إعداد مستمع المهام بنجاح');
    } catch (e) {
      debugPrint('خطأ في إعداد مستمع المهام: $e');
    }
  }

  /// تحديث البيانات يدوياً
  Future<void> refresh() async {
    try {
      debugPrint('بدء تحديث البيانات يدوياً...');

      isLoading = true;
      notifyListeners();

      // إعادة تحميل البيانات
      await _loadData();

      isLoading = false;
      notifyListeners();

      debugPrint('تم تحديث البيانات بنجاح');
      debugPrint(
          'بعد التحديث - مهمة اليوم: ${todayTask?.name ?? "غير موجودة"}');
      debugPrint(
          'بعد التحديث - مهمة متأخرة: ${overdueTask?.name ?? "غير موجودة"}');
    } catch (e) {
      debugPrint('خطأ في تحديث البيانات: $e');
      isLoading = false;
      hasError = true;
      errorMessage = 'حدث خطأ أثناء تحديث البيانات: $e';
      notifyListeners();
    }
  }

  /// إكمال مهمة
  Future<void> completeTask(String taskId) async {
    try {
      debugPrint('بدء إكمال المهمة: $taskId');

      // إكمال المهمة في قاعدة البيانات
      await _service.completeTask(taskId);

      // تحديث الحالة المحلية
      if (todayTask?.id == taskId) {
        todayTask = null;
      }
      if (overdueTask?.id == taskId) {
        overdueTask = null;
      }

      // إعادة تحميل البيانات لتحديث الإحصائيات
      await _loadData();

      // إخطار المستمعين بالتغييرات
      notifyListeners();

      debugPrint('تم إكمال المهمة بنجاح');
    } catch (e) {
      debugPrint('خطأ في إكمال المهمة: $e');
      throw e;
    }
  }

  @override
  void dispose() {
    debugPrint('تحرير موارد وحدة تحكم المهام...');
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
