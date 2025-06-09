import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fateen/screens/home/home_screen/controllers/header_controller.dart';
import 'package:fateen/screens/tasks/task_screen/task_screen.dart';
import '../home_screen/components/header.dart';

// استيراد ملفات ميزة المحاضرة القادمة
import '../home_screen/controllers/next_lecture_controller.dart';
import '../home_screen/components/next_lecture_card.dart';
import '../home_screen/constants/next_lecture_constants.dart';

// استيراد ملفات ميزة شريط التنقل السفلي
import '../../bottom_nav/index.dart';

// استيراد ملفات ميزة الإحصائيات
import '../home_screen/components/stats_components.dart';
import '../home_screen/controllers/stats_controller.dart';
import '../home_screen/constants/stats_constants.dart';

// استيراد ملفات ميزة المهام التي تحتاج اهتمام
import '../home_screen/controllers/tasks_controller.dart';

// استيراد قسم فئات المهام الجديد
import '../home_screen/components/task_categories_section.dart';

// استيراد ملفات الصفحات الرئيسية
import 'package:fateen/screens/courses/course_screen/course_screen.dart';
import '../../tasks/Task_screen/Task_screen.dart' hide TasksScreen;
import '../services_screen/services_screen.dart';
import '../settings_screen/settings_screen.dart';

// استيراد MyScheduleScreen
import '../../courses/Schedule_screen/Schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userMajor;

  const HomeScreen({Key? key, required this.userName, required this.userMajor})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final HeaderController _headerController = HeaderController();
  late NextLectureController _nextLectureController;
  late StatsController _statsController;
  late TasksController _tasksController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // إضافة وحدة تحكم شريط التنقل
  late BottomNavController _navController;

  // قائمة بالصفحات المتوفرة في التطبيق
  late List<Widget> _pages;

  // حاوية لتخزين حالة الصفحات
  final PageStorageBucket _bucket = PageStorageBucket();

  // مؤشر التحميل الأولي
  bool _isInitialLoading = true;

  // مؤشر لعملية التحديث
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  // استخدام دالة منفصلة لتهيئة وحدات التحكم لتحسين الأداء
  Future<void> _initializeControllers() async {
    setState(() {
      _isInitialLoading = true;
    });

    // تهيئة وحدات التحكم في مجموعات متوازية لتحسين الأداء
    await Future.wait([
      _headerController.initialize(),
      Future(() async {
        _nextLectureController = NextLectureController();
        await _nextLectureController.initialize();
      }),
      Future(() async {
        _statsController = StatsController();
        await _statsController.initialize();
      }),
      Future(() async {
        _tasksController = TasksController();
        await _tasksController.initialize();
      }),
    ]);

    // تهيئة وحدة تحكم شريط التنقل
    _navController = BottomNavController();

    // إعداد الأنيميشن للمحاضرة القادمة
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
    _animationController.forward();

    // تهيئة الصفحات
    _initializePages();

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  // تهيئة قائمة الصفحات
  void _initializePages() {
    _pages = [
      _buildHomeContent(), // الصفحة الرئيسية
      const MyScheduleScreen(), // صفحة الجدول - استخدام MyScheduleScreen
      const CourseScreen(), // صفحة المقررات
      const TasksScreen(), // صفحة المهام
      const ServicesScreen(), // صفحة الخدمات
      const SettingsScreen(), // صفحة الإعدادات
    ];
  }

  // معالجة النقر على بطاقة الإحصائيات
  void _handleStatsCardTap(String cardType) {
    // تنفيذ إجراء مناسب حسب نوع البطاقة
    switch (cardType) {
      case 'courses':
        _navController.changeIndex(2); // الانتقال إلى صفحة المقررات
        break;
      case 'tasks':
        _navController.changeIndex(3); // الانتقال إلى صفحة المهام
        break;
      case 'attendance':
        // يمكن إضافة تنقل لصفحة الحضور إذا كانت موجودة
        break;
      case 'exams':
        // يمكن إضافة تنقل لصفحة الاختبارات إذا كانت موجودة
        break;
    }
  }

  // بناء محتوى الصفحة الرئيسية
  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // الحصول على أبعاد الشاشة
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;

        // حساب المسافات والأحجام النسبية
        final double horizontalPadding =
            screenSize.width * 0.04; // 4% من عرض الشاشة
        final double verticalPadding =
            screenSize.height * 0.02; // 2% من ارتفاع الشاشة
        final double sectionSpacing =
            screenSize.height * 0.015; // 1.5% من ارتفاع الشاشة
        final double smallSpacing =
            screenSize.height * 0.01; // 1% من ارتفاع الشاشة

        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _nextLectureController),
            ChangeNotifierProvider.value(value: _statsController),
            ChangeNotifierProvider.value(value: _tasksController),
          ],
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFF4338CA), // لون منسجم مع ألوان باقي التطبيق
            strokeWidth: 2.5,
            child: Stack(
              children: [
                // المحتوى الرئيسي
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الهيدر
                      Padding(
                        padding: EdgeInsets.fromLTRB(horizontalPadding,
                            verticalPadding, horizontalPadding, smallSpacing),
                        child: HeaderComponent(
                          controller: _headerController,
                        ),
                      ),

                      // المحاضرة القادمة
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Consumer<NextLectureController>(
                          builder: (context, controller, child) {
                            // عرض المحاضرة القادمة فقط إذا لم تكن حالة التحميل وكانت المحاضرة متوفرة
                            if (!controller.isLoading &&
                                controller.nextLectureMap != null) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // عنوان قسم المحاضرة القادمة
                                  NextLectureComponents.buildSectionTitle(),

                                  SizedBox(height: smallSpacing),

                                  // بطاقة المحاضرة القادمة
                                  NextLectureCard(
                                    courseName: controller.nextLectureMap![
                                        NextLectureConstants.courseNameField],
                                    classroom: controller.nextLectureMap![
                                        NextLectureConstants.classroomField],
                                    diffSeconds: controller
                                        .nextLectureMap!['diffSeconds'],
                                    animation: _animation,
                                  ),

                                  SizedBox(height: sectionSpacing),
                                ],
                              );
                            }

                            // في حالة التحميل أو عدم وجود محاضرة، لن نعرض أي شيء
                            return const SizedBox.shrink();
                          },
                        ),
                      ),

                      // قسم الإحصائيات
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Consumer<StatsController>(
                          builder: (context, statsController, child) {
                            // في حالة التحميل نعرض مؤشر التحميل
                            if (statsController.isLoading) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // عنوان قسم الإحصائيات
                                  StatsComponents.buildSectionTitle(
                                      StatsConstants.statisticsTitle),
                                  SizedBox(height: sectionSpacing),
                                  Center(
                                    child: SizedBox(
                                      height: screenSize.height *
                                          0.05, // 5% من ارتفاع الشاشة
                                      width: screenSize.height *
                                          0.05, // 5% من ارتفاع الشاشة
                                      child: const CircularProgressIndicator(
                                        color: Color(0xFF4338CA),
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: smallSpacing),
                                ],
                              );
                            }

                            // في حالة حدوث خطأ نعرض رسالة الخطأ
                            if (statsController.errorMessage != null) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // عنوان قسم الإحصائيات
                                  StatsComponents.buildSectionTitle(
                                      StatsConstants.statisticsTitle),
                                  SizedBox(height: smallSpacing),
                                  Container(
                                    width: double.infinity,
                                    padding:
                                        EdgeInsets.all(horizontalPadding * 0.8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.red.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      'حدث خطأ: ${statsController.errorMessage}',
                                      style: TextStyle(
                                        color: Colors.red[600],
                                        fontFamily: 'SYMBIOAR+LT',
                                        fontSize: isSmallScreen ? 12.0 : 14.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            }

                            // إنشاء بيانات بطاقات الإحصائيات
                            final statsCardsData =
                                statsController.buildStatsCardsData(
                              onCardTap: _handleStatsCardTap,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // عنوان قسم الإحصائيات
                                StatsComponents.buildSectionTitle(
                                    StatsConstants.statisticsTitle),

                                SizedBox(height: smallSpacing),

                                // صف بطاقات الإحصائيات - استخدام LayoutBuilder لضمان العرض الصحيح
                                StatsComponents.buildStatsRowWithLayoutBuilder(
                                  statsCards: statsCardsData,
                                  completedTasks:
                                      statsController.tasksStats['completed'] ??
                                          0,
                                  totalTasks:
                                      statsController.tasksStats['total'] ?? 0,
                                ),

                                SizedBox(height: smallSpacing),
                              ],
                            );
                          },
                        ),
                      ),

                      // قسم "فئات المهام" الجديد
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: TaskCategoriesSection(
                          onTaskTap: () => _navController
                              .changeIndex(3), // الانتقال إلى صفحة المهام
                          animation: _animation,
                        ),
                      ),

                      // مساحة إضافية في الأسفل للسماح بالسحب للأسفل بشكل أفضل
                      SizedBox(
                          height: screenSize.height *
                              0.1), // 10% من ارتفاع الشاشة لإعطاء مساحة للشريط السفلي
                    ],
                  ),
                ),

                // مؤشر التحديث
                if (_isRefreshing)
                  Container(
                    width: double.infinity,
                    height: screenSize.height * 0.06, // 6% من ارتفاع الشاشة
                    color: Colors.black.withOpacity(0.1),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "جاري التحديث...",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDFDFF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF4338CA),
              ),
              const SizedBox(height: 20),
              Text(
                "جاري تحميل البيانات...",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _navController,
      child: Consumer<BottomNavController>(
        builder: (context, controller, _) {
          return WillPopScope(
            onWillPop: () async {
              // إذا كنا في صفحة غير الرئيسية، انتقل إلى الرئيسية بدلاً من الخروج
              return !controller.handleBackPress();
            },
            child: Scaffold(
              backgroundColor:
                  const Color(0xFFFDFDFF), // استخدام نفس خلفية التطبيق
              body: SafeArea(
                // إضافة هامش سفلي إضافي للمحتوى ليتناسب مع شريط التنقل
                bottom: false,
                child: PageStorage(
                  bucket: _bucket,
                  child: IndexedStack(
                    key: ValueKey<int>(controller.selectedIndex),
                    index: controller.selectedIndex,
                    children: _pages,
                  ),
                ),
              ),
              // إضافة شريط التنقل السفلي بدون هوامش إضافية
              bottomNavigationBar: ColorfulNavBar(
                selectedIndex: controller.selectedIndex,
                onItemTapped: (index) => controller.changeIndex(index),
              ),
            ),
          );
        },
      ),
    );
  }

  // دالة لتحديث البيانات عند السحب للأسفل
  Future<void> _refreshData() async {
    if (_isRefreshing) return; // منع التحديث المتزامن المتعدد

    setState(() {
      _isRefreshing = true;
    });

    debugPrint('بدء تحديث البيانات...');

    try {
      // تحديث البيانات بشكل متوازي
      await Future.wait([
        _nextLectureController.refresh(),
        _statsController.refresh(),
        _tasksController.refresh(),
        _headerController.initialize(),
      ]);

      // إعلام واجهة المستخدم بالتحديث
      if (mounted) {
        debugPrint('تم تحديث جميع البيانات');
      }
    } catch (e) {
      debugPrint('حدث خطأ أثناء التحديث: $e');
      // يمكن إضافة عرض رسالة خطأ للمستخدم هنا
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nextLectureController.dispose();
    _statsController.dispose();
    _tasksController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
