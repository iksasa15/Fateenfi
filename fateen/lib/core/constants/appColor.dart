import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية (توحيد الهوية) - محدثة بألوان عصرية وهادئة
  static const Color primary = Color(0xFF5B63B7); // لون أزرق-بنفسجي هادئ
  static const Color primaryDark = Color(0xFF404B8C); // داكن متناسق مع الرئيسي
  static const Color primaryLight = Color(0xFF7E85D0); // خفيف متناسق
  static const Color primaryPale = Color(0xFFF0F1FA); // شاحب للخلفيات الخفيفة
  static const Color accent = Color(0xFFEF6C9E); // وردي معتدل للتمييز

  // ألوان الخلفية (موحدة) - محدثة لمظهر أكثر انتعاشًا
  static const Color background = Color(0xFFFAFBFF); // خلفية بلمسة زرقاء خفيفة
  static const Color surface = Color(0xFFFFFFFF); // خلفية البطاقات والعناصر
  static const Color surfaceLight =
      Color(0xFFF5F7FC); // خلفية ثانوية بلمسة زرقاء

  // ألوان النصوص (موحدة) - محسنة للقراءة
  static const Color textPrimary = Color(0xFF2C3256); // أزرق داكن للنص الأساسي
  static const Color textSecondary = Color(0xFF6B7194); // رمادي مائل للأزرق
  static const Color textHint = Color(0xFF9CA3BD); // لون تلميحات معتدل

  // ألوان الحالة (موحدة) - أكثر حيوية ولكن متناسقة
  static const Color success = Color(0xFF66BB6A); // أخضر معتدل للنجاح
  static const Color warning = Color(0xFFFFB74D); // برتقالي معتدل للتنبيه
  static const Color error = Color(0xFFE57373); // أحمر معتدل للخطأ
  static const Color info = Color(0xFF64B5F6); // أزرق معتدل للمعلومات

  // ألوان الحدود والفواصل (موحدة) - ألطف للعين
  static const Color border = Color(0xFFE4E6F0); // رمادي فاتح بلمسة زرقاء
  static const Color divider = Color(0xFFF0F1FA); // متناسق مع primaryPale

  // ألوان الظلال (موحدة) - معدلة للتناسق
  static const Color shadow =
      Color(0x0D404B8C); // ظلال خفيفة من لون primaryDark
  static const Color shadowDark = Color(0x14404B8C); // ظلال أعمق قليلًا

  // ألوان التفاعل (موحدة) - محسنة للاستجابة البصرية
  static const Color focusState = Color(0xFFE8EAFB); // حالة التركيز بلون هادئ
  static const Color disabledState = Color(0xFFE1E2ED); // حالة التعطيل متناسقة

  // ألوان وسائل التواصل الاجتماعي (موحدة)
  static const Color google = Color(0xFFEA4335);
  static const Color facebook = Color(0xFF1877F2);
  static const Color apple = Color(0xFF000000);

  // التدرجات الرئيسية (موحدة) - معدلة للمظهر العصري
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7E85D0), // primaryLight
      Color(0xFF5B63B7), // primary
    ],
  );

  // تدرجات إضافية للعناصر المختلفة - محسنة للتناسق
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF6C9E), // accent
      Color(0xFFE64B8C), // accent dark
    ],
  );

  // تعريف القيم المساعدة
  static const Color shimmerBase = Color(0xFFECEEF5);
  static const Color shimmerHighlight = Color(0xFFF8F9FF);
  static const Color mediumPurple =
      Color(0xFF8388C7); // متوسط بين primary و primaryLight
  static const Color shadowColor = Color(0x14404B8C);
  static const Color primaryExtraLight = Color(0xFFE8EAFB);

  // ألوان الوضع الليلي (الداكن) - معدلة للراحة البصرية
  // الألوان الأساسية (وضع داكن)
  static const Color darkPrimary =
      Color(0xFF6A75C9); // نسخة وضع داكن من primary
  static const Color darkPrimaryDark = Color(0xFF4F579F); // نسخة داكنة متناسقة
  static const Color darkPrimaryLight =
      Color(0xFF8A92D6); // نسخة خفيفة للوضع الداكن
  static const Color darkPrimaryPale = Color(0xFF242A45); // شاحب للوضع الداكن
  static const Color darkAccent = Color(0xFFF27FAA); // وردي متناسق للوضع الداكن

  // ألوان الخلفية (وضع داكن) - محسنة للراحة الليلية
  static const Color darkBackground =
      Color(0xFF121625); // خلفية داكنة بلمسة زرقاء
  static const Color darkSurface =
      Color(0xFF1A1F30); // خلفية البطاقات في الوضع الداكن
  static const Color darkSurfaceLight = Color(0xFF252C42); // خلفية ثانوية خفيفة

  // ألوان النصوص (وضع داكن) - محسنة للقراءة في الإضاءة المنخفضة
  static const Color darkTextPrimary = Color(0xFFE6E8F5); // نص أساسي واضح
  static const Color darkTextSecondary = Color(0xFFB0B5D0); // نص ثانوي واضح
  static const Color darkTextHint = Color(0xFF787E9E); // تلميحات واضحة

  // ألوان الحالة (وضع داكن) - متناسقة مع الوضع الداكن
  static const Color darkSuccess =
      Color(0xFF81C784); // أخضر للنجاح في الوضع الداكن
  static const Color darkWarning =
      Color(0xFFFFD54F); // تنبيه واضح في الوضع الداكن
  static const Color darkError = Color(0xFFE57373); // خطأ واضح في الوضع الداكن
  static const Color darkInfo =
      Color(0xFF64B5F6); // معلومات واضحة في الوضع الداكن

  // ألوان الحدود والفواصل (وضع داكن) - متناسقة مع ألوان الخلفية
  static const Color darkBorder =
      Color(0xFF303752); // حدود واضحة في الوضع الداكن
  static const Color darkDivider = Color(0xFF252C42); // فواصل متناسقة

  // ألوان الظلال (وضع داكن)
  static const Color darkShadow = Color(0x40121625); // ظلال مناسبة للوضع الداكن
  static const Color darkShadowDark = Color(0x80121625); // ظلال داكنة أكثر

  // ألوان التفاعل (وضع داكن)
  static const Color darkFocusState = Color(0xFF303752); // حالة تركيز واضحة
  static const Color darkDisabledState = Color(0xFF343B52); // حالة تعطيل واضحة

  // التدرجات الرئيسية (وضع داكن)
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8A92D6), // darkPrimaryLight
      Color(0xFF6A75C9), // darkPrimary
    ],
  );

  // تدرجات إضافية للعناصر المختلفة (وضع داكن)
  static const LinearGradient darkAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF27FAA), // darkAccent
      Color(0xFFE65A8C), // darkAccent dark
    ],
  );

  // ألوان إضافية للوضع الداكن
  static const Color darkShimmerBase = Color(0xFF242A45);
  static const Color darkShimmerHighlight = Color(0xFF303752);
  static const Color darkMediumPurple = Color(0xFF7981CF);
  static const Color darkShadowColor = Color(0x40121625);
  static const Color darkPrimaryExtraLight = Color(0xFF303752);

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
        100: Color(0xFF303752),
        200: Color(0xFF3F4876),
        300: Color(0xFF4F579F),
        400: Color(0xFF5A64B9),
        500: darkPrimary,
        600: Color(0xFF7981CF),
        700: darkPrimaryLight,
        800: Color(0xFF9BA2DF),
        900: Color(0xFFACB2EA),
      });
    } else {
      return MaterialColor(primary.value, {
        50: primaryPale,
        100: Color(0xFFE8EAFB),
        200: Color(0xFFD1D4F7),
        300: Color(0xFFAFB3EB),
        400: Color(0xFF8E93DF),
        500: primary,
        600: Color(0xFF4F579F),
        700: primaryDark,
        800: Color(0xFF36406F),
        900: Color(0xFF28304F),
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
