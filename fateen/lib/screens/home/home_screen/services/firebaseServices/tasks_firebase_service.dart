// lib/services/tasks_firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../models/task.dart';

/// خدمة Firebase للتعامل مع المهام بشكل مباشر
class TasksFirebaseService {
  // تطبيق النمط Singleton
  static final TasksFirebaseService _instance =
      TasksFirebaseService._internal();
  factory TasksFirebaseService() => _instance;
  TasksFirebaseService._internal();

  // مراجع Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // الحصول على معرف المستخدم الحالي
  String? get _userId => _auth.currentUser?.uid;

  // التحقق من تسجيل الدخول
  bool get isUserLoggedIn => _auth.currentUser != null;

  // الحصول على مرجع مجموعة المهام
  CollectionReference _getTasksCollection() {
    if (_userId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }
    return _firestore.collection('users').doc(_userId).collection('tasks');
  }

  // جلب مهمة اليوم - تاريخ استحقاقها اليوم وحالتها قيد التنفيذ
  Future<Task?> getTodayTask() async {
    try {
      if (_userId == null) return null;

      // تحديد بداية ونهاية اليوم الحالي
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      debugPrint(
          'جلب مهمة اليوم... من ${startOfDay.toIso8601String()} إلى ${endOfDay.toIso8601String()}');

      // جلب مهام اليوم المحددة
      final query = await _getTasksCollection()
          .where('dueDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('status', isEqualTo: 'قيد التنفيذ')
          .orderBy('dueDate')
          .limit(1)
          .get();

      // تحقق من وجود مهام
      debugPrint('عدد المهام التي تم استرجاعها لليوم: ${query.docs.length}');
      if (query.docs.isEmpty) {
        debugPrint('لا توجد مهام لليوم');
        return null;
      }

      // تحويل المستند إلى كائن Task
      final taskDoc = query.docs.first;
      debugPrint('تم العثور على مهمة اليوم: ${taskDoc.id}');
      return Task.fromFirestore(taskDoc);
    } catch (e) {
      debugPrint('خطأ في جلب مهمة اليوم: $e');
      return null;
    }
  }

  // جلب مهمة متأخرة - تاريخ استحقاقها قبل اليوم وحالتها قيد التنفيذ
  Future<Task?> getOverdueTask() async {
    try {
      if (_userId == null) return null;

      // تحديد بداية اليوم الحالي
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      debugPrint('جلب مهمة متأخرة... قبل ${startOfToday.toIso8601String()}');

      // جلب المهام المتأخرة
      final query = await _getTasksCollection()
          .where('dueDate', isLessThan: Timestamp.fromDate(startOfToday))
          .where('status', isEqualTo: 'قيد التنفيذ')
          .orderBy('dueDate', descending: true) // أحدث المهام المتأخرة أولاً
          .limit(1)
          .get();

      // تحقق من وجود مهام
      debugPrint('عدد المهام التي تم استرجاعها المتأخرة: ${query.docs.length}');
      if (query.docs.isEmpty) {
        debugPrint('لا توجد مهام متأخرة');
        return null;
      }

      // تحويل المستند إلى كائن Task
      final taskDoc = query.docs.first;
      debugPrint('تم العثور على مهمة متأخرة: ${taskDoc.id}');
      final task = Task.fromFirestore(taskDoc);
      debugPrint(
          'تفاصيل المهمة المتأخرة: ${task.name}, التاريخ: ${task.dueDateFormatted}');
      return task;
    } catch (e) {
      debugPrint('خطأ في جلب مهمة متأخرة: $e');
      return null;
    }
  }

  // جلب إحصائيات المهام
  Future<Map<String, int>> getTasksStatistics() async {
    try {
      if (_userId == null) {
        return {
          'total': 0,
          'completed': 0,
          'overdue': 0,
          'today': 0,
          'upcoming': 0,
          'highPriority': 0,
        };
      }

      // جلب جميع المهام
      final snapshot = await _getTasksCollection().get();
      final tasks =
          snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();

      // تحديد التواريخ الهامة
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      // حساب الإحصائيات
      int totalTasks = tasks.length;
      int completedTasks = 0;
      int overdueTasks = 0;
      int todayTasks = 0;
      int upcomingTasks = 0;
      int highPriorityTasks = 0;

      debugPrint('إجمالي المهام المسترجعة للإحصائيات: $totalTasks');

      for (final task in tasks) {
        final taskDate = DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
        );

        if (task.status == 'مكتملة') {
          completedTasks++;
          continue;
        }

        if (task.status == 'ملغاة') {
          continue;
        }

        // الأولوية العالية
        if (task.priority == 'عالية') {
          highPriorityTasks++;
        }

        // تصنيف المهام حسب التاريخ
        if (taskDate.isBefore(today)) {
          overdueTasks++;
        } else if (taskDate.year == today.year &&
            taskDate.month == today.month &&
            taskDate.day == today.day) {
          todayTasks++;
        } else {
          upcomingTasks++;
        }
      }

      final stats = {
        'total': totalTasks,
        'completed': completedTasks,
        'overdue': overdueTasks,
        'today': todayTasks,
        'upcoming': upcomingTasks,
        'highPriority': highPriorityTasks,
      };

      debugPrint('الإحصائيات المحسوبة: $stats');
      return stats;
    } catch (e) {
      debugPrint('خطأ في جلب إحصائيات المهام: $e');
      return {
        'total': 0,
        'completed': 0,
        'overdue': 0,
        'today': 0,
        'upcoming': 0,
        'highPriority': 0,
      };
    }
  }

  // إكمال مهمة
  Future<void> completeTask(String taskId) async {
    try {
      if (_userId == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      await _getTasksCollection().doc(taskId).update({
        'status': 'مكتملة',
        'completedDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'progress': 1.0
      });

      debugPrint('تم إكمال المهمة بنجاح: $taskId');
    } catch (e) {
      debugPrint('خطأ في إكمال المهمة: $e');
      throw Exception('فشل في إكمال المهمة: $e');
    }
  }

  // مراقبة التغييرات في المهام
  Stream<QuerySnapshot> watchTasks() {
    try {
      if (_userId == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }
      return _getTasksCollection().snapshots();
    } catch (e) {
      debugPrint('خطأ في مراقبة المهام: $e');
      throw Exception('فشل في مراقبة المهام: $e');
    }
  }

  // التهيئة والتحقق من الاتصال
  Future<void> initialize() async {
    try {
      if (_userId != null) {
        // محاولة جلب وثيقة واحدة للتحقق من الاتصال
        final snapshot = await _getTasksCollection().limit(1).get();
        debugPrint('تمت تهيئة خدمة المهام بنجاح للمستخدم: $_userId');
        debugPrint('عدد المهام المسترجعة في التهيئة: ${snapshot.docs.length}');
      } else {
        debugPrint('لم يتم تسجيل الدخول، لا يمكن تهيئة خدمة المهام');
      }
    } catch (e) {
      debugPrint('خطأ في تهيئة خدمة المهام: $e');
    }
  }
}
