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
            alignment: Alignment.center,
          ),

          // جدول وهمي
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // صف العناوين
                Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4338CA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),

                // صفوف الجدول
                ...List.generate(
                  6, // 6 صفوف وهمية
                  (index) => Container(
                    height: 80,
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
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ScheduleCalendarConstants.addCoursesHint,
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

  /// بناء فقاعة المحاضرة في الجدول
  static Widget buildCourseBubble(BuildContext context, Course course,
      Color bgColor, Color borderColor, VoidCallback onTap) {
    // استخدام MediaQuery للتجاوب
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    final double fontSize =
        isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0);
    final double subtitleSize =
        isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0);

    return Hero(
      tag: 'course_${course.id}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // اسم المادة بالكامل
                  Text(
                    course.courseName,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4338CA),
                      height: 1.2,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  if (course.classroom != null && course.classroom!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        course.classroom!,
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: Colors.grey.shade700,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء صف عناوين الجدول
  static Widget buildHeaderRow(List<String> days, List<String> englishDays) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF4338CA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // عنوان الوقت/اليوم
          buildHeaderCell('الوقت/\nاليوم', true, true),

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
      width: isFirstColumn ? 60 : null,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: isCurrentDay && !isFirstColumn ? const Color(0xFF3620c0) : null,
        border: Border(
          right: isFirstColumn
              ? const BorderSide(color: Colors.white38)
              : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'SYMBIOAR+LT',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// بناء خلية الوقت
  static Widget buildTimeCell(String timeSlot, bool isCurrentTime) {
    return Container(
      width: 60,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isCurrentTime ? const Color(0xFFF5F3FF).withOpacity(0.5) : null,
        border: const Border(
          right: BorderSide(color: Color(0xFFEFEFEF)),
        ),
      ),
      child: Center(
        child: Text(
          timeSlot,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCurrentTime ? FontWeight.bold : FontWeight.normal,
            color:
                isCurrentTime ? const Color(0xFF4338CA) : Colors.grey.shade600,
            fontFamily: 'SYMBIOAR+LT',
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
      height: double.infinity,
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFF5F3FF).withOpacity(0.2) : null,
        border: Border(
          right: const BorderSide(color: Color(0xFFEFEFEF)),
          left: highlight
              ? const BorderSide(color: Color(0xFF4338CA), width: 2)
              : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: course != null &&
              onTap != null &&
              bgColor != null &&
              borderColor != null
          ? buildCourseBubble(context, course, bgColor, borderColor, onTap)
          : null,
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
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4338CA),
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
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
