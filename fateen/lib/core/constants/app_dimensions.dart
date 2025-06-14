import 'package:flutter/material.dart';

class AppDimensions {
  // قيم الزوايا
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;
  static const double cardBorderRadius = 12.0;
  static const double inputBorderRadius = 16.0;
  static const double toggleBarBorderRadius = 12.0;
  static const double toggleButtonBorderRadius = 8.0;

  // ارتفاعات الأزرار
  static const double buttonHeight = 56.0;
  static const double smallButtonHeight = 50.0;
  static const double extraSmallButtonHeight = 48.0;
  static const double mediumButtonHeight = 52.0;
  static const double socialButtonSize = 54.0;
  static const double smallSocialButtonSize = 46.0;

  // أبعاد حقول الإدخال
  static const double inputFieldHeight = 60.0;
  static const double smallInputFieldHeight = 56.0;
  static const double inputFieldPadding = 20.0;
  static const double smallInputFieldPadding = 16.0;

  // أحجام الأيقونات
  static const double iconSize = 24.0;
  static const double smallIconSize = 20.0;
  static const double extraSmallIconSize = 18.0;
  static const double mediumIconSize = 22.0;
  static const double largeIconSize = 100.0;

  // قيم التباعد
  static const double defaultSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  static const double sectionPadding = 20.0;

  // أحجام الخطوط
  static const double titleFontSize = 28.0;
  static const double smallTitleFontSize = 24.0;
  static const double subtitleFontSize = 16.0;
  static const double smallSubtitleFontSize = 14.0;
  static const double bodyFontSize = 15.0;
  static const double smallBodyFontSize = 14.0;
  static const double buttonFontSize = 16.0;
  static const double smallButtonFontSize = 15.0;
  static const double labelFontSize = 14.0;
  static const double smallLabelFontSize = 13.0;

  // قيم الارتفاع
  static const double defaultElevation = 2.0;
  static const double cardElevation = 4.0;

  // مدة الحركات
  static const Duration animationDuration = Duration(milliseconds: 300);

  // طرق الأبعاد المتجاوبة

  // طرق الزوايا
  static double getSmallRadius(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.021;
  }

  static double getMediumRadius(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.032;
  }

  static double getLargeRadius(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.043;
  }

  static double getExtraLargeRadius(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.064;
  }

  // طرق أحجام العناصر
  static double getButtonHeight(BuildContext context,
      {ButtonSize size = ButtonSize.regular, required bool small}) {
    final screenHeight = MediaQuery.of(context).size.height;

    switch (size) {
      case ButtonSize.extraSmall:
        return screenHeight * 0.06;
      case ButtonSize.small:
        return screenHeight * 0.0625;
      case ButtonSize.regular:
        return screenHeight * 0.07;
      case ButtonSize.medium:
        return screenHeight * 0.065;
    }
  }

  static double getSocialButtonSize(BuildContext context,
      {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return small ? screenWidth * 0.123 : screenWidth * 0.144;
  }

  static double getInputFieldHeight(BuildContext context,
      {bool small = false}) {
    final screenHeight = MediaQuery.of(context).size.height;
    return small ? screenHeight * 0.07 : screenHeight * 0.075;
  }

  static double getInputBorderRadius(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.043;
  }

  // طرق أحجام الأيقونات
  static double getIconSize(BuildContext context,
      {IconSize size = IconSize.regular, required bool small}) {
    final screenWidth = MediaQuery.of(context).size.width;

    switch (size) {
      case IconSize.extraSmall:
        return screenWidth * 0.048;
      case IconSize.small:
        return screenWidth * 0.053;
      case IconSize.regular:
        return screenWidth * 0.064;
      case IconSize.medium:
        return screenWidth * 0.059;
      case IconSize.large:
        return screenWidth * 0.267;
    }
  }

  // طرق حقول الإدخال
  static double getInputFieldPadding(BuildContext context,
      {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return small ? screenWidth * 0.043 : screenWidth * 0.053;
  }

  // طرق التباعد
  static double getSpacing(BuildContext context,
      {SpacingSize size = SpacingSize.medium}) {
    final screenWidth = MediaQuery.of(context).size.width;
    switch (size) {
      case SpacingSize.small:
        return screenWidth * 0.021;
      case SpacingSize.medium:
        return screenWidth * 0.043;
      case SpacingSize.large:
        return screenWidth * 0.064;
      case SpacingSize.extraLarge:
        return screenWidth * 0.085;
    }
  }

  // طرق أحجام الخطوط
  static double getTitleFontSize(BuildContext context, {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (isTablet) {
      return screenWidth * 0.047;
    }

    return small ? screenWidth * 0.064 : screenWidth * 0.075;
  }

  static double getSubtitleFontSize(BuildContext context,
      {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (isTablet) {
      return screenWidth * 0.027;
    }

    return small ? screenWidth * 0.037 : screenWidth * 0.043;
  }

  static double getBodyFontSize(BuildContext context, {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return small ? screenWidth * 0.037 : screenWidth * 0.04;
  }

  static double getButtonFontSize(BuildContext context, {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return small ? screenWidth * 0.04 : screenWidth * 0.043;
  }

  static double getLabelFontSize(BuildContext context, {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return small ? screenWidth * 0.035 : screenWidth * 0.037;
  }
}

// تعدادات لتسهيل اختيار الأحجام
enum SpacingSize {
  small,
  medium,
  large,
  extraLarge,
}

enum ButtonSize {
  extraSmall,
  small,
  medium,
  regular,
}

enum IconSize {
  extraSmall,
  small,
  medium,
  regular,
  large,
}
