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

  static var shimmerBase;

  static var shimmerHighlight;

  static var mediumPurple;

  static var shadowColor;

  static var primaryExtraLight;

  // الحصول على مجموعة ألوان ماتيريال من اللون الرئيسي
  static MaterialColor getMaterialPrimary() {
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
