// daily_schedule_view.dart
import 'package:fateen/screens/courses/Schedule_screen/components/daily_schedule_screen.dart';
import 'package:flutter/material.dart';
import '../controllers/daily_schedule_controller.dart';
import '../components/daily_schedule_components.dart';
import '../../../../models/course.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class DailyScheduleView extends StatefulWidget {
  final Function(Course course)? onCourseSelected;

  const DailyScheduleView({
    Key? key,
    this.onCourseSelected,
  }) : super(key: key);

  @override
  _DailyScheduleViewState createState() => _DailyScheduleViewState();
}

class _DailyScheduleViewState extends State<DailyScheduleView>
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
    _controller.fetchCoursesFromFirestore();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return DailyScheduleComponents.buildShimmerLoading(context);
        }

        return TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: _controller.allDays.map((day) {
            final courses = _controller.getCoursesForDaySorted(day);

            if (courses.isEmpty) {
              return DailyScheduleComponents.buildEmptyDayView(context, day);
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    AppDimensions.getSpacing(context, size: SpacingSize.small),
                vertical:
                    AppDimensions.getSpacing(context, size: SpacingSize.small) /
                        2,
              ),
              child: ListView.builder(
                itemCount: courses.length,
                padding: EdgeInsets.only(
                    bottom: AppDimensions.getSpacing(context,
                        size: SpacingSize.small)),
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: AppDimensions.getSpacing(context,
                            size: SpacingSize.small)),
                    child: DailyScheduleComponents.buildCourseCard(
                      context,
                      course,
                      _controller.courseColors[course.id] ??
                          context.colorPrimaryPale,
                      _controller.courseBorderColors[course.id] ??
                          context.colorPrimaryLight,
                      () {
                        if (widget.onCourseSelected != null) {
                          widget.onCourseSelected!(course);
                        }
                      },
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
