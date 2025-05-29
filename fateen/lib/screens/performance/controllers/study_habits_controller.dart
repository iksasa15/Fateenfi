import 'package:flutter/material.dart';
import '../../../models/student_performance_model.dart';
import '../services/student_performance_service.dart';

/// وحدة التحكم بنموذج عادات الدراسة
/// مسؤولة عن إدارة حالة بيانات عادات الدراسة وتوفير واجهة للتفاعل معها
class StudyHabitsController extends ChangeNotifier {
  //
  // ============ متغيرات الحالة ============
  //

  // عادات الدراسة والتحليل
  StudentHabits _habits = StudentHabits(
    sleepHours: 7,
    studyHoursDaily: 2,
    studyHoursWeekly: 10,
    understandingLevel: 3,
    distractionLevel: 3,
    hasHealthIssues: false,
    learningStyle: 'visual',
    additionalNotes: '',
  );

  // وحدات التحكم بنماذج الإدخال
  final formKey = GlobalKey<FormState>();
  final sleepHoursController = TextEditingController(text: '7');
  final studyHoursDailyController = TextEditingController(text: '2');
  final studyHoursWeeklyController = TextEditingController(text: '10');

  //
  // ============ الواجهة العامة (Getters) ============
  //

  // البيانات الأساسية
  StudentHabits get habits => _habits;

  //
  // ============ دورة حياة وحدة التحكم ============
  //

  /// المنشئ - يقوم بتحميل بيانات عادات الدراسة عند إنشاء وحدة التحكم
  StudyHabitsController() {
    _loadSavedStudyHabits();
  }

  /// تنظيف الموارد عند التخلص من وحدة التحكم
  @override
  void dispose() {
    sleepHoursController.dispose();
    studyHoursDailyController.dispose();
    studyHoursWeeklyController.dispose();
    super.dispose();
  }

  //
  // ============ وظائف تحميل وتهيئة البيانات ============
  //

  /// تحميل عادات الدراسة المحفوظة
  Future<void> _loadSavedStudyHabits() async {
    final savedHabits = await StudentPerformanceService.getSavedStudyHabits();
    if (savedHabits != null) {
      _habits = savedHabits;
      sleepHoursController.text = _habits.sleepHours.toString();
      studyHoursDailyController.text = _habits.studyHoursDaily.toString();
      studyHoursWeeklyController.text = _habits.studyHoursWeekly.toString();
      notifyListeners();
    }
  }

  /// تهيئة وحدة التحكم ببيانات خارجية
  /// @param externalHabits - عادات الدراسة الخارجية
  void initializeWithExternalData(StudentHabits externalHabits) {
    _habits = externalHabits;
    sleepHoursController.text = _habits.sleepHours.toString();
    studyHoursDailyController.text = _habits.studyHoursDaily.toString();
    studyHoursWeeklyController.text = _habits.studyHoursWeekly.toString();
    notifyListeners();
  }

  //
  // ============ وظائف تحديث البيانات ============
  //

  /// تحديث عادات الطالب الدراسية
  Future<void> updateHabits({
    int? sleepHours,
    int? studyHoursDaily,
    int? studyHoursWeekly,
    int? understandingLevel,
    int? distractionLevel,
    bool? hasHealthIssues,
    String? learningStyle,
    String? additionalNotes,
  }) async {
    _habits = StudentHabits(
      sleepHours: sleepHours ?? _habits.sleepHours,
      studyHoursDaily: studyHoursDaily ?? _habits.studyHoursDaily,
      studyHoursWeekly: studyHoursWeekly ?? _habits.studyHoursWeekly,
      understandingLevel: understandingLevel ?? _habits.understandingLevel,
      distractionLevel: distractionLevel ?? _habits.distractionLevel,
      hasHealthIssues: hasHealthIssues ?? _habits.hasHealthIssues,
      learningStyle: learningStyle ?? _habits.learningStyle,
      additionalNotes: additionalNotes ?? _habits.additionalNotes,
    );

    // حفظ العادات في التخزين
    await StudentPerformanceService.saveStudyHabits(_habits);

    notifyListeners();
  }

  /// تحديث عادات الدراسة بناءً على نموذج كامل
  Future<void> updateStudyHabitsFromForm(StudentHabits newHabits) async {
    _habits = newHabits;

    // تحديث التحكم بالنص
    sleepHoursController.text = _habits.sleepHours.toString();
    studyHoursDailyController.text = _habits.studyHoursDaily.toString();
    studyHoursWeeklyController.text = _habits.studyHoursWeekly.toString();

    // حفظ العادات في التخزين
    await StudentPerformanceService.saveStudyHabits(_habits);

    notifyListeners();
  }
}
