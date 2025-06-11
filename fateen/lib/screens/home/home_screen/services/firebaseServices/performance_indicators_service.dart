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

  // حساب معدل الدرجات - تم تعديل هذه الدالة لحساب المعدل الفعلي
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

      double totalGradePoints = 0;
      double totalPossiblePoints = 0;

      // حساب مجموع الدرجات ومجموع الدرجات الممكنة
      for (var doc in coursesSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // استخراج بيانات الدرجات والدرجات القصوى
        Map<String, dynamic> gradesData = data['grades'] ?? {};
        Map<String, dynamic> maxGradesData = data['maxGrades'] ?? {};

        if (gradesData.isEmpty) {
          continue; // تخطي المقررات التي ليس لها درجات
        }

        // حساب مجموع نقاط الدرجات لهذا المقرر
        gradesData.forEach((key, value) {
          double gradeValue = 0;
          if (value is int) {
            gradeValue = value.toDouble();
          } else if (value is double) {
            gradeValue = value;
          } else if (value is String) {
            gradeValue = double.tryParse(value) ?? 0.0;
          }

          // الحصول على الدرجة القصوى لهذا التقييم
          double maxGrade = 100.0;
          if (maxGradesData.containsKey(key)) {
            var maxValue = maxGradesData[key];
            if (maxValue is int) {
              maxGrade = maxValue.toDouble();
            } else if (maxValue is double) {
              maxGrade = maxValue;
            } else if (maxValue is String) {
              maxGrade = double.tryParse(maxValue) ?? 100.0;
            }
          }

          // إضافة النقاط إلى المجموع
          totalGradePoints += gradeValue;
          totalPossiblePoints += maxGrade;
        });
      }

      // التحقق من وجود نقاط ممكنة
      if (totalPossiblePoints == 0) {
        return 78; // قيمة افتراضية إذا لم تكن هناك نقاط ممكنة
      }

      // حساب النسبة المئوية للمعدل
      double averagePercentage = (totalGradePoints / totalPossiblePoints) * 100;

      // تحويل النسبة إلى عدد صحيح
      return averagePercentage.round();
    } catch (e) {
      print('خطأ في حساب معدل الدرجات: $e');
      print(e.toString());
      return 78; // قيمة افتراضية في حالة الخطأ
    }
  }
}
