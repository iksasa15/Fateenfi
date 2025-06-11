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
              borderRadius:
                  BorderRadius.circular(16), // تعديل لتوحيد أنصاف أقطار الحواف
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
                          16), // تعديل لتوحيد أنصاف أقطار الحواف
                      topRight: Radius.circular(
                          16), // تعديل لتوحيد أنصاف أقطار الحواف
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
          ),
        ],
      ),
    );
  }

  /// بناء فقاعة المحاضرة في الجدول
  static Widget buildCourseBubble(
      Course course, Color bgColor, Color borderColor, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // اسم المادة بالكامل
                Text(
                  course.courseName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(
                        0xFF4338CA), // استخدام لون kDarkPurple من صفحات التسجيل
                    height: 1.2,
                    fontFamily: 'SYMBIOAR+LT',
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
                        fontFamily: 'SYMBIOAR+LT',
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
              color: const Color(
                  0xFFF5F3FF), // استخدام لون kLightPurple من صفحات التسجيل
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(
                  0xFF4338CA), // استخدام لون kDarkPurple من صفحات التسجيل
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

  /// بناء صف عناوين الجدول
  static Widget buildHeaderRow(List<String> days, List<String> englishDays) {
    return Container(
      decoration: BoxDecoration(
        color:
            const Color(0xFF4338CA), // استخدام لون kDarkPurple من صفحات التسجيل
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16), // تعديل لتوحيد أنصاف أقطار الحواف
          topRight: Radius.circular(16), // تعديل لتوحيد أنصاف أقطار الحواف
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
        color: isCurrentDay && !isFirstColumn
            ? const Color(0xFF3620c0)
            : null, // تعديل لتناسب ألوان صفحات التسجيل
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
      height: 80,
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
                ? const Color(
                    0xFF4338CA) // استخدام لون kDarkPurple من صفحات التسجيل
                : Colors.grey.shade600,
            fontFamily: 'SYMBIOAR+LT',
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
      height: 80, // زيادة ارتفاع الخلية لإتاحة مساحة أكبر لعرض الاسم
      decoration: BoxDecoration(
        border: Border(
          right: const BorderSide(color: Color(0xFFEFEFEF)),
          left: highlight
              ? BorderSide(
                  color: const Color(0xFF4338CA),
                  width: 2) // استخدام لون kDarkPurple من صفحات التسجيل
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
