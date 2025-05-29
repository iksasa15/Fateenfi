import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/course_model.dart';

class StatsFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // التحقق ما إذا كان المستخدم مسجل الدخول
  bool get isUserLoggedIn => currentUser != null;

  // الحصول على تدفق المقررات للمستخدم الحالي
  Stream<List<Course>> getCoursesStream() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('courses')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Course.fromMap(data, doc.id);
      }).toList();
    });
  }
}
