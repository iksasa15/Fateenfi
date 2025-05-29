import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/student_performance_model.dart';
import '../services/student_performance_service.dart';
import '../../../models/course.dart';
import '../../../models/student.dart';

/// وحدة التحكم بتحليل أداء الطالب
/// مسؤولة عن إدارة حالة تحليل البيانات وتحليلها وتوفير واجهة للتفاعل معها
class PerformanceAnalysisController extends ChangeNotifier {
  //
  // ============ متغيرات الحالة ============
  //

  // حالة التحليل والأخطاء
  bool _isAnalysisLoading = false;
  bool _hasAnalysis = false;
  String _error = '';

  // حالة تقدم التحليل
  bool _showAnalyzingProgress = false;
  String _analysisProgress = '';
  Timer? _progressTimer;

  // التحليل
  PerformanceAnalysis? _analysis;

  //
  // ============ الواجهة العامة (Getters) ============
  //

  // معلومات الحالة
  bool get isAnalysisLoading => _isAnalysisLoading;
  bool get hasAnalysis => _hasAnalysis;
  bool get showAnalyzingProgress => _showAnalyzingProgress;
  String get analysisProgress => _analysisProgress;
  String get error => _error;

  // البيانات الأساسية
  PerformanceAnalysis? get analysis => _analysis;

  //
  // ============ دورة حياة وحدة التحكم ============
  //

  /// المنشئ
  PerformanceAnalysisController();

  /// تنظيف الموارد عند التخلص من وحدة التحكم
  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  //
  // ============ وظائف التهيئة وتحميل البيانات ============
  //

  /// تهيئة الكنترولر بتحليل موجود
  void initializeWithAnalysis(PerformanceAnalysis? existingAnalysis) {
    if (existingAnalysis != null) {
      _analysis = existingAnalysis;
      _hasAnalysis = true;
      notifyListeners();
    }
  }

  /// تحميل التحليل المحفوظ
  Future<void> loadSavedAnalysis() async {
    final savedAnalysis =
        await StudentPerformanceService.getSavedPerformanceAnalysis();
    if (savedAnalysis != null) {
      _analysis = savedAnalysis;

      // التحقق من وجود رسائل خطأ في التحليل المحفوظ
      bool hasErrorMessages = _containsAnyErrorMessages(savedAnalysis);

      if (hasErrorMessages) {
        _hasAnalysis = false;
      } else {
        _hasAnalysis = true;
      }

      notifyListeners();
    }
  }

  /// تحديث المعدل التراكمي في التحليل
  void updateAnalysisGPA(double gpa) {
    if (_analysis != null &&
        (_analysis!.calculatedGPA == null || _analysis!.calculatedGPA == 0.0)) {
      _analysis = PerformanceAnalysis(
        strengths: _analysis!.strengths,
        weaknesses: _analysis!.weaknesses,
        correlations: _analysis!.correlations,
        studyPatterns: _analysis!.studyPatterns,
        studyPlan: _analysis!.studyPlan,
        resources: _analysis!.resources,
        calculatedGPA: gpa,
      );
      notifyListeners();
    }
  }

  /// إعادة تعيين التحليل
  void resetAnalysis() {
    _hasAnalysis = false;
    _analysis = null;
    _error = '';

    // حذف التحليل المحفوظ
    StudentPerformanceService.savePerformanceAnalysis(PerformanceAnalysis(
      strengths: [],
      weaknesses: [],
      correlations: [],
      studyPatterns: [],
      studyPlan: StudyPlan(
        title: '',
        description: '',
        sessions: [],
        tips: [],
      ),
      resources: [],
      calculatedGPA: 0.0,
    ));

    notifyListeners();
  }

  //
  // ============ وظائف التحليل الأساسي ============
  //

  /// إنشاء تحليل أساسي محلي
  PerformanceAnalysis createBasicLocalAnalysis(double overallAverage) {
    return PerformanceAnalysis(
      strengths: [
        "لم يتم تحديد نقاط قوة واضحة بناءً على البيانات المتوفرة حالياً."
      ],
      weaknesses: [
        "لم يتم تحديد نقاط ضعف واضحة بناءً على البيانات المتوفرة حالياً."
      ],
      correlations: [
        "لم يتم العثور على علاقات واضحة بين أدائك وعاداتك الدراسية."
      ],
      studyPatterns: [
        "لم يتم تحديد أنماط دراسة واضحة بناءً على البيانات المتوفرة."
      ],
      studyPlan: _createBasicStudyPlan(),
      resources: [],
      calculatedGPA: overallAverage,
    );
  }

  /// إنشاء خطة دراسة أساسية
  StudyPlan _createBasicStudyPlan() {
    return StudyPlan(
      title: 'خطة الدراسة المقترحة',
      description: 'خطة مخصصة بناءً على أدائك ونقاط القوة والضعف',
      sessions: [],
      tips: [
        "قسّم وقت المذاكرة إلى فترات قصيرة مع أخذ استراحات منتظمة.",
        "راجع المواد الدراسية بشكل دوري لترسيخ المعلومات.",
        "استخدم طرق تدوين ملاحظات منظمة تناسب أسلوب تعلمك.",
        "حافظ على بيئة دراسية خالية من المشتتات.",
        "خصص وقتاً إضافياً للمواد التي تجد فيها صعوبة."
      ],
    );
  }

  /// إجراء تحليل أداء محلي باستخدام البيانات المتوفرة
  void performLocalAnalysis(List<Course> courses, StudentHabits habits) {
    List<String> strengths = [];
    List<String> weaknesses = [];
    List<String> correlations = [];
    List<String> studyPatterns = [];

    // تحليل الدرجات
    _analyzeGrades(courses, strengths, weaknesses);

    // تحليل الملفات
    _analyzeFiles(courses, strengths, weaknesses);

    // تحليل عادات الدراسة
    _analyzeStudyHabits(
        habits, strengths, weaknesses, correlations, studyPatterns);

    // التأكد من وجود قيم لجميع أقسام التحليل
    _ensureAnalysisValidity(strengths, weaknesses, correlations, studyPatterns);

    // حساب المعدل التراكمي
    double overallAverage = 0.0;
    if (courses.isNotEmpty) {
      overallAverage = StudentPerformanceService.calculateGPA(courses);
    }

    // تحديث التحليل بالنتائج المحلية
    _updateAnalysisWithLocalResults(
        strengths, weaknesses, correlations, studyPatterns, overallAverage);

    // حفظ التحليل المحدث
    StudentPerformanceService.savePerformanceAnalysis(_analysis!);
    _hasAnalysis = true;

    notifyListeners();
  }

  //
  // ============ وظائف تحليل المكونات الفردية ============
  //

  /// تحليل الدرجات في المقررات
  void _analyzeGrades(
      List<Course> courses, List<String> strengths, List<String> weaknesses) {
    for (var course in courses) {
      // تحليل الدرجات الفردية في كل مقرر
      course.grades.forEach((assignmentName, gradeValue) {
        double maxGrade = course.maxGrades[assignmentName] ?? 100.0;
        double percentage = (gradeValue / maxGrade) * 100;

        if (percentage >= 75) {
          strengths.add(
              'أداء ممتاز في $assignmentName لمادة ${course.courseName} حيث حصلت على ${percentage.toStringAsFixed(1)}%.');
        } else if (percentage < 60) {
          weaknesses.add(
              'تحتاج إلى تحسين في $assignmentName لمادة ${course.courseName} حيث حصلت على ${percentage.toStringAsFixed(1)}%.');
        }
      });

      // تحليل المتوسط الكلي للمقرر
      if (course.grades.isNotEmpty) {
        double average = course.calculateAverage();
        if (average >= 75) {
          strengths.add(
              'تفوق في مادة ${course.courseName} بمعدل كلي ${average.toStringAsFixed(1)}%.');
        } else if (average < 60) {
          weaknesses.add(
              'تحتاج إلى تحسين في مادة ${course.courseName} حيث أن متوسط درجاتك ${average.toStringAsFixed(1)}%.');
        }
      }
    }
  }

  /// تحليل الملفات الدراسية
  void _analyzeFiles(
      List<Course> courses, List<String> strengths, List<String> weaknesses) {
    for (var course in courses) {
      bool hasReadingNotes = false;
      bool hasAssignments = false;
      bool hasPresentations = false;

      // فحص أنواع الملفات في المقرر
      for (var file in course.files) {
        final fileName = file.fileName.toLowerCase();
        final fileType = file.fileType.toLowerCase();

        if (fileName.contains('note') ||
            fileName.contains('ملاحظة') ||
            fileName.contains('محاضرة') ||
            fileName.contains('lecture')) {
          hasReadingNotes = true;
        } else if (fileType.contains('ppt') ||
            fileName.contains('presentation') ||
            fileName.contains('عرض')) {
          hasPresentations = true;
        } else if (fileName.contains('assignment') ||
            fileName.contains('واجب') ||
            fileName.contains('تكليف') ||
            fileName.contains('project')) {
          hasAssignments = true;
        }
      }

      // إضافة نتائج تحليل الملفات
      if (hasReadingNotes) {
        strengths.add(
            'لديك ملاحظات قراءة ومحاضرات منظمة لمادة ${course.courseName} مما يساعد في المراجعة والدراسة.');
      } else {
        weaknesses.add(
            'لا توجد ملاحظات قراءة أو محاضرات لمادة ${course.courseName} - قد تحتاج إلى تنظيم ملاحظاتك لتحسين الدراسة.');
      }

      if (hasAssignments) {
        strengths.add(
            'قمت بتنظيم ملفات الواجبات والمشاريع لمادة ${course.courseName} مما يظهر التزامك بمتطلبات المقرر.');
      }

      if (hasPresentations) {
        strengths.add(
            'لديك عروض تقديمية منظمة لمادة ${course.courseName} مما يساعد في فهم المادة بشكل مرئي.');
      }
    }
  }

  /// تحليل عادات الدراسة وأنماطها
  void _analyzeStudyHabits(
      StudentHabits habits,
      List<String> strengths,
      List<String> weaknesses,
      List<String> correlations,
      List<String> studyPatterns) {
    // تحليل ساعات النوم
    if (habits.sleepHours < 6) {
      weaknesses.add(
          'ساعات النوم اليومية (${habits.sleepHours} ساعات) أقل من المعدل الصحي وقد تؤثر سلباً على أدائك الأكاديمي.');
      correlations.add(
          'توجد علاقة بين قلة النوم وضعف التركيز أثناء المذاكرة وانخفاض القدرة على الاستيعاب.');
    } else if (habits.sleepHours >= 8) {
      strengths.add(
          'ساعات النوم اليومية (${habits.sleepHours} ساعات) ضمن المعدل الصحي مما يساعد على التركيز والاستيعاب.');
      correlations.add(
          'النوم الكافي يحسن قدرتك على التركيز واستيعاب المعلومات الجديدة.');
    }

    // تحليل ساعات المذاكرة اليومية
    if (habits.studyHoursDaily < 2) {
      weaknesses.add(
          'ساعات المذاكرة اليومية (${habits.studyHoursDaily} ساعات) قد لا تكون كافية للتحصيل الجيد.');
      correlations.add(
          'قلة وقت المذاكرة اليومي يؤثر سلباً على فهمك للمواد وتراكم الدروس.');
    } else if (habits.studyHoursDaily >= 4) {
      strengths.add(
          'ساعات المذاكرة اليومية (${habits.studyHoursDaily} ساعات) جيدة وتدل على التزامك بالدراسة.');
      correlations.add(
          'المذاكرة المنتظمة يومياً تساعد على ترسيخ المعلومات وتحسين الفهم.');
    }

    // تحليل ساعات المذاكرة الأسبوعية
    if (habits.studyHoursWeekly < 10) {
      correlations.add(
          'انخفاض ساعات المذاكرة الأسبوعية (${habits.studyHoursWeekly} ساعات) قد يكون سبباً في صعوبة استيعاب بعض المواد.');
    } else if (habits.studyHoursWeekly >= 20) {
      correlations.add(
          'ارتفاع ساعات المذاكرة الأسبوعية (${habits.studyHoursWeekly} ساعات) يدل على التزامك بالدراسة ويساهم في تحسين الفهم.');
    }

    // تحليل مستوى التشتت
    if (habits.distractionLevel >= 4) {
      correlations.add(
          'ارتفاع مستوى التشتت أثناء المذاكرة يؤثر سلباً على التركيز ويقلل من فعالية وقت الدراسة.');
    } else if (habits.distractionLevel <= 2) {
      correlations.add(
          'انخفاض مستوى التشتت أثناء المذاكرة يزيد من فعالية وقت الدراسة ويحسن من استيعاب المعلومات.');
    }

    // تحليل أسلوب التعلم
    _analyzeLearnignStyle(studyPatterns, habits.learningStyle);

    // إضافة أنماط دراسة عامة
    studyPatterns.add(
        'تميل إلى المذاكرة ${habits.distractionLevel >= 3 ? "مع وجود بعض المشتتات" : "في بيئة هادئة نسبياً"}.');
    studyPatterns.add(
        'تستغرق وقتاً ${habits.understandingLevel >= 3 ? "متوسطاً" : "طويلاً"} لفهم المفاهيم الجديدة.');
  }

  /// تحليل أسلوب التعلم
  void _analyzeLearnignStyle(List<String> studyPatterns, String learningStyle) {
    switch (learningStyle) {
      case 'visual':
        studyPatterns.add(
            'أسلوب تعلمك البصري يعني أنك تتعلم بشكل أفضل من خلال الصور والرسومات البيانية والخرائط الذهنية.');
        studyPatterns.add(
            'تستفيد أكثر من استخدام الألوان المختلفة في تنظيم ملاحظاتك وتمييز المعلومات المهمة.');
        break;
      case 'auditory':
        studyPatterns.add(
            'أسلوب تعلمك السمعي يعني أنك تتعلم بشكل أفضل من خلال الاستماع والمناقشات والتسجيلات الصوتية.');
        studyPatterns.add(
            'قراءة المعلومات بصوت عالٍ والاستماع للمحاضرات المسجلة يساعدك على الفهم والاستيعاب بشكل أفضل.');
        break;
      case 'kinesthetic':
        studyPatterns.add(
            'أسلوب تعلمك الحركي يعني أنك تتعلم بشكل أفضل من خلال الممارسة العملية والتجارب والأنشطة.');
        studyPatterns.add(
            'التحرك أثناء المذاكرة وتطبيق المفاهيم عملياً يساعدك على ترسيخ المعلومات بشكل أفضل.');
        break;
      case 'reading':
        studyPatterns.add(
            'أسلوب تعلمك القرائي يعني أنك تتعلم بشكل أفضل من خلال القراءة وكتابة الملاحظات والملخصات.');
        studyPatterns.add(
            'كتابة الملخصات وإعادة صياغة المعلومات بأسلوبك الخاص يساعدك على الفهم والاستيعاب بشكل أفضل.');
        break;
    }
  }

  /// التأكد من وجود قيم لجميع أقسام التحليل
  void _ensureAnalysisValidity(List<String> strengths, List<String> weaknesses,
      List<String> correlations, List<String> studyPatterns) {
    if (strengths.isEmpty) {
      strengths.add(
          "لم يتم تحديد نقاط قوة واضحة بناءً على البيانات المتوفرة حالياً.");
    }

    if (weaknesses.isEmpty) {
      weaknesses.add(
          "لم يتم تحديد نقاط ضعف واضحة بناءً على البيانات المتوفرة حالياً.");
    }

    if (correlations.isEmpty) {
      correlations
          .add("لم يتم العثور على علاقات واضحة بين أدائك وعاداتك الدراسية.");
    }

    if (studyPatterns.isEmpty) {
      studyPatterns
          .add("لم يتم تحديد أنماط دراسة واضحة بناءً على البيانات المتوفرة.");
    }
  }

  //
  // ============ وظائف تحديث البيانات ============
  //

  /// تحديث التحليل الحالي بالنتائج المحلية
  void _updateAnalysisWithLocalResults(
      List<String> strengths,
      List<String> weaknesses,
      List<String> correlations,
      List<String> studyPatterns,
      double overallAverage) {
    if (_analysis == null) {
      // إنشاء تحليل جديد إذا لم يكن موجوداً
      _analysis = PerformanceAnalysis(
        strengths: strengths,
        weaknesses: weaknesses,
        correlations: correlations,
        studyPatterns: studyPatterns,
        studyPlan: _createBasicStudyPlan(),
        resources: [],
        calculatedGPA: overallAverage,
      );
    } else {
      // فلترة وتجميع النتائج من التحليل الحالي والتحليل المحلي
      List<String> aiStrengths = _extractAIAnalysisItems(_analysis!.strengths);
      List<String> aiWeaknesses =
          _extractAIAnalysisItems(_analysis!.weaknesses);
      List<String> aiCorrelations =
          _extractAIAnalysisItems(_analysis!.correlations);
      List<String> aiPatterns =
          _extractAIAnalysisItems(_analysis!.studyPatterns);

      // تحديث التحليل بدمج النتائج المحلية مع نتائج الذكاء الاصطناعي
      List<String> finalStrengths = [...strengths, ...aiStrengths];
      List<String> finalWeaknesses = [...weaknesses, ...aiWeaknesses];
      List<String> finalCorrelations =
          _containsErrorMessages(_analysis!.correlations)
              ? correlations
              : [...correlations, ...aiCorrelations];
      List<String> finalPatterns =
          _containsErrorMessages(_analysis!.studyPatterns)
              ? studyPatterns
              : [...studyPatterns, ...aiPatterns];

      _analysis = PerformanceAnalysis(
        strengths: finalStrengths,
        weaknesses: finalWeaknesses,
        correlations: finalCorrelations,
        studyPatterns: finalPatterns,
        studyPlan: _analysis!.studyPlan,
        resources: _analysis!.resources,
        calculatedGPA: _analysis!.calculatedGPA ?? overallAverage,
      );
    }
  }

  /// تحديث التحليل بموارد جديدة
  void _updateAnalysisWithNewResources(List<LearningResource> newResources) {
    if (_analysis != null) {
      final updatedResources = newResources;

      _analysis = PerformanceAnalysis(
        strengths: _analysis!.strengths,
        weaknesses: _analysis!.weaknesses,
        correlations: _analysis!.correlations,
        studyPatterns: _analysis!.studyPatterns,
        studyPlan: _analysis!.studyPlan,
        resources: updatedResources,
        calculatedGPA: _analysis!.calculatedGPA,
      );

      // حفظ التحليل المحدث
      StudentPerformanceService.savePerformanceAnalysis(_analysis!);
    }
  }

  /// تحديث التحليل بقائمة فارغة من الموارد
  void _updateAnalysisWithEmptyResources() {
    if (_analysis != null) {
      _analysis = PerformanceAnalysis(
        strengths: _analysis!.strengths,
        weaknesses: _analysis!.weaknesses,
        correlations: _analysis!.correlations,
        studyPatterns: _analysis!.studyPatterns,
        studyPlan: _analysis!.studyPlan,
        resources: [], // قائمة فارغة من الموارد
        calculatedGPA: _analysis!.calculatedGPA,
      );

      // حفظ التحليل المحدث
      StudentPerformanceService.savePerformanceAnalysis(_analysis!);
    }
  }

  //
  // ============ وظائف التحليل المتقدم مع الذكاء الاصطناعي ============
  //

  /// تحليل أداء الطالب باستخدام الذكاء الاصطناعي
  Future<void> analyzePerformance(
      List<Course> courses, StudentHabits habits, Student? student) async {
    if (courses.isEmpty) {
      _error = 'لا توجد بيانات للمقررات';
      notifyListeners();
      return;
    }

    _isAnalysisLoading = true;
    _error = '';
    _showAnalyzingProgress = true;
    _analysisProgress =
        'جاري التواصل مع الذكاء الاصطناعي لتحليل أدائك الدراسي...';
    notifyListeners();

    try {
      // تعيين تحديث التقدم على فترات
      _startProgressUpdates();

      // تحقق من اتصال API أولاً
      bool isApiConnected =
          await StudentPerformanceService.checkApiConnection();

      // إجراء التحليل المحلي أولاً
      performLocalAnalysis(courses, habits);

      // الاحتفاظ بنسخة من التحليل المحلي
      PerformanceAnalysis localAnalysis = _extractLocalAnalysis();

      // استخدام التحليل المحلي فقط إذا فشل الاتصال بالخادم
      if (!isApiConnected) {
        _finishAnalysisWithError(
            'لا يمكن الاتصال بخادم الذكاء الاصطناعي. تم استخدام التحليل المحلي فقط.');
        return;
      }

      // طلب تحليل الذكاء الاصطناعي
      var aiAnalysis = await StudentPerformanceService.analyzePerformance(
        courses,
        habits,
        student,
      );

      // دمج نتائج التحليل المحلي مع تحليل الذكاء الاصطناعي
      _mergeLocalAndAIAnalysis(localAnalysis, aiAnalysis);

      // طلب موارد تعليمية مخصصة إذا لم تكن متوفرة
      if (_analysis!.resources.isEmpty) {
        await _requestCourseSpecificResources(courses, habits);
      }

      _finishAnalysisSuccessfully();
    } catch (e) {
      _finishAnalysisWithError(
          'حدث خطأ في تحليل البيانات. سيتم استخدام التحليل المحلي بدلاً من ذلك.');
    }
  }

  /// توليد خطة دراسية جديدة
  Future<void> generateNewStudyPlan(
      List<Course> courses, StudentHabits habits) async {
    if (courses.isEmpty) {
      _error = 'لا توجد بيانات للمقررات';
      notifyListeners();
      return;
    }

    _isAnalysisLoading = true;
    _showAnalyzingProgress = true;
    _analysisProgress = 'جاري إنشاء خطة دراسية جديدة...';
    notifyListeners();

    try {
      // تعيين تحديث التقدم على فترات
      _startProgressUpdates();

      // تحقق من اتصال API أولاً
      bool isApiConnected =
          await StudentPerformanceService.checkApiConnection();

      if (!isApiConnected) {
        throw Exception(
            'لا يمكن الاتصال بخادم الذكاء الاصطناعي. تأكد من تشغيل الخادم والاتصال بالشبكة.');
      }

      final newPlan =
          await StudentPerformanceService.generateStudyPlan(courses, habits);

      if (_analysis != null) {
        // تحديث الخطة الدراسية في التحليل الحالي
        _analysis = PerformanceAnalysis(
          strengths: _analysis!.strengths,
          weaknesses: _analysis!.weaknesses,
          correlations: _analysis!.correlations,
          studyPatterns: _analysis!.studyPatterns,
          studyPlan: newPlan,
          resources: _analysis!.resources,
          calculatedGPA: _analysis!.calculatedGPA,
        );

        // حفظ التحليل المحدث
        await StudentPerformanceService.savePerformanceAnalysis(_analysis!);
      }

      _isAnalysisLoading = false;
      _showAnalyzingProgress = false;
      _progressTimer?.cancel();
      notifyListeners();
    } catch (e) {
      _isAnalysisLoading = false;
      _showAnalyzingProgress = false;
      _error = e.toString();
      _progressTimer?.cancel();
      notifyListeners();
    }
  }

  /// طلب موارد تعليمية إضافية لمواد محددة
  Future<void> requestMoreResources(
      List<Course> courses, StudentHabits habits) async {
    if (courses.isEmpty) {
      _error = 'لا توجد بيانات للمقررات';
      notifyListeners();
      return;
    }

    _isAnalysisLoading = true;
    _showAnalyzingProgress = true;
    _analysisProgress = 'جاري البحث عن موارد تعليمية مخصصة لمواد دراستك...';
    notifyListeners();

    try {
      // تعيين تحديث التقدم على فترات
      _startProgressUpdates();

      // تحقق من اتصال API أولاً
      bool isApiConnected =
          await StudentPerformanceService.checkApiConnection();

      if (!isApiConnected) {
        throw Exception(
            'لا يمكن الاتصال بخادم الذكاء الاصطناعي. تأكد من تشغيل الخادم والاتصال بالشبكة.');
      }

      // إعداد قائمة أسماء المواد التي يدرسها الطالب وتحديد المواد الضعيفة
      List<String> courseNames =
          courses.map((course) => course.courseName).toList();

      // إنشاء قائمة نقاط الضعف استنادًا إلى الدرجات المنخفضة
      List<String> weaknesses = [];
      for (var course in courses) {
        double average = course.calculateAverage();
        if (average < 70) {
          weaknesses.add(
              'أداء منخفض في مادة ${course.courseName} بمعدل ${average.toStringAsFixed(1)}%');
        }
      }

      // طلب الموارد التعليمية المخصصة للمواد الدراسية
      final resources = await StudentPerformanceService.getLearningResources(
        weaknesses,
        habits.learningStyle,
        courseNames,
      );

      // تحديث التحليل بالموارد الجديدة
      if (resources.isNotEmpty) {
        _updateAnalysisWithNewResources(resources);
      } else {
        // في حالة عدم الحصول على موارد، نقوم بتحديث التحليل بقائمة فارغة
        _updateAnalysisWithEmptyResources();
      }

      _isAnalysisLoading = false;
      _showAnalyzingProgress = false;
      _progressTimer?.cancel();
      notifyListeners();
    } catch (e) {
      _isAnalysisLoading = false;
      _showAnalyzingProgress = false;
      _error = 'حدث خطأ في طلب الموارد التعليمية: ${e.toString()}';
      _progressTimer?.cancel();

      // في حالة الخطأ، نقوم بتحديث التحليل بقائمة فارغة من الموارد
      _updateAnalysisWithEmptyResources();

      notifyListeners();
    }
  }

  //
  // ============ مساعدات التحليل المتقدم ============
  //

  /// استخراج التحليل المحلي (بدون عناصر الذكاء الاصطناعي)
  PerformanceAnalysis _extractLocalAnalysis() {
    if (_analysis == null) {
      return createBasicLocalAnalysis(0.0);
    }

    return PerformanceAnalysis(
      strengths: _analysis!.strengths
          .where((s) => !s.startsWith('(تحليل الذكاء الاصطناعي)'))
          .toList(),
      weaknesses: _analysis!.weaknesses
          .where((w) => !w.startsWith('(تحليل الذكاء الاصطناعي)'))
          .toList(),
      correlations: _analysis!.correlations
          .where((c) => !c.startsWith('(تحليل الذكاء الاصطناعي)'))
          .toList(),
      studyPatterns: _analysis!.studyPatterns
          .where((p) => !p.startsWith('(تحليل الذكاء الاصطناعي)'))
          .toList(),
      studyPlan: _analysis!.studyPlan,
      resources: _analysis!.resources,
      calculatedGPA: _analysis!.calculatedGPA,
    );
  }

  /// دمج التحليل المحلي مع تحليل الذكاء الاصطناعي
  void _mergeLocalAndAIAnalysis(
      PerformanceAnalysis localAnalysis, PerformanceAnalysis aiAnalysis) {
    // التحقق من صحة تحليل الذكاء الاصطناعي
    bool aiStrengthsValid = !_containsErrorMessages(aiAnalysis.strengths);
    bool aiWeaknessesValid = !_containsErrorMessages(aiAnalysis.weaknesses);
    bool aiCorrelationsValid = !_containsErrorMessages(aiAnalysis.correlations);
    bool aiPatternsValid = !_containsErrorMessages(aiAnalysis.studyPatterns);

    // إضافة إشارة "(تحليل الذكاء الاصطناعي)" إلى التحليلات الصالحة فقط
    List<String> aiLabeledStrengths = aiStrengthsValid
        ? aiAnalysis.strengths
            .map((strength) => '(تحليل الذكاء الاصطناعي) $strength')
            .toList()
        : [];

    List<String> aiLabeledWeaknesses = aiWeaknessesValid
        ? aiAnalysis.weaknesses
            .map((weakness) => '(تحليل الذكاء الاصطناعي) $weakness')
            .toList()
        : [];

    List<String> aiLabeledCorrelations =
        aiCorrelationsValid && aiAnalysis.correlations.isNotEmpty
            ? aiAnalysis.correlations
                .map((correlation) => '(تحليل الذكاء الاصطناعي) $correlation')
                .toList()
            : [];

    List<String> aiLabeledPatterns =
        aiPatternsValid && aiAnalysis.studyPatterns.isNotEmpty
            ? aiAnalysis.studyPatterns
                .map((pattern) => '(تحليل الذكاء الاصطناعي) $pattern')
                .toList()
            : [];

    // دمج التحليلات
    List<String> finalStrengths = [
      ...localAnalysis.strengths,
      ...aiLabeledStrengths
    ];

    List<String> finalWeaknesses = [
      ...localAnalysis.weaknesses,
      ...aiLabeledWeaknesses
    ];

    List<String> finalCorrelations = aiLabeledCorrelations.isEmpty
        ? localAnalysis.correlations
        : [...localAnalysis.correlations, ...aiLabeledCorrelations];

    List<String> finalPatterns = aiLabeledPatterns.isEmpty
        ? localAnalysis.studyPatterns
        : [...localAnalysis.studyPatterns, ...aiLabeledPatterns];

    // إنشاء التحليل النهائي
    _analysis = PerformanceAnalysis(
      strengths: finalStrengths,
      weaknesses: finalWeaknesses,
      correlations: finalCorrelations,
      studyPatterns: finalPatterns,
      studyPlan: aiAnalysis.studyPlan,
      resources: aiAnalysis.resources,
      calculatedGPA: aiAnalysis.calculatedGPA! > 0
          ? aiAnalysis.calculatedGPA
          : localAnalysis.calculatedGPA,
    );
  }

  /// طلب موارد تعليمية مخصصة للمقررات
  Future<void> _requestCourseSpecificResources(
      List<Course> courses, StudentHabits habits) async {
    try {
      List<String> courseNames =
          courses.map((course) => course.courseName).toList();

      // إنشاء قائمة نقاط الضعف استنادًا إلى الدرجات المنخفضة
      List<String> weaknesses = [];
      for (var course in courses) {
        double average = course.calculateAverage();
        if (average < 70) {
          weaknesses.add(
              'أداء منخفض في مادة ${course.courseName} بمعدل ${average.toStringAsFixed(1)}%');
        }
      }

      final resources = await StudentPerformanceService.getLearningResources(
        weaknesses,
        habits.learningStyle,
        courseNames,
      );

      if (resources.isNotEmpty) {
        _analysis = PerformanceAnalysis(
          strengths: _analysis!.strengths,
          weaknesses: _analysis!.weaknesses,
          correlations: _analysis!.correlations,
          studyPatterns: _analysis!.studyPatterns,
          studyPlan: _analysis!.studyPlan,
          resources: resources,
          calculatedGPA: _analysis!.calculatedGPA,
        );
      }
    } catch (resourceError) {
      // يتم تجاهل أخطاء الموارد للسماح بإكمال التحليل
    }
  }

  /// إنهاء عملية التحليل بنجاح
  void _finishAnalysisSuccessfully() {
    _hasAnalysis = true;
    _isAnalysisLoading = false;
    _showAnalyzingProgress = false;
    _progressTimer?.cancel();

    // حفظ التحليل المحدث
    StudentPerformanceService.savePerformanceAnalysis(_analysis!);

    notifyListeners();
  }

  /// إنهاء عملية التحليل مع خطأ
  void _finishAnalysisWithError(String errorMessage) {
    _isAnalysisLoading = false;
    _error = errorMessage;

    // التأكد من وجود تحليل محلي
    if (_analysis == null) {
      _analysis = createBasicLocalAnalysis(0.0);
    }

    _hasAnalysis = true;
    _showAnalyzingProgress = false;
    _progressTimer?.cancel();

    // حفظ التحليل المحدث
    StudentPerformanceService.savePerformanceAnalysis(_analysis!);

    notifyListeners();
  }

  //
  // ============ دوال مساعدة ============
  //

  /// استخراج العناصر المحددة بتحليل الذكاء الاصطناعي من القائمة
  List<String> _extractAIAnalysisItems(List<String> items) {
    return items
        .where((item) =>
            item.startsWith('(تحليل الذكاء الاصطناعي)') &&
            !_isErrorMessage(item))
        .toList();
  }

  /// فحص هل تحتوي أي قائمة على رسائل خطأ
  bool _containsAnyErrorMessages(PerformanceAnalysis analysis) {
    return _containsErrorMessages(analysis.strengths) ||
        _containsErrorMessages(analysis.weaknesses) ||
        _containsErrorMessages(analysis.correlations) ||
        _containsErrorMessages(analysis.studyPatterns);
  }

  /// فحص هل تحتوي القائمة على رسائل خطأ
  bool _containsErrorMessages(List<String> items) {
    if (items.isEmpty) return true;

    if (items.length == 1) {
      return _isErrorMessage(items[0]);
    }

    return false;
  }

  /// التحقق إذا كانت الرسالة هي رسالة خطأ
  bool _isErrorMessage(String message) {
    List<String> errorPhrases = [
      "تحليل نقاط القوة غير متاح",
      "تحليل الأداء غير متاح",
      "غير متاح حالياً",
      "تعذر تحليل نقاط الضعف",
      "لم يتم العثور على علاقات",
      "تعذر تحليل أنماط الدراسة"
    ];

    for (var phrase in errorPhrases) {
      if (message.contains(phrase)) {
        return true;
      }
    }

    return false;
  }

  /// تحديث رسائل التقدم على فترات لتحسين تجربة المستخدم
  void _startProgressUpdates() {
    // قائمة من رسائل التقدم
    final List<String> progressMessages = [
      'جاري التواصل مع الذكاء الاصطناعي لتحليل أدائك الدراسي...',
      'تحليل درجاتك والعادات الدراسية...',
      'استخراج نقاط القوة والضعف...',
      'إنشاء خطة دراسية مخصصة لك...',
      'تحديد العلاقات بين العادات الدراسية والأداء...',
      'اقتراح موارد تعليمية مناسبة لأسلوب تعلمك...',
      'البحث عن مقاطع فيديو تعليمية لمواد دراستك...',
      'الانتهاء من التحليل، جاري تجهيز التقرير...',
    ];

    int messageIndex = 0;

    // إيقاف المؤقت السابق إن وجد
    _progressTimer?.cancel();

    // إنشاء مؤقت جديد
    _progressTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      messageIndex = (messageIndex + 1) % progressMessages.length;
      _analysisProgress = progressMessages[messageIndex];
      notifyListeners();
    });
  }
}
