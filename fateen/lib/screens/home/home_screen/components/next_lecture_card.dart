import 'package:flutter/material.dart';
import '../constants/next_lecture_constants.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../home/home_screen/components/countdown_timer.dart';

/// بطاقة المحاضرة القادمة بتصميم محسّن
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

    // حساب أحجام العناصر بناءً على حجم الشاشة
    final double cardHeight = screenSize.height * 0.13;
    final double titleSize =
        isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 17.0);
    final double subtitleSize =
        isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final double iconSize =
        isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 22.0);

    // تحديد الألوان بناءً على الوقت المتبقي
    Color timeColor = _getTimeColor(context, diffSeconds);
    Color cardColor = _getCardBackgroundColor(context, diffSeconds);

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
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
          boxShadow: [
            BoxShadow(
              color: context.colorShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: timeColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // زخرفة الخلفية - مستطيل ملون على الجانب
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: timeColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                    topLeft: Radius.circular(AppDimensions.largeRadius),
                    bottomLeft: Radius.circular(AppDimensions.largeRadius),
                  ),
                ),
              ),
            ),

            // المحتوى الرئيسي
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.getSpacing(context),
                vertical: screenSize.height * 0.015,
              ),
              child: Row(
                children: [
                  // أيقونة المحاضرة (مربع دائري ملون)
                  Container(
                    width: iconSize * 2,
                    height: iconSize * 2,
                    margin: EdgeInsets.only(
                        right: screenSize.width * 0.03, left: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: timeColor.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      color: timeColor,
                      size: iconSize,
                    ),
                  ),

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
                            color: context.colorTextPrimary,
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SYMBIOAR+LT',
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: screenSize.height * 0.007),

                        // القاعة
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: context.colorTextSecondary,
                              size: subtitleSize,
                            ),
                            SizedBox(width: screenSize.width * 0.01),
                            Expanded(
                              child: Text(
                                '${NextLectureConstants.classroomPrefix}$classroom',
                                style: TextStyle(
                                  color: context.colorTextSecondary,
                                  fontSize: subtitleSize - 1,
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

                        SizedBox(height: screenSize.height * 0.007),

                        // الوقت المتبقي مع العداد التنازلي
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: timeColor,
                              size: subtitleSize,
                            ),
                            SizedBox(width: screenSize.width * 0.01),
                            CountdownTimer(
                              initialSeconds: diffSeconds,
                              fontSize: subtitleSize - 1,
                              showIcon: false,
                              customColor: timeColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // مؤشر الوقت المتبقي (دائرة تظهر مستوى الأهمية)
                  Container(
                    width: iconSize * 2,
                    height: iconSize * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: timeColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child:
                          _buildTimeIndicator(context, diffSeconds, iconSize),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لإنشاء مؤشر الوقت المتبقي
  Widget _buildTimeIndicator(BuildContext context, int seconds, double size) {
    // تحديد نوع الأيقونة بناءً على الوقت المتبقي
    IconData iconData;
    String label;

    if (seconds < 900) {
      // أقل من 15 دقيقة
      iconData = Icons.warning_amber_rounded;
      label = "عاجل";
    } else if (seconds < 1800) {
      // أقل من 30 دقيقة
      iconData = Icons.watch_later_outlined;
      label = "قريب";
    } else if (seconds < 3600) {
      // أقل من ساعة
      iconData = Icons.access_time;
      label = "قادم";
    } else {
      // أكثر من ساعة
      iconData = Icons.event_available_outlined;
      label = "لاحقاً";
    }

    Color timeColor = _getTimeColor(context, seconds);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconData,
          color: timeColor,
          size: size,
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: timeColor,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  // لون الوقت حسب المدة المتبقية
  Color _getTimeColor(BuildContext context, int seconds) {
    if (seconds < 900) {
      // أقل من 15 دقيقة
      return context.colorError;
    } else if (seconds < 1800) {
      // أقل من 30 دقيقة
      return context.colorWarning;
    } else {
      return context.colorSuccess;
    }
  }

  // لون خلفية البطاقة حسب المدة المتبقية
  Color _getCardBackgroundColor(BuildContext context, int seconds) {
    if (seconds < 900) {
      // أقل من 15 دقيقة
      return context.colorError.withOpacity(0.05);
    } else if (seconds < 1800) {
      // أقل من 30 دقيقة
      return context.colorWarning.withOpacity(0.05);
    } else {
      return context.colorSuccess.withOpacity(0.05);
    }
  }
}

/// مكونات إضافية خاصة بالمحاضرة القادمة
class NextLectureComponents {
  /// بناء عنوان قسم المحاضرة القادمة
  static Widget buildSectionTitle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: AppDimensions.getSpacing(context, size: SpacingSize.small),
          ),
          child: Row(
            children: [
              // أيقونة العنوان
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.colorPrimaryPale,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school_rounded,
                  size: AppDimensions.getIconSize(context,
                      size: IconSize.small, small: true),
                  color: context.colorPrimaryDark,
                ),
              ),
              SizedBox(width: 8),

              // نص العنوان
              Text(
                NextLectureConstants.nextLectureTitle,
                style: TextStyle(
                  fontSize: AppDimensions.smallTitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: context.colorTextPrimary,
                  fontFamily: 'SYMBIOAR+LT',
                  height: 1.2,
                ),
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
            horizontal: AppDimensions.getSpacing(context),
          ),
          height: screenSize.height * 0.12,
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
            border: Border.all(color: context.colorBorder),
            boxShadow: [
              BoxShadow(
                color: context.colorShadow,
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
                  color: context.colorPrimaryLight.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: context.colorPrimary,
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
                        color: context.colorPrimaryDark,
                        fontFamily: 'SYMBIOAR+LT',
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.0025),
                    Text(
                      'يمكنك إضافة محاضراتك من قسم الجدول الدراسي',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: context.colorTextSecondary,
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
