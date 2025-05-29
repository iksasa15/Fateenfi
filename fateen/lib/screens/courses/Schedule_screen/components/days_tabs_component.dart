import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/days_tabs_constants.dart';
import '../controllers/days_tabs_controller.dart';

class DaysTabsComponent {
  /// بناء تابات الأيام
  static Widget buildDaysTabs(BuildContext context,
      DaysTabsController controller, TabController tabController) {
    // ضبط الحجم ليكون متجاوبًا
    final tabHeight =
        DaysTabsConstants.getResponsiveSize(context, 35.0, 40.0, 45.0);
    final fontSize =
        DaysTabsConstants.getResponsiveSize(context, 12.0, 14.0, 16.0);

    // حساب عرض كل تاب بناءً على عرض الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding =
        DaysTabsConstants.getResponsiveSize(context, 12.0, 16.0, 20.0);
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final tabWidth = availableWidth / controller.allDays.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      height: tabHeight,
      child: TabBar(
        controller: tabController,
        labelColor: Colors.white,
        unselectedLabelColor:
            const Color(0xFF4338CA), // استخدام لون kDarkPurple من صفحات التسجيل
        indicator: BoxDecoration(
          color: const Color(
              0xFF4338CA), // استخدام لون kDarkPurple من صفحات التسجيل
          borderRadius: BorderRadius.circular(12),
        ),
        tabs: controller.allDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;

          // التحقق إذا كان هذا هو اليوم الحالي
          final isToday = controller.englishDays[index] ==
              DateFormat('EEEE').format(DateTime.now());

          return Tab(
            child: Container(
              width: tabWidth - 1, // ترك مساحة صغيرة للتباعد
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              decoration: isToday && index != controller.selectedDayIndex
                  ? BoxDecoration(
                      border: Border.all(
                          color: const Color(
                              0xFF4338CA)), // استخدام لون kDarkPurple من صفحات التسجيل
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  day,
                  style: const TextStyle(
                    fontFamily: 'SYMBIOAR+LT',
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
    );
  }

  /// بناء ملخص الجدول اليومي - يعرض فوق قائمة المحاضرات
  static Widget buildDaySummary(
      BuildContext context, DaysTabsController controller) {
    // استخدام دالة قياس حجم الشاشة
    final titleSize = DaysTabsConstants.getResponsiveSize(
      context,
      14.0, // للشاشات الصغيرة
      16.0, // للشاشات المتوسطة
      18.0, // للشاشات الكبيرة
    );

    final countSize = DaysTabsConstants.getResponsiveSize(
      context,
      10.0, // للشاشات الصغيرة
      12.0, // للشاشات المتوسطة
      14.0, // للشاشات الكبيرة
    );

    final padding = DaysTabsConstants.getResponsiveSize(
      context,
      12.0, // للشاشات الصغيرة
      15.0, // للشاشات المتوسطة
      20.0, // للشاشات الكبيرة
    );

    return Container(
      padding: EdgeInsets.all(padding),
      color:
          Colors.white, // خلفية بيضاء لضمان التمييز عن المحتوى الذي يأتي بعده
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
                color: const Color(
                    0xFF4338CA), // استخدام لون kDarkPurple من صفحات التسجيل
                fontFamily: 'SYMBIOAR+LT',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // عدد المحاضرات في هذا اليوم
          Container(
            padding: EdgeInsets.symmetric(
              horizontal:
                  DaysTabsConstants.getResponsiveSize(context, 8.0, 10.0, 12.0),
              vertical:
                  DaysTabsConstants.getResponsiveSize(context, 4.0, 5.0, 6.0),
            ),
            decoration: BoxDecoration(
              color: const Color(
                  0xFFF5F3FF), // استخدام لون kLightPurple من صفحات التسجيل
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '${controller.getCoursesCountForDay(controller.allDays[controller.selectedDayIndex])} ${DaysTabsConstants.lectureCountSuffix}',
              style: TextStyle(
                fontSize: countSize,
                color: const Color(
                    0xFF4338CA), // استخدام لون kDarkPurple من صفحات التسجيل
                fontWeight: FontWeight.w500,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
