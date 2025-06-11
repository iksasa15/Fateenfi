import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SemesterProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // مجموعة البيانات في Firestore
  final String _semesterCollection = 'semester_data';

  // الحصول على بيانات الفصل الدراسي
  Future<Map<String, dynamic>> getSemesterData() async {
    try {
      // الحصول على المستخدم الحالي
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // الحصول على بيانات الفصل الدراسي المرتبطة بالمستخدم
        final DocumentSnapshot semesterDoc = await _firestore
            .collection(_semesterCollection)
            .doc(currentUser.uid)
            .get();

        if (semesterDoc.exists && semesterDoc.data() != null) {
          return semesterDoc.data() as Map<String, dynamic>;
        }
      }

      // إذا لم يتم العثور على بيانات للمستخدم، نحصل على البيانات العامة
      final DocumentSnapshot defaultSemesterDoc =
          await _firestore.collection(_semesterCollection).doc('default').get();

      if (defaultSemesterDoc.exists && defaultSemesterDoc.data() != null) {
        return defaultSemesterDoc.data() as Map<String, dynamic>;
      }

      // إرجاع قيم افتراضية إذا لم يتم العثور على أي بيانات
      return {
        'totalDays': 105,
        'passedDays': 65,
        'startDate': '2025-03-15',
        'endDate': '2025-06-28',
      };
    } catch (e) {
      print('خطأ في الحصول على بيانات الفصل الدراسي: $e');

      // إرجاع قيم افتراضية في حالة حدوث خطأ
      return {
        'totalDays': 105,
        'passedDays': 65,
        'startDate': '2025-03-15',
        'endDate': '2025-06-28',
      };
    }
  }
}
