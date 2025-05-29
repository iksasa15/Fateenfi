import 'package:flutter/material.dart';
import 'dart:async';

// استيراد المكونات
import 'package:fateen/screens/courses/Schedule_screen/widgets/schedule_header_widget.dart';
import 'package:fateen/screens/courses/Schedule_screen/components/days_tabs_component.dart';

// استيراد المتحكمات
import 'package:fateen/screens/courses/Schedule_screen/controllers/schedule_view_controller.dart';
import 'package:fateen/screens/courses/Schedule_screen/controllers/schedule_calendar_view_controller.dart';
import 'package:fateen/screens/courses/Schedule_screen/controllers/daily_schedule_controller.dart';
import 'package:fateen/screens/courses/Schedule_screen/controllers/days_tabs_controller.dart';

// استيراد مكونات العرض
import 'package:fateen/screens/courses/Schedule_screen/components/schedule_calendar_components.dart';
import 'package:fateen/screens/courses/Schedule_screen/components/daily_schedule_components.dart';

// استيراد نموذج المادة
import 'package:fateen/models/course.dart';

/// شاشة الجدول الدراسي
///
/// تعرض جدول المحاضرات بطريقتين:
/// 1. عرض أسبوعي (جدول)
/// 2. عرض يومي (قائمة)
class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({Key? key}) : super(key: key);

  @override
  _MyScheduleScreenState createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen>
    with SingleTickerProviderStateMixin {
  // التعريف بالمتحكمات
  final _viewController = ScheduleViewController();
  late ScheduleCalendarViewController _calendarController;
  late DailyScheduleController _dailyController;
  late TabController _tabController;
  late DaysTabsController _daysTabsController;

  // متغيرات تعقب حالة تحميل البيانات
  bool _isCalendarDataLoaded = false;
  bool _isDailyDataLoaded = false;

  // متغيرات للاستماع لتغييرات قاعدة البيانات
  StreamSubscription? _calendarStreamSubscription;
  StreamSubscription? _dailyStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();

    // تحميل بيانات العرض اليومي في البداية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDailyData();
    });
  }

  /// تهيئة المتحكمات
  void _initializeControllers() {
    // تهيئة متحكمات العرض المختلفة
    _calendarController = ScheduleCalendarViewController();
    _dailyController = DailyScheduleController();
    _daysTabsController = DaysTabsController();

    // تهيئة متحكم التابات
    _tabController = TabController(
      length: _dailyController.allDays.length,
      vsync: this,
      initialIndex: _dailyController.selectedDayIndex,
    );

    // الاستماع للتغييرات في التابات
    _tabController.addListener(_handleTabChange);
  }

  /// معالجة تغيير التاب المحدد
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _dailyController.setSelectedDayIndex(_tabController.index);
      _daysTabsController.setSelectedDayIndex(_tabController.index);
      setState(() {});
    }
  }

  /// إعداد الاستماع للتغييرات في قاعدة البيانات
  void _setupListeners() {
    // الاستماع للتغييرات في المقررات للعرض الأسبوعي
    _calendarStreamSubscription =
        _calendarController.listenToCourses().listen((courses) {
      if (_isCalendarDataLoaded && mounted) {
        setState(() {
          _calendarController.updateCourses(courses);
        });
      }
    });

    // الاستماع للتغييرات في المقررات للعرض اليومي
    _dailyStreamSubscription =
        _dailyController.listenToCourses().listen((courses) {
      if (_isDailyDataLoaded && mounted) {
        setState(() {
          _dailyController.updateCourses(courses);
          _daysTabsController.updateCourses(courses);
        });
      }
    });
  }

  /// تحميل بيانات العرض الأسبوعي
  Future<void> _loadCalendarData() async {
    setState(() {
      _isCalendarDataLoaded = false;
    });

    await _calendarController.fetchCoursesFromFirestore();

    if (mounted) {
      setState(() {
        _isCalendarDataLoaded = true;
      });
    }
  }

  /// تحميل بيانات العرض اليومي
  Future<void> _loadDailyData() async {
    setState(() {
      _isDailyDataLoaded = false;
    });

    await _dailyController.fetchCoursesFromFirestore();
    _daysTabsController.updateCourses(_dailyController.allCourses);

    if (mounted) {
      setState(() {
        _isDailyDataLoaded = true;
      });
    }
  }

  /// تحديث بيانات الجدول
  void _refreshScheduleData() {
    if (_viewController.showCalendarView) {
      _loadCalendarData();
    } else {
      _loadDailyData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      body: SafeArea(
        child: Column(
          children: [
            // هيدر الجدول الدراسي
            _buildHeader(),

            // شريط التبويبات لأيام الأسبوع (يظهر فقط في العرض اليومي)
            _buildDaysTabs(),

            // محتوى الجدول (أسبوعي/يومي)
            _buildScheduleContent(),
          ],
        ),
      ),
    );
  }

  /// بناء هيدر الجدول
  Widget _buildHeader() {
    return ScheduleHeaderWidget(
      controller: _viewController,
      onViewModeChanged: (isCalendarView) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isCalendarView && !_isCalendarDataLoaded) {
            _loadCalendarData();
          } else if (!isCalendarView && !_isDailyDataLoaded) {
            _loadDailyData();
          }
        });
      },
    );
  }

  /// بناء شريط تبويبات الأيام
  Widget _buildDaysTabs() {
    return ListenableBuilder(
      listenable: _viewController,
      builder: (context, _) {
        // نعرض شريط الأيام فقط في عرض القائمة اليومية
        if (!_viewController.showCalendarView) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                // شريط الأيام
                DaysTabsComponent.buildDaysTabs(
                    context, _daysTabsController, _tabController),

                // ملخص اليوم
                if (_isDailyDataLoaded)
                  DaysTabsComponent.buildDaySummary(
                      context, _daysTabsController),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// بناء محتوى الجدول (يتغير حسب وضع العرض المختار)
  Widget _buildScheduleContent() {
    return Expanded(
      child: ListenableBuilder(
        listenable: _viewController,
        builder: (context, _) {
          return _viewController.showCalendarView
              ? _buildCalendarView(context)
              : _buildDailyView(context);
        },
      ),
    );
  }

  /// بناء عرض الجدول الأسبوعي
  Widget _buildCalendarView(BuildContext context) {
    if (!_isCalendarDataLoaded) {
      return ScheduleCalendarComponents.buildShimmerLoading();
    }

    // إذا تم تحميل البيانات، عرض المحتوى بناءً على حالة البيانات
    if (_calendarController.allCourses.isEmpty) {
      return ScheduleCalendarComponents.buildEmptyCoursesView();
    }

    if (_calendarController.timeSlots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'لا توجد مواعيد محاضرات محددة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // تحسين تجاوب الجدول مع أحجام الشاشة المختلفة
    final fontSize = 18.0;
    final paddingHorizontal = 10.0;
    final paddingVertical = 10.0;

    return ListView(
      padding: EdgeInsets.symmetric(
          vertical: paddingVertical, horizontal: paddingHorizontal),
      children: [
        // عنوان الجدول
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text(
            'جدول المحاضرات الأسبوعي',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4338CA),
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // الجدول نفسه
        _buildResponsiveCalendarTable(context),
      ],
    );
  }

  /// بناء جدول متجاوب مع حجم الشاشة
  Widget _buildResponsiveCalendarTable(BuildContext context) {
    // تحديد ما إذا كنا بحاجة لتصغير الجدول أو تمريره أفقيًا
    final screenWidth = MediaQuery.of(context).size.width;
    final minRequiredWidth = 500.0; // العرض المقدر المطلوب للجدول

    // للشاشات الصغيرة نستخدم تمرير أفقي
    if (screenWidth < minRequiredWidth) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          // تحديد عرض ثابت للجدول على الشاشات الصغيرة
          width: minRequiredWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // صف عناوين الأيام
              ScheduleCalendarComponents.buildHeaderRow(
                  _calendarController.allDays, _calendarController.englishDays),

              // صفوف الأوقات
              ..._buildTimeRows(context),
            ],
          ),
        ),
      );
    } else {
      // للشاشات الكبيرة نعرض الجدول عاديًا
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // صف عناوين الأيام
            ScheduleCalendarComponents.buildHeaderRow(
                _calendarController.allDays, _calendarController.englishDays),

            // صفوف الأوقات
            ..._buildTimeRows(context),
          ],
        ),
      );
    }
  }

  /// بناء صفوف الجدول الزمني
  List<Widget> _buildTimeRows(BuildContext context) {
    // قياس ارتفاع الخلية حسب حجم الشاشة
    final cellHeight = 80.0;

    return _calendarController.timeSlots.map((timeSlot) {
      final isCurrentTime = _calendarController.isCurrentTime(timeSlot);

      return Container(
        height: cellHeight,
        decoration: BoxDecoration(
          color:
              isCurrentTime ? const Color(0xFFF5F3FF).withOpacity(0.3) : null,
          border: const Border(
            top: BorderSide(color: Color(0xFFEFEFEF)),
          ),
        ),
        child: Row(
          children: [
            // خلية الوقت
            ScheduleCalendarComponents.buildTimeCell(timeSlot, isCurrentTime),

            // خلايا الأيام
            ..._calendarController.allDays.map((day) {
              final isToday = _calendarController.isCurrentDay(day);
              final course =
                  _calendarController.getCourseAtTimeSlot(day, timeSlot);

              return Expanded(
                child: ScheduleCalendarComponents.buildDayCell(
                  course,
                  isToday && isCurrentTime,
                  course != null
                      ? _calendarController.courseColors[course.id]
                      : null,
                  course != null
                      ? _calendarController.courseBorderColors[course.id]
                      : null,
                  course != null
                      ? () => _showCourseDetails(course, context)
                      : null,
                ),
              );
            }),
          ],
        ),
      );
    }).toList();
  }

  /// عرض تفاصيل المادة في العرض الأسبوعي
  void _showCourseDetails(Course course, BuildContext context) {
    // تحديد الحد الأقصى للارتفاع
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.7; // بحد أقصى 70% من ارتفاع الشاشة

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // هيدر
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF4338CA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      course.courseName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 5),
                        Text(
                          course.lectureTime ?? 'وقت غير محدد',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // تفاصيل
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ScheduleCalendarComponents.buildDetailItem(
                      icon: Icons.location_on_outlined,
                      title: 'القاعة',
                      value: course.classroom ?? 'غير محدد',
                    ),
                    ScheduleCalendarComponents.buildDetailItem(
                      icon: Icons.calendar_today_outlined,
                      title: 'أيام المحاضرة',
                      value: course.days.join(' - '),
                    ),
                    if (course.creditHours != null)
                      ScheduleCalendarComponents.buildDetailItem(
                        icon: Icons.book_outlined,
                        title: 'الساعات المعتمدة',
                        value: '${course.creditHours} ساعات',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء عرض القائمة اليومية
  Widget _buildDailyView(BuildContext context) {
    if (!_isDailyDataLoaded) {
      return DailyScheduleComponents.buildShimmerLoading();
    }

    // عرض القائمة اليومية باستخدام مكونات DailyScheduleComponents
    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(), // للتمرير السلس
      children: _dailyController.allDays.map((day) {
        final courses = _dailyController.getCoursesForDaySorted(day);

        if (courses.isEmpty) {
          return DailyScheduleComponents.buildEmptyDayView(day);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListView.builder(
            itemCount: courses.length,
            padding: const EdgeInsets.only(bottom: 15),
            itemBuilder: (context, index) {
              final course = courses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: DailyScheduleComponents.buildCourseCard(
                  course,
                  _dailyController.courseColors[course.id] ??
                      const Color(0xFFF5F3FF),
                  _dailyController.courseBorderColors[course.id] ??
                      const Color(0xFF6366F1),
                  () => _showDailyCourseDetails(course, context),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  /// عرض تفاصيل المادة في العرض اليومي
  void _showDailyCourseDetails(Course course, BuildContext context) {
    // تحديد الحد الأقصى للارتفاع
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.7; // بحد أقصى 70% من ارتفاع الشاشة

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      builder: (context) => SingleChildScrollView(
        child: DailyScheduleComponents.buildCourseDetailsSheet(context, course),
      ),
    );
  }

  @override
  void dispose() {
    // إلغاء الاستماع للتغييرات
    _calendarStreamSubscription?.cancel();
    _dailyStreamSubscription?.cancel();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
}
