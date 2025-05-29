import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/course.dart';
import '../constants/grades/course_grades_colors.dart';
import '../services/course_grades_service.dart';

class CourseGradesController extends ChangeNotifier {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final CourseGradesService _service = CourseGradesService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // خريطة لتخزين الدرجات القصوى المخصصة لكل تقييم في كل مقرر
  // المفتاح: معرّف المقرر + اسم التقييم
  final Map<String, double> _customMaxGrades = {};

  // قائمة بأنواع الدرجات الجاهزة
  final List<String> predefinedAssignments = [
    'اختبار دوري أول',
    'اختبار دوري ثاني',
    'اختبار نصفي',
    'اختبار نهائي',
    'واجب',
    'مشروع',
    'عملي',
    'أخرى'
  ];

  // قائمة بالدرجات القصوى الافتراضية لكل نوع تقييم
  final Map<String, double> defaultMaxGrades = {
    'اختبار دوري أول': 20.0,
    'اختبار دوري ثاني': 20.0,
    'اختبار نصفي': 30.0,
    'اختبار نهائي': 40.0,
    'واجب': 10.0,
    'مشروع': 20.0,
    'عملي': 15.0,
    'أخرى': 10.0
  };

  // الحصول على الدرجة القصوى الافتراضية لنوع تقييم معين
  double getDefaultMaxGrade(String assignmentType) {
    return defaultMaxGrades[assignmentType] ?? 100.0;
  }

  // الحصول على الدرجة القصوى المخصصة للتقييم في مقرر معين
  double getCustomMaxGrade(Course course, String assignmentType) {
    // طباعة تشخيصية
    print("DEBUG CONTROLLER: Getting custom max grade for $assignmentType");

    // أولاً نحاول الحصول على الدرجة القصوى من نموذج المقرر
    if (course.maxGrades.containsKey(assignmentType)) {
      double result = course.maxGrades[assignmentType]!;
      print("DEBUG CONTROLLER: Found in course model: $result");
      return result;
    }

    // ثانياً نحاول الحصول من الخريطة المحلية
    String key = '${course.id}:$assignmentType';
    if (_customMaxGrades.containsKey(key)) {
      double result = _customMaxGrades[key]!;
      print("DEBUG CONTROLLER: Found in local map: $result");
      return result;
    }

    // أخيراً نعود إلى القيمة الافتراضية
    double result = getDefaultMaxGrade(assignmentType);
    print("DEBUG CONTROLLER: Using default: $result");
    return result;
  }

  // حفظ الدرجة القصوى المخصصة للتقييم
  void saveCustomMaxGrade(
      Course course, String assignmentType, double maxGrade) {
    print(
        "DEBUG CONTROLLER: Saving custom max grade $maxGrade for $assignmentType");

    if (course.id == null || assignmentType.trim().isEmpty) {
      print("DEBUG CONTROLLER: Invalid data for saving custom max grade");
      return;
    }

    String key = '${course.id}:$assignmentType';
    _customMaxGrades[key] = maxGrade;

    // أيضا نحفظها في خريطة المقرر
    course.maxGrades[assignmentType] = maxGrade;

    print(
        "DEBUG CONTROLLER: Saved max grade: ${course.maxGrades[assignmentType]}");
  }

  // إضافة أو تعديل درجة مع حفظ الدرجة القصوى
  Future<bool> saveGrade(Course course, String? oldAssignment,
      String newAssignment, double actualGrade, double maxGrade) async {
    print(
        "DEBUG CONTROLLER: saveGrade called with $actualGrade/$maxGrade for $newAssignment");

    if (newAssignment.trim().isEmpty) {
      _errorMessage = 'اسم التقييم فارغ!';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // CRITICAL FIX: تمرير الدرجة الفعلية والقصوى مباشرة
      final bool result = await _service.saveGrade(
          course,
          currentUser,
          oldAssignment,
          newAssignment,
          actualGrade, // الدرجة الفعلية
          maxGrade // الدرجة القصوى
          );

      // التحقق من القيم بعد الحفظ
      if (course.grades.containsKey(newAssignment)) {
        double savedGrade = course.grades[newAssignment]!;
        double savedMaxGrade = course.maxGrades[newAssignment]!;

        print(
            "DEBUG CONTROLLER: After save, grade in course = $savedGrade/$savedMaxGrade");

        // التحقق من صحة التخزين
        if (savedGrade != actualGrade) {
          print(
              "WARNING CONTROLLER: Grade mismatch! Expected $actualGrade but got $savedGrade");
        }
      } else {
        print("DEBUG CONTROLLER: Assignment not found in course after save!");
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'حدث خطأ أثناء حفظ الدرجة: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  // حذف درجة
  Future<bool> deleteGrade(Course course, String assignment) async {
    if (assignment.trim().isEmpty) {
      _errorMessage = 'اسم التقييم فارغ!';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bool result =
          await _service.deleteGrade(course, currentUser, assignment);

      _isLoading = false;
      // تنبيه المستمعين بعد تحديث البيانات للتأكد من تحديث واجهة المستخدم
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'حدث خطأ أثناء حذف الدرجة: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  // دالة مساعدة للحصول على لون الدرجة
  Color getGradeColor(double actualGrade, double maxGrade) {
    // حساب النسبة المئوية للون
    double percentage = maxGrade > 0 ? (actualGrade / maxGrade) * 100 : 0.0;

    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return CourseGradesColors.darkPurple;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 60) return Colors.orange;
    return CourseGradesColors.accentColor;
  }

  void clearErrors() {
    _errorMessage = null;
    notifyListeners();
  }

  // يستخدم لتحديث واجهة المستخدم بشكل مباشر
  void refreshUI() {
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
