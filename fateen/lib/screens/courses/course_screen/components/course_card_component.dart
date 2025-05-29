// components/course_card_component.dart
import 'package:flutter/material.dart';
import '../constants/(course_card_constants.dart';
import '../../../../models/course.dart';

class CourseCardComponent {
  /// بناء بطاقة المقرر بتصميم متناسق مع تصاميم الصفحات الأخرى
  static Widget buildCourseCard(
      Course course, int index, VoidCallback onTap, int colorIndex) {
    final daysString = course.days.join(' · ');

    // إنشاء ألوان متوافقة مع ألوان الصفحات الأخرى
    final bgColor = const Color(0xFFF5F3FF); // kLightPurple
    final accentColor = const Color(0xFF6366F1); // kMediumPurple

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المقرر وعدد الساعات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        course.courseName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4338CA), // kDarkPurple
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 14,
                            color: accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${course.creditHours ?? ''} ساعات",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: accentColor,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 12),

                // تفاصيل المقرر (الأيام والوقت والقاعة)
                Row(
                  children: [
                    // الأيام
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  CourseCardConstants.daysLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9CA3AF), // kHintColor
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                ),
                                Text(
                                  daysString.isEmpty
                                      ? CourseCardConstants.undefinedLabel
                                      : daysString,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151), // kTextColor
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // الوقت
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.access_time_outlined,
                              size: 16,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  CourseCardConstants.timeLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9CA3AF), // kHintColor
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                ),
                                Text(
                                  course.lectureTime ??
                                      CourseCardConstants.undefinedLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151), // kTextColor
                                    fontFamily: 'SYMBIOAR+LT',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // تفاصيل القاعة
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CourseCardConstants.roomLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF9CA3AF), // kHintColor
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          Text(
                            course.classroom.isEmpty
                                ? CourseCardConstants.undefinedRoomLabel
                                : course.classroom,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151), // kTextColor
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء عرض المقررات الفارغة بتصميم متناسق مع الصفحات الأخرى
  static Widget buildEmptyCoursesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF), // kLightPurple
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 60,
                color: Color(0xFF6366F1), // kMediumPurple
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              CourseCardConstants.noCoursesMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4338CA), // kDarkPurple
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                CourseCardConstants.addCoursesHint,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF), // kHintColor
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
