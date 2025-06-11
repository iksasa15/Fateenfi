import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/days_tabs_constants.dart';
import '../controllers/days_tabs_controller.dart';

class DaysTabsComponent {
  /// بناء تابات الأيام
  static Widget buildDaysTabs(BuildContext context,
      DaysTabsController controller, TabController tabController) {
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
    final tabWidth = availableWidth / controller.allDays.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      height: tabHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
        tabs: controller.allDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;

          // التحقق إذا كان هذا هو اليوم الحالي
          final isToday = controller.englishDays[index] ==
              DateFormat('EEEE').format(DateTime.now());

          return Tab(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: tabWidth - 1,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              decoration: isToday && index != controller.selectedDayIndex
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

  /// بناء ملخص الجدول اليومي - يعرض فوق قائمة المحاضرات
  static Widget buildDaySummary(
      BuildContext context, DaysTabsController controller) {
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
        isSmallScreen ? 12.0 : (isMediumScreen ? 15.0 : 20.0);

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
          // استخدام selectedDayIndex حتى يتغير العنوان مع تغير المحتوى
          Expanded(
            child: Text(
              '${DaysTabsConstants.dayLecturesPrefix} ${controller.allDays[controller.selectedDayIndex]}',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4338CA),
                fontFamily: 'SYMBIOAR+LT',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // عدد المحاضرات في هذا اليوم
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
              '${controller.getCoursesCountForDay(controller.allDays[controller.selectedDayIndex])} ${DaysTabsConstants.lectureCountSuffix}',
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
}
