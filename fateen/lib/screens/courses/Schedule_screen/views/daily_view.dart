import 'package:fateen/screens/courses/Schedule_screen/components/daily_schedule_screen.dart';
import 'package:flutter/material.dart';
import '../controllers/daily_schedule_controller.dart';
import '../components/daily_schedule_components.dart';
import '../../../../models/course.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

/// عرض الجدول اليومي
class DailyView extends StatelessWidget {
  final DailyScheduleController controller;
  final TabController tabController;
  final Function(Course)? onCourseSelected;

  const DailyView({
    Key? key,
    required this.controller,
    required this.tabController,
    this.onCourseSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      return DailyScheduleComponents.buildEmptyDayView(context, day);
    }

    // عرض قائمة المحاضرات
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.getSpacing(context, size: SpacingSize.small),
        vertical:
            AppDimensions.getSpacing(context, size: SpacingSize.small) / 2,
      ),
      child: ListView.builder(
        itemCount: courses.length,
        padding: EdgeInsets.only(
            bottom: AppDimensions.getSpacing(context, size: SpacingSize.small)),
        itemBuilder: (context, index) {
          final course = courses[index];
          return Padding(
            padding: EdgeInsets.only(
                bottom:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),
            child: DailyScheduleComponents.buildCourseCard(
              context,
              course,
              controller.courseColors[course.id] ?? context.colorPrimaryPale,
              controller.courseBorderColors[course.id] ??
                  context.colorPrimaryLight,
              () => onCourseSelected?.call(course),
            ),
          );
        },
      ),
    );
  }

  /// عرض تفاصيل المادة
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
        child: DailyScheduleComponents.buildCourseDetailsSheet(context, course),
      ),
    );
  }

  /// إنشاء واجهة التحميل
  static Widget buildLoadingView(BuildContext context) {
    return DailyScheduleComponents.buildShimmerLoading(context);
  }
}
