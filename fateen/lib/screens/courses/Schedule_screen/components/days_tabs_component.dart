import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/days_tabs_constants.dart';
import '../controllers/days_tabs_controller.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class DaysTabsComponent {
  /// بناء تابات الأيام
  static Widget buildDaysTabs(BuildContext context,
      DaysTabsController controller, TabController tabController) {
    // ضبط الحجم ليكون متجاوبًا
    final tabHeight = AppDimensions.getButtonHeight(context,
        size: ButtonSize.small, small: true);
    final fontSize = AppDimensions.getLabelFontSize(context);

    // حساب عرض كل تاب بناءً على عرض الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding =
        AppDimensions.getSpacing(context, size: SpacingSize.small);
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final tabWidth = availableWidth / controller.allDays.length;

    return AnimatedContainer(
      duration: DaysTabsConstants.tabAnimationDuration,
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
      child: Material(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        child: TabBar(
          controller: tabController,
          labelColor: context.colorSurface,
          unselectedLabelColor: context.colorPrimaryDark,
          indicator: BoxDecoration(
            color: context.colorPrimaryDark,
            borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
          ),
          tabs: controller.allDays.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;

            // التحقق إذا كان هذا هو اليوم الحالي
            final isToday = controller.englishDays[index] ==
                DateFormat('EEEE').format(DateTime.now());

            return Tab(
              child: AnimatedContainer(
                duration: DaysTabsConstants.tabAnimationDuration,
                width: tabWidth - 1, // ترك مساحة صغيرة للتباعد
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.getSpacing(context,
                            size: SpacingSize.small) /
                        4,
                    horizontal: AppDimensions.getSpacing(context,
                            size: SpacingSize.small) /
                        4),
                decoration: isToday && index != controller.selectedDayIndex
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
                      fontFamily: DaysTabsConstants.fontFamily,
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
    );
  }

  /// بناء ملخص الجدول اليومي - يعرض فوق قائمة المحاضرات
  static Widget buildDaySummary(
      BuildContext context, DaysTabsController controller) {
    // استخدام دالة قياس حجم الشاشة
    final titleSize = AppDimensions.getSubtitleFontSize(context);
    final countSize = AppDimensions.getLabelFontSize(context, small: true);
    final padding = AppDimensions.getSpacing(context, size: SpacingSize.small);

    return AnimatedContainer(
      duration: DaysTabsConstants.animationDuration,
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
              '${DaysTabsConstants.dayLecturesPrefix} ${controller.allDays[controller.selectedDayIndex]}',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
                fontFamily: DaysTabsConstants.fontFamily,
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
              borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
              boxShadow: [
                BoxShadow(
                  color: context.colorShadow,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              '${controller.getCoursesCountForDay(controller.allDays[controller.selectedDayIndex])} ${DaysTabsConstants.lectureCountSuffix}',
              style: TextStyle(
                fontSize: countSize,
                color: context.colorPrimaryDark,
                fontWeight: FontWeight.w500,
                fontFamily: DaysTabsConstants.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
