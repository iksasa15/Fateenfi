import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/daily_schedule_constants.dart';
import '../../../../models/course.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class DailyScheduleComponents {
  /// بناء واجهة Shimmer للتحميل
  static Widget buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorShimmerBase,
      highlightColor: context.colorShimmerHighlight,
      child: _buildListViewShimmer(context),
    );
  }

  /// Shimmer لعرض القائمة
  static Widget _buildListViewShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان وهمي للقائمة
        Padding(
          padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 130,
                height: 20,
                decoration: BoxDecoration(
                  color: context.colorSurface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius),
                ),
              ),
              Container(
                width: 80,
                height: 30,
                decoration: BoxDecoration(
                  color: context.colorSurface,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ],
          ),
        ),

        // بطاقات وهمية
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.getSpacing(context)),
          child: Column(
            children: List.generate(
              4, // 4 بطاقات وهمية
              (index) => Container(
                width: double.infinity,
                height: AppDimensions.getButtonHeight(context,
                        size: ButtonSize.medium, small: false) *
                    1.5,
                margin: EdgeInsets.only(
                    bottom: AppDimensions.getSpacing(context,
                        size: SpacingSize.small)),
                decoration: BoxDecoration(
                  color: context.colorSurface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.mediumRadius),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء عرض اليوم الفارغ (بدون محاضرات)
  static Widget buildEmptyDayView(BuildContext context, String day) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: DailyScheduleConstants.animationDuration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: AppDimensions.getIconSize(context,
                      size: IconSize.large, small: false) *
                  0.9,
              color: context.colorTextHint,
            ),
            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),
            Text(
              '${DailyScheduleConstants.noLecturesMessage} $day',
              style: TextStyle(
                fontSize: AppDimensions.getSubtitleFontSize(context),
                color: context.colorTextSecondary,
                fontWeight: FontWeight.bold,
                fontFamily: DailyScheduleConstants.fontFamily,
              ),
            ),
            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),
            Text(
              DailyScheduleConstants.emptyScheduleMessage,
              style: TextStyle(
                fontSize: AppDimensions.getBodyFontSize(context, small: true),
                color: context.colorTextHint,
                fontFamily: DailyScheduleConstants.fontFamily,
              ),
            ),
            SizedBox(
                height: AppDimensions.getSpacing(context,
                    size: SpacingSize.medium)),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة المادة للعرض في قائمة المحاضرات
  static Widget buildCourseCard(BuildContext context, Course course,
      Color bgColor, Color borderColor, VoidCallback onTap) {
    return Hero(
      tag: 'course_${course.id}',
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: DailyScheduleConstants.cardAnimationDuration,
          curve: DailyScheduleConstants.animationCurve,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: context.colorShadow,
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
            child: Padding(
              padding: EdgeInsets.all(
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الصف الأول: الوقت واسم المادة
                  Row(
                    children: [
                      // أيقونة ووقت المحاضرة
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.getSpacing(context,
                              size: SpacingSize.small),
                          vertical: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorSurface,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.smallRadius),
                          border: Border.all(color: borderColor, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: borderColor.withOpacity(0.2),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: AppDimensions.getIconSize(context,
                                  size: IconSize.small, small: true),
                              color: context.colorPrimaryDark,
                            ),
                            SizedBox(
                                width: AppDimensions.getSpacing(context,
                                        size: SpacingSize.small) /
                                    2),
                            Text(
                              course.lectureTime ??
                                  DailyScheduleConstants.undefinedTime,
                              style: TextStyle(
                                fontSize:
                                    AppDimensions.getLabelFontSize(context),
                                fontWeight: FontWeight.w500,
                                color: context.colorPrimaryDark,
                                fontFamily: DailyScheduleConstants.fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                          width: AppDimensions.getSpacing(context,
                              size: SpacingSize.small)),

                      // اسم المادة
                      Expanded(
                        child: Text(
                          course.courseName,
                          style: TextStyle(
                            fontSize:
                                AppDimensions.getSubtitleFontSize(context),
                            fontWeight: FontWeight.bold,
                            color: context.colorTextPrimary,
                            fontFamily: DailyScheduleConstants.fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                      height: AppDimensions.getSpacing(context,
                          size: SpacingSize.small)),

                  // الصف الثاني: القاعة فقط
                  Row(
                    children: [
                      // معلومات القاعة
                      Icon(
                        Icons.location_on_outlined,
                        size: AppDimensions.getIconSize(context,
                            size: IconSize.small, small: true),
                        color: context.colorTextHint,
                      ),
                      SizedBox(
                          width: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2),
                      Text(
                        course.classroom != null && course.classroom!.isNotEmpty
                            ? '${DailyScheduleConstants.roomPrefix} ${course.classroom}'
                            : '${DailyScheduleConstants.roomPrefix} ${DailyScheduleConstants.undefinedRoom}',
                        style: TextStyle(
                          fontSize: AppDimensions.getBodyFontSize(context,
                              small: true),
                          color: context.colorTextSecondary,
                          fontFamily: DailyScheduleConstants.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء تابات الأيام
  static Widget buildDaysTabs(
    BuildContext context,
    List<String> days,
    TabController tabController,
    int selectedDayIndex,
    Function(int) onDayChanged,
    String todayEnglish,
    List<String> englishDays,
  ) {
    // ضبط الحجم ليكون متجاوبًا
    final tabHeight = AppDimensions.getButtonHeight(context,
        size: ButtonSize.small, small: true);
    final fontSize = AppDimensions.getLabelFontSize(context);

    // حساب عرض كل تاب بناءً على عرض الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding =
        AppDimensions.getSpacing(context, size: SpacingSize.small);
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final tabWidth = availableWidth / days.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      height: tabHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        child: Material(
          color: context.colorSurface,
          child: TabBar(
            controller: tabController,
            labelColor: context.colorSurface,
            unselectedLabelColor: context.colorPrimaryDark,
            indicator: BoxDecoration(
              color: context.colorPrimaryDark,
              borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
            ),
            splashFactory: NoSplash.splashFactory,
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                return states.contains(MaterialState.focused)
                    ? null
                    : Colors.transparent;
              },
            ),
            tabs: days.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;

              // التحقق إذا كان هذا هو اليوم الحالي
              final isToday = englishDays[index] == todayEnglish;

              return Tab(
                child: AnimatedContainer(
                  duration: DailyScheduleConstants.animationDuration,
                  width: tabWidth - 1, // ترك مساحة صغيرة للتباعد
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.getSpacing(context,
                            size: SpacingSize.small) /
                        4,
                    horizontal: AppDimensions.getSpacing(context,
                            size: SpacingSize.small) /
                        4,
                  ),
                  decoration: isToday && index != selectedDayIndex
                      ? BoxDecoration(
                          border: Border.all(color: context.colorPrimaryDark),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.smallRadius),
                        )
                      : null,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      day,
                      style: TextStyle(
                        fontFamily: DailyScheduleConstants.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            isScrollable: false, // جعل التابات ثابتة
            labelPadding: EdgeInsets.zero, // إزالة المسافات بين التابات
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
      ),
    );
  }

  /// بناء ملخص الجدول اليومي
  static Widget buildDaySummary(
    BuildContext context,
    List<String> days,
    int selectedDayIndex,
    int coursesCount,
  ) {
    // استخدام دالة قياس حجم الشاشة
    final titleSize = AppDimensions.getSubtitleFontSize(context);
    final countSize = AppDimensions.getLabelFontSize(context, small: true);
    final padding = AppDimensions.getSpacing(context, size: SpacingSize.small);

    return AnimatedContainer(
      duration: DailyScheduleConstants.animationDuration,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: context.colorSurface,
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // استخدام selectedDayIndex حتى يتغير العنوان مع تغير المحتوى
          Expanded(
            child: Text(
              '${DailyScheduleConstants.dayLecturesPrefix} ${days[selectedDayIndex]}',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
                fontFamily: DailyScheduleConstants.fontFamily,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // عدد المحاضرات في هذا اليوم
          Container(
            padding: EdgeInsets.symmetric(
              horizontal:
                  AppDimensions.getSpacing(context, size: SpacingSize.small),
              vertical:
                  AppDimensions.getSpacing(context, size: SpacingSize.small) /
                      2,
            ),
            decoration: BoxDecoration(
              color: context.colorPrimaryPale,
              borderRadius:
                  BorderRadius.circular(AppDimensions.smallRadius / 2),
              boxShadow: [
                BoxShadow(
                  color: context.colorShadow,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              '$coursesCount ${DailyScheduleConstants.lectureCountSuffix}',
              style: TextStyle(
                fontSize: countSize,
                color: context.colorPrimaryDark,
                fontWeight: FontWeight.w500,
                fontFamily: DailyScheduleConstants.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء عنصر تفاصيل المادة
  static Widget buildDetailItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: AppDimensions.getSpacing(context, size: SpacingSize.small)),
      child: Row(
        children: [
          Container(
            width: AppDimensions.getIconSize(context,
                size: IconSize.medium, small: false),
            height: AppDimensions.getIconSize(context,
                size: IconSize.medium, small: false),
            decoration: BoxDecoration(
              color: context.colorPrimaryPale,
              borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
            ),
            child: Icon(
              icon,
              color: context.colorPrimaryDark,
              size: AppDimensions.getIconSize(context,
                  size: IconSize.small, small: true),
            ),
          ),
          SizedBox(
              width:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize:
                      AppDimensions.getLabelFontSize(context, small: true),
                  color: context.colorTextSecondary,
                  fontFamily: DailyScheduleConstants.fontFamily,
                ),
              ),
              SizedBox(
                  height: AppDimensions.getSpacing(context,
                          size: SpacingSize.small) /
                      4),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppDimensions.getBodyFontSize(context),
                  fontWeight: FontWeight.w500,
                  color: context.colorTextPrimary,
                  fontFamily: DailyScheduleConstants.fontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء ورقة تفاصيل المادة
  static Widget buildCourseDetailsSheet(
    BuildContext context,
    Course course,
  ) {
    // تحديد حجم الخط حسب حجم الشاشة
    final titleFontSize =
        AppDimensions.getSubtitleFontSize(context, small: false);
    final subtitleFontSize =
        AppDimensions.getBodyFontSize(context, small: true);
    final padding = AppDimensions.getSpacing(context);

    return Hero(
      tag: 'course_${course.id}',
      child: Material(
        color: Colors.transparent,
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
                padding: EdgeInsets.all(padding),
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
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: DailyScheduleConstants.fontFamily,
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
                            size: subtitleFontSize, color: Colors.white70),
                        SizedBox(
                            width: AppDimensions.getSpacing(context,
                                    size: SpacingSize.small) /
                                2),
                        Text(
                          course.lectureTime ??
                              DailyScheduleConstants.undefinedTime,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.white70,
                            fontFamily: DailyScheduleConstants.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // تفاصيل
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    buildDetailItem(
                      context: context,
                      icon: Icons.location_on_outlined,
                      title: DailyScheduleConstants.roomTitle,
                      value: course.classroom ??
                          DailyScheduleConstants.undefinedRoom,
                    ),
                    buildDetailItem(
                      context: context,
                      icon: Icons.calendar_today_outlined,
                      title: DailyScheduleConstants.daysTitle,
                      value: course.days.join(' - '),
                    ),
                    if (course.creditHours != null)
                      buildDetailItem(
                        context: context,
                        icon: Icons.book_outlined,
                        title: DailyScheduleConstants.creditHoursTitle,
                        value:
                            '${course.creditHours} ${DailyScheduleConstants.creditHoursSuffix}',
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
}
