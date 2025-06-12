import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../../models/course.dart';
import '../constants/schedule_calendar_constants.dart';

class ScheduleCalendarComponents {
  /// بناء واجهة Shimmer للتحميل
  static Widget buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: _buildCalendarViewShimmer(),
    );
  }

  /// Shimmer لعرض الجدول
  static Widget _buildCalendarViewShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان وهمي
          Container(
            width: 180,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.only(bottom: 20, top: 10),
          ),

          // جدول وهمي
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                  ScheduleCalendarConstants.cardBorderRadius),
              boxShadow: ScheduleCalendarConstants.getUnifiedShadow(),
            ),
            child: Column(
              children: [
                // صف العناوين
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(
                          ScheduleCalendarConstants.cardBorderRadius),
                      topRight: Radius.circular(
                          ScheduleCalendarConstants.cardBorderRadius),
                    ),
                  ),
                ),

                // صفوف الجدول
                ...List.generate(
                  6, // 6 صفوف وهمية
                  (index) => Container(
                    height: ScheduleCalendarConstants.rowHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!),
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
  static Widget buildEmptyCoursesView() {
    return Center(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: ScheduleCalendarConstants.animationDuration,
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
              ScheduleCalendarConstants.noCoursesMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontFamily: ScheduleCalendarConstants.fontFamily,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                ScheduleCalendarConstants.addCoursesHint,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
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
  static Widget buildCourseBubble(
      Course course, Color bgColor, Color borderColor, VoidCallback onTap) {
    return AnimatedContainer(
      duration: ScheduleCalendarConstants.animationDuration,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(ScheduleCalendarConstants.itemBorderRadius),
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
          borderRadius:
              BorderRadius.circular(ScheduleCalendarConstants.itemBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // اسم المادة بالكامل
                Text(
                  course.courseName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ScheduleCalendarConstants.kDarkPurple,
                    height: 1.2,
                    fontFamily: ScheduleCalendarConstants.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // السماح بسطرين لعرض الاسم
                ),
                if (course.classroom != null && course.classroom!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      course.classroom!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
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
              color: ScheduleCalendarConstants.kLightPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: ScheduleCalendarConstants.kDarkPurple,
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
                  fontFamily: ScheduleCalendarConstants.fontFamily,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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
  static Widget buildHeaderRow(List<String> days, List<String> englishDays) {
    return Container(
      decoration: BoxDecoration(
        color: ScheduleCalendarConstants.kDarkPurple,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ScheduleCalendarConstants.cardBorderRadius),
          topRight: Radius.circular(ScheduleCalendarConstants.cardBorderRadius),
        ),
      ),
      child: Row(
        children: [
          // عنوان الوقت/اليوم
          buildHeaderCell(
              ScheduleCalendarConstants.timeHeaderLabel, true, true),

          // عناوين الأيام
          ...days.map((day) => Expanded(
                child: buildHeaderCell(
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
  static Widget buildHeaderCell(
      String text, bool isFirstColumn, bool isCurrentDay) {
    return Container(
      width: isFirstColumn ? ScheduleCalendarConstants.timeColumnWidth : null,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: isCurrentDay && !isFirstColumn
            ? ScheduleCalendarConstants.kMediumPurple
            : null,
        border: Border(
          right: isFirstColumn
              ? const BorderSide(color: Colors.white38)
              : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: ScheduleCalendarConstants.fontFamily,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// بناء خلية الوقت
  static Widget buildTimeCell(String timeSlot, bool isCurrentTime) {
    return Container(
      width: ScheduleCalendarConstants.timeColumnWidth,
      height: ScheduleCalendarConstants.rowHeight,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFEFEFEF)),
        ),
      ),
      child: Center(
        child: Text(
          timeSlot,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCurrentTime ? FontWeight.bold : FontWeight.normal,
            color: isCurrentTime
                ? ScheduleCalendarConstants.kDarkPurple
                : Colors.grey.shade600,
            fontFamily: ScheduleCalendarConstants.fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// بناء خلية اليوم
  static Widget buildDayCell(Course? course, bool highlight, Color? bgColor,
      Color? borderColor, VoidCallback? onTap) {
    return Container(
      height: ScheduleCalendarConstants.rowHeight,
      decoration: BoxDecoration(
        border: Border(
          right: const BorderSide(color: Color(0xFFEFEFEF)),
          left: highlight
              ? BorderSide(
                  color: ScheduleCalendarConstants.kDarkPurple, width: 2)
              : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: course != null &&
              onTap != null &&
              bgColor != null &&
              borderColor != null
          ? buildCourseBubble(course, bgColor, borderColor, onTap)
          : null,
    );
  }
}
