// components/stats/stat_block.dart

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart'; // Updated import
import '../../../../../core/constants/appColor.dart'; // Updated import

class StatBlock extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDarkMode;

  const StatBlock({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تقليل الهوامش والحشو بصورة أكبر لتجنب أي تجاوز للحدود
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = AppDimensions.defaultSpacing * 2;
    final edgePadding = AppDimensions.smallSpacing * 2;
    final internalSpacing = AppDimensions.smallSpacing; // المسافة بين البلوكات

    // إعادة حساب عرض البلوك مع هامش أمان أكبر
    final availableWidth =
        screenWidth - cardPadding - edgePadding - (internalSpacing * 2);
    final width = (availableWidth / 3) - 4.0; // هامش أمان إضافي

    return Container(
      width: width,
      height: 80, // حفظ الارتفاع للتناسب مع التصميم
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.smallSpacing / 2,
        horizontal: AppDimensions.smallSpacing / 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.getThemeColor(
          AppColors.surface,
          AppColors.darkSurface,
          isDarkMode,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius + 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.getThemeColor(
              AppColors.shadow,
              AppColors.darkShadow,
              isDarkMode,
            ),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: AppColors.getThemeColor(
            AppColors.border,
            AppColors.darkBorder,
            isDarkMode,
          ),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة البلوك
          Container(
            width: AppDimensions.iconSize + 4,
            height: AppDimensions.iconSize + 4,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppDimensions.extraSmallIconSize,
            ),
          ),
          SizedBox(height: AppDimensions.smallSpacing / 3),

          // قيمة الإحصائية
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppDimensions.smallBodyFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.getThemeColor(
                  AppColors.textPrimary,
                  AppColors.darkTextPrimary,
                  isDarkMode,
                ),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          SizedBox(height: AppDimensions.smallSpacing / 4),

          // عنوان الإحصائية
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: AppDimensions.smallLabelFontSize,
                color: AppColors.getThemeColor(
                  AppColors.textSecondary,
                  AppColors.darkTextSecondary,
                  isDarkMode,
                ),
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
