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
import 'package:fateen/screens/courses/Schedule_screen/views/daily_view.dart';
import 'package:fateen/screens/courses/Schedule_screen/views/calendar_view.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      body: SafeArea(
        child: Column(
          children: [
            // هيدر الجدول الدراسي
            ScheduleHeaderWidget(
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
            ),

            // شريط التبويبات لأيام الأسبوع (يظهر فقط في العرض اليومي)
            _buildDaysTabs(),

            // محتوى الجدول (أسبوعي/يومي)
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _viewController.showCalendarView
                    ? CalendarView(
                        key: const ValueKey('calendar_view'),
                        controller: _calendarController,
                        onCourseSelected: _showCourseDetails,
                        isLoading: !_isCalendarDataLoaded,
                      )
                    : DailyView(
                        key: const ValueKey('daily_view'),
                        controller: _dailyController,
                        tabController: _tabController,
                        onCourseSelected: _showDailyCourseDetails,
                        isLoading: !_isDailyDataLoaded,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء شريط تبويبات الأيام
  Widget _buildDaysTabs() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _viewController.showCalendarView
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('days_tabs'),
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
            ),
    );
  }

  /// عرض تفاصيل المادة في العرض الأسبوعي
  void _showCourseDetails(Course course, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.7,
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
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
                    _buildDetailItem(
                      icon: Icons.location_on_outlined,
                      title: 'القاعة',
                      value: course.classroom ?? 'غير محدد',
                    ),
                    _buildDetailItem(
                      icon: Icons.calendar_today_outlined,
                      title: 'أيام المحاضرة',
                      value: course.days.join(' - '),
                    ),
                    if (course.creditHours != null)
                      _buildDetailItem(
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

  /// عرض تفاصيل المادة في العرض اليومي
  void _showDailyCourseDetails(Course course) {
    _showCourseDetails(course, context);
  }

  /// بناء عنصر تفاصيل المادة
  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4338CA),
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ],
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
