import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية (توحيد الهوية)
  static const Color primary = Color(0xFF6A2FEC); // اللون الرئيسي للتطبيق
  static const Color primaryDark =
      Color(0xFF4338CA); // نسخة داكنة من اللون الرئيسي
  static const Color primaryLight =
      Color(0xFF6366F1); // نسخة خفيفة من اللون الرئيسي
  static const Color primaryPale =
      Color(0xFFF5F3FF); // نسخة شاحبة من اللون الرئيسي
  static const Color accent =
      Color(0xFFEC4899); // لون التمييز للتأكيد والأزرار المهمة

  // ألوان الخلفية (موحدة)
  static const Color background = Color(0xFFFDFDFF); // خلفية التطبيق الرئيسية
  static const Color surface = Color(0xFFFFFFFF); // خلفية البطاقات والعناصر
  static const Color surfaceLight =
      Color(0xFFF8F8F8); // خلفية ثانوية أخف قليلاً

  // ألوان النصوص (موحدة)
  static const Color textPrimary = Color(0xFF374151); // النص الأساسي
  static const Color textSecondary = Color(0xFF757575); // النص الثانوي
  static const Color textHint = Color(0xFF9CA3AF); // نص التلميحات والإرشادات

  // ألوان الحالة (موحدة)
  static const Color success = Color(0xFF34D399); // النجاح والحالة الإيجابية
  static const Color warning = Color(0xFFFF9800); // التنبيه والحالة المعلقة
  static const Color error = Color(0xFFE64646); // الخطأ والحالة السلبية
  static const Color info = Color(0xFF3B82F6); // المعلومات

  // ألوان الحدود والفواصل (موحدة)
  static const Color border = Color(0xFFE0E0E0); // لون الحدود
  static const Color divider = Color(0xFFEEEEEE); // لون الفواصل

  // ألوان الظلال (موحدة)
  static const Color shadow = Color(0x0D221291); // ظلال خفيفة
  static const Color shadowDark = Color(0x0F000000); // ظلال داكنة

  // ألوان التفاعل (موحدة)
  static const Color focusState = Color(0xFFEEF2FF); // حالة التركيز
  static const Color disabledState = Color(0xFFDDDDDD); // حالة التعطيل

  // ألوان وسائل التواصل الاجتماعي (موحدة إذا كانت ضرورية)
  static const Color google = Color(0xFFEA4335);
  static const Color facebook = Color(0xFF1877F2);
  static const Color apple = Color(0xFF000000);

  // التدرجات الرئيسية (موحدة)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8753F7),
      Color(0xFF6A2FEC),
    ],
  );

  // الإضافات الجديدة - تدرجات إضافية للعناصر المختلفة
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEC4899),
      Color(0xFFE02D6F),
    ],
  );

  // تعريف القيم غير المعرفة سابقاً
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color mediumPurple = Color(0xFF9F7AEA);
  static const Color shadowColor = Color(0x1A000000);
  static const Color primaryExtraLight = Color(0xFFEEE9FF);

  // ألوان الوضع الليلي (الداكن)
  // الألوان الأساسية (وضع داكن)
  static const Color darkPrimary = Color(0xFF8B5CF6); // اللون الرئيسي للتطبيق
  static const Color darkPrimaryDark =
      Color(0xFF7C3AED); // نسخة داكنة من اللون الرئيسي
  static const Color darkPrimaryLight =
      Color(0xFFA78BFA); // نسخة خفيفة من اللون الرئيسي
  static const Color darkPrimaryPale =
      Color(0xFF2E1065); // نسخة شاحبة من اللون الرئيسي
  static const Color darkAccent =
      Color(0xFFF472B6); // لون التمييز للتأكيد والأزرار المهمة

  // ألوان الخلفية (وضع داكن)
  static const Color darkBackground =
      Color(0xFF121212); // خلفية التطبيق الرئيسية
  static const Color darkSurface = Color(0xFF1E1E1E); // خلفية البطاقات والعناصر
  static const Color darkSurfaceLight =
      Color(0xFF2C2C2C); // خلفية ثانوية أخف قليلاً

  // ألوان النصوص (وضع داكن)
  static const Color darkTextPrimary = Color(0xFFE2E8F0); // النص الأساسي
  static const Color darkTextSecondary = Color(0xFFABB3BF); // النص الثانوي
  static const Color darkTextHint =
      Color(0xFF6B7280); // نص التلميحات والإرشادات

  // ألوان الحالة (وضع داكن)
  static const Color darkSuccess =
      Color(0xFF10B981); // النجاح والحالة الإيجابية
  static const Color darkWarning = Color(0xFFF59E0B); // التنبيه والحالة المعلقة
  static const Color darkError = Color(0xFFEF4444); // الخطأ والحالة السلبية
  static const Color darkInfo = Color(0xFF3B82F6); // المعلومات

  // ألوان الحدود والفواصل (وضع داكن)
  static const Color darkBorder = Color(0xFF333333); // لون الحدود
  static const Color darkDivider = Color(0xFF2A2A2A); // لون الفواصل

  // ألوان الظلال (وضع داكن)
  static const Color darkShadow = Color(0x3D000000); // ظلال خفيفة
  static const Color darkShadowDark = Color(0x66000000); // ظلال داكنة

  // ألوان التفاعل (وضع داكن)
  static const Color darkFocusState = Color(0xFF2D3748); // حالة التركيز
  static const Color darkDisabledState = Color(0xFF4B5563); // حالة التعطيل

  // التدرجات الرئيسية (وضع داكن)
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9F7AEA),
      Color(0xFF8B5CF6),
    ],
  );

  // تدرجات إضافية للعناصر المختلفة (وضع داكن)
  static const LinearGradient darkAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEC4899),
      Color(0xFFDB2777),
    ],
  );

  // ألوان إضافية للوضع الداكن
  static const Color darkShimmerBase = Color(0xFF2A2A2A);
  static const Color darkShimmerHighlight = Color(0xFF3D3D3D);
  static const Color darkMediumPurple = Color(0xFF8B5CF6);
  static const Color darkShadowColor = Color(0x40000000);
  static const Color darkPrimaryExtraLight = Color(0xFF312E81);

  // دالة مساعدة للحصول على اللون المناسب حسب وضع الثيم
  static Color getThemeColor(
      Color lightColor, Color darkColor, bool isDarkMode) {
    return isDarkMode ? darkColor : lightColor;
  }

  // الحصول على مجموعة ألوان ماتيريال من اللون الرئيسي
  static MaterialColor getMaterialPrimary({bool isDarkMode = false}) {
    final baseColor = isDarkMode ? darkPrimary : primary;

    if (isDarkMode) {
      return MaterialColor(darkPrimary.value, {
        50: darkPrimaryPale,
        100: Color(0xFF312E81),
        200: Color(0xFF4338CA),
        300: Color(0xFF4F46E5),
        400: Color(0xFF6366F1),
        500: darkPrimaryLight,
        600: Color(0xFF7C3AED),
        700: darkPrimaryDark,
        800: Color(0xFF6D28D9),
        900: Color(0xFF5B21B6),
      });
    } else {
      return MaterialColor(primary.value, {
        50: primaryPale,
        100: Color(0xFFEBE9FF),
        200: Color(0xFFD7D4FF),
        300: Color(0xFFC2BFFF),
        400: Color(0xFF9C98FF),
        500: primaryLight,
        600: Color(0xFF5152D9),
        700: primaryDark,
        800: Color(0xFF382DA6),
        900: Color(0xFF231C6A),
      });
    }
  }

  // الحصول على التدرج المناسب حسب وضع الثيم
  static LinearGradient getThemeGradient(LinearGradient lightGradient,
      LinearGradient darkGradient, bool isDarkMode) {
    return isDarkMode ? darkGradient : lightGradient;
  }
}

// إضافة Extension للحصول على الألوان بناءً على الثيم الحالي
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // الألوان الأساسية
  Color get colorPrimary =>
      isDarkMode ? AppColors.darkPrimary : AppColors.primary;
  Color get colorPrimaryDark =>
      isDarkMode ? AppColors.darkPrimaryDark : AppColors.primaryDark;
  Color get colorPrimaryLight =>
      isDarkMode ? AppColors.darkPrimaryLight : AppColors.primaryLight;
  Color get colorPrimaryPale =>
      isDarkMode ? AppColors.darkPrimaryPale : AppColors.primaryPale;
  Color get colorPrimaryExtraLight => isDarkMode
      ? AppColors.darkPrimaryExtraLight
      : AppColors.primaryExtraLight;
  Color get colorAccent => isDarkMode ? AppColors.darkAccent : AppColors.accent;

  // ألوان الخلفية
  Color get colorBackground =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;
  Color get colorSurface =>
      isDarkMode ? AppColors.darkSurface : AppColors.surface;
  Color get colorSurfaceLight =>
      isDarkMode ? AppColors.darkSurfaceLight : AppColors.surfaceLight;

  // ألوان النصوص
  Color get colorTextPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get colorTextSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get colorTextHint =>
      isDarkMode ? AppColors.darkTextHint : AppColors.textHint;

  // ألوان الحالة
  Color get colorSuccess =>
      isDarkMode ? AppColors.darkSuccess : AppColors.success;
  Color get colorWarning =>
      isDarkMode ? AppColors.darkWarning : AppColors.warning;
  Color get colorError => isDarkMode ? AppColors.darkError : AppColors.error;
  Color get colorInfo => isDarkMode ? AppColors.darkInfo : AppColors.info;

  // ألوان الحدود والفواصل
  Color get colorBorder => isDarkMode ? AppColors.darkBorder : AppColors.border;
  Color get colorDivider =>
      isDarkMode ? AppColors.darkDivider : AppColors.divider;

  // ألوان الظلال
  Color get colorShadow => isDarkMode ? AppColors.darkShadow : AppColors.shadow;
  Color get colorShadowDark =>
      isDarkMode ? AppColors.darkShadowDark : AppColors.shadowDark;
  Color get colorShadowColor =>
      isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor;

  // ألوان التفاعل
  Color get colorFocusState =>
      isDarkMode ? AppColors.darkFocusState : AppColors.focusState;
  Color get colorDisabledState =>
      isDarkMode ? AppColors.darkDisabledState : AppColors.disabledState;

  // ألوان shimmer
  Color get colorShimmerBase =>
      isDarkMode ? AppColors.darkShimmerBase : AppColors.shimmerBase;
  Color get colorShimmerHighlight =>
      isDarkMode ? AppColors.darkShimmerHighlight : AppColors.shimmerHighlight;

  // ألوان أخرى
  Color get colorMediumPurple =>
      isDarkMode ? AppColors.darkMediumPurple : AppColors.mediumPurple;

  // ألوان وسائل التواصل
  Color get colorGoogle => AppColors.google;
  Color get colorFacebook => AppColors.facebook;
  Color get colorApple => AppColors.apple;

  // التدرجات
  LinearGradient get gradientPrimary =>
      isDarkMode ? AppColors.darkPrimaryGradient : AppColors.primaryGradient;
  LinearGradient get gradientAccent =>
      isDarkMode ? AppColors.darkAccentGradient : AppColors.accentGradient;

  // الحصول على MaterialColor للثيم الحالي
  MaterialColor get materialPrimary =>
      AppColors.getMaterialPrimary(isDarkMode: isDarkMode);
}
