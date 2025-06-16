// components/result_dialog_component.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
import '../constants/gpa_calculator_strings.dart';
import '../controllers/gpa_calculator_controller.dart';

class ResultDialogComponent extends StatelessWidget {
  final double termGPA;
  final double cumulativeGPA;
  final double totalCredits;
  final double totalPoints;
  final GPACalculatorController controller;

  const ResultDialogComponent({
    Key? key,
    required this.termGPA,
    required this.cumulativeGPA,
    required this.totalCredits,
    required this.totalPoints,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // الحصول على نظام المعدل الحالي
    bool isSystem5 = controller.isSystem5;

    // الحد الأقصى للمعدل
    double maxGPA = isSystem5 ? 5.0 : 4.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: FadeIn(
        duration: const Duration(milliseconds: 300),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
          child: Container(
            color: AppColors.getThemeColor(
              AppColors.surface,
              AppColors.darkSurface,
              isDarkMode,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب
                Padding(
                  padding: EdgeInsets.only(
                    top: AppDimensions.smallSpacing,
                    bottom: AppDimensions.smallSpacing,
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.getThemeColor(
                          AppColors.border,
                          AppColors.darkBorder,
                          isDarkMode,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),

                // شريط العنوان
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصف الأول: زر الرجوع والعنوان
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.defaultSpacing),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // زر الرجوع
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.getThemeColor(
                                  AppColors.surface,
                                  AppColors.darkSurface,
                                  isDarkMode,
                                ),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.smallRadius),
                                border: Border.all(
                                  color: AppColors.getThemeColor(
                                    AppColors.border,
                                    AppColors.darkBorder,
                                    isDarkMode,
                                  ),
                                  width: 1.0,
                                ),
                              ),
                              child: Icon(
                                Icons.close,
                                color: AppColors.getThemeColor(
                                  AppColors.primaryDark,
                                  AppColors.darkPrimaryDark,
                                  isDarkMode,
                                ),
                                size: AppDimensions.extraSmallIconSize,
                              ),
                            ),
                          ),
                          // العنوان
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.defaultSpacing - 2,
                              vertical: AppDimensions.smallSpacing - 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getThemeColor(
                                AppColors.surface,
                                AppColors.darkSurface,
                                isDarkMode,
                              ),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.smallRadius),
                              border: Border.all(
                                color: AppColors.getThemeColor(
                                  AppColors.border,
                                  AppColors.darkBorder,
                                  isDarkMode,
                                ),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              GPACalculatorStrings.resultTitle,
                              style: TextStyle(
                                fontSize: AppDimensions.bodyFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getThemeColor(
                                  AppColors.primaryDark,
                                  AppColors.darkPrimaryDark,
                                  isDarkMode,
                                ),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                          // مساحة فارغة للمحاذاة
                          const SizedBox(width: 36),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.defaultSpacing),

                    // وصف مع أيقونة
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.defaultSpacing),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.smallSpacing,
                          vertical: AppDimensions.smallSpacing,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.getThemeColor(
                            AppColors.surface,
                            AppColors.darkSurface,
                            isDarkMode,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.smallRadius),
                          border: Border.all(
                            color: AppColors.getThemeColor(
                              AppColors.primaryDark,
                              AppColors.darkPrimaryDark,
                              isDarkMode,
                            ).withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.getThemeColor(
                                AppColors.primaryDark,
                                AppColors.darkPrimaryDark,
                                isDarkMode,
                              ),
                              size: AppDimensions.extraSmallIconSize,
                            ),
                            SizedBox(width: AppDimensions.smallSpacing),
                            Expanded(
                              child: Text(
                                "تم حساب المعدل بنجاح وفقًا للمعلومات المدخلة (نظام $maxGPA)",
                                style: TextStyle(
                                  fontSize: AppDimensions.smallLabelFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.getThemeColor(
                                    AppColors.textPrimary,
                                    AppColors.darkTextPrimary,
                                    isDarkMode,
                                  ),
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.defaultSpacing),

                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.getThemeColor(
                        AppColors.divider,
                        AppColors.darkDivider,
                        isDarkMode,
                      ),
                    ),
                  ],
                ),

                // المحتوى
                Padding(
                  padding: EdgeInsets.all(AppDimensions.largeSpacing),
                  child: Column(
                    children: [
                      // معدلات الفصل والتراكمي
                      Row(
                        children: [
                          // معدل الفصل
                          Expanded(
                            child: _buildGPACircle(
                              context,
                              termGPA,
                              GPACalculatorStrings.termGPA,
                              controller.getGPAColor(termGPA),
                              maxGPA,
                            ),
                          ),

                          // المعدل التراكمي
                          Expanded(
                            child: _buildGPACircle(
                              context,
                              cumulativeGPA,
                              GPACalculatorStrings.cumulativeGPAResult,
                              controller.getGPAColor(cumulativeGPA),
                              maxGPA,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppDimensions.largeSpacing),

                      // تفاصيل إضافية
                      Container(
                        padding: EdgeInsets.all(AppDimensions.defaultSpacing),
                        decoration: BoxDecoration(
                          color: AppColors.getThemeColor(
                            AppColors.primaryPale,
                            AppColors.darkPrimaryPale,
                            isDarkMode,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.mediumRadius),
                          border: Border.all(
                            color: AppColors.getThemeColor(
                              AppColors.divider,
                              AppColors.darkDivider,
                              isDarkMode,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildResultRow(
                              context,
                              GPACalculatorStrings.registeredHours,
                              '${totalCredits.toStringAsFixed(0)}',
                            ),
                            Divider(
                              height: AppDimensions.defaultSpacing,
                              color: AppColors.getThemeColor(
                                AppColors.border,
                                AppColors.darkBorder,
                                isDarkMode,
                              ).withOpacity(0.3),
                            ),
                            _buildResultRow(
                              context,
                              GPACalculatorStrings.earnedPoints,
                              '${totalPoints.toStringAsFixed(2)}',
                            ),
                            Divider(
                              height: AppDimensions.defaultSpacing,
                              color: AppColors.getThemeColor(
                                AppColors.border,
                                AppColors.darkBorder,
                                isDarkMode,
                              ).withOpacity(0.3),
                            ),
                            _buildResultRow(
                              context,
                              GPACalculatorStrings.gradeLabel,
                              controller.getGPAGrade(cumulativeGPA),
                              color: controller.getGPAColor(cumulativeGPA),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppDimensions.largeSpacing),

                      // زر موافق
                      _buildPrimaryButton(
                        context: context,
                        text: GPACalculatorStrings.ok,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء دائرة عرض المعدل
  Widget _buildGPACircle(BuildContext context, double gpa, String label,
      Color color, double maxGPA) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // للتأكد من عدم تجاوز الحد الأقصى للمعدل في العرض
    double displayGPA = gpa > maxGPA ? maxGPA : gpa;

    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              displayGPA.toStringAsFixed(2),
              style: TextStyle(
                fontSize: AppDimensions.smallTitleFontSize,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.smallSpacing),
        Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.smallBodyFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.getThemeColor(
              AppColors.textPrimary,
              AppColors.darkTextPrimary,
              isDarkMode,
            ),
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  // بناء صف في نتائج الحساب
  Widget _buildResultRow(BuildContext context, String label, String value,
      {Color? color}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.smallBodyFontSize,
            color: AppColors.getThemeColor(
              AppColors.textSecondary,
              AppColors.darkTextSecondary,
              isDarkMode,
            ),
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppDimensions.smallBodyFontSize,
            fontWeight: FontWeight.bold,
            color: color ??
                AppColors.getThemeColor(
                  AppColors.textPrimary,
                  AppColors.darkTextPrimary,
                  isDarkMode,
                ),
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  // بناء زر رئيسي بتصميم محسّن
  Widget _buildPrimaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.getThemeColor(
              AppColors.primaryDark,
              AppColors.darkPrimaryDark,
              isDarkMode,
            ).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getThemeColor(
            AppColors.primaryDark,
            AppColors.darkPrimaryDark,
            isDarkMode,
          ),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
          ),
          padding:
              EdgeInsets.symmetric(horizontal: AppDimensions.defaultSpacing),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.bodyFontSize,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ),
    );
  }
}
