import 'package:flutter/material.dart';

class ResponsiveHelper {
  final BuildContext context;
  late final Size _screenSize;
  late final double _screenWidth;
  late final double _screenHeight;
  late final Orientation _orientation;

  // فئات أحجام الشاشات
  static const double smallMobileBreakpoint = 360.0;
  static const double normalMobileBreakpoint = 480.0;
  static const double largeMobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  ResponsiveHelper(this.context) {
    _screenSize = MediaQuery.of(context).size;
    _screenWidth = _screenSize.width;
    _screenHeight = _screenSize.height;
    _orientation = MediaQuery.of(context).orientation;
  }

  // الحصول على حجم الشاشة
  Size get screenSize => _screenSize;
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  Orientation get orientation => _orientation;
  bool get isPortrait => _orientation == Orientation.portrait;
  bool get isLandscape => _orientation == Orientation.landscape;

  // دوال للتحقق من فئة الجهاز
  bool isSmallMobile(BuildContext context) =>
      _screenWidth < smallMobileBreakpoint;
  bool isNormalMobile(BuildContext context) =>
      _screenWidth >= smallMobileBreakpoint &&
      _screenWidth < normalMobileBreakpoint;
  bool isLargeMobile(BuildContext context) =>
      _screenWidth >= normalMobileBreakpoint &&
      _screenWidth < largeMobileBreakpoint;
  bool isTablet(BuildContext context) =>
      _screenWidth >= largeMobileBreakpoint && _screenWidth < tabletBreakpoint;
  bool isDesktop(BuildContext context) => _screenWidth >= tabletBreakpoint;

  // الحصول على القيمة المناسبة لكل فئة جهاز
  T getResponsiveValue<T>({
    required BuildContext context,
    required T mobileSmallValue,
    required T mobileNormalValue,
    required T mobileLargeValue,
    required T tabletValue,
    required T desktopValue,
  }) {
    if (isSmallMobile(context)) {
      return mobileSmallValue;
    } else if (isNormalMobile(context)) {
      return mobileNormalValue;
    } else if (isLargeMobile(context)) {
      return mobileLargeValue;
    } else if (isTablet(context)) {
      return tabletValue;
    } else {
      return desktopValue;
    }
  }

  // حساب حجم الخط المتجاوب
  double getResponsiveFontSize(
    BuildContext context, {
    required double smallSize,
    required double mediumSize,
    required double largeSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    if (isSmallMobile(context)) {
      return smallSize;
    } else if (isNormalMobile(context) || isLargeMobile(context)) {
      return mediumSize;
    } else if (isTablet(context)) {
      return tabletSize ?? largeSize;
    } else {
      return desktopSize ?? (tabletSize ?? largeSize) * 1.15;
    }
  }

  // حساب حجم الزر المتجاوب
  double getResponsiveButtonHeight(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobileSmallValue: _screenHeight * 0.065, // 6.5% من ارتفاع الشاشة
      mobileNormalValue: _screenHeight * 0.07, // 7% من ارتفاع الشاشة
      mobileLargeValue: _screenHeight * 0.075, // 7.5% من ارتفاع الشاشة
      tabletValue: _screenHeight * 0.08, // 8% من ارتفاع الشاشة
      desktopValue: 65.0, // قيمة ثابتة للديسكتوب
    );
  }

  // حساب عرض الزر المتجاوب
  double getResponsiveButtonWidth(BuildContext context,
      {bool isFullWidth = false}) {
    if (isFullWidth) {
      return double.infinity;
    }

    return getResponsiveValue(
      context: context,
      mobileSmallValue: _screenWidth * 0.8, // 80% من عرض الشاشة
      mobileNormalValue: _screenWidth * 0.7, // 70% من عرض الشاشة
      mobileLargeValue: _screenWidth * 0.6, // 60% من عرض الشاشة
      tabletValue: _screenWidth * 0.4, // 40% من عرض الشاشة
      desktopValue: 350.0, // قيمة ثابتة للديسكتوب
    );
  }

  // حساب نصف قطر الحواف المتجاوب
  double getResponsiveBorderRadius(BuildContext context,
      {BorderRadiusSize size = BorderRadiusSize.medium}) {
    // قيم أساسية لكل حجم
    final Map<BorderRadiusSize, double> baseValues = {
      BorderRadiusSize.small: 4.0,
      BorderRadiusSize.medium: 8.0,
      BorderRadiusSize.large: 16.0,
      BorderRadiusSize.extraLarge: 24.0,
    };

    // معامل التكبير لكل فئة جهاز
    final scaleFactor = getResponsiveValue<double>(
      context: context,
      mobileSmallValue: 1.0,
      mobileNormalValue: 1.1,
      mobileLargeValue: 1.2,
      tabletValue: 1.3,
      desktopValue: 1.5,
    );

    return baseValues[size]! * scaleFactor;
  }

  // حساب قيمة التباعد المتجاوب
  double getResponsiveSpacing(BuildContext context,
      {SpacingSize size = SpacingSize.medium}) {
    // قيم أساسية لكل حجم
    final Map<SpacingSize, double> baseValues = {
      SpacingSize.extraSmall: 4.0,
      SpacingSize.small: 8.0,
      SpacingSize.medium: 16.0,
      SpacingSize.large: 24.0,
      SpacingSize.extraLarge: 32.0,
    };

    // معامل التكبير لكل فئة جهاز
    final scaleFactor = getResponsiveValue<double>(
      context: context,
      mobileSmallValue: 1.0,
      mobileNormalValue: 1.1,
      mobileLargeValue: 1.2,
      tabletValue: 1.3,
      desktopValue: 1.5,
    );

    return baseValues[size]! * scaleFactor;
  }

  // حساب هوامش العرض والارتفاع المتجاوبة
  EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final horizontalPadding = getResponsiveValue<double>(
      context: context,
      mobileSmallValue: _screenWidth * 0.05, // 5% من عرض الشاشة
      mobileNormalValue: _screenWidth * 0.06, // 6% من عرض الشاشة
      mobileLargeValue: _screenWidth * 0.07, // 7% من عرض الشاشة
      tabletValue: _screenWidth * 0.08, // 8% من عرض الشاشة
      desktopValue: _screenWidth * 0.1, // 10% من عرض الشاشة
    );

    return EdgeInsets.symmetric(horizontal: horizontalPadding);
  }

  // إنشاء نسب متجاوبة للعناصر
  double getResponsiveRatio(BuildContext context, double percentage) {
    if (isPortrait) {
      return _screenWidth * percentage;
    } else {
      return _screenHeight * percentage;
    }
  }

  // حساب حجم الأيقونة المتجاوب
  double getResponsiveIconSize(BuildContext context,
      {IconSize size = IconSize.medium}) {
    // قيم أساسية لكل حجم
    final Map<IconSize, double> baseValues = {
      IconSize.small: 16.0,
      IconSize.medium: 24.0,
      IconSize.large: 32.0,
      IconSize.extraLarge: 48.0,
    };

    // معامل التكبير لكل فئة جهاز
    final scaleFactor = getResponsiveValue<double>(
      context: context,
      mobileSmallValue: 1.0,
      mobileNormalValue: 1.1,
      mobileLargeValue: 1.2,
      tabletValue: 1.3,
      desktopValue: 1.5,
    );

    return baseValues[size]! * scaleFactor;
  }

  // تطبيق حجم قائمة متجاوب
  int getResponsiveGridCount(BuildContext context) {
    return getResponsiveValue<int>(
      context: context,
      mobileSmallValue: 1,
      mobileNormalValue: 2,
      mobileLargeValue: 2,
      tabletValue: 3,
      desktopValue: 4,
    );
  }

  // حساب ارتفاع حقل الإدخال المتجاوب
  double getResponsiveInputHeight(BuildContext context) {
    return getResponsiveValue<double>(
      context: context,
      mobileSmallValue: 50.0,
      mobileNormalValue: 55.0,
      mobileLargeValue: 60.0,
      tabletValue: 65.0,
      desktopValue: 70.0,
    );
  }
}

// تعريف فئات أحجام نصف قطر الحواف
enum BorderRadiusSize { small, medium, large, extraLarge }

// تعريف فئات أحجام التباعد
enum SpacingSize { extraSmall, small, medium, large, extraLarge }

// تعريف فئات أحجام الأيقونات
enum IconSize { small, medium, large, extraLarge }
