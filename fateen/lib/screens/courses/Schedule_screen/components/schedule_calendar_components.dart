import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../../models/course.dart';
import '../constants/schedule_calendar_constants.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class ScheduleCalendarComponents {
  /// بناء واجهة Shimmer للتحميل
  static Widget buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorShimmerBase,
      highlightColor: context.colorShimmerHighlight,
      child: _buildCalendarViewShimmer(context),
    );
  }

  /// Shimmer لعرض الجدول
  static Widget _buildCalendarViewShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان وهمي
          Container(
            width: 180,
            height: 25,
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
            ),
            margin: EdgeInsets.only(
                bottom: AppDimensions.getSpacing(context),
                top:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),
          ),

          // جدول وهمي
          Container(
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
              children: [
                // صف العناوين
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.mediumRadius),
                      topRight: Radius.circular(AppDimensions.mediumRadius),
                    ),
                  ),
                ),

                // صفوف الجدول
                ...List.generate(
                  6, // 6 صفوف وهمية
                  (index) => Container(
                    height: ScheduleCalendarConstants.rowHeight,
                    decoration: BoxDecoration(
                      color: context.colorSurface,
                      border: Border(
                        top: BorderSide(color: context.colorDivider),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء عرض المقررات الفارغة (لا توجد محاضرات مضافة)
  static Widget buildEmptyCoursesView(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: ScheduleCalendarConstants.animationDuration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: AppDimensions.getIconSize(context,
                  size: IconSize.large, small: true),
              color: context.colorTextHint,
            ),
            SizedBox(height: AppDimensions.getSpacing(context)),
            Text(
              ScheduleCalendarConstants.noCoursesMessage,
              style: TextStyle(
                fontSize: AppDimensions.getSubtitleFontSize(context),
                color: context.colorTextSecondary,
                fontWeight: FontWeight.bold,
                fontFamily: ScheduleCalendarConstants.fontFamily,
              ),
            ),
            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.getSpacing(context,
                      size: SpacingSize.large)),
              child: Text(
                ScheduleCalendarConstants.addCoursesHint,
                style: TextStyle(
                  fontSize: AppDimensions.getLabelFontSize(context),
                  color: context.colorTextHint,
                  fontFamily: ScheduleCalendarConstants.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء فقاعة المحاضرة في الجدول
  static Widget buildCourseBubble(BuildContext context, Course course,
      Color bgColor, Color borderColor, VoidCallback onTap) {
    return AnimatedContainer(
      duration: ScheduleCalendarConstants.animationDuration,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
          child: Padding(
            padding: EdgeInsets.all(
                AppDimensions.getSpacing(context, size: SpacingSize.small) / 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // اسم المادة بالكامل - زيادة حجم الخط
                Text(
                  course.courseName,
                  style: TextStyle(
                    // زيادة حجم الخط لاسم المادة
                    fontSize: 13.0, // حجم ثابت بدلاً من القيمة الديناميكية
                    fontWeight: FontWeight.bold,
                    color: context.colorPrimaryDark,
                    height: 1.2,
                    fontFamily: ScheduleCalendarConstants.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // السماح بسطرين لعرض الاسم
                ),
                if (course.classroom != null && course.classroom!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                        top: AppDimensions.getSpacing(context,
                                size: SpacingSize.small) /
                            2),
                    child: Text(
                      course.classroom!,
                      style: TextStyle(
                        // زيادة حجم الخط للقاعة
                        fontSize: 11.0, // حجم ثابت أكبر
                        color: context.colorTextSecondary,
                        fontFamily: ScheduleCalendarConstants.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
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
                  fontFamily: ScheduleCalendarConstants.fontFamily,
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
                  fontFamily: ScheduleCalendarConstants.fontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء صف عناوين الجدول
  static Widget buildHeaderRow(
      BuildContext context, List<String> days, List<String> englishDays) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorPrimaryDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.mediumRadius),
          topRight: Radius.circular(AppDimensions.mediumRadius),
        ),
      ),
      child: Row(
        children: [
          // عنوان الوقت/اليوم
          buildHeaderCell(
              context, ScheduleCalendarConstants.timeHeaderLabel, true, true),

          // عناوين الأيام
          ...days.map((day) => Expanded(
                child: buildHeaderCell(
                    context,
                    day,
                    false,
                    englishDays[days.indexOf(day)] ==
                        DateFormat('EEEE').format(DateTime.now())),
              )),
        ],
      ),
    );
  }

  /// بناء خلية عنوان الجدول
  static Widget buildHeaderCell(BuildContext context, String text,
      bool isFirstColumn, bool isCurrentDay) {
    return Container(
      width: isFirstColumn ? ScheduleCalendarConstants.timeColumnWidth : null,
      padding: EdgeInsets.symmetric(
          vertical: AppDimensions.getSpacing(context, size: SpacingSize.small),
          horizontal:
              AppDimensions.getSpacing(context, size: SpacingSize.small) / 2),
      decoration: BoxDecoration(
        color:
            isCurrentDay && !isFirstColumn ? context.colorPrimaryLight : null,
        border: Border(
          right: isFirstColumn
              ? BorderSide(color: Colors.white38)
              : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          // زيادة حجم خط العناوين
          fontSize: 14.0, // قيمة ثابتة أكبر
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: ScheduleCalendarConstants.fontFamily,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// بناء خلية الوقت
  static Widget buildTimeCell(
      BuildContext context, String timeSlot, bool isCurrentTime) {
    return Container(
      width: ScheduleCalendarConstants.timeColumnWidth,
      height: ScheduleCalendarConstants.rowHeight,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: context.colorDivider),
        ),
      ),
      child: Center(
        child: Text(
          timeSlot,
          style: TextStyle(
            // زيادة حجم خط الوقت
            fontSize: 13.0, // قيمة ثابتة أكبر
            fontWeight: isCurrentTime ? FontWeight.bold : FontWeight.normal,
            color: isCurrentTime
                ? context.colorPrimaryDark
                : context.colorTextSecondary,
            fontFamily: ScheduleCalendarConstants.fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// بناء خلية اليوم
  static Widget buildDayCell(BuildContext context, Course? course,
      bool highlight, Color? bgColor, Color? borderColor, VoidCallback? onTap) {
    return Container(
      height: ScheduleCalendarConstants.rowHeight,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: context.colorDivider),
          left: highlight
              ? BorderSide(color: context.colorPrimaryDark, width: 2)
              : BorderSide.none,
        ),
      ),
      padding: EdgeInsets.all(
          AppDimensions.getSpacing(context, size: SpacingSize.small) / 2),
      child: course != null &&
              onTap != null &&
              bgColor != null &&
              borderColor != null
          ? buildCourseBubble(context, course, bgColor, borderColor, onTap)
          : null,
    );
  }
}
