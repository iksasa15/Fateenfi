import 'package:flutter/material.dart';

class LoginDimensions {
  // قيم الزوايا الثابتة
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // أحجام العناصر الثابتة
  static const double defaultButtonHeight = 56.0;
  static const double smallButtonHeight = 50.0;
  static const double socialButtonSize = 54.0;
  static const double smallSocialButtonSize = 46.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 20.0;
  static const double inputFieldPadding = 20.0;
  static const double smallInputFieldPadding = 16.0;

  // قيم التباعد الثابتة
  static const double defaultSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // أحجام الخطوط الثابتة
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

  // قيم الحواف والظلال الثابتة
  static const double defaultElevation = 2.0;
  static const double cardElevation = 4.0;

  // طرق دعم MediaQuery - للتحجيم النسبي

  // زوايا متجاوبة
  static double getSmallRadius(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.021; // ~8.0 على شاشة 375 بكسل
  }

  static double getMediumRadius(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.032; // ~12.0 على شاشة 375 بكسل
  }

  static double getLargeRadius(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.043; // ~16.0 على شاشة 375 بكسل
  }

  static double getExtraLargeRadius(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.064; // ~24.0 على شاشة 375 بكسل
  }

  // أحجام العناصر المتجاوبة
  static double getButtonHeight(BuildContext context, {bool small = false}) {
    final screenHeight = MediaQuery.of(context).size.height;
    return small
        ? screenHeight * 0.062 // ~50.0 على شاشة 800 بكسل
        : screenHeight * 0.07; // ~56.0 على شاشة 800 بكسل
  }

  static double getSocialButtonSize(BuildContext context,
      {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return small
        ? screenWidth * 0.123 // ~46.0 على شاشة 375 بكسل
        : screenWidth * 0.144; // ~54.0 على شاشة 375 بكسل
  }

  // إضافة طريقة للحصول على حجم الأيقونة
  static double getIconSize(BuildContext context, {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return small
        ? screenWidth * 0.053 // ~20.0 على شاشة 375 بكسل
        : screenWidth * 0.064; // ~24.0 على شاشة 375 بكسل
  }

  // إضافة طريقة للحصول على تباعد حقل الإدخال
  static double getInputFieldPadding(BuildContext context,
      {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return small
        ? screenWidth * 0.043 // ~16.0 على شاشة 375 بكسل
        : screenWidth * 0.053; // ~20.0 على شاشة 375 بكسل
  }

  // قيم التباعد المتجاوبة
  static double getSpacing(BuildContext context,
      {SpacingSize size = SpacingSize.medium}) {
    final screenWidth = MediaQuery.of(context).size.width;
    switch (size) {
      case SpacingSize.small:
        return screenWidth * 0.021; // ~8.0 على شاشة 375 بكسل
      case SpacingSize.medium:
        return screenWidth * 0.043; // ~16.0 على شاشة 375 بكسل
      case SpacingSize.large:
        return screenWidth * 0.064; // ~24.0 على شاشة 375 بكسل
      case SpacingSize.extraLarge:
        return screenWidth * 0.085; // ~32.0 على شاشة 375 بكسل
    }
  }

  // أحجام الخطوط المتجاوبة
  static double getTitleFontSize(BuildContext context, {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (isTablet) {
      return screenWidth * 0.047; // ~28.0 أكبر قليلاً على الأجهزة اللوحية
    }

    return small
        ? screenWidth * 0.064 // ~24.0 على شاشة 375 بكسل
        : screenWidth * 0.075; // ~28.0 على شاشة 375 بكسل
  }

  static double getSubtitleFontSize(BuildContext context,
      {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (isTablet) {
      return screenWidth * 0.027; // ~16.0 أكبر قليلاً على الأجهزة اللوحية
    }

    return small
        ? screenWidth * 0.037 // ~14.0 على شاشة 375 بكسل
        : screenWidth * 0.043; // ~16.0 على شاشة 375 بكسل
  }

  static double getBodyFontSize(BuildContext context, {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return small
        ? screenWidth * 0.037 // ~14.0 على شاشة 375 بكسل
        : screenWidth * 0.04; // ~15.0 على شاشة 375 بكسل
  }

  static double getButtonFontSize(BuildContext context, {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return small
        ? screenWidth * 0.04 // ~15.0 على شاشة 375 بكسل
        : screenWidth * 0.043; // ~16.0 على شاشة 375 بكسل
  }

  // إضافة طريقة للحصول على حجم النص للعناوين الفرعية
  static double getLabelFontSize(BuildContext context, {bool small = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return small
        ? screenWidth * 0.035 // ~13.0 على شاشة 375 بكسل
        : screenWidth * 0.037; // ~14.0 على شاشة 375 بكسل
  }
}

// تعداد لتسهيل تحديد حجم التباعد
enum SpacingSize {
  small,
  medium,
  large,
  extraLarge,
}
