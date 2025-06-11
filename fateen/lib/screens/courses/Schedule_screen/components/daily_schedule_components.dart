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
        // بطاقات وهمية
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: List.generate(
              4, // 4 بطاقات وهمية
              (index) => Container(
                width: double.infinity,
                height: 100,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 70,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            '${DailyScheduleConstants.noLecturesMessage} $day',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنك إضافة محاضرات جديدة من صفحة المقررات',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// بناء بطاقة المادة للعرض في قائمة المحاضرات
  static Widget buildCourseCard(BuildContext context, Course course,
      Color bgColor, Color borderColor, VoidCallback onTap) {
    // استخدام MediaQuery للتجاوب
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    final double titleSize =
        isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 17.0);
    final double subtitleSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final double iconSize =
        isSmallScreen ? 14.0 : (isMediumScreen ? 16.0 : 18.0);
    final double padding =
        isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // خلفية زخرفية
              Positioned(
                right: -30,
                top: -20,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصف الأول: الوقت واسم المادة
                    Row(
                      children: [
                        // أيقونة ووقت المحاضرة
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: padding * 0.7,
                            vertical: padding * 0.4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: borderColor.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: iconSize,
                                color: const Color(0xFF4338CA),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                course.lectureTime ??
                                    DailyScheduleConstants.undefinedTime,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4338CA),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // اسم المادة
                        Expanded(
                          child: Text(
                            course.courseName,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF374151),
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: padding * 0.8),

                    // الصف الثاني: القاعة والساعات المعتمدة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // معلومات القاعة
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: iconSize,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              course.classroom != null &&
                                      course.classroom!.isNotEmpty
                                  ? '${DailyScheduleConstants.roomPrefix} ${course.classroom}'
                                  : '${DailyScheduleConstants.roomPrefix} ${DailyScheduleConstants.undefinedRoom}',
                              style: TextStyle(
                                fontSize: subtitleSize,
                                color: Colors.grey.shade700,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ],
                        ),

                        // عرض الساعات المعتمدة إذا كانت متوفرة
                        if (course.creditHours != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: padding * 0.5,
                              vertical: padding * 0.2,
                            ),
                            decoration: BoxDecoration(
                              color: borderColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${course.creditHours} ساعات',
                              style: TextStyle(
                                fontSize: subtitleSize - 1,
                                color: borderColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
    // استخدام MediaQuery للتجاوب
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    final double tabHeight =
        isSmallScreen ? 36.0 : (isMediumScreen ? 40.0 : 44.0);
    final double fontSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final double horizontalPadding = screenSize.width * 0.04;

    // حساب عرض كل تاب بناءً على عرض الشاشة
    final availableWidth = screenSize.width - (horizontalPadding * 2);
    final tabWidth = availableWidth / days.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      height: tabHeight,
      child: TabBar(
        controller: tabController,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF4338CA),
        indicator: BoxDecoration(
          color: const Color(0xFF4338CA),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4338CA).withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        tabs: days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;

          // التحقق إذا كان هذا هو اليوم الحالي
          final isToday = englishDays[index] == todayEnglish;

          return Tab(
            child: Container(
              width: tabWidth - 1,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              decoration: isToday && index != selectedDayIndex
                  ? BoxDecoration(
                      border: Border.all(color: const Color(0xFF4338CA)),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  day,
                  style: TextStyle(
                    fontFamily: 'SYMBIOAR+LT',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        isScrollable: false,
        labelPadding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.tab,
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
    // استخدام MediaQuery للتجاوب
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    final double titleSize =
        isSmallScreen ? 14.0 : (isMediumScreen ? 16.0 : 18.0);
    final double countSize =
        isSmallScreen ? 10.0 : (isMediumScreen ? 12.0 : 14.0);
    final double padding =
        isSmallScreen ? 10.0 : (isMediumScreen ? 12.0 : 15.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${DailyScheduleConstants.dayLecturesPrefix} ${days[selectedDayIndex]}',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4338CA),
                fontFamily: 'SYMBIOAR+LT',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0),
              vertical: isSmallScreen ? 4.0 : (isMediumScreen ? 5.0 : 6.0),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$coursesCount ${DailyScheduleConstants.lectureCountSuffix}',
              style: TextStyle(
                fontSize: countSize,
                color: const Color(0xFF4338CA),
                fontWeight: FontWeight.w600,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
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
    // استخدام MediaQuery للتجاوب
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    final double titleSize =
        isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : 20.0);
    final double subtitleSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final double padding =
        isSmallScreen ? 15.0 : (isMediumScreen ? 20.0 : 25.0);

    return Hero(
      tag: 'course_${course.id}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(screenSize.width * 0.025),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0, 5),
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
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: subtitleSize, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          course.lectureTime ??
                              DailyScheduleConstants.undefinedTime,
                          style: TextStyle(
                            fontSize: subtitleSize - 2,
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
              SizedBox(height: screenSize.height * 0.02),
            ],
          ),
        ),
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
    // استخدام MediaQuery للتجاوب
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    final double titleSize =
        isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0);
    final double valueSize =
        isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
    final double iconSize =
        isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 22.0);
    final double containerSize =
        isSmallScreen ? 36.0 : (isMediumScreen ? 40.0 : 44.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4338CA),
              size: iconSize,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.grey.shade600,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
