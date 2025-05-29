import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/course.dart';

class CourseGradesService {
  // إضافة أو تعديل درجة
  Future<bool> saveGrade(
    Course course,
    User? currentUser,
    String? oldAssignment,
    String newAssignment,
    double actualGrade, // الدرجة الفعلية
    double maxGrade, // الدرجة القصوى
  ) async {
    try {
      // طباعة تشخيصية
      print(
          "DEBUG SERVICE: Saving grade $actualGrade/$maxGrade for $newAssignment");

      // التحقق من صحة البيانات
      if (newAssignment.trim().isEmpty) {
        throw Exception('اسم التقييم فارغ!');
      }

      if (actualGrade < 0 || actualGrade > maxGrade) {
        throw Exception('الدرجة يجب أن تكون بين 0 و $maxGrade!');
      }

      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول!');
      }

      // CRITICAL FIX: التخزين المباشر للدرجات الفعلية
      // إضافة أو تعديل الدرجة
      if (oldAssignment != null && oldAssignment.isNotEmpty) {
        course.editGrade(oldAssignment, newAssignment, actualGrade, maxGrade);
      } else {
        course.createGrade(newAssignment, actualGrade, maxGrade);
      }

      // طباعة تشخيصية قبل الحفظ في قاعدة البيانات
      print(
          "DEBUG SERVICE: Before saving to Firestore - grade=${course.grades[newAssignment]}, maxGrade=${course.maxGrades[newAssignment]}");

      // حفظ البيانات في Firestore
      await course.saveToFirestore(currentUser);

      // التحقق بعد الحفظ
      print(
          "DEBUG SERVICE: After saving to Firestore - grade=${course.grades[newAssignment]}, maxGrade=${course.maxGrades[newAssignment]}");

      return true;
    } catch (e) {
      debugPrint('حدث خطأ أثناء حفظ الدرجة: $e');
      rethrow;
    }
  }

  // حذف درجة
  Future<bool> deleteGrade(
    Course course,
    User? currentUser,
    String assignment,
  ) async {
    try {
      // التحقق من صحة البيانات
      if (assignment.trim().isEmpty) {
        throw Exception('اسم التقييم فارغ!');
      }

      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول!');
      }

      // حذف الدرجة - التأكد من أن الحذف من الكائن المحلي يتم بشكل صحيح
      if (!course.grades.containsKey(assignment)) {
        throw Exception('الدرجة غير موجودة!');
      }

      course.deleteGrade(assignment);

      // حفظ التغييرات في Firestore
      await course.saveToFirestore(currentUser);

      // تأكد من نجاح الحذف محلياً
      if (course.grades.containsKey(assignment)) {
        throw Exception('فشل حذف الدرجة محلياً!');
      }

      return true;
    } catch (e) {
      debugPrint('حدث خطأ أثناء حذف الدرجة: $e');
      rethrow;
    }
  }

  // تحديث كامل للمقرر (إذا لزم الأمر)
  Future<void> refreshCourseData(Course course, User? currentUser) async {
    try {
      if (currentUser == null || course.id == null) {
        throw Exception('بيانات غير كافية لتحديث المقرر');
      }

      // يمكن هنا استرجاع بيانات المقرر من Firestore مباشرة
      // لكن هذا خارج نطاق هذا الملف حالياً
    } catch (e) {
      debugPrint('حدث خطأ أثناء تحديث بيانات المقرر: $e');
      rethrow;
    }
  }
}
