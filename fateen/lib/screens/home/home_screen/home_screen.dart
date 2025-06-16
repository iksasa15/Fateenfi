import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // إضافة استيراد Timer
import 'package:fateen/screens/home/home_screen/controllers/header_controller.dart';
import 'package:fateen/screens/tasks/task_screen/task_screen.dart';
import '../home_screen/components/header.dart';

// استيراد ميزة بطاقة الملف الشخصي
import 'components/profile_card_widget.dart';
import 'controllers/profile_card_controller.dart';

// استيراد ميزة تقدم التقويم الدراسي
import 'components/semester_progress_widget.dart';
import 'controllers/semester_progress_controller.dart';

// استيراد ميزة مؤشرات الأداء
import 'components/performance_indicators_widget.dart';
import 'controllers/performance_indicators_controller.dart';

// استيراد ميزة فئات المهام
import 'components/task_categories_widget.dart';
import 'controllers/task_categories_controller.dart';

// استيراد ملفات ميزة المحاضرة القادمة
import '../home_screen/controllers/next_lecture_controller.dart';
import '../home_screen/components/next_lecture_card.dart';
import '../home_screen/constants/next_lecture_constants.dart';
// استيراد العداد التنازلي - تم تضمينه في هذا الملف بدلاً من استيراده

// استيراد ملفات ميزة شريط التنقل السفلي
import '../../bottom_nav/index.dart';

// استيراد ملفات ميزة الإحصائيات
import '../home_screen/controllers/stats_controller.dart';

// استيراد ملفات الصفحات الرئيسية
import 'package:fateen/screens/courses/course_screen/course_screen.dart';
import '../../tasks/Task_screen/Task_screen.dart' hide TasksScreen;
import '../services_screen/services_screen.dart';
import '../settings_screen/settings_screen.dart';

// استيراد MyScheduleScreen
import '../../courses/Schedule_screen/Schedule_screen.dart';

// استيراد ملفات النظام الموحد
import '../../../core/constants/appColor.dart';
import '../../../core/constants/app_dimensions.dart';

// إنشاء مكون NextLectureCard معدل لإزالة الأنيميشن
class StaticNextLectureCard extends StatelessWidget {
  final String courseName;
  final String classroom;
  final int diffSeconds;

  const StaticNextLectureCard({
    Key? key,
    required this.courseName,
    required this.classroom,
    required this.diffSeconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تنسيق الوقت وتحديد الألوان
    Color timeColor = _getTimeColor(context, diffSeconds);
    Color bgColor = _getBgColor(context, diffSeconds);

    // إضافة التدرج اللوني للخلفية
    LinearGradient gradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        bgColor,
        bgColor.withOpacity(0.8),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // زخارف الخلفية
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          Positioned(
            left: -15,
            bottom: -15,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // محتوى البطاقة
          Padding(
            padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // معلومات المحاضرة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        courseName,
                        style: TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                          fontSize: AppDimensions.getBodyFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: timeColor.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                          height: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: AppDimensions.getIconSize(context,
                                size: IconSize.small, small: true),
                            color: context.colorTextHint,
                          ),
                          SizedBox(
                              width: AppDimensions.getSpacing(context,
                                      size: SpacingSize.small) /
                                  2),
                          Expanded(
                            child: Text(
                              classroom,
                              style: TextStyle(
                                fontFamily: 'SYMBIOAR+LT',
                                fontSize:
                                    AppDimensions.getLabelFontSize(context),
                                color: context.colorTextSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // مؤشر الوقت المتبقي - تحسين بإضافة العداد المتحرك
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: timeColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: timeColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: AppDimensions.getIconSize(context,
                              size: IconSize.small, small: true),
                          color: timeColor,
                        ),
                        SizedBox(height: 2),
                        // استخدام عداد تنازلي متحرك
                        CountdownTimer(
                          initialSeconds: diffSeconds,
                          fontSize:
                              AppDimensions.getLabelFontSize(context) * 0.8,
                          showIcon: false,
                          customColor: timeColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // تحسين ألوان العرض حسب الوقت المتبقي
  Color _getTimeColor(BuildContext context, int diffSeconds) {
    if (diffSeconds < 900) {
      // أقل من 15 دقيقة
      return context.colorError;
    } else if (diffSeconds < 1800) {
      // أقل من 30 دقيقة
      return context.colorWarning;
    } else {
      return context.colorSuccess;
    }
  }

  Color _getBgColor(BuildContext context, int diffSeconds) {
    if (diffSeconds < 900) {
      // أقل من 15 دقيقة
      return context.colorError.withOpacity(0.15);
    } else if (diffSeconds < 1800) {
      // أقل من 30 دقيقة
      return context.colorWarning.withOpacity(0.15);
    } else {
      return context.colorSuccess.withOpacity(0.15);
    }
  }
}

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userMajor;

  const HomeScreen({Key? key, required this.userName, required this.userMajor})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final HeaderController _headerController = HeaderController();
  late NextLectureController _nextLectureController;
  late StatsController _statsController;

  // إضافة متحكمات الميزات المستخرجة
  late ProfileCardController _profileCardController;
  late SemesterProgressController _semesterProgressController;
  late PerformanceIndicatorsController _performanceIndicatorsController;
  late TaskCategoriesController _taskCategoriesController;

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

  // إضافة متغير لتتبع الصفحة النشطة السابقة
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    // إضافة مراقب التطبيق لتتبع حالة التطبيق (في الخلفية، نشط، الخ)
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تفقد ما إذا كانت وحدة تحكم التنقل متاحة
    if (!_isInitialLoading) {
      final navController =
          Provider.of<BottomNavController>(context, listen: true);
      _listenToPageChanges(navController);
    }
  }

  // استماع للتغييرات في الصفحة النشطة
  void _listenToPageChanges(BottomNavController navController) {
    if (navController.selectedIndex == 0 && _previousIndex != 0) {
      // تم الانتقال إلى الصفحة الرئيسية من صفحة أخرى
      debugPrint('تم الانتقال إلى الصفحة الرئيسية - تحديث البيانات');
      _updateHomePageData();
    }
    _previousIndex = navController.selectedIndex;
  }

  // تحديث بيانات الصفحة الرئيسية
  Future<void> _updateHomePageData() async {
    if (_isRefreshing) return; // منع التحديث المتزامن المتعدد

    debugPrint('بدء تحديث بيانات الصفحة الرئيسية...');

    try {
      // تحديث مؤشرات الأداء والمهام والمحاضرة القادمة
      await Future.wait([
        _performanceIndicatorsController.refresh(),
        _taskCategoriesController.refresh(),
        _nextLectureController.refresh(),
      ]);

      // لا نحتاج لتحديث واجهة المستخدم هنا لأن وحدات التحكم تستخدم ChangeNotifier
      debugPrint('تم تحديث بيانات الصفحة الرئيسية بنجاح');
    } catch (e) {
      debugPrint('حدث خطأ أثناء تحديث بيانات الصفحة الرئيسية: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // تحديث البيانات عند العودة إلى التطبيق
    if (state == AppLifecycleState.resumed) {
      final navController =
          Provider.of<BottomNavController>(context, listen: false);
      if (navController.selectedIndex == 0) {
        debugPrint('العودة إلى التطبيق في الصفحة الرئيسية - تحديث البيانات');
        _updateHomePageData();
      }
    }
  }

  // استخدام دالة منفصلة لتهيئة وحدات التحكم لتحسين الأداء
  Future<void> _initializeControllers() async {
    setState(() {
      _isInitialLoading = true;
    });

    // تهيئة متحكمات الميزات المستخرجة
    _profileCardController = ProfileCardController();
    _semesterProgressController = SemesterProgressController();
    _performanceIndicatorsController = PerformanceIndicatorsController();
    _taskCategoriesController = TaskCategoriesController();

    // تهيئة وحدات التحكم في مجموعات متوازية لتحسين الأداء
    await Future.wait([
      _headerController.initialize(),
      _profileCardController.initialize(),
      _semesterProgressController.initialize(),
      _performanceIndicatorsController.initialize(),
      _taskCategoriesController.initialize(),
      Future(() async {
        _nextLectureController = NextLectureController();
        await _nextLectureController.initialize();
      }),
      Future(() async {
        _statsController = StatsController();
        await _statsController.initialize();
      }),
    ]);

    // تهيئة وحدة تحكم شريط التنقل
    _navController = BottomNavController();

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
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _nextLectureController),
            ChangeNotifierProvider.value(value: _statsController),
            ChangeNotifierProvider.value(value: _profileCardController),
            ChangeNotifierProvider.value(value: _semesterProgressController),
            ChangeNotifierProvider.value(
                value: _performanceIndicatorsController),
            ChangeNotifierProvider.value(value: _taskCategoriesController),
          ],
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: context.colorPrimaryDark,
            strokeWidth: 2.5,
            child: Stack(
              children: [
                // المحتوى الرئيسي
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: AppDimensions.getSpacing(context,
                              size: SpacingSize.medium)),

                      // استخدام بطاقة الملف الشخصي المستخرجة
                      Consumer<ProfileCardController>(
                        builder: (context, controller, _) {
                          // تعيين بيانات المستخدم من خلال المتحكم (للاختبار)
                          if (widget.userName != controller.userName ||
                              widget.userMajor != controller.userMajor) {
                            controller.setUserData(
                                widget.userName, widget.userMajor);
                          }

                          return ProfileCardWidget(
                            controller: controller,
                            onSettingsPressed: () {
                              _navController.changeIndex(
                                  5); // الانتقال إلى صفحة الإعدادات
                            },
                          );
                        },
                      ),

                      SizedBox(
                          height: AppDimensions.getSpacing(context,
                              size: SpacingSize.medium)),

                      // استخدام ميزة تقدم التقويم الدراسي المستخرجة
                      Consumer<SemesterProgressController>(
                        builder: (context, controller, _) {
                          return SemesterProgressWidget(
                            controller: controller,
                          );
                        },
                      ),

                      SizedBox(
                          height: AppDimensions.getSpacing(context,
                              size: SpacingSize.medium)),

                      // المحاضرة القادمة - تحت التقويم الدراسي مباشرة
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.getSpacing(context),
                        ),
                        child: Consumer<NextLectureController>(
                          builder: (context, controller, child) {
                            // عرض عنوان قسم المحاضرة القادمة دائماً
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // عنوان قسم المحاضرة القادمة مع تحسينات
                                Row(
                                  children: [
                                    Icon(
                                      Icons.school_rounded,
                                      size: AppDimensions.getIconSize(context,
                                          size: IconSize.small, small: true),
                                      color: context.colorPrimaryDark,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      NextLectureConstants.nextLectureTitle,
                                      style: TextStyle(
                                        fontSize:
                                            AppDimensions.smallTitleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: context.colorTextPrimary,
                                        fontFamily: 'SYMBIOAR+LT',
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                    height: AppDimensions.getSpacing(context,
                                        size: SpacingSize.small)),

                                // حالة التحميل
                                if (controller.isLoading)
                                  Container(
                                    height:
                                        _AppDimensionsExtensions.getCardHeight(
                                            context),
                                    decoration: BoxDecoration(
                                      color: context.colorSurfaceLight,
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.mediumRadius),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: context.colorPrimaryLight,
                                            strokeWidth: 2,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'جاري البحث عن المحاضرات...',
                                            style: TextStyle(
                                              color: context.colorTextSecondary,
                                              fontSize: AppDimensions
                                                  .getLabelFontSize(context),
                                              fontFamily: 'SYMBIOAR+LT',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                // حالة وجود محاضرة قادمة
                                else if (controller.nextLectureMap != null)
                                  StaticNextLectureCard(
                                    courseName: controller.nextLectureMap![
                                        NextLectureConstants.courseNameField],
                                    classroom: controller.nextLectureMap![
                                        NextLectureConstants.classroomField],
                                    diffSeconds: controller
                                        .nextLectureMap!['diffSeconds'],
                                  )
                                // حالة عدم وجود محاضرة قادمة
                                else
                                  NextLectureComponents
                                      .buildEmptyLectureState(),

                                // حالة الخطأ - إضافة جديدة
                                if (controller.hasError)
                                  Container(
                                    margin: EdgeInsets.only(top: 8),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          context.colorError.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: context.colorError,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            controller.errorMessage,
                                            style: TextStyle(
                                              color: context.colorError,
                                              fontSize: AppDimensions
                                                      .getLabelFontSize(
                                                          context) *
                                                  0.9,
                                              fontFamily: 'SYMBIOAR+LT',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),

                      SizedBox(
                          height: AppDimensions.getSpacing(context,
                              size: SpacingSize.medium)),

                      // استخدام ميزة مؤشرات الأداء المستخرجة
                      Consumer<PerformanceIndicatorsController>(
                        builder: (context, controller, _) {
                          return PerformanceIndicatorsWidget(
                            controller: controller,
                          );
                        },
                      ),

                      SizedBox(
                          height: AppDimensions.getSpacing(context,
                              size: SpacingSize.medium)),

                      // استخدام ميزة فئات المهام المستخرجة
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.getSpacing(context),
                        ),
                        child: Consumer<TaskCategoriesController>(
                          builder: (context, controller, _) {
                            return TaskCategoriesWidget(
                              controller: controller,
                              onTaskTap: () => _navController
                                  .changeIndex(3), // الانتقال إلى صفحة المهام
                            );
                          },
                        ),
                      ),

                      // مساحة إضافية في الأسفل للسماح بالسحب للأسفل بشكل أفضل
                      SizedBox(
                          height: _AppDimensionsExtensions.getCardHeight(
                              context,
                              size: CardSize.large)),
                    ],
                  ),
                ),

                // مؤشر التحديث
                if (_isRefreshing)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      height: AppDimensions.getButtonHeight(context,
                          size: ButtonSize.small, small: true),
                      decoration: BoxDecoration(
                        color: context.colorPrimaryDark.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: context.colorShadow,
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: AppDimensions.getIconSize(context,
                                  size: IconSize.small, small: true),
                              height: AppDimensions.getIconSize(context,
                                  size: IconSize.small, small: true),
                              child: CircularProgressIndicator(
                                color: context.colorSurface,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(
                                width: AppDimensions.getSpacing(context,
                                    size: SpacingSize.small)),
                            Text(
                              "جاري التحديث...",
                              style: TextStyle(
                                color: context.colorSurface,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    AppDimensions.getLabelFontSize(context),
                                fontFamily: 'SYMBIOAR+LT',
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
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
        backgroundColor: context.colorBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: AppDimensions.getIconSize(context,
                    size: IconSize.large, small: true),
                height: AppDimensions.getIconSize(context,
                    size: IconSize.large, small: true),
                child: CircularProgressIndicator(
                  color: context.colorPrimaryDark,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(
                  height: AppDimensions.getSpacing(context,
                      size: SpacingSize.medium)),
              Text(
                "جاري تحميل البيانات...",
                style: TextStyle(
                  color: context.colorTextSecondary,
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.getBodyFontSize(context),
                  fontWeight: FontWeight.w500,
                  height: 1.2,
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
          // تتبع التغييرات في الصفحة النشطة
          _listenToPageChanges(controller);

          return WillPopScope(
            onWillPop: () async {
              // إذا كنا في صفحة غير الرئيسية، انتقل إلى الرئيسية بدلاً من الخروج
              return !controller.handleBackPress();
            },
            child: Scaffold(
              backgroundColor: context.colorBackground,
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
        _headerController.initialize(),
        _profileCardController.refresh(),
        _semesterProgressController.refresh(),
        _performanceIndicatorsController.refresh(),
        _taskCategoriesController.refresh(),
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
    // إزالة مراقب دورة حياة التطبيق
    WidgetsBinding.instance.removeObserver(this);

    _nextLectureController.dispose();
    _statsController.dispose();
    _profileCardController.dispose();
    _semesterProgressController.dispose();
    _performanceIndicatorsController.dispose();
    _taskCategoriesController.dispose();
    super.dispose();
  }
}

// إضافة هذه التوسعات لدعم AppDimensions
extension _AppDimensionsExtensions on AppDimensions {
  static double getCardHeight(BuildContext context,
      {CardSize size = CardSize.regular}) {
    final double baseHeight = AppDimensions.getButtonHeight(context,
        size: ButtonSize.regular, small: false);

    switch (size) {
      case CardSize.small:
        return baseHeight * 1.2;
      case CardSize.regular:
        return baseHeight * 1.5;
      case CardSize.medium:
        return baseHeight * 1.8;
      case CardSize.large:
        return baseHeight * 2.2;
    }
  }
}

enum CardSize {
  small,
  regular,
  medium,
  large,
}

// عنصر العداد التنازلي
class CountdownTimer extends StatefulWidget {
  final int initialSeconds;
  final double? fontSize;
  final bool showIcon;
  final Color? customColor;

  const CountdownTimer({
    Key? key,
    required this.initialSeconds,
    this.fontSize,
    this.showIcon = true,
    this.customColor,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تنسيق الوقت المتبقي
    String formattedTime = _formatRemainingTime(_remainingSeconds);
    Color timeColor =
        widget.customColor ?? _getTimeColor(context, _remainingSeconds);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showIcon) ...[
          Icon(
            Icons.access_time_rounded,
            size: widget.fontSize != null
                ? widget.fontSize! * 1.2
                : AppDimensions.getIconSize(context,
                    size: IconSize.small, small: true),
            color: timeColor,
          ),
          SizedBox(width: 4),
        ],
        Text(
          formattedTime,
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontSize: widget.fontSize ??
                AppDimensions.getLabelFontSize(context) * 0.9,
            fontWeight: FontWeight.bold,
            color: timeColor,
          ),
        ),
      ],
    );
  }

  String _formatRemainingTime(int seconds) {
    if (seconds < 60) {
      return "$seconds ث";
    }

    int minutes = seconds ~/ 60;
    if (minutes < 60) {
      return "$minutes د";
    }

    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return "$hours س";
    }

    return "$hours:${remainingMinutes.toString().padLeft(2, '0')}";
  }

  Color _getTimeColor(BuildContext context, int seconds) {
    if (seconds < 900) {
      // أقل من 15 دقيقة
      return context.colorError;
    } else if (seconds < 1800) {
      // أقل من 30 دقيقة
      return context.colorWarning;
    } else {
      return context.colorSuccess;
    }
  }
}
