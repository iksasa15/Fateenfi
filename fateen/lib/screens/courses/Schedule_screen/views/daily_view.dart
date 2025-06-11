import 'package:flutter/material.dart';
import '../controllers/daily_schedule_controller.dart';
import '../components/daily_schedule_components.dart';
import '../../../../models/course.dart';

/// عرض الجدول اليومي
class DailyView extends StatelessWidget {
  final DailyScheduleController controller;
  final TabController tabController;
  final Function(Course)? onCourseSelected;
  final bool isLoading;

  const DailyView({
    Key? key,
    required this.controller,
    required this.tabController,
    this.onCourseSelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return DailyScheduleComponents.buildShimmerLoading();
    }

    return TabBarView(
      controller: tabController,
      physics: const BouncingScrollPhysics(),
      children: controller.allDays.map((day) {
        return _buildDayContent(context, day);
      }).toList(),
    );
  }

  /// بناء محتوى اليوم
  Widget _buildDayContent(BuildContext context, String day) {
    // الحصول على المقررات لهذا اليوم
    final courses = controller.getCoursesForDaySorted(day);

    // عرض رسالة في حال عدم وجود محاضرات
    if (courses.isEmpty) {
      return DailyScheduleComponents.buildEmptyDayView(day);
    }

    // استخدام MediaQuery للتجاوب
    final Size screenSize = MediaQuery.of(context).size;
    final double cardSpacing = screenSize.height * 0.015;
    final double horizontalPadding = screenSize.width * 0.04;

    // عرض قائمة المحاضرات
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: cardSpacing,
      ),
      child: ListView.builder(
        itemCount: courses.length,
        padding: EdgeInsets.only(bottom: cardSpacing),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final course = courses[index];

          // استخدام Hero لإضافة انتقال سلس عند فتح التفاصيل
          return Hero(
            tag: 'course_${course.id}',
            child: Material(
              // استخدام Material للحفاظ على النص أثناء انتقال Hero
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.only(bottom: cardSpacing),
                child: DailyScheduleComponents.buildCourseCard(
                  context,
                  course,
                  controller.courseColors[course.id] ?? const Color(0xFFF5F3FF),
                  controller.courseBorderColors[course.id] ??
                      const Color(0xFF6366F1),
                  () => onCourseSelected?.call(course),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
