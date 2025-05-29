import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/next_lecture_constants.dart';

/// خدمة التعامل مع Firebase للمحاضرات
class NextLectureFirebase {
  // مراجع Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// جلب المقررات من Firebase
  Future<List<Map<String, dynamic>>> fetchCourses() async {
    if (currentUser == null) {
      debugPrint('لا يوجد مستخدم مسجل دخول لجلب المقررات');
      return [];
    }

    try {
      final userId = currentUser!.uid;
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      final loadedCourses = snapshot.docs.map((doc) {
        final data = doc.data();
        // استخدام courseName بدلاً من name للتوافق مع كلاس Course
        final name = data[NextLectureConstants.courseNameField] ??
            data[NextLectureConstants.courseOldNameField] ??
            '';
        return {
          NextLectureConstants.idField: doc.id,
          NextLectureConstants.courseNameField: name,
          NextLectureConstants.lectureTimeField:
              data[NextLectureConstants.lectureTimeField] ?? '',
          NextLectureConstants.classroomField:
              data[NextLectureConstants.classroomField] ?? '',
          NextLectureConstants.dayOfWeekField:
              data[NextLectureConstants.dayOfWeekField] ?? 0,
        };
      }).toList();

      debugPrint('تم جلب ${loadedCourses.length} مقرر بنجاح من Firebase');
      return loadedCourses;
    } catch (e) {
      debugPrint('حدث خطأ أثناء جلب المقررات من Firebase: $e');
      throw e;
    }
  }

  /// الاستماع للتغييرات في المقررات
  Stream<List<Map<String, dynamic>>> listenToCourses() {
    if (currentUser == null) {
      debugPrint('لا يوجد مستخدم مسجل دخول للاستماع للتغييرات في المقررات');
      return Stream.value([]);
    }

    try {
      final userId = currentUser!.uid;
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final name = data[NextLectureConstants.courseNameField] ??
              data[NextLectureConstants.courseOldNameField] ??
              '';
          return {
            NextLectureConstants.idField: doc.id,
            NextLectureConstants.courseNameField: name,
            NextLectureConstants.lectureTimeField:
                data[NextLectureConstants.lectureTimeField] ?? '',
            NextLectureConstants.classroomField:
                data[NextLectureConstants.classroomField] ?? '',
            NextLectureConstants.dayOfWeekField:
                data[NextLectureConstants.dayOfWeekField] ?? 0,
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('خطأ في إنشاء مستمع المقررات: $e');
      return Stream.value([]);
    }
  }
}
