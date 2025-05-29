import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/course.dart';

class CourseDeleteController extends ChangeNotifier {
  User? currentUser = FirebaseAuth.instance.currentUser;

  // حذف مقرر
  Future<bool> deleteCourse(Course course) async {
    try {
      await course.deleteFromFirestore(currentUser);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('حدث خطأ أثناء حذف المقرر: $e');
      return false;
    }
  }
}
