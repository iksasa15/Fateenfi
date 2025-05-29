import 'package:flutter/material.dart';

/// مساعد للتجاوب مع مختلف أحجام الشاشات
/// يوفر طرقًا سهلة للتحقق من حجم الشاشة وضبط القيم المناسبة
class ResponsiveHelper {
  /// قيم ثابتة لنقاط التوقف عند أحجام مختلفة
  static const double mobileSmallBreakpoint = 320.0;
  static const double mobileNormalBreakpoint = 360.0;
  static const double mobileLargeBreakpoint = 480.0;
  static const double tabletBreakpoint = 600.0;
  static const double largeTabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 900.0;

  /// التحقق ما إذا كان الجهاز هاتف صغير (أقل من 320)
  static bool isTinyMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileSmallBreakpoint;
  }

  /// التحقق ما إذا كان الجهاز هاتف صغير (320-360)
  static bool isSmallMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileSmallBreakpoint && width < mobileNormalBreakpoint;
  }

  /// التحقق ما إذا كان الجهاز هاتف عادي (360-480)
  static bool isNormalMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileNormalBreakpoint && width < mobileLargeBreakpoint;
  }

  /// التحقق ما إذا كان الجهاز هاتف كبير (480-600)
  static bool isLargeMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileLargeBreakpoint && width < tabletBreakpoint;
  }

  /// التحقق ما إذا كان الجهاز هاتف (أقل من 600)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  /// التحقق ما إذا كان الجهاز جهاز لوحي (600-900)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  /// التحقق ما إذا كان الجهاز جهاز لوحي صغير (600-768)
  static bool isSmallTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < largeTabletBreakpoint;
  }

  /// التحقق ما إذا كان الجهاز جهاز لوحي كبير (768-900)
  static bool isLargeTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= largeTabletBreakpoint && width < desktopBreakpoint;
  }

  /// التحقق ما إذا كان الجهاز حاسوب مكتبي (أكبر من 900)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// الحصول على وضع التوجيه الحالي (أفقي/عمودي)
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// التحقق ما إذا كان التوجيه أفقيًا
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// التحقق ما إذا كان التوجيه عموديًا
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// الحصول على حجم الخط المناسب حسب حجم الشاشة
  static double getResponsiveFontSize(
    BuildContext context, {
    required double smallSize,
    required double mediumSize,
    required double largeSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < mobileNormalBreakpoint) {
      return smallSize;
    } else if (screenWidth < tabletBreakpoint) {
      return mediumSize;
    } else {
      return largeSize;
    }
  }

  /// الحصول على الهوامش المناسبة حسب حجم الشاشة
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < mobileNormalBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (screenWidth < tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    } else if (screenWidth < desktopBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else {
      // نسبة مئوية من عرض الشاشة للشاشات الكبيرة
      final horizontalPadding = screenWidth * 0.08; // 8% من عرض الشاشة
      return EdgeInsets.symmetric(horizontal: horizontalPadding);
    }
  }

  /// الحصول على قيمة متجاوبة بناءً على حجم الشاشة
  static double getResponsiveValue(
    BuildContext context, {
    required double mobileSmallValue,
    required double mobileNormalValue,
    required double mobileLargeValue,
    required double tabletValue,
    required double desktopValue,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < mobileSmallBreakpoint) {
      return mobileSmallValue;
    } else if (screenWidth < mobileNormalBreakpoint) {
      return mobileNormalValue;
    } else if (screenWidth < tabletBreakpoint) {
      return mobileLargeValue;
    } else if (screenWidth < desktopBreakpoint) {
      return tabletValue;
    } else {
      return desktopValue;
    }
  }

  /// الحصول على حجم أيقونة متجاوب بناءً على حجم الشاشة
  static double getResponsiveIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < mobileNormalBreakpoint) {
      return 18.0;
    } else if (screenWidth < tabletBreakpoint) {
      return 22.0;
    } else {
      return 24.0;
    }
  }

  /// الحصول على ارتفاع زر متجاوب بناءً على حجم الشاشة
  static double getResponsiveButtonHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < mobileNormalBreakpoint) {
      return 48.0;
    } else if (screenWidth < tabletBreakpoint) {
      return 52.0;
    } else {
      return 56.0;
    }
  }

  /// الحصول على نصف قطر حواف متجاوب بناءً على حجم الشاشة
  static double getResponsiveBorderRadius(
    BuildContext context, {
    required double smallValue,
    required double normalValue,
    required double largeValue,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < mobileNormalBreakpoint) {
      return smallValue;
    } else if (screenWidth < tabletBreakpoint) {
      return normalValue;
    } else {
      return largeValue;
    }
  }
}
