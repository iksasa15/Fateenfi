import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UpcomingEventsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب المواعيد القادمة من Firestore
  Future<Map<String, dynamic>> getUpcomingEvents() async {
    try {
      // الحصول على المستخدم الحالي
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // الحصول على المهام القادمة
        final QuerySnapshot tasksSnapshot = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('tasks')
            .where('status', whereIn: ['قيد التنفيذ', 'معلقة'])
            .where('dueDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
            .orderBy('dueDate')
            .limit(5)
            .get();

        // الحصول على المواعيد من التقويم
        final QuerySnapshot countdownsSnapshot = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('countdowns')
            .where('targetDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
            .orderBy('targetDate')
            .limit(5)
            .get();

        // تحويل المهام والمواعيد إلى تنسيق موحد
        Map<String, dynamic> events = {};
        int eventId = 1;

        // إضافة المهام
        for (var doc in tasksSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final dueDate = (data['dueDate'] as Timestamp).toDate();

          // تنسيق التاريخ بالعربية
          final formattedDate = _formatDateInArabic(dueDate);

          // تحديد نوع الحدث والأولوية
          String eventType = 'assignment';
          bool isUrgent = false;

          if (data['priority'] == 'عالية') {
            isUrgent = true;
          }

          events[eventId.toString()] = {
            'title': data['name'],
            'date': formattedDate,
            'type': eventType,
            'isUrgent': isUrgent,
            'originalId': doc.id,
            'source': 'tasks',
          };

          eventId++;
        }

        // إضافة المواعيد من التقويم
        for (var doc in countdownsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final targetDate = (data['targetDate'] is Timestamp)
              ? (data['targetDate'] as Timestamp).toDate()
              : DateTime.parse(data['targetDate'].toString());

          // تنسيق التاريخ بالعربية
          final formattedDate = _formatDateInArabic(targetDate);

          // حساب الأيام المتبقية لتحديد الأولوية
          final daysLeft = targetDate.difference(DateTime.now()).inDays;

          events[eventId.toString()] = {
            'title': data['title'],
            'date': formattedDate,
            'type': 'event',
            'isUrgent': daysLeft <= 1, // تعتبر عاجلة إذا كان متبقي يوم أو أقل
            'originalId': data['id'].toString(),
            'source': 'countdowns',
          };

          eventId++;
        }

        // إذا كان هناك أحداث
        if (events.isNotEmpty) {
          return events;
        }
      }

      // في حالة عدم وجود مستخدم أو بيانات، استخدم البيانات الافتراضية
      return _getDefaultEventsData();
    } catch (e) {
      print('خطأ في الحصول على المواعيد القادمة: $e');

      // إرجاع بيانات افتراضية في حالة حدوث خطأ
      return _getDefaultEventsData();
    }
  }

  // تنسيق التاريخ بالعربية
  String _formatDateInArabic(DateTime date) {
    // أسماء الأيام بالعربية
    final List<String> arabicDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];

    // اسم اليوم
    final String dayName = arabicDays[date.weekday - 1];

    // رقم اليوم والشهر والسنة
    final String formattedDate =
        '$dayName، ${date.day}/${date.month}/${date.year}';

    return formattedDate;
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
