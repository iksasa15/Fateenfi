import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpcomingEventsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // اسم المجموعة في Firestore
  final String _eventsCollection = 'upcoming_events';

  // جلب المواعيد القادمة من Firestore
  Future<Map<String, dynamic>> getUpcomingEvents() async {
    try {
      // الحصول على المستخدم الحالي
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // الحصول على المواعيد الخاصة بالمستخدم
        final QuerySnapshot eventsSnapshot = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection(_eventsCollection)
            .get();

        if (eventsSnapshot.docs.isNotEmpty) {
          Map<String, dynamic> events = {};
          for (var doc in eventsSnapshot.docs) {
            events[doc.id] = doc.data();
          }
          return events;
        }
      }

      // في حالة عدم وجود مستخدم أو بيانات، نحصل على البيانات العامة
      final QuerySnapshot defaultEventsSnapshot =
          await _firestore.collection(_eventsCollection).get();

      if (defaultEventsSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> events = {};
        for (var doc in defaultEventsSnapshot.docs) {
          events[doc.id] = doc.data();
        }
        return events;
      }

      // إرجاع بيانات افتراضية إذا لم نجد أي بيانات
      return _getDefaultEventsData();
    } catch (e) {
      print('خطأ في الحصول على المواعيد القادمة: $e');

      // إرجاع بيانات افتراضية في حالة حدوث خطأ
      return _getDefaultEventsData();
    }
  }

  // بيانات افتراضية للعرض في حالة الخطأ
  Map<String, dynamic> _getDefaultEventsData() {
    return {
      '1': {
        'title': 'اختبار نصفي - مقدمة في البرمجة',
        'date': 'الثلاثاء، ١٠ يونيو',
        'type': 'exam',
        'isUrgent': true,
      },
      '2': {
        'title': 'تسليم واجب - هندسة البرمجيات',
        'date': 'الخميس، ١٢ يونيو',
        'type': 'assignment',
        'isUrgent': false,
      },
      '3': {
        'title': 'محاضرة استثنائية - تصميم قواعد البيانات',
        'date': 'الأحد، ١٥ يونيو',
        'type': 'lecture',
        'isUrgent': false,
      },
    };
  }
}
