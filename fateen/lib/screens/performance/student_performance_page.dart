import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';

import 'controllers/student_performance_controller.dart';
import 'controllers/files_statistics_controller.dart';
import 'controllers/study_habits_controller.dart';
import 'controllers/performance_analysis_controller.dart'; // إضافة كنترولر التحليل الجديد
import 'components/student_performance_header_component.dart';
import 'components/course_card_component.dart';
import 'components/study_habits_form_component.dart';
import 'components/analysis_result_component.dart';
import 'components/files_statistics_component.dart';
import 'components/analyzing_progress_component.dart';
import 'constants/performance_colors.dart';
import 'constants/performance_strings.dart';
import 'components/performance_theme.dart';
import '../../models/app_file.dart';
import '../../models/course.dart';

class StudentPerformancePage extends StatelessWidget {
  final List<Course> coursesFromStats;
  final double overallAverage;
  final Map<String, int> gradeDistribution;

  const StudentPerformancePage({
    Key? key,
    required this.coursesFromStats,
    required this.overallAverage,
    required this.gradeDistribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => StudentPerformanceController()),
        ChangeNotifierProvider(
            create: (context) => FilesStatisticsController()),
        ChangeNotifierProvider(create: (context) => StudyHabitsController()),
        ChangeNotifierProvider(
            create: (context) =>
                PerformanceAnalysisController()), // إضافة كنترولر التحليل الجديد
      ],
      child: Builder(builder: (context) {
        final performanceController =
            Provider.of<StudentPerformanceController>(context);
        final filesController =
            Provider.of<FilesStatisticsController>(context, listen: false);

        // تمرير البيانات من خلال الكونستركتور إلى المتحكم
        WidgetsBinding.instance.addPostFrameCallback((_) {
          performanceController.initializeWithExternalData(
              coursesFromStats, overallAverage, gradeDistribution);
          // تحديث إحصائيات الملفات بعد تهيئة المقررات
          filesController.calculateFilesStatistics(coursesFromStats);
        });

        return Directionality(
          textDirection: TextDirection.rtl, // اتجاه النص من اليمين لليسار
          child: Scaffold(
            backgroundColor:
                const Color(0xFFFDFDFF), // نفس لون خلفية صفحة المعدل
            body: SafeArea(
              child: FadeTransition(
                opacity: const AlwaysStoppedAnimation(
                    1.0), // لمحاكاة fadeAnimation من صفحة المعدل
                child: Column(
                  children: [
                    // رأس الصفحة - بنمط مماثل لصفحة المعدل
                    StudentPerformanceHeaderComponent(
                      controller: performanceController,
                      title: PerformanceStrings.pageTitle,
                      onBackPressed: () => Navigator.pop(context),
                    ),

                    // محتوى الصفحة
                    Expanded(
                      child: _StudentPerformanceContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StudentPerformanceContent extends StatelessWidget {
  const _StudentPerformanceContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentPerformanceController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF4338CA)), // لون متوافق مع صفحة المعدل
                ),
                const SizedBox(height: 16),
                const Text(
                  PerformanceStrings.loadingText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.error.isNotEmpty && controller.courses.isEmpty) {
          return _buildErrorView(context, controller);
        }

        return DefaultTabController(
          length: 2,
          child: _buildMainContent(context, controller),
        );
      },
    );
  }

  Widget _buildMainContent(
      BuildContext context, StudentPerformanceController controller) {
    // استخدام Column بدلاً من NestedScrollView لمعالجة مشكلة المساحة الفارغة
    return Column(
      children: [
        // شريط التبويب
        Container(
          color: const Color(0xFFFDFDFF), // لون متوافق مع صفحة المعدل
          child: TabBar(
            labelColor: const Color(0xFF4338CA), // لون متوافق مع صفحة المعدل
            unselectedLabelColor: const Color(0xFF718096),
            indicatorColor:
                const Color(0xFF4338CA), // لون متوافق مع صفحة المعدل
            tabs: const [
              Tab(text: PerformanceStrings.tabCourses),
              Tab(text: PerformanceStrings.tabAnalysis),
            ],
          ),
        ),

        // محتوى التبويب - يستخدم معظم المساحة المتاحة
        Expanded(
          child: TabBarView(
            children: [
              // علامة التبويب الأولى: عرض المقررات وإدخال البيانات
              _buildCoursesTab(context, controller),

              // علامة التبويب الثانية: التحليل والخطة
              _buildAnalysisTab(context, controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(
      BuildContext context, StudentPerformanceController controller) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              PerformanceStrings.errorTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151), // لون متوافق مع صفحة المعدل
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                controller.error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF718096), // لون متوافق مع صفحة المعدل
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text(PerformanceStrings.backButton),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF4338CA), // لون متوافق مع صفحة المعدل
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesTab(
      BuildContext context, StudentPerformanceController controller) {
    // Obtener el controlador de hábitos de estudio
    final habitsController = Provider.of<StudyHabitsController>(context);

    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshData();
          // Actualizar también las estadísticas de archivos
          final filesController =
              Provider.of<FilesStatisticsController>(context, listen: false);
          filesController.calculateFilesStatistics(controller.courses);
        },
        color: const Color(0xFF4338CA), // لون متوافق مع صفحة المعدل
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // إحصائيات الملفات - ahora usando el componente sin parámetros
              const FilesStatisticsComponent(),

              const SizedBox(height: 16),

              // عنوان المقررات - بتصميم متوافق مع صفحة المعدل
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF4338CA)
                          .withOpacity(0.1), // لون متوافق مع صفحة المعدل
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school,
                          color: Color(0xFF4338CA), // لون متوافق مع صفحة المعدل
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          PerformanceStrings.coursesTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Color(0xFF374151), // لون متوافق مع صفحة المعدل
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4338CA)
                            .withOpacity(0.1), // لون متوافق مع صفحة المعدل
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${PerformanceStrings.coursesCount}: ${controller.courses.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4338CA), // لون متوافق مع صفحة المعدل
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // المقررات الدراسية
              if (controller.courses.isEmpty)
                _buildEmptyCoursesView(context)
              else
                ...controller.courses.map((course) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CourseCardComponent(
                        course: course,
                        onFileSelected: (file) =>
                            _showFilePreview(context, file),
                      ),
                    )),

              const SizedBox(height: 16),

              // نموذج إدخال بيانات العادات الدراسية - بتصميم متوافق مع صفحة المعدل
              StudyHabitsFormComponent(
                habits: habitsController.habits,
                controller: habitsController,
                onSubmit: (habits) {
                  print(
                      "StudyHabitsFormComponent onSubmit callback received with habits:");
                  print("Sleep Hours: ${habits.sleepHours}");
                  print("Study Hours Daily: ${habits.studyHoursDaily}");

                  // تحديث عادات الدراسة واستدعاء تحليل البيانات
                  controller.updateStudyHabits(habits);

                  print("Calling controller.analyzePerformance() now...");
                  // طلب تحليل الأداء
                  controller.analyzePerformance();
                  print("controller.analyzePerformance() called successfully");

                  // الانتقال إلى تبويب التحليل
                  DefaultTabController.of(context).animateTo(1);
                },
              ),

              // مساحة إضافية للتمرير بسهولة
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCoursesView(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF4338CA)
                      .withOpacity(0.1), // لون متوافق مع صفحة المعدل
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_outlined,
                  size: 48,
                  color: Color(0xFF4338CA), // لون متوافق مع صفحة المعدل
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                PerformanceStrings.noCoursesTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151), // لون متوافق مع صفحة المعدل
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                PerformanceStrings.noCoursesDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF718096), // لون متوافق مع صفحة المعدل
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // إجراء إضافة مقرر جديد
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add),
                label: const Text(PerformanceStrings.addCourseButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF4338CA), // لون متوافق مع صفحة المعدل
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisTab(
      BuildContext context, StudentPerformanceController controller) {
    // استخدام كنترولر التحليل بدلاً من الكنترولر الرئيسي
    final analysisController = controller.analysisController;

    // التحقق من حالة التحليل باستخدام كنترولر التحليل الجديد
    if (analysisController.isAnalysisLoading) {
      return AnalyzingProgressComponent(
        progressMessage: analysisController.analysisProgress,
      );
    }

    if (analysisController.hasAnalysis) {
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          color: const Color(0xFF4338CA), // لون متوافق مع صفحة المعدل
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (analysisController.error.isNotEmpty)
                  _buildWarningMessage(analysisController.error),

                AnalysisResultComponent(
                  analysis: analysisController.analysis!,
                  onRequestMoreResources: () =>
                      controller.requestMoreResources(),
                ),

                const SizedBox(height: 24),

                // أزرار إضافية - بتصميم متوافق مع صفحة المعدل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: analysisController.isAnalysisLoading
                          ? null
                          : () => controller.generateNewStudyPlan(),
                      icon: const Icon(Icons.refresh),
                      label: const Text(PerformanceStrings.generatePlanButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFF4338CA), // لون متوافق مع صفحة المعدل
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: analysisController.isAnalysisLoading
                          ? null
                          : () => controller.requestMoreResources(),
                      icon: const Icon(Icons.library_add),
                      label: const Text(PerformanceStrings.moreResourcesButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFF6366F1), // لون متوافق مع صفحة المعدل
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      );
    }

    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4338CA)
                    .withOpacity(0.1), // لون متوافق مع صفحة المعدل
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics,
                size: 48,
                color: Color(0xFF4338CA), // لون متوافق مع صفحة المعدل
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              PerformanceStrings.noAnalysisTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151), // لون متوافق مع صفحة المعدل
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                PerformanceStrings.noAnalysisDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF718096), // لون متوافق مع صفحة المعدل
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                DefaultTabController.of(context).animateTo(0);
              },
              icon: const Icon(Icons.edit),
              label: const Text(PerformanceStrings.inputDataButton),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF4338CA), // لون متوافق مع صفحة المعدل
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.yellow[700]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.yellow[800],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.yellow[900],
                fontSize: 14,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilePreview(BuildContext context, AppFile file) {
    // معاينة الملف (يمكن إضافة التنفيذ لاحقاً)
  }
}
