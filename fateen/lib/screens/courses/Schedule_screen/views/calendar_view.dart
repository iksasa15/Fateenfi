import 'package:flutter/material.dart';
import '../controllers/schedule_calendar_view_controller.dart';
import '../components/schedule_calendar_components.dart';
import '../../../../models/course.dart';

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
      return ScheduleCalendarComponents.buildEmptyCoursesView();
    }

    // التحقق من وجود أوقات محاضرات
    if (controller.timeSlots.isEmpty) {
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

    // عرض الجدول
    return _buildWeeklySchedule(context);
  }

  /// بناء تخطيط الجدول الأسبوعي
  Widget _buildWeeklySchedule(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      children: [
        // عنوان الجدول
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text(
            'جدول المحاضرات الأسبوعي',
            style: TextStyle(
              fontSize: 18,
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

    return Container(
      height: 80,
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

  /// إنشاء واجهة التحميل
  static Widget buildLoadingView() {
    return ScheduleCalendarComponents.buildShimmerLoading();
  }
}
