import 'package:flutter/material.dart';
import '../constants/performance_colors.dart';

/// مكتبة أنماط تصميم تطبيق تحليل الأداء
/// توفر أنماط موحدة للبطاقات والأزرار والنصوص وغيرها من عناصر واجهة المستخدم
class PerformanceTheme {
  //
  // ============ أنماط البطاقات والحاويات ============
  //

  /// نمط بطاقة عادية
  /// يستخدم لجميع البطاقات الرئيسية في التطبيق
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: PerformanceColors.card,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: PerformanceColors.shadow,
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// نمط رأس البطاقة
  /// يستخدم للجزء العلوي من البطاقات لتمييزه بلون مختلف
  static final BoxDecoration cardHeaderDecoration = BoxDecoration(
    color: PerformanceColors.primary,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
  );

  /// نمط حاوية أيقونة
  /// يستخدم لإحاطة الأيقونات بخلفية شفافة
  static final BoxDecoration iconContainerDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.2),
    borderRadius: BorderRadius.circular(8),
  );

  /// نمط حاوية معلومات
  /// خلفية فاتحة مع إطار للمعلومات الهامة
  static final BoxDecoration infoContainerDecoration = BoxDecoration(
    color: PerformanceColors.primary.withOpacity(0.05),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: PerformanceColors.primary.withOpacity(0.2),
      width: 1,
    ),
  );

  /// نمط حاوية للتنبيهات والتحذيرات
  static final BoxDecoration alertContainerDecoration = BoxDecoration(
    color: PerformanceColors.warning.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: PerformanceColors.warning.withOpacity(0.3),
      width: 1,
    ),
  );

  //
  // ============ أنماط الأزرار ============
  //

  /// نمط زر أساسي
  /// يستخدم للإجراءات الرئيسية في التطبيق
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: PerformanceColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  );

  /// نمط زر ثانوي
  /// يستخدم للإجراءات الثانوية أو البديلة
  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: PerformanceColors.secondary,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  );

  /// نمط زر مسطح
  /// يستخدم للإجراءات الأقل أهمية
  static final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    foregroundColor: PerformanceColors.primary,
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  /// نمط زر صغير
  /// يستخدم في المساحات الضيقة
  static final ButtonStyle smallButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: PerformanceColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    textStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      fontFamily: 'SYMBIOAR+LT',
    ),
  );

  //
  // ============ أنماط النصوص ============
  //

  /// نمط عنوان رئيسي
  static final TextStyle headingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: PerformanceColors.textPrimary,
    fontFamily: 'SYMBIOAR+LT',
  );

  /// نمط عنوان قسم
  /// يستخدم لعناوين الأقسام الرئيسية في التطبيق
  static final TextStyle sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: PerformanceColors.textPrimary,
    fontFamily: 'SYMBIOAR+LT',
  );

  /// نمط نص عادي
  /// يستخدم للنصوص الأساسية في التطبيق
  static final TextStyle bodyTextStyle = TextStyle(
    fontSize: 14,
    color: PerformanceColors.textPrimary,
    fontFamily: 'SYMBIOAR+LT',
  );

  /// نمط تذييل
  /// يستخدم للنصوص الصغيرة والمعلومات الإضافية
  static final TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: PerformanceColors.textSecondary,
    fontFamily: 'SYMBIOAR+LT',
  );

  /// نمط نص تنبيه
  /// يستخدم للتنبيهات والتحذيرات
  static final TextStyle alertTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: PerformanceColors.warning,
    fontFamily: 'SYMBIOAR+LT',
  );

  /// نمط عنوان البطاقة
  /// يستخدم لعناوين البطاقات
  static final TextStyle cardTitleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: PerformanceColors.primary,
    fontFamily: 'SYMBIOAR+LT',
  );

  //
  // ============ أنماط مؤشرات التقدم ============
  //

  /// نمط مؤشر تقدم خطي
  static final progressIndicatorTheme = ProgressIndicatorThemeData(
    color: PerformanceColors.primary,
    linearTrackColor: PerformanceColors.primary.withOpacity(0.1),
  );

  /// نمط توسيم النسب المئوية
  static TextStyle getPercentageStyle(double percentage) {
    Color color;
    if (percentage >= 90) {
      color = PerformanceColors.excellent;
    } else if (percentage >= 70) {
      color = PerformanceColors.good;
    } else if (percentage >= 50) {
      color = PerformanceColors.average;
    } else {
      color = PerformanceColors.weak;
    }

    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: color,
      fontFamily: 'SYMBIOAR+LT',
    );
  }

  //
  // ============ دوال مساعدة للأنماط ============
  //

  /// إنشاء تذييل مع حدود دائرية
  /// @param color - لون الخلفية
  /// @param textColor - لون النص
  /// @returns - نمط النص المطلوب
  static TextStyle chipTextStyle({
    required Color color,
    Color? textColor,
  }) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textColor ?? Colors.white,
      fontFamily: 'SYMBIOAR+LT',
    );
  }

  /// إنشاء نمط حاوية مخصص بلون محدد
  /// @param color - لون الحاوية
  /// @param radius - نصف قطر الحدود الدائرية
  /// @returns - نمط الحاوية المطلوب
  static BoxDecoration customContainer({
    required Color color,
    double radius = 8.0,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: color.withOpacity(0.3),
        width: 1,
      ),
    );
  }
}
