// lib/screens/tasks/services/tasks_firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../models/course.dart';

class TasksFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // الحصول على مرجع مجموعة المهام
  CollectionReference<Map<String, dynamic>> get tasksCollection {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks');
  }

  // الحصول على مرجع مجموعة الكورسات
  CollectionReference<Map<String, dynamic>> get coursesCollection {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('courses');
  }

  // إنشاء Stream لمراقبة تغيرات المهام
  Stream<List<Task>> getTasksStream({String? courseId}) {
    if (currentUser == null) {
      return Stream.value([]);
    }

    Query<Map<String, dynamic>> query = tasksCollection.orderBy('dueDate');

    // إذا كان هناك courseId محدد، قم بتصفية المهام على أساسه
    if (courseId != null) {
      query = query.where('courseId', isEqualTo: courseId);
    }

    return query.snapshots().asyncMap((snapshot) async {
      List<Task> tasks = [];

      // تحميل الكورسات مرة واحدة لتجنب استعلامات متعددة
      final courses = await getCourses();

      for (var doc in snapshot.docs) {
        try {
          // البحث عن الكورس المرتبط بالمهمة
          final courseId = doc.data()['courseId'] as String?;
          Course? course;

          if (courseId != null) {
            try {
              course = courses.firstWhere(
                (c) => c.id == courseId,
                orElse: () => throw Exception('Course not found'),
              );
            } catch (e) {
              print('Error finding course: $e for courseId: $courseId');
            }
          }

          // إنشاء كائن Task
          tasks.add(Task.fromFirestore(doc, course: course));
        } catch (e) {
          print('Error parsing task: $e');
        }
      }

      return tasks;
    });
  }

  // الحصول على جميع الكورسات
  Future<List<Course>> getCourses() async {
    if (currentUser == null) {
      return [];
    }

    try {
      final snapshot = await coursesCollection.get();
      return snapshot.docs.map((doc) {
        return Course.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error loading courses: $e');
      return [];
    }
  }

  // إضافة مهمة جديدة
  Future<void> addTask(Map<String, dynamic> data) async {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    // إنشاء معرف جديد
    DocumentReference docRef = tasksCollection.doc();

    // تعيين الطوابع الزمنية
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    // حفظ المهمة
    await docRef.set({
      ...data,
      'id': docRef.id,
    });
  }

  // تحديث مهمة موجودة
  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    // تحديث الطابع الزمني
    data['updatedAt'] = FieldValue.serverTimestamp();

    // تحديث المهمة
    print('Updating task $taskId with data: $data');
    await tasksCollection.doc(taskId).update(data);
  }

  // تحديث حقل courseId بشكل منفصل
  Future<void> updateTaskCourseId(String taskId, String? courseId) async {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    try {
      // استخدام Map مختلف للتحديث
      final updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // إضافة courseId أو حذفه حسب الحالة
      if (courseId != null) {
        updateData['courseId'] = courseId as FieldValue;
      } else {
        // إذا كان courseId هو null، نحذف الحقل من Firestore
        updateData['courseId'] = FieldValue.delete();
      }

      await tasksCollection.doc(taskId).update(updateData);
      print('Task courseId updated successfully: $courseId');
    } catch (e) {
      print('Error updating task courseId: $e');
      throw e;
    }
  }

  // تحديث حقل معين في المهمة
  Future<void> updateTaskField(
      String taskId, String fieldName, dynamic value) async {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    try {
      if (value == null) {
        // إذا كانت القيمة هي null، نستخدم FieldValue.delete() لحذف الحقل
        await tasksCollection.doc(taskId).update({
          fieldName: FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Field $fieldName deleted from task $taskId');
      } else {
        // وإلا نقوم بتحديث الحقل بالقيمة المعطاة
        await tasksCollection.doc(taskId).update({
          fieldName: value,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Field $fieldName updated in task $taskId with value: $value');
      }
    } catch (e) {
      print('Error updating $fieldName: $e');
      throw e;
    }
  }

  // حذف مهمة
  Future<void> deleteTask(String taskId) async {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    await tasksCollection.doc(taskId).delete();
  }

  // الحصول على مهمة بواسطة المعرّف
  Future<Task?> getTaskById(String taskId) async {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    try {
      final doc = await tasksCollection.doc(taskId).get();
      if (!doc.exists) {
        return null;
      }

      // البحث عن الكورس المرتبط بالمهمة
      final courseId = doc.data()?['courseId'] as String?;
      Course? course;

      if (courseId != null) {
        final courseDoc = await coursesCollection.doc(courseId).get();
        if (courseDoc.exists) {
          course = Course.fromMap(courseDoc.data()!, courseId);
        }
      }

      return Task.fromFirestore(doc, course: course);
    } catch (e) {
      print('Error getting task: $e');
      return null;
    }
  }

  // الحصول على المهام الخاصة بكورس
  Future<List<Task>> getTasksByCourse(String courseId) async {
    if (currentUser == null) {
      return [];
    }

    try {
      final snapshot = await tasksCollection
          .where('courseId', isEqualTo: courseId)
          .orderBy('dueDate')
          .get();

      // الحصول على الكورس
      final courseDoc = await coursesCollection.doc(courseId).get();
      Course? course;

      if (courseDoc.exists) {
        course = Course.fromMap(courseDoc.data()!, courseId);
      }

      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc, course: course);
      }).toList();
    } catch (e) {
      print('Error getting tasks by course: $e');
      return [];
    }
  }

  // الحصول على المهام بناءً على الحالة
  Future<List<Task>> getTasksByStatus(String status) async {
    if (currentUser == null) {
      return [];
    }

    try {
      final snapshot = await tasksCollection
          .where('status', isEqualTo: status)
          .orderBy('dueDate')
          .get();

      // تحميل الكورسات
      final courses = await getCourses();

      List<Task> tasks = [];
      for (var doc in snapshot.docs) {
        final courseId = doc.data()['courseId'] as String?;
        Course? course;

        if (courseId != null) {
          course = courses.firstWhere(
            (c) => c.id == courseId,
            orElse: () => Course(
                id: 'unknown',
                courseName: 'غير معروف',
                creditHours: 0,
                days: [],
                classroom: '',
                grades: {},
                files: []),
          );
        }

        tasks.add(Task.fromFirestore(doc, course: course));
      }

      return tasks;
    } catch (e) {
      print('Error getting tasks by status: $e');
      return [];
    }
  }

  // الحصول على المهام حسب التاريخ
  Future<List<Task>> getTasksByDate(DateTime date) async {
    if (currentUser == null) {
      return [];
    }

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay
          .add(Duration(milliseconds: (0.9999 * 24 * 60 * 60 * 1000).toInt()));

      final snapshot = await tasksCollection
          .where('dueDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dueDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      // تحميل الكورسات
      final courses = await getCourses();

      List<Task> tasks = [];
      for (var doc in snapshot.docs) {
        final courseId = doc.data()['courseId'] as String?;
        Course? course;

        if (courseId != null) {
          course = courses.firstWhere(
            (c) => c.id == courseId,
            orElse: () => Course(
                id: 'unknown',
                courseName: 'غير معروف',
                creditHours: 0,
                days: [],
                classroom: '',
                grades: {},
                files: []),
          );
        }

        tasks.add(Task.fromFirestore(doc, course: course));
      }

      return tasks;
    } catch (e) {
      print('Error getting tasks by date: $e');
      return [];
    }
  }

  // البحث عن المهام
  Future<List<Task>> searchTasks(String query) async {
    if (currentUser == null || query.trim().isEmpty) {
      return [];
    }

    try {
      // Firestore لا يدعم البحث النصي، لذا سنقوم بتنزيل جميع المهام وتصفيتها على جانب العميل
      final snapshot = await tasksCollection.get();

      // تحميل الكورسات
      final courses = await getCourses();

      List<Task> allTasks = [];
      for (var doc in snapshot.docs) {
        final courseId = doc.data()['courseId'] as String?;
        Course? course;

        if (courseId != null) {
          course = courses.firstWhere(
            (c) => c.id == courseId,
            orElse: () => Course(
                id: 'unknown',
                courseName: 'غير معروف',
                creditHours: 0,
                days: [],
                classroom: '',
                grades: {},
                files: []),
          );
        }

        allTasks.add(Task.fromFirestore(doc, course: course));
      }

      // تصفية المهام بناءً على النص المطلوب
      final lowercaseQuery = query.toLowerCase();
      return allTasks.where((task) {
        return task.name.toLowerCase().contains(lowercaseQuery) ||
            task.description.toLowerCase().contains(lowercaseQuery) ||
            task.tags
                .any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
            (task.course?.courseName.toLowerCase().contains(lowercaseQuery) ??
                false);
      }).toList();
    } catch (e) {
      print('Error searching tasks: $e');
      return [];
    }
  }
}
