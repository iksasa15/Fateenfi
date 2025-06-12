import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/daily_schedule_constants.dart';
import '../../../../models/course.dart';

class DailyScheduleComponents {
  /// بناء واجهة Shimmer للتحميل
  static Widget buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: _buildListViewShimmer(),
    );
  }

  /// Shimmer لعرض القائمة
  static Widget _buildListViewShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان وهمي للقائمة
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 130,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                width: 80,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ],
          ),
        ),

        // بطاقات وهمية
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: List.generate(
              4, // 4 بطاقات وهمية
              (index) => Container(
                width: double.infinity,
                height: 100,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      DailyScheduleConstants.cardBorderRadius),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء عرض اليوم الفارغ (بدون محاضرات)
  static Widget buildEmptyDayView(String day) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: DailyScheduleConstants.animationDuration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 15),
            Text(
              '${DailyScheduleConstants.noLecturesMessage} $day',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontFamily: DailyScheduleConstants.fontFamily,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              DailyScheduleConstants.emptyScheduleMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontFamily: DailyScheduleConstants.fontFamily,
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة المادة للعرض في قائمة المحاضرات
  static Widget buildCourseCard(
      Course course, Color bgColor, Color borderColor, VoidCallback onTap) {
    return Hero(
      tag: 'course_${course.id}',
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: DailyScheduleConstants.cardAnimationDuration,
          curve: DailyScheduleConstants.animationCurve,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius:
                BorderRadius.circular(DailyScheduleConstants.cardBorderRadius),
            border: Border.all(color: borderColor),
            boxShadow: DailyScheduleConstants.getUnifiedShadow(),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius:
                BorderRadius.circular(DailyScheduleConstants.cardBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الصف الأول: الوقت واسم المادة
                  Row(
                    children: [
                      // أيقونة ووقت المحاضرة
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
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
                              size: 14,
                              color: DailyScheduleConstants.kDarkPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              course.lectureTime ??
                                  DailyScheduleConstants.undefinedTime,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: DailyScheduleConstants.kDarkPurple,
                                fontFamily: DailyScheduleConstants.fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // اسم المادة
                      Expanded(
                        child: Text(
                          course.courseName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: DailyScheduleConstants.kTextColor,
                            fontFamily: DailyScheduleConstants.fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // الصف الثاني: القاعة فقط
                  Row(
                    children: [
                      // معلومات القاعة
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course.classroom != null && course.classroom!.isNotEmpty
                            ? '${DailyScheduleConstants.roomPrefix} ${course.classroom}'
                            : '${DailyScheduleConstants.roomPrefix} ${DailyScheduleConstants.undefinedRoom}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
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
    final tabHeight =
        DailyScheduleConstants.getResponsiveSize(context, 35.0, 40.0, 45.0);
    final fontSize =
        DailyScheduleConstants.getResponsiveSize(context, 12.0, 14.0, 16.0);

    // حساب عرض كل تاب بناءً على عرض الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding =
        DailyScheduleConstants.getResponsiveSize(context, 12.0, 16.0, 20.0);
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final tabWidth = availableWidth / days.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      height: tabHeight,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(DailyScheduleConstants.tabBorderRadius),
        boxShadow: [
          BoxShadow(
            color: DailyScheduleConstants.kShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(DailyScheduleConstants.tabBorderRadius),
        child: Material(
          color: Colors.white,
          child: TabBar(
            controller: tabController,
            labelColor: Colors.white,
            unselectedLabelColor: DailyScheduleConstants.kDarkPurple,
            indicator: BoxDecoration(
              color: DailyScheduleConstants.kDarkPurple,
              borderRadius:
                  BorderRadius.circular(DailyScheduleConstants.tabBorderRadius),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  decoration: isToday && index != selectedDayIndex
                      ? BoxDecoration(
                          border: Border.all(
                              color: DailyScheduleConstants.kDarkPurple),
                          borderRadius: BorderRadius.circular(
                              DailyScheduleConstants.tabBorderRadius),
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
    final titleSize = DailyScheduleConstants.getResponsiveSize(
      context,
      14.0, // للشاشات الصغيرة
      16.0, // للشاشات المتوسطة
      18.0, // للشاشات الكبيرة
    );

    final countSize = DailyScheduleConstants.getResponsiveSize(
      context,
      10.0, // للشاشات الصغيرة
      12.0, // للشاشات المتوسطة
      14.0, // للشاشات الكبيرة
    );

    final padding = DailyScheduleConstants.getResponsiveSize(
      context,
      12.0, // للشاشات الصغيرة
      15.0, // للشاشات المتوسطة
      20.0, // للشاشات الكبيرة
    );

    return AnimatedContainer(
      duration: DailyScheduleConstants.animationDuration,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: DailyScheduleConstants.kShadowColor,
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
                color: DailyScheduleConstants.kDarkPurple,
                fontFamily: DailyScheduleConstants.fontFamily,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // عدد المحاضرات في هذا اليوم
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DailyScheduleConstants.getResponsiveSize(
                  context, 8.0, 10.0, 12.0),
              vertical: DailyScheduleConstants.getResponsiveSize(
                  context, 4.0, 5.0, 6.0),
            ),
            decoration: BoxDecoration(
              color: DailyScheduleConstants.kLightPurple,
              borderRadius: BorderRadius.circular(
                  DailyScheduleConstants.badgeBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: DailyScheduleConstants.kShadowColor,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              '$coursesCount ${DailyScheduleConstants.lectureCountSuffix}',
              style: TextStyle(
                fontSize: countSize,
                color: DailyScheduleConstants.kDarkPurple,
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
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DailyScheduleConstants.kLightPurple,
              borderRadius: BorderRadius.circular(
                  DailyScheduleConstants.detailIconBorderRadius),
            ),
            child: Icon(
              icon,
              color: DailyScheduleConstants.kDarkPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: DailyScheduleConstants.fontFamily,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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
        DailyScheduleConstants.getResponsiveSize(context, 16.0, 18.0, 20.0);
    final subtitleFontSize =
        DailyScheduleConstants.getResponsiveSize(context, 12.0, 14.0, 16.0);
    final padding =
        DailyScheduleConstants.getResponsiveSize(context, 15.0, 20.0, 25.0);

    return Hero(
      tag: 'course_${course.id}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(DailyScheduleConstants.getResponsiveSize(
              context, 8.0, 10.0, 12.0)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(DailyScheduleConstants.cardBorderRadius),
            boxShadow: DailyScheduleConstants.getUnifiedShadow(),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // هيدر
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: DailyScheduleConstants.kDarkPurple,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(
                        DailyScheduleConstants.cardBorderRadius),
                    topRight: Radius.circular(
                        DailyScheduleConstants.cardBorderRadius),
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
                        height: DailyScheduleConstants.getResponsiveSize(
                            context, 3.0, 5.0, 7.0)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time,
                            size: subtitleFontSize, color: Colors.white70),
                        SizedBox(
                            width: DailyScheduleConstants.getResponsiveSize(
                                context, 4.0, 6.0, 8.0)),
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
                      icon: Icons.location_on_outlined,
                      title: DailyScheduleConstants.roomTitle,
                      value: course.classroom ??
                          DailyScheduleConstants.undefinedRoom,
                    ),
                    buildDetailItem(
                      icon: Icons.calendar_today_outlined,
                      title: DailyScheduleConstants.daysTitle,
                      value: course.days.join(' - '),
                    ),
                    if (course.creditHours != null)
                      buildDetailItem(
                        icon: Icons.book_outlined,
                        title: DailyScheduleConstants.creditHoursTitle,
                        value:
                            '${course.creditHours} ${DailyScheduleConstants.creditHoursSuffix}',
                      ),
                  ],
                ),
              ),
              SizedBox(
                  height: DailyScheduleConstants.getResponsiveSize(
                      context, 10.0, 15.0, 20.0)),
            ],
          ),
        ),
      ),
    );
  }
}
