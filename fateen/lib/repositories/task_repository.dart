// lib/repositories/task_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/course.dart';

class TaskRepository {
  // حالة واحدة من الريبوزيتوري (Singleton)
  static final TaskRepository _instance = TaskRepository._internal();
  factory TaskRepository() => _instance;
  TaskRepository._internal();

  // مراجع Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // الحصول على مرجع لمجموعة المهام
  CollectionReference _getTasksCollection() {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }
    return _firestore.collection('users').doc(user.uid).collection('tasks');
  }

  // تهيئة المستودع
  Future<void> initialize() async {
    // تأكد من وجود مستخدم حالي
    try {
      final user = _auth.currentUser;
      if (user != null) {
        debugPrint('تم تهيئة مستودع المهام بنجاح للمستخدم: ${user.uid}');
      }
    } catch (e) {
      debugPrint('خطأ في تهيئة مستودع المهام: $e');
    }
  }

  // جلب جميع المهام
  Future<List<Task>> getAllTasks() async {
    try {
      final snapshot = await _getTasksCollection().get();
      final tasks = <Task>[];

      for (var doc in snapshot.docs) {
        try {
          tasks.add(Task.fromFirestore(doc));
        } catch (e) {
          debugPrint('خطأ في تحويل المهمة: ${doc.id}, خطأ: $e');
        }
      }

      return tasks;
    } catch (e) {
      debugPrint('خطأ في جلب جميع المهام: $e');
      return [];
    }
  }

  // الحصول على المهام النشطة اليوم
  Future<List<Task>> getTodayTasks() async {
    try {
      final allTasks = await getAllTasks();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      return allTasks.where((task) {
        final taskDate = DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
        );
        return taskDate.isAtSameMomentAs(today) && task.status == 'قيد التنفيذ';
      }).toList();
    } catch (e) {
      debugPrint('خطأ في جلب مهام اليوم: $e');
      return [];
    }
  }

  // الحصول على المهام المتأخرة
  Future<List<Task>> getOverdueTasks() async {
    try {
      final allTasks = await getAllTasks();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      return allTasks.where((task) {
        final taskDate = DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
        );
        return taskDate.isBefore(today) && task.status == 'قيد التنفيذ';
      }).toList();
    } catch (e) {
      debugPrint('خطأ في جلب المهام المتأخرة: $e');
      return [];
    }
  }

  // إكمال مهمة
  Future<void> completeTask(String taskId) async {
    try {
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

  // حساب إحصائيات المهام
  Future<Map<String, int>> getTasksStatistics() async {
    try {
      final allTasks = await getAllTasks();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int totalTasks = allTasks.length;
      int completedTasks = 0;
      int overdueTasks = 0;
      int todayTasks = 0;
      int upcomingTasks = 0;
      int highPriorityTasks = 0;

      for (final task in allTasks) {
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

        if (task.priority == 'عالية') {
          highPriorityTasks++;
        }

        if (taskDate.isBefore(today)) {
          overdueTasks++;
        } else if (taskDate.isAtSameMomentAs(today)) {
          todayTasks++;
        } else if (taskDate.isAfter(today)) {
          upcomingTasks++;
        }
      }

      return {
        'total': totalTasks,
        'completed': completedTasks,
        'overdue': overdueTasks,
        'today': todayTasks,
        'upcoming': upcomingTasks,
        'highPriority': highPriorityTasks,
      };
    } catch (e) {
      debugPrint('خطأ في حساب إحصائيات المهام: $e');
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

  // إضافة مهمة جديدة
  Future<Task> createTask({
    required String name,
    required String description,
    required DateTime dueDate,
    String status = 'قيد التنفيذ',
    String priority = 'متوسطة',
  }) async {
    try {
      final docRef = _getTasksCollection().doc();

      final task = Task(
        id: docRef.id,
        name: name,
        description: description,
        dueDate: dueDate,
        status: status,
        priority: priority,
        userId: _auth.currentUser?.uid,
      );

      await docRef.set(task.toMap());
      return task;
    } catch (e) {
      debugPrint('خطأ في إنشاء مهمة جديدة: $e');
      throw Exception('فشل في إنشاء مهمة جديدة: $e');
    }
  }

  // مراقبة التغييرات في المهام
  Stream<List<Task>> watchAllTasks() {
    try {
      return _getTasksCollection().snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            return Task.fromFirestore(doc);
          } catch (e) {
            debugPrint('خطأ في تحويل المهمة: ${doc.id}, خطأ: $e');
            // إعادة مهمة فارغة في حالة الخطأ
            return Task(
              id: doc.id,
              name: 'خطأ في البيانات',
              description: 'تعذر تحميل بيانات هذه المهمة',
              dueDate: DateTime.now(),
              status: 'قيد التنفيذ',
            );
          }
        }).toList();
      });
    } catch (e) {
      debugPrint('خطأ في مراقبة المهام: $e');
      return Stream.value([]);
    }
  }
}
