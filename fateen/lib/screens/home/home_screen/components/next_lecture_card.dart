import 'package:flutter/material.dart';
import '../constants/next_lecture_constants.dart';

/// بطاقة المحاضرة القادمة
class NextLectureCard extends StatelessWidget {
  final String courseName;
  final String classroom;
  final int diffSeconds;
  final Animation<double> animation;

  const NextLectureCard({
    Key? key,
    required this.courseName,
    required this.classroom,
    required this.diffSeconds,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    // الألوان المستخدمة في التطبيق
    const Color kMediumPurple = Color(0xFF6366F1);
    const Color kDarkPurple = Color(0xFF4338CA);

    // حساب الوقت المتبقي بشكل أكثر دقة
    int diffHours = diffSeconds ~/ 3600;
    int diffMinutes = (diffSeconds % 3600) ~/ 60;

    // تنسيق عرض الوقت
    String timeDisplay;
    if (diffHours > 0) {
      timeDisplay = '$diffHours س $diffMinutes د';
    } else {
      timeDisplay = '$diffMinutes د';
    }

    // حساب أحجام العناصر بناءً على حجم الشاشة - تحسين الأحجام
    final double cardHeight = screenSize.height * 0.12;

    // زيادة أحجام النصوص والأيقونات
    final double titleSize =
        isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 17.0);
    final double subtitleSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final double iconSize =
        isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
    final double timeCircleSize = screenSize.width * 0.14;
    final double timeTextSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: cardHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [kMediumPurple, kDarkPurple],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kMediumPurple.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        // استخدام ClipRRect لضمان عدم تجاوز أي عنصر داخلي
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // زخارف الخلفية
              Positioned(
                left: -25,
                top: -10,
                child: Container(
                  width: screenSize.width * 0.15,
                  height: screenSize.width * 0.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),

              // المحتوى الرئيسي
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04,
                  vertical: screenSize.height * 0.015,
                ),
                child: Row(
                  children: [
                    // المعلومات الرئيسية (اسم المقرر + القاعة)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // اسم المقرر
                          Text(
                            courseName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SYMBIOAR+LT',
                              height: 1.2, // تحسين المسافة بين السطور
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: screenSize.height * 0.01),

                          // القاعة
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: iconSize,
                              ),
                              SizedBox(width: screenSize.width * 0.01),
                              Expanded(
                                child: Text(
                                  '${NextLectureConstants.classroomPrefix}$classroom',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: subtitleSize,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'SYMBIOAR+LT',
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: screenSize.width * 0.03),

                    // دائرة الوقت المتبقي
                    Container(
                      width: timeCircleSize,
                      height: timeCircleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: Colors.white,
                              size: iconSize,
                            ),
                            SizedBox(height: screenSize.height * 0.0025),
                            Text(
                              timeDisplay,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: timeTextSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SYMBIOAR+LT',
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// مكونات إضافية خاصة بالمحاضرة القادمة
class NextLectureComponents {
  /// بناء عنوان قسم المحاضرة القادمة
  static Widget buildSectionTitle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        // زيادة حجم العنوان
        final double titleSize =
            isSmallScreen ? 17.0 : (isMediumScreen ? 18.0 : 19.0);

        return Padding(
          padding: EdgeInsets.only(
            bottom: screenSize.height * 0.01,
            top: screenSize.height * 0.02,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NextLectureConstants.nextLectureTitle,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4338CA),
                      letterSpacing: 0.3,
                      fontFamily: 'SYMBIOAR+LT',
                      height: 1.2, // تحسين المسافة بين السطور
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.004),
                  Container(
                    width: screenSize.width * 0.07,
                    height: 2.5, // زيادة سمك الخط
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// رسالة فارغة عندما لا توجد محاضرات قادمة
  static Widget buildEmptyLectureState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        // تحسين أحجام النصوص
        final double titleSize =
            isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
        final double subtitleSize =
            isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0);
        final double iconSize =
            isSmallScreen ? 48.0 : (isMediumScreen ? 50.0 : 52.0);

        return Container(
          margin: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.01,
          ),
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.02,
            horizontal: screenSize.width * 0.04,
          ),
          height: screenSize.height * 0.12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade50,
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // أيقونة
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: const Color(0xFF6366F1),
                  size: iconSize * 0.5,
                ),
              ),

              SizedBox(width: screenSize.width * 0.04),

              // النص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      NextLectureConstants.noLecturesMessage,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4338CA),
                        fontFamily: 'SYMBIOAR+LT',
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.0025),
                    Text(
                      'يمكنك إضافة محاضراتك من قسم الجدول الدراسي',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.grey[600],
                        fontFamily: 'SYMBIOAR+LT',
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
