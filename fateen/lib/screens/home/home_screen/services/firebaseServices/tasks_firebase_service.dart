import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fateen/models/task.dart';

/// خدمة Firebase للمهام التي تحتاج اهتمام
class TasksFirebaseService {
  // حقول Firestore
  static const String tasksCollection = 'tasks';
  static const String usersCollection = 'users';
  static const String nameField = 'name';
  static const String descriptionField = 'description';
  static const String dueDateField = 'dueDate';
  static const String statusField = 'status';
  static const String priorityField = 'priority';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';

  // قيم الحالة
  static const String statusInProgress = 'قيد التنفيذ';
  static const String statusCompleted = 'مكتملة';
  static const String statusCancelled = 'ملغية';

  // جلب المهام ليوم اليوم
  static Future<List<Task>> getTodayTasks() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.uid)
          .collection(tasksCollection)
          .where(dueDateField, isGreaterThanOrEqualTo: startOfDay)
          .where(dueDateField, isLessThan: endOfDay)
          .where(statusField, isEqualTo: statusInProgress)
          .orderBy(dueDateField)
          .limit(1); // نحتاج فقط للمهمة الأولى

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('خطأ في جلب مهام اليوم: $e');
      return [];
    }
  }

  // جلب المهام المتأخرة
  static Future<List<Task>> getOverdueTasks() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final query = FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.uid)
          .collection(tasksCollection)
          .where(dueDateField, isLessThan: startOfDay)
          .where(statusField, isEqualTo: statusInProgress)
          .orderBy(dueDateField, descending: true)
          .limit(1); // نحتاج فقط للمهمة الأولى

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('خطأ في جلب المهام المتأخرة: $e');
      return [];
    }
  }

  // الاستماع للتغييرات في المهام
  static Stream<List<Task>> listenToAllTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(user.uid)
        .collection(tasksCollection)
        .orderBy(dueDateField)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  // جلب إحصائيات المهام
  static Future<Map<String, int>> getTasksStatistics() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {
          'total': 0,
          'completed': 0,
          'overdue': 0,
          'today': 0,
          'upcoming': 0,
          'highPriority': 0,
        };
      }

      final tasksRef = FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.uid)
          .collection(tasksCollection);

      // إجمالي المهام
      final totalSnapshot = await tasksRef.get();
      final totalTasks = totalSnapshot.docs.length;

      // المهام المكتملة
      final completedSnapshot =
          await tasksRef.where(statusField, isEqualTo: statusCompleted).get();
      final completedTasks = completedSnapshot.docs.length;

      // استخدام التاريخ للمقارنة
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // المهام المتأخرة
      final overdueSnapshot = await tasksRef
          .where(dueDateField, isLessThan: startOfDay)
          .where(statusField, isEqualTo: statusInProgress)
          .get();
      final overdueTasks = overdueSnapshot.docs.length;

      // مهام اليوم
      final todaySnapshot = await tasksRef
          .where(dueDateField, isGreaterThanOrEqualTo: startOfDay)
          .where(dueDateField, isLessThan: endOfDay)
          .where(statusField, isEqualTo: statusInProgress)
          .get();
      final todayTasks = todaySnapshot.docs.length;

      // المهام القادمة
      final upcomingSnapshot = await tasksRef
          .where(dueDateField, isGreaterThanOrEqualTo: endOfDay)
          .where(statusField, isEqualTo: statusInProgress)
          .get();
      final upcomingTasks = upcomingSnapshot.docs.length;

      // المهام ذات الأولوية العالية
      final highPrioritySnapshot = await tasksRef
          .where(priorityField, isEqualTo: 'عالية')
          .where(statusField, isEqualTo: statusInProgress)
          .get();
      final highPriorityTasks = highPrioritySnapshot.docs.length;

      return {
        'total': totalTasks,
        'completed': completedTasks,
        'overdue': overdueTasks,
        'today': todayTasks,
        'upcoming': upcomingTasks,
        'highPriority': highPriorityTasks,
      };
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

  // إنشاء مهمة جديدة (للاختبار)
  static Future<void> createNewTask({
    required String name,
    required String description,
    required DateTime dueDate,
    required String status,
    String priority = 'متوسطة',
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('لم يتم تسجيل الدخول');
      }

      final taskData = {
        nameField: name,
        descriptionField: description,
        dueDateField: Timestamp.fromDate(dueDate),
        statusField: status,
        priorityField: priority,
        createdAtField: FieldValue.serverTimestamp(),
        updatedAtField: FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.uid)
          .collection(tasksCollection)
          .add(taskData);

      debugPrint('تم إنشاء مهمة جديدة: $name');
    } catch (e) {
      debugPrint('خطأ في إنشاء مهمة جديدة: $e');
      throw e;
    }
  }
}
