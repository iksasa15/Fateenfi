// components/course_card_component.dart
import 'package:flutter/material.dart';
import '../constants/course_card_constants.dart';
import '../../../../models/course.dart';

class CourseCardComponent {
  // ألوان التطبيق
  static const Color kPrimaryColor = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kMediumPurple = Color(0xFF6366F1);
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kTextColor = Color(0xFF374151);
  static const Color kHintColor = Color(0xFF9CA3AF);
  static const Color kBackgroundColor = Colors.white;
  static const Color kShadowColor = Color(0x10000000);

  // ألوان العناصر
  static const List<Color> kIconBackgrounds = [
    Color(0xFFF0F9FF), // أزرق فاتح
    Color(0xFFFEF3F2), // أحمر فاتح
    Color(0xFFF5F3FF), // بنفسجي فاتح
  ];

  static const List<Color> kIconColors = [
    Color(0xFF0EA5E9), // أزرق
    Color(0xFFF43F5E), // أحمر
    Color(0xFF8B5CF6), // بنفسجي
  ];

  /// بناء بطاقة المقرر بتصميم عصري ومتناسق
  static Widget buildCourseCard(BuildContext context, Course course, int index,
      VoidCallback onTap, Function(Course) onEdit, Function(Course) onDelete) {
    final daysString = course.days.join(' · ');

    return LayoutBuilder(
      builder: (context, constraints) {
        return Dismissible(
          key: Key(course.id ?? "course-${course.courseName}-$index"),
          background: _buildDismissibleBackground(
            Colors.blue.shade50,
            kPrimaryColor,
            Icons.edit,
            EdgeInsets.only(right: 15),
            MainAxisAlignment.start,
          ),
          secondaryBackground: _buildDismissibleBackground(
            Colors.red.shade50,
            Colors.red,
            Icons.delete,
            EdgeInsets.only(left: 15),
            MainAxisAlignment.end,
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // حذف المقرر
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(CourseCardConstants.deleteConfirmation),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('حذف'),
                    ),
                  ],
                ),
              );
              if (result == true) {
                onDelete(course);
              }
              return false;
            } else if (direction == DismissDirection.startToEnd) {
              // تعديل المقرر
              onEdit(course);
              return false;
            }
            return false;
          },
          child: Hero(
            tag: 'course-${course.id}',
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kShadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  splashColor: kLightPurple,
                  highlightColor: kLightPurple.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // رأس البطاقة - اسم المقرر وعدد الساعات
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // أيقونة المقرر مع تأثير بصري
                            _buildCourseIcon(index),
                            SizedBox(width: 10),

                            // معلومات المقرر
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.courseName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: kDarkPurple,
                                      fontFamily: 'SYMBIOAR+LT',
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: kLightPurple,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: kPrimaryColor.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "${course.creditHours ?? ''} ${CourseCardConstants.creditHoursLabel}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: kPrimaryColor,
                                        fontFamily: 'SYMBIOAR+LT',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),
                        // فاصل مع تأثير ظل خفيف
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade50,
                                Colors.grey.shade200,
                                Colors.grey.shade50,
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        // تفاصيل المقرر في صف واحد
                        _buildDetailsRow(
                            context, constraints, daysString, course, index),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // أيقونة المقرر مع تأثير - حجم أصغر
  static Widget _buildCourseIcon(int index) {
    final colorIndex = index % kIconBackgrounds.length;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: kIconBackgrounds[colorIndex],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kIconColors[colorIndex].withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // دائرة خلفية للأيقونة
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: kIconColors[colorIndex].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
          Icon(
            [
              Icons.menu_book_rounded,
              Icons.book,
              Icons.auto_stories
            ][colorIndex],
            color: kIconColors[colorIndex],
            size: 20,
          ),
        ],
      ),
    );
  }

  // صف التفاصيل (الأيام والوقت والقاعة) بحجم أصغر
  static Widget _buildDetailsRow(BuildContext context,
      BoxConstraints constraints, String daysString, Course course, int index) {
    final isSmallScreen = constraints.maxWidth < 360;
    final spacing = isSmallScreen ? 6.0 : 8.0;

    return Container(
      padding: EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الأيام
          Expanded(
            flex: isSmallScreen ? 4 : 3,
            child: _buildEnhancedDetailItem(
              Icons.calendar_today_rounded,
              CourseCardConstants.daysLabel,
              daysString.isEmpty
                  ? CourseCardConstants.undefinedLabel
                  : daysString,
              0, // استخدام نفس ترتيب الألوان
            ),
          ),
          SizedBox(width: spacing),

          // الوقت
          Expanded(
            flex: isSmallScreen ? 3 : 3,
            child: _buildEnhancedDetailItem(
              Icons.access_time_rounded,
              CourseCardConstants.timeLabel,
              course.lectureTime ?? CourseCardConstants.undefinedLabel,
              1,
            ),
          ),
          SizedBox(width: spacing),

          // القاعة
          Expanded(
            flex: isSmallScreen ? 3 : 3,
            child: _buildEnhancedDetailItem(
              Icons.location_on_rounded,
              CourseCardConstants.roomLabel,
              course.classroom.isEmpty
                  ? CourseCardConstants.undefinedRoomLabel
                  : course.classroom,
              2,
            ),
          ),
        ],
      ),
    );
  }

  // عنصر تفاصيل محسن بتصميم أصغر
  static Widget _buildEnhancedDetailItem(
      IconData icon, String label, String value, int colorIndex) {
    return Container(
      decoration: BoxDecoration(
        color: kIconBackgrounds[colorIndex].withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: kIconColors[colorIndex].withOpacity(0.15),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان التفصيل مع أيقونة
          Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: kIconColors[colorIndex],
              ),
              SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: kIconColors[colorIndex],
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
          SizedBox(height: 3),

          // قيمة التفصيل
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kTextColor,
              fontFamily: 'SYMBIOAR+LT',
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // خلفية للسحب بحجم أصغر
  static Widget _buildDismissibleBackground(
    Color backgroundColor,
    Color iconColor,
    IconData icon,
    EdgeInsets padding,
    MainAxisAlignment alignment,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  // باقي الكود كما هو...
  static Widget buildEmptyCoursesView(BuildContext context,
      {VoidCallback? onAddCourse}) {
    return LayoutBuilder(builder: (context, constraints) {
      // تحقق من حجم الشاشة للتكيف مع مختلف الأجهزة
      final screenHeight = MediaQuery.of(context).size.height;
      final imageSize = constraints.maxWidth > 600 ? 150.0 : 120.0;

      return Center(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: Duration(seconds: 1),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: imageSize,
                        height: imageSize,
                        decoration: BoxDecoration(
                          color: kLightPurple,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.school_rounded,
                            size: imageSize * 0.5,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  CourseCardConstants.noCoursesMessage,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kDarkPurple,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.01),
                Container(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Text(
                    CourseCardConstants.addCoursesHint,
                    style: TextStyle(
                      fontSize: 14,
                      color: kHintColor,
                      fontFamily: 'SYMBIOAR+LT',
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                if (onAddCourse != null)
                  ElevatedButton.icon(
                    onPressed: onAddCourse,
                    icon: Icon(Icons.add_rounded, size: 20),
                    label: Text(
                      CourseCardConstants.addCourseButton,
                      style: TextStyle(
                        fontFamily: 'SYMBIOAR+LT',
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  static Widget buildCoursesList(
    BuildContext context,
    List<Course> courses, {
    required Function(Course) onCourseTap,
    required Function(Course) onCourseEdit,
    required Function(Course) onCourseDelete,
    VoidCallback? onAddCourse,
  }) {
    if (courses.isEmpty) {
      return buildEmptyCoursesView(context, onAddCourse: onAddCourse);
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return buildCourseCard(
          context,
          courses[index],
          index,
          () => onCourseTap(courses[index]),
          onCourseEdit,
          onCourseDelete,
        );
      },
    );
  }
}
