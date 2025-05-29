import 'package:flutter/material.dart';
import '../constants/schedule_header_constants.dart';
import '../controllers/schedule_view_controller.dart';

/// مكونات الهيدر الخاص بالجدول الدراسي
class ScheduleHeaderComponent {
  /// بناء هيدر الجدول الدراسي
  static Widget buildHeader(BuildContext context,
      ScheduleViewController controller, VoidCallback? onRefresh) {
    // استخدام دالة قياس حجم الشاشة
    final titleSize = ScheduleHeaderConstants.getResponsiveSize(
      context,
      22.0, // للشاشات الصغيرة
      26.0, // للشاشات المتوسطة
      30.0, // للشاشات الكبيرة
    );

    final iconSize = ScheduleHeaderConstants.getResponsiveSize(
      context,
      18.0, // للشاشات الصغيرة
      22.0, // للشاشات المتوسطة
      26.0, // للشاشات الكبيرة
    );

    final buttonSize = ScheduleHeaderConstants.getResponsiveSize(
      context,
      40.0, // للشاشات الصغيرة
      45.0, // للشاشات المتوسطة
      50.0, // للشاشات الكبيرة
    );

    final padding = ScheduleHeaderConstants.getResponsiveSize(
      context,
      15.0, // للشاشات الصغيرة
      20.0, // للشاشات المتوسطة
      25.0, // للشاشات الكبيرة
    );

    return Container(
      padding: EdgeInsets.all(padding),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // عنوان صفحة الجدول الدراسي
          Text(
            ScheduleHeaderConstants.screenTitle,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF374151),
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),

          // زر تبديل نوع العرض (يومي/أسبوعي)
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              onPressed: () => controller.toggleViewMode(),
              icon: Icon(
                controller.showCalendarView
                    ? Icons.view_list_outlined
                    : Icons.calendar_view_week_outlined,
                color: const Color(0xFF4338CA),
                size: iconSize,
              ),
              tooltip: controller.showCalendarView
                  ? ScheduleHeaderConstants.listViewTooltip
                  : ScheduleHeaderConstants.calendarViewTooltip,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء عنوان عرض الجدول الأسبوعي
  static Widget buildWeeklyScheduleTitle(BuildContext context) {
    final fontSize = ScheduleHeaderConstants.getResponsiveSize(
      context,
      16.0, // للشاشات الصغيرة
      18.0, // للشاشات المتوسطة
      20.0, // للشاشات الكبيرة
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: ScheduleHeaderConstants.getResponsiveSize(
            context, 15.0, 20.0, 25.0),
      ),
      child: Text(
        ScheduleHeaderConstants.weeklyScheduleTitle,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4338CA),
          fontFamily: 'SYMBIOAR+LT',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
