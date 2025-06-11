import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCategoriesService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // اسم المجموعة في Firestore
  final String _tasksCollection = 'tasks';
  final String _categoriesCollection = 'task_categories';

  // جلب بيانات فئات المهام من Firestore
  Future<Map<String, dynamic>> getTaskCategories() async {
    try {
      // الحصول على المستخدم الحالي
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // الحصول على بيانات فئات المهام للمستخدم
        final DocumentSnapshot categoriesDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection(_categoriesCollection)
            .doc('summary')
            .get();

        if (categoriesDoc.exists && categoriesDoc.data() != null) {
          return categoriesDoc.data() as Map<String, dynamic>;
        }

        // إذا لم يكن هناك ملخص جاهز، قم بحساب الإحصائيات من المهام الفعلية
        final QuerySnapshot tasksSnapshot = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection(_tasksCollection)
            .get();

        if (tasksSnapshot.docs.isNotEmpty) {
          int urgentCount = 0;
          int upcomingCount = 0;
          int completedCount = 0;

          for (var doc in tasksSnapshot.docs) {
            final Map<String, dynamic> task =
                doc.data() as Map<String, dynamic>;

            // حساب المهام حسب الفئة
            if (task['isCompleted'] == true) {
              completedCount++;
            } else {
              // التحقق مما إذا كانت المهمة عاجلة
              if (task['isUrgent'] == true || task['priority'] == 'high') {
                urgentCount++;
              }

              // التحقق مما إذا كانت المهمة قادمة
              if (task['dueDate'] != null) {
                upcomingCount++;
              }
            }
          }

          // إرجاع الإحصائيات المحسوبة
          return {
            'urgent': urgentCount,
            'upcoming': upcomingCount,
            'completed': completedCount,
            'all': tasksSnapshot.docs.length,
          };
        }
      }

      // في حالة عدم وجود مستخدم أو بيانات، استخدم بيانات افتراضية
      return _getDefaultCategoriesData();
    } catch (e) {
      print('خطأ في الحصول على بيانات فئات المهام: $e');

      // إرجاع بيانات افتراضية في حالة الخطأ
      return _getDefaultCategoriesData();
    }
  }

  // بيانات افتراضية لفئات المهام
  Map<String, dynamic> _getDefaultCategoriesData() {
    return {
      'urgent': 3,
      'upcoming': 5,
      'completed': 12,
      'all': 20,
    };
  }
}
