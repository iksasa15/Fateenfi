// stats_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/stats_colors.dart';
import 'constants/stats_strings.dart';
import 'controllers/stats_controller.dart';
import 'firebase/stats_firebase_service.dart';
import '../../../models/course_model.dart';
import '../../../models/course.dart' as course_file;
import 'components/empty_state.dart';
import 'components/loading_state.dart';
import 'components/summary_tab/summary_card.dart';
import 'components/summary_tab/stats_info_item.dart';
import 'components/summary_tab/tips_card.dart';
import 'components/summary_tab/course_highlight_card.dart';
import 'components/charts_tab/chart_section.dart';
import 'components/charts_tab/grade_distribution_chart.dart';
import 'components/charts_tab/course_average_chart.dart';
import 'components/charts_tab/color_legend_item.dart';
import 'components/courses_tab/course_list_item.dart';
import 'components/courses_tab/sort_dropdown.dart';
import 'components/stats_header_component.dart';
import '../../performance/student_performance_page.dart';

// دالة التحويل من course_model.dart إلى course.dart
List<course_file.Course> _convertToFileCourses(List<Course> courses) {
  return courses.map((c) {
    // تحويل الدرجات من course_model إلى course.dart
    Map<String, double> convertedGrades = {};
    c.grades.forEach((key, value) {
      convertedGrades[key] = value;
    });

    Map<String, double> convertedMaxGrades = {};
    c.maxGrades.forEach((key, value) {
      convertedMaxGrades[key] = value;
    });

    return course_file.Course(
      id: c.id,
      courseName: c.courseName,
      creditHours: 3, // قيمة افتراضية
      days: [], // قيمة افتراضية
      classroom: '', // قيمة افتراضية
      grades: convertedGrades,
      maxGrades: convertedMaxGrades,
    );
  }).toList();
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key, required List courses}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  // الخدمات والمتحكمات
  final StatsFirebaseService _firebaseService = StatsFirebaseService();
  final StatsController _statsController = StatsController();

  // متحكم التبويب
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // تهيئة متحكم التبويب
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // تحديث البيانات
  Future<void> _refreshData() async {
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    // التحقق من تسجيل دخول المستخدم
    if (!_firebaseService.isUserLoggedIn) {
      return _buildLoginRequiredScreen();
    }

    return Directionality(
      textDirection: TextDirection.rtl, // اتجاه النص من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // استخدام مكون الهيدر
              const StatsHeaderComponent(),

              // شريط التبويب
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: StatsColors.kDarkPurple,
                  labelColor: StatsColors.kDarkPurple,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  tabs: const [
                    Tab(text: StatsStrings.summaryTab),
                    Tab(text: StatsStrings.chartsTab),
                    Tab(text: StatsStrings.coursesTab),
                  ],
                ),
              ),

              // محتوى التبويب
              Expanded(
                child: StreamBuilder<List<Course>>(
                  stream: _firebaseService.getCoursesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingState();
                    }

                    if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const EmptyState(
                        title: StatsStrings.noCoursesYet,
                        subtitle: StatsStrings.addCoursesToView,
                      );
                    }

                    final courses =
                        _statsController.sortCourses(snapshot.data!);

                    // حساب المتوسط مع معالجة الأخطاء
                    double overallAverage = 0.0;
                    try {
                      overallAverage =
                          _statsController.calculateOverallAverage(courses);
                    } catch (e) {
                      print("خطأ في حساب المتوسط العام: $e");
                    }

                    // حساب توزيع الدرجات مع معالجة الأخطاء
                    Map<String, int> gradeDistribution = {
                      'أقل من 60': 0,
                      '60 - 69': 0,
                      '70 - 79': 0,
                      '80 - 89': 0,
                      '90 - 100': 0,
                    };
                    try {
                      gradeDistribution =
                          _statsController.calculateGradeDistribution(courses);
                    } catch (e) {
                      print("خطأ في حساب توزيع الدرجات: $e");
                    }

                    // عدد الدرجات الإجمالي
                    final totalGrades =
                        gradeDistribution.values.fold(0, (p, c) => p + c);

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        // تبويب الملخص
                        _buildSummaryTab(courses, overallAverage,
                            gradeDistribution, totalGrades),

                        // تبويب الرسوم البيانية
                        _buildChartsTab(courses, gradeDistribution),

                        // تبويب المقررات
                        _buildCoursesTab(courses),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء شاشة طلب تسجيل الدخول
  Widget _buildLoginRequiredScreen() {
    return Directionality(
      textDirection: TextDirection.rtl, // اتجاه النص من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const StatsHeaderComponent(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        size: 80,
                        color: StatsColors.kDarkPurple.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        StatsStrings.loginRequired,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SYMBIOAR+LT',
                          color: StatsColors.kDarkPurple,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: StatsColors.kDarkPurple.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StatsColors.kDarkPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 0),
                          ),
                          child: const Text(
                            StatsStrings.goBackBtn,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء تبويب الملخص
  Widget _buildSummaryTab(
    List<Course> courses,
    double overallAverage,
    Map<String, int> gradeDistribution,
    int totalGrades,
  ) {
    final highestAndLowestCourses =
        _statsController.getHighestAndLowestCourses(courses);
    final String tipText = StatsStrings.getDistributionTip(gradeDistribution);

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: StatsColors.kDarkPurple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة المتوسط العام
            SummaryCard(
              title: StatsStrings.overallAverage,
              value: overallAverage.toStringAsFixed(2),
              icon: Icons.analytics,
              iconColor: StatsColors.kDarkPurple,
              valueColor: StatsColors.getGradeStatusColor(overallAverage),
              subtitle: StatsStrings.fromAllCourses,
            ),
            const SizedBox(height: 20),

            // بطاقة ملخص الإحصائيات
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFE3E0F8),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: StatsColors.kDarkPurple.withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.summarize_outlined,
                          color: StatsColors.kDarkPurple,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        StatsStrings.statsOverview,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE3E0F8),
                  ),
                  const SizedBox(height: 16),

                  // معلومات عددية
                  Row(
                    children: [
                      Expanded(
                        child: StatsInfoItem(
                          title: StatsStrings.courses,
                          value: courses.length.toString(),
                          icon: Icons.book_outlined,
                          iconColor: StatsColors.kDarkPurple,
                        ),
                      ),
                      Expanded(
                        child: StatsInfoItem(
                          title: StatsStrings.grades,
                          value: totalGrades.toString(),
                          icon: Icons.assignment_outlined,
                          iconColor: StatsColors.kAccentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatsInfoItem(
                          title: StatsStrings.highGrades,
                          value:
                              "${(gradeDistribution['90 - 100'] ?? 0) + (gradeDistribution['80 - 89'] ?? 0)}",
                          icon: Icons.emoji_events_outlined,
                          iconColor: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: StatsInfoItem(
                          title: StatsStrings.lowGrades,
                          value: "${gradeDistribution['أقل من 60'] ?? 0}",
                          icon: Icons.warning_amber_outlined,
                          iconColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // نصائح وتوجيهات
            TipsCard(
              tipText: tipText,
              showAiButton: totalGrades > 0,
              onAiAnalysisPressed: () {
                // توجيه المستخدم إلى صفحة تحليل أداء الطالب
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentPerformancePage(
                      coursesFromStats: _convertToFileCourses(courses),
                      gradeDistribution: gradeDistribution,
                      overallAverage: overallAverage,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // أعلى وأقل المقررات
            if (courses.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: const Text(
                  StatsStrings.topAndLowestCourses,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (highestAndLowestCourses['highest'] != null)
                CourseHighlightCard(
                  course: highestAndLowestCourses['highest']!,
                  isHighest: true,
                ),
              const SizedBox(height: 12),
              if (highestAndLowestCourses['lowest'] != null)
                CourseHighlightCard(
                  course: highestAndLowestCourses['lowest']!,
                  isHighest: false,
                ),
            ],

            // مساحة إضافية للتمرير
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // بناء تبويب الرسوم البيانية
  Widget _buildChartsTab(
      List<Course> courses, Map<String, int> gradeDistribution) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: StatsColors.kDarkPurple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مخطط توزيع الدرجات الدائري
            ChartSection(
              title: 'توزيع المقررات حسب مجموع الدرجات',
              child: Column(
                children: [
                  GradeDistributionChart(
                    distribution: gradeDistribution,
                    touchedIndex: _statsController.touchedIndex,
                    onTouch: (index) {
                      setState(() {
                        _statsController.setTouchedIndex(index);
                      });
                    },
                  ),

                  // مفتاح الألوان للمخطط الدائري
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        for (int i = 0;
                            i < StatsStrings.gradeRanges.length;
                            i++)
                          ColorLegendItem(
                            color: StatsColors.pieChartColors[i],
                            label: StatsStrings.gradeRanges[i],
                            count: gradeDistribution[
                                    StatsStrings.gradeRanges[i]] ??
                                0,
                          ),
                      ],
                    ),
                  ),

                  // عرض المقررات في الشريحة المحددة
                  if (_statsController.touchedIndex != null &&
                      _statsController.touchedIndex! >= 0 &&
                      _statsController.touchedIndex! <
                          StatsStrings.gradeRanges.length)
                    _buildGradesForTouchedSlice(
                      StatsStrings.gradeRanges[_statsController.touchedIndex!],
                      courses,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // مخطط مجموع الدرجات للمقررات
            ChartSection(
              title: 'مجموع الدرجات الفعلية للمقررات',
              child: CourseAverageChart(
                courses: courses,
                selectedChartIndex: -1,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // بناء تبويب المقررات
  Widget _buildCoursesTab(List<Course> courses) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: StatsColors.kDarkPurple,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // خيارات الفرز
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    StatsStrings.sortCoursesBy,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                  SortDropdown(
                    currentValue: _statsController.sortOption,
                    onChanged: (val) {
                      setState(() {
                        _statsController.setSortOption(val ?? 'name');
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // قائمة المقررات
            Expanded(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return CourseListItem(
                    course: course,
                    controller: _statsController,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء قائمة المقررات ضمن فئة معينة
  Widget _buildGradesForTouchedSlice(
    String rangeLabel,
    List<Course> courses,
  ) {
    if (rangeLabel.isEmpty) {
      return Container(); // إرجاع حاوية فارغة في حالة عدم وجود نطاق
    }

    List<Map<String, dynamic>> selectedCourses = [];
    try {
      selectedCourses = _statsController.getGradesInRange(rangeLabel, courses);
    } catch (e) {
      print("خطأ في استخراج المقررات ضمن النطاق $rangeLabel: $e");
    }

    // إذا لا توجد مقررات في هذه الشريحة:
    if (selectedCourses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: StatsColors.kDarkPurple,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Text(
              "لا توجد مقررات ضمن هذه الفئة!",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'SYMBIOAR+LT',
                color: StatsColors.kDarkPurple,
              ),
            ),
          ],
        ),
      );
    }

    // مكوّن يوسّع لعرض التفاصيل
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE3E0F8),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          'المقررات ضمن الفئة: $rangeLabel (${selectedCourses.length})',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'SYMBIOAR+LT',
            color: StatsColors.kDarkPurple,
          ),
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedCourses.length,
            itemBuilder: (context, index) {
              // التحقق من الوصول إلى العنصر
              if (index >= selectedCourses.length) {
                return Container();
              }

              final item = selectedCourses[index];
              if (item == null) return Container();

              // استخراج القيم مع فحص لوجودها
              final courseName = item['courseName'] ?? '';
              final totalGrades = item['totalGrades'] ?? 0.0;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE3E0F8),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.03),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: StatsColors.kDarkPurple.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.book_outlined,
                        color: StatsColors.kDarkPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "مجموع الدرجات: ${totalGrades.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  StatsColors.getGradeStatusColor(totalGrades),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
