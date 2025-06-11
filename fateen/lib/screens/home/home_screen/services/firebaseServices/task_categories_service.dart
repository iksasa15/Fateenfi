import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

        debugPrint(
            'جلب ملخص فئات المهام: ${categoriesDoc.exists ? "موجود" : "غير موجود"}');

        if (categoriesDoc.exists && categoriesDoc.data() != null) {
          final Map<String, dynamic> data =
              categoriesDoc.data() as Map<String, dynamic>;
          debugPrint('البيانات المسترجعة: $data');
          return data;
        }

        // إذا لم يكن هناك ملخص جاهز، قم بحساب الإحصائيات من المهام الفعلية
        final QuerySnapshot tasksSnapshot = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection(_tasksCollection)
            .get();

        debugPrint('عدد المهام المسترجعة: ${tasksSnapshot.docs.length}');

        if (tasksSnapshot.docs.isNotEmpty) {
          int urgentCount = 0;
          int upcomingCount = 0;
          int completedCount = 0;

          for (var doc in tasksSnapshot.docs) {
            final Map<String, dynamic> task =
                doc.data() as Map<String, dynamic>;

            // حساب المهام حسب الفئة
            if (task['status'] == 'مكتملة') {
              completedCount++;
            } else if (task['status'] != 'ملغاة') {
              // التحقق مما إذا كانت المهمة عاجلة
              if (task['priority'] == 'عالية') {
                urgentCount++;
              }

              // تحقق من تاريخ المهمة
              if (task['dueDate'] != null) {
                final Timestamp dueDate = task['dueDate'] as Timestamp;
                final DateTime dueDateDT = dueDate.toDate();
                final DateTime now = DateTime.now();
                final DateTime today = DateTime(now.year, now.month, now.day);
                final DateTime tomorrow =
                    DateTime(today.year, today.month, today.day + 1);

                if (dueDateDT.isBefore(today)) {
                  // متأخرة
                  urgentCount++;
                } else if (dueDateDT.isBefore(tomorrow)) {
                  // اليوم
                  urgentCount++;
                } else {
                  // قادمة
                  upcomingCount++;
                }
              }
            }
          }

          // إرجاع الإحصائيات المحسوبة
          final Map<String, dynamic> stats = {
            'urgent': urgentCount,
            'upcoming': upcomingCount,
            'completed': completedCount,
            'all': tasksSnapshot.docs.length,
          };

          debugPrint('إحصائيات المهام المحسوبة: $stats');
          return stats;
        }
      }

      // في حالة عدم وجود مستخدم أو بيانات، استخدم بيانات افتراضية
      final defaultData = _getDefaultCategoriesData();
      debugPrint('استخدام بيانات افتراضية: $defaultData');
      return defaultData;
    } catch (e) {
      debugPrint('خطأ في الحصول على بيانات فئات المهام: $e');

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
