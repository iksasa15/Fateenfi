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
              color: ScheduleHeaderConstants.kTextColor,
              fontFamily: ScheduleHeaderConstants.fontFamily,
            ),
          ),

          // زر تبديل نوع العرض (يومي/أسبوعي) فقط
          _buildActionButton(
            context: context,
            icon: controller.showCalendarView
                ? Icons.view_list_rounded
                : Icons.calendar_view_week_rounded,
            tooltip: controller.showCalendarView
                ? ScheduleHeaderConstants.listViewTooltip
                : ScheduleHeaderConstants.calendarViewTooltip,
            onPressed: () => controller.toggleViewMode(),
            size: buttonSize,
            iconSize: iconSize,
            color: ScheduleHeaderConstants.kDarkPurple,
            margin: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  /// بناء زر إجراء موحد
  static Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required double size,
    required double iconSize,
    required Color color,
    required EdgeInsets margin,
  }) {
    return Container(
      margin: margin,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(ScheduleHeaderConstants.buttonBorderRadius),
        border: Border.all(color: ScheduleHeaderConstants.kBorderColor),
        boxShadow: [
          BoxShadow(
            color: ScheduleHeaderConstants.kShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(ScheduleHeaderConstants.buttonBorderRadius),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(ScheduleHeaderConstants.buttonBorderRadius),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: iconSize,
              ),
            ),
          ),
        ),
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
          color: ScheduleHeaderConstants.kDarkPurple,
          fontFamily: ScheduleHeaderConstants.fontFamily,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
