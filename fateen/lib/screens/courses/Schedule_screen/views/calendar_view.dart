import 'package:flutter/material.dart';
import '../controllers/schedule_calendar_view_controller.dart';
import '../components/schedule_calendar_components.dart';
import '../../../../models/course.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

/// عرض الجدول الأسبوعي
class CalendarView extends StatelessWidget {
  final ScheduleCalendarViewController controller;
  final Function(Course, BuildContext)? onCourseSelected;

  const CalendarView({
    Key? key,
    required this.controller,
    this.onCourseSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // التحقق من وجود مواد
    if (controller.allCourses.isEmpty) {
      return ScheduleCalendarComponents.buildEmptyCoursesView(context);
    }

    // التحقق من وجود أوقات محاضرات
    if (controller.timeSlots.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
          child: Text(
            'لا توجد مواعيد محاضرات محددة',
            style: TextStyle(
              fontSize: AppDimensions.getBodyFontSize(context),
              color: context.colorTextSecondary,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // عرض الجدول
    return _buildWeeklySchedule(context);
  }

  /// بناء تخطيط الجدول الأسبوعي
  Widget _buildWeeklySchedule(BuildContext context) {
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
              bottom:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          child: Text(
            'جدول المحاضرات الأسبوعي',
            style: TextStyle(
              fontSize: AppDimensions.getSubtitleFontSize(context),
              fontWeight: FontWeight.bold,
              color: context.colorPrimaryDark,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildTableContent(context, 500),
    );
  }

  /// بناء جدول بعرض كامل (للشاشات الكبيرة)
  Widget _buildFullWidthTable(BuildContext context) {
    return _buildTableContent(context, null);
  }

  /// بناء محتوى الجدول
  Widget _buildTableContent(BuildContext context, double? fixedWidth) {
    return Container(
      width: fixedWidth,
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
          // صف العناوين (الأيام)
          ScheduleCalendarComponents.buildHeaderRow(
              context, controller.allDays, controller.englishDays),

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

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isCurrentTime ? context.colorPrimaryPale.withOpacity(0.3) : null,
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

  /// عرض تفاصيل المادة عند النقر عليها
  static void showCourseDetails(BuildContext context, Course course) {
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
          margin: EdgeInsets.all(
              AppDimensions.getSpacing(context, size: SpacingSize.small)),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // هيدر
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
                decoration: BoxDecoration(
                  color: context.colorPrimaryDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.mediumRadius),
                    topRight: Radius.circular(AppDimensions.mediumRadius),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      course.courseName,
                      style: TextStyle(
                        fontSize: AppDimensions.getSubtitleFontSize(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                        height: AppDimensions.getSpacing(context,
                                size: SpacingSize.small) /
                            2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time,
                            size: AppDimensions.getIconSize(context,
                                size: IconSize.small, small: true),
                            color: Colors.white70),
                        SizedBox(
                            width: AppDimensions.getSpacing(context,
                                    size: SpacingSize.small) /
                                2),
                        Text(
                          course.lectureTime ?? 'وقت غير محدد',
                          style: TextStyle(
                            fontSize: AppDimensions.getBodyFontSize(context,
                                small: true),
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
                padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
                child: Column(
                  children: [
                    ScheduleCalendarComponents.buildDetailItem(
                      context: context,
                      icon: Icons.location_on_outlined,
                      title: 'القاعة',
                      value: course.classroom ?? 'غير محدد',
                    ),
                    ScheduleCalendarComponents.buildDetailItem(
                      context: context,
                      icon: Icons.calendar_today_outlined,
                      title: 'أيام المحاضرة',
                      value: course.days.join(' - '),
                    ),
                    if (course.creditHours != null)
                      ScheduleCalendarComponents.buildDetailItem(
                        context: context,
                        icon: Icons.book_outlined,
                        title: 'الساعات المعتمدة',
                        value: '${course.creditHours} ساعات',
                      ),
                  ],
                ),
              ),
              SizedBox(
                  height: AppDimensions.getSpacing(context,
                      size: SpacingSize.small)),
            ],
          ),
        ),
      ),
    );
  }

  /// إنشاء واجهة التحميل
  static Widget buildLoadingView(BuildContext context) {
    return ScheduleCalendarComponents.buildShimmerLoading(context);
  }
}
