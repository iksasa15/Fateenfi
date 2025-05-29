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

  @override
  void initState() {
    super.initState();
    _headerController.initialize();

    // تهيئة وحدة تحكم المحاضرة القادمة
    _nextLectureController = NextLectureController();
    _nextLectureController.initialize();

    // تهيئة وحدة تحكم الإحصائيات
    _statsController = StatsController();
    _statsController.initialize();

    // تهيئة وحدة تحكم المهام التي تحتاج اهتمام
    _tasksController = TasksController();
    _tasksController.initialize();

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _nextLectureController),
        ChangeNotifierProvider.value(value: _statsController),
        ChangeNotifierProvider.value(value: _tasksController),
      ],
      child: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF4338CA), // لون منسجم مع ألوان باقي التطبيق
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: HeaderComponent(
                  controller: _headerController,
                ),
              ),

              // المحاضرة القادمة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

                          const SizedBox(height: 8),

                          // بطاقة المحاضرة القادمة
                          NextLectureCard(
                            courseName: controller.nextLectureMap![
                                NextLectureConstants.courseNameField],
                            classroom: controller.nextLectureMap![
                                NextLectureConstants.classroomField],
                            diffSeconds:
                                controller.nextLectureMap!['diffSeconds'],
                            animation: _animation,
                          ),

                          const SizedBox(
                              height: 16), // تم تقليل المسافة من 24 إلى 16
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                          const SizedBox(height: 16),
                          const Center(
                              child: CircularProgressIndicator(
                            color: Color(0xFF4338CA),
                          )),
                          const SizedBox(
                              height: 8), // تم تقليل المسافة من 16 إلى 8
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
                          const SizedBox(height: 8),
                          Text(
                            'حدث خطأ: ${statsController.errorMessage}',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      );
                    }

                    // إنشاء بيانات بطاقات الإحصائيات
                    final statsCardsData = statsController.buildStatsCardsData(
                      onCardTap: _handleStatsCardTap,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // عنوان قسم الإحصائيات
                        StatsComponents.buildSectionTitle(
                            StatsConstants.statisticsTitle),

                        const SizedBox(height: 8),

                        // صف بطاقات الإحصائيات - استخدام LayoutBuilder لضمان العرض الصحيح
                        LayoutBuilder(builder: (context, constraints) {
                          return StatsComponents.buildStatsRow(
                            statsCards: statsCardsData,
                            totalWidth: constraints.maxWidth,
                          );
                        }),

                        const SizedBox(
                            height: 8), // تم تقليل المسافة من 24 إلى 8
                      ],
                    );
                  },
                ),
              ),

              // قسم "فئات المهام" الجديد
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TaskCategoriesSection(
                  onTaskTap: () =>
                      _navController.changeIndex(3), // الانتقال إلى صفحة المهام
                  animation: _animation,
                ),
              ),

              // مساحة إضافية في الأسفل للسماح بالسحب للأسفل بشكل أفضل
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _navController,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFF), // استخدام نفس خلفية التطبيق
        body: SafeArea(
          child: Consumer<BottomNavController>(
            builder: (context, controller, _) {
              return PageStorage(
                bucket: _bucket,
                child: IndexedStack(
                  index: controller.selectedIndex,
                  children: _pages,
                ),
              );
            },
          ),
        ),
        // إضافة شريط التنقل السفلي
        bottomNavigationBar: Consumer<BottomNavController>(
          builder: (context, controller, _) {
            return ColorfulNavBar(
              selectedIndex: controller.selectedIndex,
              onItemTapped: (index) => controller.changeIndex(index),
            );
          },
        ),
      ),
    );
  }

  // دالة لتحديث البيانات عند السحب للأسفل
  Future<void> _refreshData() async {
    debugPrint('بدء تحديث البيانات...');

    // تحديث بيانات المحاضرة القادمة
    await _nextLectureController.refresh();

    // تحديث بيانات الإحصائيات
    await _statsController.refresh();

    // تحديث بيانات المهام التي تحتاج اهتمام
    await _tasksController.refresh();

    // استخدم initialize بدلاً من refresh للـ HeaderController
    _headerController.initialize();

    // إعلام واجهة المستخدم بالتحديث
    if (mounted) {
      setState(() {
        debugPrint('تم تحديث جميع البيانات');
      });
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
