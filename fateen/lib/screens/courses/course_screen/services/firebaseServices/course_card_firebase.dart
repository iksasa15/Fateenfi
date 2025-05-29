// course_card_firebase.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../models/course.dart';

class CourseCardFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على معرّف المستخدم الحالي
  String? get currentUserId => _auth.currentUser?.uid;

  // جلب قائمة المقررات من فايرستور
  Future<List<Course>> fetchCourses() async {
    try {
      if (currentUserId == null) {
        return [];
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('courses')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Course.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('خطأ في جلب المقررات: $e');
      return [];
    }
  }

  // جلب مقرر محدد بواسطة المعرّف
  Future<Course?> getCourseById(String courseId) async {
    try {
      if (currentUserId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('courses')
          .doc(courseId)
          .get();

      if (doc.exists) {
        return Course.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في جلب المقرر: $e');
      return null;
    }
  }

  // إنشاء مستمع للتغييرات في المقررات
  Stream<List<Course>> coursesStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('courses')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Course.fromMap(doc.data(), doc.id);
            }).toList());
  }
}
