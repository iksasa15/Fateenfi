// Ruta: lib/screens/home/home_screen/services/firebaseServices/stats_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants/stats_constants.dart';

/// خدمة التعامل مع Firebase للحصول على إحصائيات
class StatsFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// جلب إحصائيات المقررات للمستخدم
  Future<Map<String, dynamic>> fetchCoursesStats(String userId) async {
    try {
      // جلب المقررات من Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      // حساب عدد المقررات
      final totalCourses = querySnapshot.docs.length;

      // حساب إجمالي الساعات المعتمدة
      int totalCreditHours = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final creditHours = data['creditHours'] ?? 0;
        totalCreditHours += (creditHours as int);
      }

      return {
        'total': totalCourses,
        'creditHours': totalCreditHours,
        'courses': querySnapshot.docs.map((doc) => doc.data()).toList(),
      };
    } catch (e) {
      debugPrint('خطأ في جلب إحصائيات المقررات: $e');
      // إرجاع القيم الافتراضية في حالة حدوث خطأ
      return StatsConstants.defaultStats['courses'];
    }
  }

  /// جلب إحصائيات المهام للمستخدم
  Future<Map<String, dynamic>> fetchTasksStats(String userId) async {
    try {
      // جلب المهام من Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .get();

      // حساب إجمالي المهام
      final totalTasks = querySnapshot.docs.length;

      // حساب المهام المكتملة والمتأخرة
      int completedTasks = 0;
      int overdueTasks = 0;
      final now = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? '';

        // المهام المكتملة
        if (status == 'مكتملة') {
          completedTasks++;
        }

        // المهام المتأخرة
        final dueDateTimestamp = data['dueDate'] as Timestamp?;
        if (dueDateTimestamp != null) {
          final dueDate = dueDateTimestamp.toDate();
          if (dueDate.isBefore(now) && status != 'مكتملة') {
            overdueTasks++;
          }
        }
      }

      return {
        'total': totalTasks,
        'completed': completedTasks,
        'overdue': overdueTasks,
        'remaining': totalTasks - completedTasks,
      };
    } catch (e) {
      debugPrint('خطأ في جلب إحصائيات المهام: $e');
      // إرجاع القيم الافتراضية في حالة حدوث خطأ
      return StatsConstants.defaultStats['tasks'];
    }
  }

  /// جلب إحصائيات الحضور للمستخدم
  Future<Map<String, dynamic>> fetchAttendanceStats(String userId) async {
    try {
      // جلب بيانات الحضور من Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .get();

      // حساب إجمالي أيام الحضور
      final totalDays = querySnapshot.docs.length;

      // حساب أيام الحضور والغياب
      int presentDays = 0;
      int absentDays = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? '';

        if (status == 'حاضر') {
          presentDays++;
        } else if (status == 'غائب') {
          absentDays++;
        }
      }

      return {
        'total': totalDays,
        'present': presentDays,
        'absent': absentDays,
      };
    } catch (e) {
      debugPrint('خطأ في جلب إحصائيات الحضور: $e');
      // إرجاع القيم الافتراضية في حالة حدوث خطأ
      return StatsConstants.defaultStats['attendance'];
    }
  }

  /// جلب إحصائيات الاختبارات للمستخدم
  Future<Map<String, dynamic>> fetchExamsStats(String userId) async {
    try {
      // جلب الاختبارات من Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exams')
          .get();

      // حساب إجمالي الاختبارات
      final totalExams = querySnapshot.docs.length;

      // حساب الاختبارات القادمة والمكتملة
      int upcomingExams = 0;
      int completedExams = 0;
      final now = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final dateTimestamp = data['date'] as Timestamp?;
        final status = data['status'] ?? '';

        if (dateTimestamp != null) {
          final examDate = dateTimestamp.toDate();
          if (examDate.isAfter(now)) {
            upcomingExams++;
          }
        }

        if (status == 'مكتمل') {
          completedExams++;
        }
      }

      return {
        'total': totalExams,
        'upcoming': upcomingExams,
        'completed': completedExams,
      };
    } catch (e) {
      debugPrint('خطأ في جلب إحصائيات الاختبارات: $e');
      // إرجاع القيم الافتراضية في حالة حدوث خطأ
      return StatsConstants.defaultStats['exams'];
    }
  }
}
