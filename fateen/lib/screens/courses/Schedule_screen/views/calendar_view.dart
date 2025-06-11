import 'package:flutter/material.dart';
import '../controllers/schedule_calendar_view_controller.dart';
import '../components/schedule_calendar_components.dart';
import '../../../../models/course.dart';

/// عرض الجدول الأسبوعي
class CalendarView extends StatelessWidget {
  final ScheduleCalendarViewController controller;
  final Function(Course, BuildContext)? onCourseSelected;
  final bool isLoading;

  const CalendarView({
    Key? key,
    required this.controller,
    this.onCourseSelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // عرض حالة التحميل
    if (isLoading) {
      return ScheduleCalendarComponents.buildShimmerLoading();
    }

    // التحقق من وجود مواد
    if (controller.allCourses.isEmpty) {
      return ScheduleCalendarComponents.buildEmptyCoursesView();
    }

    // التحقق من وجود أوقات محاضرات
    if (controller.timeSlots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 60,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد مواعيد محاضرات محددة',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // عرض الجدول
    return _buildWeeklySchedule(context);
  }

  /// بناء تخطيط الجدول الأسبوعي
  Widget _buildWeeklySchedule(BuildContext context) {
    // استخدام MediaQuery للتجاوب
    final Size screenSize = MediaQuery.of(context).size;
    final double titleSize = screenSize.width < 360 ? 16.0 : 18.0;
    final double horizontalPadding = screenSize.width * 0.04;
    final double verticalPadding = screenSize.height * 0.02;

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        // عنوان الجدول
        Padding(
          padding: EdgeInsets.only(bottom: verticalPadding * 0.8),
          child: Text(
            'جدول المحاضرات الأسبوعي',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4338CA),
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // جدول المحاضرات
        _buildResponsiveCalendarTable(context),
      ],
    );
  }

  /// بناء جدول متجاوب مع أحجام الشاشات المختلفة
  Widget _buildResponsiveCalendarTable(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 500) {
      return _buildScrollableTable(context);
    } else {
      return _buildFullWidthTable(context);
    }
  }

  /// بناء جدول قابل للتمرير أفقيًا (للشاشات الصغيرة)
  Widget _buildScrollableTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: _buildTableContent(context, 550), // عرض ثابت للجدول
      ),
    );
  }

  /// بناء جدول بعرض كامل (للشاشات الكبيرة)
  Widget _buildFullWidthTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildTableContent(context, null),
    );
  }

  /// بناء محتوى الجدول
  Widget _buildTableContent(BuildContext context, double? fixedWidth) {
    return SizedBox(
      width: fixedWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // صف العناوين (الأيام)
          ScheduleCalendarComponents.buildHeaderRow(
              controller.allDays, controller.englishDays),

          // صفوف الأوقات والمحاضرات
          ...controller.timeSlots.map((timeSlot) {
            return _buildTimeRow(context, timeSlot);
          }).toList(),
        ],
      ),
    );
  }

  /// بناء صف لوقت معين
  Widget _buildTimeRow(BuildContext context, String timeSlot) {
    final isCurrentTime = controller.isCurrentTime(timeSlot);

    // استخدام MediaQuery للتجاوب
    final Size screenSize = MediaQuery.of(context).size;
    final double rowHeight = screenSize.height * 0.1; // 10% من ارتفاع الشاشة

    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        color: isCurrentTime ? const Color(0xFFF5F3FF).withOpacity(0.3) : null,
        border: const Border(
          top: BorderSide(color: Color(0xFFEFEFEF)),
        ),
      ),
      child: Row(
        children: [
          // خلية الوقت
          ScheduleCalendarComponents.buildTimeCell(timeSlot, isCurrentTime),

          // خلايا الأيام
          ...controller.allDays.map((day) {
            final isToday = controller.isCurrentDay(day);
            final course = controller.getCourseAtTimeSlot(day, timeSlot);

            return Expanded(
              child: ScheduleCalendarComponents.buildDayCell(
                context,
                course,
                isToday && isCurrentTime,
                course != null ? controller.courseColors[course.id] : null,
                course != null
                    ? controller.courseBorderColors[course.id]
                    : null,
                course != null
                    ? () => onCourseSelected?.call(course, context)
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}
