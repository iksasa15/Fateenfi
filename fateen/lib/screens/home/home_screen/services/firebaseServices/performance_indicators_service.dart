import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerformanceIndicatorsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // اسم المجموعة في Firestore
  final String _performanceCollection = 'performance_indicators';

  // جلب بيانات الأداء من Firestore
  Future<Map<String, dynamic>> getPerformanceData() async {
    try {
      // الحصول على المستخدم الحالي
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // الحصول على بيانات الأداء للمستخدم الحالي
        final DocumentSnapshot performanceDoc = await _firestore
            .collection(_performanceCollection)
            .doc(currentUser.uid)
            .get();

        if (performanceDoc.exists && performanceDoc.data() != null) {
          return performanceDoc.data() as Map<String, dynamic>;
        }
      }

      // في حالة عدم وجود مستخدم أو عدم وجود بيانات، استخدم القيم الافتراضية
      return {
        'attendance': 92,
        'tasksCompletion': 85,
        'gradesAverage': 78,
        'activities': 60,
      };
    } catch (e) {
      print('خطأ في الحصول على بيانات الأداء: $e');

      // إرجاع قيم افتراضية في حالة حدوث خطأ
      return {
        'attendance': 92,
        'tasksCompletion': 85,
        'gradesAverage': 78,
        'activities': 60,
      };
    }
  }
}
