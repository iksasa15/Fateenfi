import 'package:flutter/material.dart';

class AppDimensions {
  // قيم الزوايا - تعديل القيم لتكون أكثر تناسقًا
  static const double smallRadius = 8.0; // للعناصر الصغيرة
  static const double mediumRadius = 12.0; // للبطاقات والأزرار
  static const double largeRadius = 16.0; // للعناصر الكبيرة
  static const double extraLargeRadius = 24.0; // للنوافذ المنبثقة
  static const double cardBorderRadius = 12.0; // لزوايا البطاقات
  static const double inputBorderRadius = 12.0; // لحقول الإدخال
  static const double toggleBarBorderRadius = 12.0; // لشريط التبديل
  static const double toggleButtonBorderRadius = 8.0; // لأزرار التبديل

  // ارتفاعات الأزرار - تعديل القيم لتناسب معايير التصميم الحديثة
  static const double buttonHeight = 52.0; // الارتفاع القياسي للأزرار
  static const double smallButtonHeight = 44.0; // ارتفاع الأزرار الصغيرة
  static const double extraSmallButtonHeight =
      40.0; // ارتفاع الأزرار الصغيرة جدًا
  static const double mediumButtonHeight = 48.0; // ارتفاع الأزرار المتوسطة
  static const double socialButtonSize = 48.0; // حجم أزرار التواصل الاجتماعي
  static const double smallSocialButtonSize = 40.0; // حجم أزرار التواصل الصغيرة

  // أبعاد حقول الإدخال - تعديل للراحة البصرية
  static const double inputFieldHeight = 52.0; // ارتفاع حقول الإدخال
  static const double smallInputFieldHeight =
      44.0; // ارتفاع حقول الإدخال الصغيرة
  static const double inputFieldPadding = 16.0; // حشو حقول الإدخال
  static const double smallInputFieldPadding = 12.0; // حشو حقول الإدخال الصغيرة

  // أحجام الأيقونات - محسنة لتكون متناسقة
  static const double iconSize = 24.0; // الحجم القياسي للأيقونات
  static const double smallIconSize = 20.0; // حجم الأيقونات الصغيرة
  static const double extraSmallIconSize = 16.0; // حجم الأيقونات الصغيرة جدًا
  static const double mediumIconSize = 22.0; // حجم الأيقونات المتوسطة
  static const double largeIconSize = 96.0; // حجم الأيقونات الكبيرة

  // قيم التباعد - مضبوطة لتحقيق تناسق أفضل
  static const double defaultSpacing = 16.0; // المسافة القياسية
  static const double smallSpacing = 8.0; // المسافة الصغيرة
  static const double largeSpacing = 24.0; // المسافة الكبيرة
  static const double extraLargeSpacing = 32.0; // المسافة الكبيرة جدًا
  static const double sectionPadding = 20.0; // حشو الأقسام

  // أحجام الخطوط - محسنة للوضوح وسهولة القراءة
  static const double titleFontSize = 24.0; // حجم العناوين
  static const double smallTitleFontSize = 20.0; // حجم العناوين الصغيرة
  static const double subtitleFontSize = 18.0; // حجم العناوين الفرعية
  static const double smallSubtitleFontSize =
      16.0; // حجم العناوين الفرعية الصغيرة
  static const double bodyFontSize = 16.0; // حجم النص الأساسي
  static const double smallBodyFontSize = 14.0; // حجم النص الصغير
  static const double buttonFontSize = 16.0; // حجم نص الأزرار
  static const double smallButtonFontSize = 14.0; // حجم نص الأزرار الصغيرة
  static const double labelFontSize = 14.0; // حجم التسميات
  static const double smallLabelFontSize = 12.0; // حجم التسميات الصغيرة

  // قيم الارتفاع - محسنة للظلال
  static const double defaultElevation = 2.0; // الارتفاع الافتراضي
  static const double cardElevation = 3.0; // ارتفاع البطاقات

  // مدة الحركات - محسنة للسلاسة
  static const Duration animationDuration =
      Duration(milliseconds: 250); // مدة الحركة القياسية

  static var cardHeightMedium;

  // طرق الأبعاد المتجاوبة - تم الحفاظ عليها كما هي

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

  static getWidth(BuildContext context, {required double percentage}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * (percentage / 100);
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
