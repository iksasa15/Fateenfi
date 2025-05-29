// days_tabs_firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../models/course.dart';

class DaysTabsFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// جلب المقررات من فايرستور للمستخدم الحالي
  Future<List<Course>> fetchUserCourses() async {
    try {
      if (currentUser == null) {
        return [];
      }

      final userId = currentUser!.uid;
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Course.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('حدث خطأ أثناء جلب المقررات: $e');
      return [];
    }
  }
}
