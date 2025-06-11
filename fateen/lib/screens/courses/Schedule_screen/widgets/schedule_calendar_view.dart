// schedule_calendar_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/course.dart';
import '../constants/schedule_calendar_constants.dart';
import '../components/schedule_calendar_components.dart';
import '../controllers/schedule_calendar_view_controller.dart';

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
          return ScheduleCalendarComponents.buildShimmerLoading();
        }

        return _buildCalendarView(context);
      },
    );
  }

  /// بناء عرض الجدول
  Widget _buildCalendarView(BuildContext context) {
    // إذا لم تكن هناك محاضرات، أظهر رسالة
    if (_controller.allCourses.isEmpty) {
      return ScheduleCalendarComponents.buildEmptyCoursesView();
    }

    // إذا لم تكن هناك أوقات محاضرات، عرض رسالة للمستخدم
    if (_controller.timeSlots.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ScheduleCalendarConstants.getResponsiveSize(
              context, 20.0, 30.0, 40.0)),
          child: Text(
            ScheduleCalendarConstants.noTimesMessage,
            style: TextStyle(
              fontSize: ScheduleCalendarConstants.getResponsiveSize(
                  context, 14.0, 16.0, 18.0),
              color: Colors.grey.shade600,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // تحسين تجاوب الجدول مع أحجام الشاشة المختلفة
    final fontSize =
        ScheduleCalendarConstants.getResponsiveSize(context, 16.0, 18.0, 20.0);
    final paddingHorizontal =
        ScheduleCalendarConstants.getResponsiveSize(context, 5.0, 10.0, 15.0);
    final paddingVertical =
        ScheduleCalendarConstants.getResponsiveSize(context, 10.0, 15.0, 20.0);

    return ListView(
      padding: EdgeInsets.symmetric(
          vertical: paddingVertical, horizontal: paddingHorizontal),
      children: [
        // عنوان الجدول
        Padding(
          padding: EdgeInsets.only(
            bottom: ScheduleCalendarConstants.getResponsiveSize(
                context, 15.0, 20.0, 25.0),
          ),
          child: Text(
            ScheduleCalendarConstants.weeklyScheduleTitle,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: ScheduleCalendarConstants.kDarkPurple,
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
            borderRadius: BorderRadius.circular(12),
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
                  _controller.allDays, _controller.englishDays),

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
          borderRadius: BorderRadius.circular(12),
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
                _controller.allDays, _controller.englishDays),

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
    final cellHeight =
        ScheduleCalendarConstants.getResponsiveSize(context, 70.0, 80.0, 90.0);

    return _controller.timeSlots.map((timeSlot) {
      final isCurrentTime = _controller.isCurrentTime(timeSlot);

      return Container(
        height: cellHeight,
        decoration: BoxDecoration(
          color: isCurrentTime
              ? ScheduleCalendarConstants.kLightPurple.withOpacity(0.3)
              : null,
          border: const Border(
            top: BorderSide(color: Color(0xFFEFEFEF)),
          ),
        ),
        child: Row(
          children: [
            // خلية الوقت
            ScheduleCalendarComponents.buildTimeCell(timeSlot, isCurrentTime),

            // خلايا الأيام
            ..._controller.allDays.map((day) {
              final isToday = _controller.isCurrentDay(day);
              final course = _controller.getCourseAtTimeSlot(day, timeSlot);

              return Expanded(
                child: ScheduleCalendarComponents.buildDayCell(
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
