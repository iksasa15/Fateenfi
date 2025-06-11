import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../models/task.dart';
import '../../../../../models/course.dart';

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
        // حساب نسبة إنجاز المهام
        final tasksCompletion =
            await _calculateTasksCompletion(currentUser.uid);

        // حساب متوسط الدرجات
        final gradesAverage = await _calculateGradesAverage(currentUser.uid);

        return {
          'tasksCompletion': tasksCompletion,
          'gradesAverage': gradesAverage,
        };
      }

      // في حالة عدم وجود مستخدم، استخدم القيم الافتراضية
      return {
        'tasksCompletion': 85,
        'gradesAverage': 78,
      };
    } catch (e) {
      print('خطأ في الحصول على بيانات الأداء: $e');

      // إرجاع قيم افتراضية في حالة حدوث خطأ
      return {
        'tasksCompletion': 85,
        'gradesAverage': 78,
      };
    }
  }

  // حساب نسبة إنجاز المهام
  Future<int> _calculateTasksCompletion(String userId) async {
    try {
      // جلب إحصائيات المهام
      QuerySnapshot tasksSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .get();

      if (tasksSnapshot.docs.isEmpty) {
        return 85; // قيمة افتراضية إذا لم تكن هناك مهام
      }

      int totalTasks = tasksSnapshot.docs.length;
      int completedTasks = 0;

      // حساب عدد المهام المكتملة
      for (var doc in tasksSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['status'] == 'مكتملة') {
          completedTasks++;
        }
      }

      // حساب النسبة المئوية للإنجاز
      double completionRate = (completedTasks / totalTasks) * 100;

      // تحويل النسبة إلى عدد صحيح
      return completionRate.round();
    } catch (e) {
      print('خطأ في حساب نسبة إنجاز المهام: $e');
      return 85; // قيمة افتراضية في حالة الخطأ
    }
  }

  // حساب متوسط الدرجات
  Future<int> _calculateGradesAverage(String userId) async {
    try {
      // جلب المقررات
      QuerySnapshot coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      if (coursesSnapshot.docs.isEmpty) {
        return 78; // قيمة افتراضية إذا لم تكن هناك مقررات
      }

      double totalWeightedGrades = 0;
      int totalCreditHours = 0;

      // حساب المتوسط المرجح للدرجات
      for (var doc in coursesSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Course course = Course.fromMap(data, doc.id);

        // الحصول على مجموع الدرجات في المقرر
        double courseTotal = course.totalGrades;

        // التحقق من وجود درجات في المقرر
        if (course.grades.isNotEmpty) {
          // إضافة الدرجة المرجحة للمجموع
          totalWeightedGrades += courseTotal * course.creditHours;
          totalCreditHours += course.creditHours;
        }
      }

      // التحقق من وجود ساعات معتمدة
      if (totalCreditHours == 0) {
        return 78; // قيمة افتراضية إذا لم تكن هناك ساعات معتمدة
      }

      // حساب المتوسط المرجح
      double averageGrade = totalWeightedGrades / totalCreditHours;

      // تحويل المتوسط إلى نسبة مئوية (افتراض أن الدرجة القصوى هي 100)
      double averagePercentage = averageGrade;

      // تحويل النسبة إلى عدد صحيح
      return averagePercentage.round();
    } catch (e) {
      print('خطأ في حساب متوسط الدرجات: $e');
      return 78; // قيمة افتراضية في حالة الخطأ
    }
  }
}
