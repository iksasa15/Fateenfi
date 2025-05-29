import 'package:flutter/material.dart';
import '../../../models/student_performance_model.dart';
import '../services/student_performance_service.dart';
import '../../../models/course.dart';
import '../../../models/student.dart';
import '../controllers/files_statistics_controller.dart';
import '../controllers/study_habits_controller.dart';
import '../controllers/performance_analysis_controller.dart';

/// وحدة التحكم بأداء الطالب
/// مسؤولة عن إدارة حالة بيانات أداء الطالب وتوفير واجهة للتفاعل معها
class StudentPerformanceController extends ChangeNotifier {
  //
  // ============ متغيرات الحالة ============
  //

  // حالة التحميل والأخطاء
  bool _isLoading = true;
  String _error = '';
  bool _isInitialized = false;

  // بيانات الطالب الأساسية
  Student? _student;
  List<Course> _courses = [];
  double _overallAverage = 0.0;
  Map<String, int> _gradeDistribution = {};

  // كنترولر إحصائيات الملفات وعادات الدراسة وتحليل الأداء
  final FilesStatisticsController filesStatisticsController =
      FilesStatisticsController();
  final StudyHabitsController studyHabitsController = StudyHabitsController();
  final PerformanceAnalysisController performanceAnalysisController =
      PerformanceAnalysisController();

  //
  // ============ الواجهة العامة (Getters) ============
  //

  // معلومات الحالة
  bool get isLoading => _isLoading;
  String get error => _error;

  // البيانات الأساسية
  List<Course> get courses => _courses;
  StudentHabits get habits => studyHabitsController.habits;
  Student? get student => _student;
  double get overallAverage => _overallAverage;
  Map<String, int> get gradeDistribution => _gradeDistribution;

  // واجهات الكنترولرز الفرعية
  PerformanceAnalysisController get analysisController =>
      performanceAnalysisController;

  //
  // ============ دورة حياة وحدة التحكم ============
  //

  /// المنشئ - يقوم بتحميل بيانات الطالب عند إنشاء وحدة التحكم
  StudentPerformanceController() {
    _loadStudentData();
  }

  //
  // ============ وظائف تحميل وتهيئة البيانات ============
  //

  /// تهيئة وحدة التحكم ببيانات خارجية
  /// @param externalCourses - المقررات الدراسية
  /// @param externalAverage - المعدل التراكمي
  /// @param externalGradeDistribution - توزيع الدرجات
  void initializeWithExternalData(List<Course> externalCourses,
      double externalAverage, Map<String, int> externalGradeDistribution) {
    // تفادي التهيئة المتكررة
    if (_isInitialized) return;
    _isInitialized = true;

    // تعيين البيانات المستلمة
    if (externalCourses.isNotEmpty) {
      _courses = externalCourses;
      _overallAverage = externalAverage;
      _gradeDistribution = externalGradeDistribution;

      // تحديث المعدل التراكمي في التحليل
      performanceAnalysisController.updateAnalysisGPA(externalAverage);

      // حساب إحصائيات الملفات
      filesStatisticsController.calculateFilesStatistics(_courses);

      // إجراء تحليل محلي
      performanceAnalysisController.performLocalAnalysis(
          _courses, studyHabitsController.habits);

      // انتهاء التحميل
      _isLoading = false;
    }

    notifyListeners();
  }

  /// تحميل بيانات الطالب والمقررات
  Future<void> _loadStudentData() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // تحميل بيانات الطالب
      _student = await StudentPerformanceService.getCurrentStudent();

      // تحميل المقررات إذا لم يتم تهيئتها من البيانات الموجودة
      if (_courses.isEmpty) {
        _courses = await StudentPerformanceService.getStudentCourses();
      }

      // حساب إحصائيات الملفات
      filesStatisticsController.calculateFilesStatistics(_courses);

      // تحميل التحليل المحفوظ
      await performanceAnalysisController.loadSavedAnalysis();

      // إذا لم يكن هناك تحليل محفوظ، قم بإنشاء تحليل محلي
      if (!performanceAnalysisController.hasAnalysis) {
        performanceAnalysisController.performLocalAnalysis(
            _courses, studyHabitsController.habits);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  //
  // ============ وظائف تحديث البيانات ============
  //

  /// تحديث عادات الطالب الدراسية وإعادة التحليل
  Future<void> updateStudyHabits(StudentHabits newHabits) async {
    // تحديث عادات الدراسة في الكنترولر المخصص
    await studyHabitsController.updateStudyHabitsFromForm(newHabits);

    // إعادة التحليل لتحديث نتائج التحليل المحلي
    performanceAnalysisController.performLocalAnalysis(
        _courses, studyHabitsController.habits);

    notifyListeners();
  }

  /// تحديث البيانات وإعادة التحليل المحلي
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // إعادة حساب إحصائيات الملفات
      filesStatisticsController.calculateFilesStatistics(_courses);

      // إعادة حساب المعدل التراكمي
      if (_courses.isNotEmpty) {
        _overallAverage = StudentPerformanceService.calculateGPA(_courses);
        performanceAnalysisController.updateAnalysisGPA(_overallAverage);
      }

      // تحليل نقاط القوة والضعف محلياً مرة أخرى
      performanceAnalysisController.performLocalAnalysis(
          _courses, studyHabitsController.habits);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  //
  // ============ واجهة لوظائف تحليل الأداء ============
  //

  /// تحليل أداء الطالب باستخدام الذكاء الاصطناعي
  Future<void> analyzePerformance() async {
    await performanceAnalysisController.analyzePerformance(
        _courses, studyHabitsController.habits, _student);
    notifyListeners();
  }

  /// توليد خطة دراسية جديدة
  Future<void> generateNewStudyPlan() async {
    await performanceAnalysisController.generateNewStudyPlan(
        _courses, studyHabitsController.habits);
    notifyListeners();
  }

  /// طلب موارد تعليمية إضافية
  Future<void> requestMoreResources() async {
    await performanceAnalysisController.requestMoreResources(
        _courses, studyHabitsController.habits);
    notifyListeners();
  }

  /// إعادة تعيين التحليل
  void resetAnalysis() {
    performanceAnalysisController.resetAnalysis();
    notifyListeners();
  }
}
