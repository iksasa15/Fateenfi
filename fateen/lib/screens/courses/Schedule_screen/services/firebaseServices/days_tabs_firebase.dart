// days_tabs_firebase.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../models/course.dart';

class DaysTabsFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // جلب جميع المقررات للمستخدم الحالي
  Future<List<Course>> fetchUserCourses() async {
    if (currentUser == null) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('courses')
          .get();

      final List<Course> courses = snapshot.docs.map((doc) {
        final data = doc.data();
        return Course.fromMap(data, doc.id);
      }).toList();

      return courses;
    } catch (e) {
      debugPrint('حدث خطأ أثناء جلب المقررات من فايرستور: $e');
      return [];
    }
  }
}
