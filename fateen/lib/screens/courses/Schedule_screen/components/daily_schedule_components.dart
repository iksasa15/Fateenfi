// daily_schedule_screen.dart
import 'package:fateen/screens/courses/Schedule_screen/components/daily_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/daily_schedule_components.dart';
import '../constants/daily_schedule_constants.dart';
import '../controllers/daily_schedule_controller.dart';
import '../../../../models/course.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class DailyScheduleScreen extends StatefulWidget {
  const DailyScheduleScreen({Key? key}) : super(key: key);

  @override
  _DailyScheduleScreenState createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends State<DailyScheduleScreen>
    with SingleTickerProviderStateMixin {
  late DailyScheduleController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // إنشاء المتحكم ببيانات الجدول
    _controller = DailyScheduleController();

    // إعداد متحكم التابات
    _tabController = TabController(
      length: _controller.allDays.length,
      vsync: this,
      initialIndex: _controller.selectedDayIndex,
    );

    // الاستماع للتغييرات عند النقر على علامة التبويب
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _controller.setSelectedDayIndex(_tabController.index);
      }
    });

    // تحميل البيانات
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.fetchCoursesFromFirestore();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorBackground,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الهيدر الثابت - يبقى دائمًا في الأعلى ولا يتحرك عند التمرير
                _buildFixedHeader(context),

                // الجزء المتحرك - محتوى الجدول
                Expanded(
                  child: _controller.isLoading
                      ? DailyScheduleComponents.buildShimmerLoading(context)
                      : _buildDailyView(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// بناء الهيدر الثابت الذي يبقى في الأعلى دائمًا
  Widget _buildFixedHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الهيدر الرئيسي
        _buildHeader(context),

        // خط أفقي رفيع بعد الهيدر
        Divider(height: 1, thickness: 1, color: context.colorDivider),

        // ملخص الجدول الزمني لليوم - لا يظهر في وضع التحميل
        if (!_controller.isLoading)
          DailyScheduleComponents.buildDaySummary(
            context,
            _controller.allDays,
            _controller.selectedDayIndex,
            _controller.getCoursesForCurrentSelectedDay().length,
          ),
      ],
    );
  }

  /// بناء رأس الصفحة بتصميم متناسق مع باقي التطبيق
  Widget _buildHeader(BuildContext context) {
    final titleSize = AppDimensions.getTitleFontSize(context, small: true);
    final padding = AppDimensions.getSpacing(context);

    return Container(
      padding: EdgeInsets.all(padding),
      color: context.colorSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Text(
            DailyScheduleConstants.screenTitle,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: context.colorTextPrimary,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),

          SizedBox(
              height:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),

          // تابات الأيام
          DailyScheduleComponents.buildDaysTabs(
            context,
            _controller.allDays,
            _tabController,
            _controller.selectedDayIndex,
            (index) => _controller.setSelectedDayIndex(index),
            _controller.todayEnglish,
            _controller.englishDays,
          ),
        ],
      ),
    );
  }

  /// بناء عرض القائمة اليومية
  Widget _buildDailyView() {
    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(), // للتمرير السلس
      children: _controller.allDays.map((day) {
        final courses = _controller.getCoursesForDaySorted(day);

        if (courses.isEmpty) {
          return DailyScheduleComponents.buildEmptyDayView(context, day);
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.getSpacing(context),
            vertical:
                AppDimensions.getSpacing(context, size: SpacingSize.small),
          ),
          child: ListView.builder(
            itemCount: courses.length,
            padding: EdgeInsets.only(
              bottom: AppDimensions.getSpacing(context),
            ),
            itemBuilder: (context, index) {
              final course = courses[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: AppDimensions.getSpacing(context,
                      size: SpacingSize.small),
                ),
                child: DailyScheduleComponents.buildCourseCard(
                  context,
                  course,
                  _controller.courseColors[course.id] ??
                      context.colorPrimaryPale,
                  _controller.courseBorderColors[course.id] ??
                      context.colorPrimaryLight,
                  () => _showCourseDetails(course),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  /// عرض تفاصيل المادة
  void _showCourseDetails(Course course) {
    // تحديد الحد الأقصى للارتفاع
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.7; // بحد أقصى 70% من ارتفاع الشاشة

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // للسماح بالتمرير
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      builder: (context) => SingleChildScrollView(
        child: DailyScheduleComponents.buildCourseDetailsSheet(context, course),
      ),
    );
  }
}
