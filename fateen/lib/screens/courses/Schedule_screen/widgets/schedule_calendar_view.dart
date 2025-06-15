// schedule_calendar_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/course.dart';
import '../constants/schedule_calendar_constants.dart';
import '../components/schedule_calendar_components.dart';
import '../controllers/schedule_calendar_view_controller.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class ScheduleCalendarView extends StatefulWidget {
  final Function(Course course, BuildContext context)? onCourseSelected;

  const ScheduleCalendarView({
    Key? key,
    this.onCourseSelected,
  }) : super(key: key);

  @override
  _ScheduleCalendarViewState createState() => _ScheduleCalendarViewState();
}

class _ScheduleCalendarViewState extends State<ScheduleCalendarView> {
  late ScheduleCalendarViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScheduleCalendarViewController();
    _controller.fetchCoursesFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return ScheduleCalendarComponents.buildShimmerLoading(context);
        }

        return _buildCalendarView(context);
      },
    );
  }

  /// بناء عرض الجدول
  Widget _buildCalendarView(BuildContext context) {
    // إذا لم تكن هناك محاضرات، أظهر رسالة
    if (_controller.allCourses.isEmpty) {
      return ScheduleCalendarComponents.buildEmptyCoursesView(context);
    }

    // إذا لم تكن هناك أوقات محاضرات، عرض رسالة للمستخدم
    if (_controller.timeSlots.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
          child: Text(
            ScheduleCalendarConstants.noTimesMessage,
            style: TextStyle(
              fontSize: AppDimensions.getBodyFontSize(context),
              color: context.colorTextSecondary,
              fontFamily: ScheduleCalendarConstants.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.getSpacing(context, size: SpacingSize.small),
        horizontal:
            AppDimensions.getSpacing(context, size: SpacingSize.small) / 2,
      ),
      children: [
        // عنوان الجدول
        Padding(
          padding: EdgeInsets.only(
            bottom: AppDimensions.getSpacing(context, size: SpacingSize.small),
          ),
          child: Text(
            ScheduleCalendarConstants.weeklyScheduleTitle,
            style: TextStyle(
              fontSize: AppDimensions.getSubtitleFontSize(context),
              fontWeight: FontWeight.bold,
              color: context.colorPrimaryDark,
              fontFamily: ScheduleCalendarConstants.fontFamily,
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
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
            boxShadow: [
              BoxShadow(
                color: context.colorShadow,
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // صف عناوين الأيام
              ScheduleCalendarComponents.buildHeaderRow(
                  context, _controller.allDays, _controller.englishDays),

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
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
          boxShadow: [
            BoxShadow(
              color: context.colorShadow,
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // صف عناوين الأيام
            ScheduleCalendarComponents.buildHeaderRow(
                context, _controller.allDays, _controller.englishDays),

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
    final cellHeight = ScheduleCalendarConstants.rowHeight;

    return _controller.timeSlots.map((timeSlot) {
      final isCurrentTime = _controller.isCurrentTime(timeSlot);

      return Container(
        height: cellHeight,
        decoration: BoxDecoration(
          color:
              isCurrentTime ? context.colorPrimaryPale.withOpacity(0.3) : null,
          border: Border(
            top: BorderSide(color: context.colorDivider),
          ),
        ),
        child: Row(
          children: [
            // خلية الوقت
            ScheduleCalendarComponents.buildTimeCell(
                context, timeSlot, isCurrentTime),

            // خلايا الأيام
            ..._controller.allDays.map((day) {
              final isToday = _controller.isCurrentDay(day);
              final course = _controller.getCourseAtTimeSlot(day, timeSlot);

              return Expanded(
                child: ScheduleCalendarComponents.buildDayCell(
                  context,
                  course,
                  isToday && isCurrentTime,
                  course != null ? _controller.courseColors[course.id] : null,
                  course != null
                      ? _controller.courseBorderColors[course.id]
                      : null,
                  course != null ? () => _courseTapped(course, context) : null,
                ),
              );
            }),
          ],
        ),
      );
    }).toList();
  }

  // معالجة النقر على مادة
  void _courseTapped(Course course, BuildContext context) {
    if (widget.onCourseSelected != null) {
      widget.onCourseSelected!(course, context);
    }
  }
}
