import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../models/course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // جلب جميع المقررات للمستخدم الحالي
  Future<List<Course>> getCourses() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("المستخدم غير مسجل الدخول");
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('courses')
          .get();

      return snapshot.docs
          .map((doc) => Course.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception("حدث خطأ أثناء جلب المقررات: $e");
    }
  }

  // جلب بيانات المقررات بتنسيق حاسبة GPA
  Future<List<Map<String, dynamic>>> getCoursesForGPA() async {
    try {
      final courses = await getCourses();
      return courses.map((course) => course.toGPAFormat()).toList();
    } catch (e) {
      throw Exception("حدث خطأ أثناء تحضير بيانات المقررات للمعدل: $e");
    }
  }
}
