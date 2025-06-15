import 'package:flutter/material.dart';
import '../constants/schedule_header_constants.dart';
import '../controllers/schedule_view_controller.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

/// مكونات الهيدر الخاص بالجدول الدراسي
class ScheduleHeaderComponent {
  /// بناء هيدر الجدول الدراسي
  static Widget buildHeader(BuildContext context,
      ScheduleViewController controller, VoidCallback? onRefresh) {
    final titleSize = AppDimensions.getTitleFontSize(context, small: true);
    final iconSize =
        AppDimensions.getIconSize(context, size: IconSize.small, small: false);
    final buttonSize = AppDimensions.getButtonHeight(context,
        size: ButtonSize.small, small: true);
    final padding = AppDimensions.getSpacing(context);

    return Container(
      padding: EdgeInsets.all(padding),
      color: context.colorSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // عنوان صفحة الجدول الدراسي
          Text(
            ScheduleHeaderConstants.screenTitle,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: context.colorTextPrimary,
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
            color: context.colorPrimaryDark,
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
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        border: Border.all(color: context.colorBorder),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
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
    final fontSize = AppDimensions.getSubtitleFontSize(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppDimensions.getSpacing(context),
      ),
      child: Text(
        ScheduleHeaderConstants.weeklyScheduleTitle,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: context.colorPrimaryDark,
          fontFamily: ScheduleHeaderConstants.fontFamily,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
