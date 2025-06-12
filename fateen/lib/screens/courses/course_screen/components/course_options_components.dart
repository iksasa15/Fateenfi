// course_options_components.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/course_options_constants.dart';
import '../../../../models/course.dart';

class CourseOptionsComponents {
  // ألوان التطبيق
  static const Color kPrimaryColor = Color(0xFF6366F1);
  static const Color kLightPurple = Color(0xFFF5F3FF);
  static const Color kDarkPurple = Color(0xFF4338CA);
  static const Color kTextColor = Color(0xFF374151);
  static const Color kHintColor = Color(0xFF9CA3AF);
  static const Color kBackgroundColor = Colors.white;
  static const Color kDangerColor = Color(0xFFF43F5E);

  // مجموعة من الألوان للخيارات
  static const List<Color> optionColors = [
    Color(0xFF4338CA), // أرجواني
    Color(0xFF0EA5E9), // أزرق
    Color(0xFF10B981), // أخضر
    Color(0xFFF97316), // برتقالي
  ];

  // رأس البطاقة مع معلومات المقرر - تصميم ديناميكي
  static Widget buildEnhancedHeader(Course course, BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // احسب الأحجام بناءً على عرض الشاشة
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;
      final isTablet = screenWidth >= 600;
      final isWeb = screenWidth >= 1024;

      // تكييف الأحجام بناءً على الجهاز - مع زيادة حجم الخط بشكل أكبر
      final headerPadding = EdgeInsets.symmetric(
          horizontal: isWeb ? 20 : (isTablet ? 16 : 12),
          vertical: isWeb ? 16 : (isTablet ? 12 : 8));

      final handleWidth = isWeb ? 40.0 : (isTablet ? 36.0 : 32.0);
      final handleHeight = isWeb ? 4.0 : 3.0;

      // زيادة حجم خط العنوان
      final titleFontSize =
          isWeb ? 22.0 : (isTablet ? 20.0 : (isSmallScreen ? 18.0 : 19.0));

      return Container(
        width: double.infinity,
        padding: headerPadding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kLightPurple, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // مؤشر السحب
            Container(
              width: handleWidth,
              height: handleHeight,
              margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // اسم المقرر
            Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 2 : 4),
              child: Text(
                course.courseName,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: kDarkPurple,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // معلومات المقرر
            Padding(
              padding: EdgeInsets.only(bottom: 6, top: 2),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: isWeb ? 12 : (isTablet ? 10 : 8),
                runSpacing: isWeb ? 8 : 6,
                children: [
                  // عدد الساعات
                  _buildInfoChip(Icons.timer_outlined,
                      "${course.creditHours} ساعات", context),

                  // القاعة
                  _buildInfoChip(
                      Icons.location_on_outlined,
                      course.classroom.isNotEmpty
                          ? course.classroom
                          : "غير محدد",
                      context),

                  // الأيام (نعرضها فقط إذا كانت الشاشة كبيرة بما يكفي)
                  if (!isSmallScreen || screenWidth > 320)
                    _buildInfoChip(
                        Icons.calendar_today_outlined,
                        course.days.isNotEmpty
                            ? course.days.join(" • ")
                            : "غير محدد",
                        context),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // عنصر معلومات صغير - مع زيادة حجم الخط والأيقونة
  static Widget _buildInfoChip(
      IconData icon, String text, BuildContext context) {
    // احسب الأحجام بناءً على عرض الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isWeb = screenWidth >= 1024;

    // زيادة حجم الأيقونة والخط
    final iconSize =
        isWeb ? 18.0 : (isTablet ? 17.0 : (isSmallScreen ? 14.0 : 15.0));
    final fontSize =
        isWeb ? 16.0 : (isTablet ? 15.0 : (isSmallScreen ? 13.0 : 14.0));
    final padding = EdgeInsets.symmetric(
        horizontal: isWeb ? 8.0 : (isTablet ? 7.0 : 6.0),
        vertical: isWeb ? 4.0 : (isTablet ? 3.0 : 2.0));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: kLightPurple,
        borderRadius: BorderRadius.circular(isWeb ? 10 : 8),
        border: Border.all(
          color: kPrimaryColor.withOpacity(0.15),
          width: isWeb ? 1.0 : 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: kPrimaryColor,
          ),
          SizedBox(width: isSmallScreen ? 2 : 3),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: kTextColor,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ],
      ),
    );
  }

  // خيار مطور وعصري - ديناميكي مع زيادة حجم الخط والأيقونات
  static Widget buildEnhancedOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      // احسب الأحجام بناءً على عرض الشاشة
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;
      final isTablet = screenWidth >= 600;
      final isWeb = screenWidth >= 1024;

      // تكييف الأحجام - مع زيادة الأحجام
      final containerPadding =
          EdgeInsets.all(isWeb ? 16.0 : (isTablet ? 14.0 : 12.0));
      final iconContainerSize =
          isWeb ? 48.0 : (isTablet ? 44.0 : (isSmallScreen ? 40.0 : 42.0));

      // زيادة حجم الأيقونة
      final iconSize =
          isWeb ? 24.0 : (isTablet ? 22.0 : (isSmallScreen ? 18.0 : 20.0));

      // زيادة حجم خط العنوان والوصف
      final titleFontSize =
          isWeb ? 19.0 : (isTablet ? 18.0 : (isSmallScreen ? 16.0 : 17.0));
      final subtitleFontSize =
          isWeb ? 16.0 : (isTablet ? 15.0 : (isSmallScreen ? 13.0 : 14.0));

      // زيادة حجم أيقونة السهم
      final arrowIconSize =
          isWeb ? 18.0 : (isTablet ? 16.0 : (isSmallScreen ? 14.0 : 15.0));

      return Padding(
        // تقليل المساحة السفلية لجعل العناصر أقرب لبعضها
        padding: const EdgeInsets.only(bottom: 4), // تم تقليلها من 8 إلى 4
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: containerPadding,
              child: Row(
                children: [
                  // أيقونة الخيار
                  Container(
                    width: iconContainerSize,
                    height: iconContainerSize,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 10),

                  // نص الخيار مع الوصف
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: kTextColor,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 1 : 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: kHintColor,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // أيقونة السهم
                  Icon(
                    Icons.arrow_forward_ios,
                    size: arrowIconSize,
                    color: kPrimaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // زر حذف عصري ومتوازن - مع زيادة حجم الخط والأيقونة
  static Widget buildEnhancedDeleteButton({
    required VoidCallback onDelete,
    required String text,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      // احسب الأحجام بناءً على عرض الشاشة
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;
      final isTablet = screenWidth >= 600;
      final isWeb = screenWidth >= 1024;

      // تكييف الأحجام - مع زيادة الأحجام
      final verticalPadding =
          isWeb ? 16.0 : (isTablet ? 14.0 : (isSmallScreen ? 12.0 : 13.0));

      // زيادة حجم الأيقونة والخط
      final iconSize =
          isWeb ? 22.0 : (isTablet ? 20.0 : (isSmallScreen ? 18.0 : 19.0));
      final fontSize =
          isWeb ? 18.0 : (isTablet ? 17.0 : (isSmallScreen ? 15.0 : 16.0));

      return InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onDelete();
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: kDangerColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            // إضافة حدود للتوازن البصري
            border: Border.all(
              color: kDangerColor.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: kDangerColor,
                  size: iconSize,
                ),
                SizedBox(width: isSmallScreen ? 4 : 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: kDangerColor,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // مربع حوار تأكيد ديناميكي - مع زيادة حجم الخط والأيقونات
  static Widget buildEnhancedConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
  }) {
    // احسب الأحجام بناءً على عرض الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isWeb = screenWidth >= 1024;

    // تكييف الأحجام - مع زيادة الأحجام
    final dialogPadding =
        isWeb ? 24.0 : (isTablet ? 20.0 : (isSmallScreen ? 16.0 : 18.0));
    final iconSize =
        isWeb ? 68.0 : (isTablet ? 58.0 : (isSmallScreen ? 48.0 : 52.0));
    final warningIconSize =
        isWeb ? 34.0 : (isTablet ? 30.0 : (isSmallScreen ? 24.0 : 26.0));

    // زيادة حجم خطوط مربع الحوار
    final titleFontSize =
        isWeb ? 22.0 : (isTablet ? 20.0 : (isSmallScreen ? 18.0 : 19.0));
    final contentFontSize =
        isWeb ? 18.0 : (isTablet ? 17.0 : (isSmallScreen ? 15.0 : 16.0));
    final buttonFontSize =
        isWeb ? 18.0 : (isTablet ? 17.0 : (isSmallScreen ? 15.0 : 16.0));

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(dialogPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة التحذير
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: kDangerColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: kDangerColor,
                size: warningIconSize,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // عنوان التأكيد
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: kTextColor,
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),

            // نص التأكيد
            Text(
              content,
              style: TextStyle(
                fontSize: contentFontSize,
                color: kHintColor,
                fontFamily: 'SYMBIOAR+LT',
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // أزرار التأكيد والإلغاء
            Row(
              children: [
                // زر الإلغاء
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.w600,
                            color: kTextColor,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 10),

                // زر التأكيد
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 14),
                      decoration: BoxDecoration(
                        color: kDangerColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          confirmText,
                          style: TextStyle(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
