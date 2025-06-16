// components/previous_gpa_component.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
import '../constants/gpa_calculator_strings.dart';

class PreviousGPAComponent extends StatelessWidget {
  final TextEditingController currentGpaController;
  final TextEditingController completedHoursController;

  const PreviousGPAComponent({
    Key? key,
    required this.currentGpaController,
    required this.completedHoursController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getThemeColor(
            AppColors.surface,
            AppColors.darkSurface,
            isDarkMode,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
          border: Border.all(
            color: AppColors.getThemeColor(
              AppColors.divider,
              AppColors.darkDivider,
              isDarkMode,
            ),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.getThemeColor(
                AppColors.shadow,
                AppColors.darkShadow,
                isDarkMode,
              ),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // رأس القسم
            Padding(
              padding: EdgeInsets.all(AppDimensions.defaultSpacing),
              child: Row(
                children: [
                  // أيقونة
                  Container(
                    width: 32,
                    height: 32,
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
                    child: Icon(
                      Icons.history_edu_rounded,
                      color: AppColors.getThemeColor(
                        AppColors.primaryLight,
                        AppColors.darkPrimaryLight,
                        isDarkMode,
                      ),
                      size: AppDimensions.extraSmallIconSize,
                    ),
                  ),
                  SizedBox(width: AppDimensions.smallSpacing),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        GPACalculatorStrings.previousGPA,
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
                      SizedBox(height: 2),
                      Text(
                        GPACalculatorStrings.previousGPASubtitle,
                        style: TextStyle(
                          fontSize: AppDimensions.smallLabelFontSize,
                          color: AppColors.getThemeColor(
                            AppColors.textSecondary,
                            AppColors.darkTextSecondary,
                            isDarkMode,
                          ),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // خط فاصل
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.getThemeColor(
                AppColors.divider,
                AppColors.darkDivider,
                isDarkMode,
              ),
            ),

            // حقول الإدخال
            Padding(
              padding: EdgeInsets.all(AppDimensions.defaultSpacing),
              child: Row(
                children: [
                  // حقل المعدل السابق
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: AppDimensions.smallSpacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            GPACalculatorStrings.cumulativeGPA,
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
                          SizedBox(height: AppDimensions.smallSpacing),
                          Container(
                            height: AppDimensions.inputFieldHeight,
                            child: TextFormField(
                              controller: currentGpaController,
                              decoration: InputDecoration(
                                hintText: '0.00',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.inputFieldPadding,
                                  vertical: AppDimensions.smallSpacing + 6,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.inputBorderRadius),
                                  borderSide: BorderSide(
                                    color: AppColors.getThemeColor(
                                      AppColors.primaryDark,
                                      AppColors.darkPrimaryDark,
                                      isDarkMode,
                                    ).withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.inputBorderRadius),
                                  borderSide: BorderSide(
                                    color: AppColors.getThemeColor(
                                      AppColors.primaryDark,
                                      AppColors.darkPrimaryDark,
                                      isDarkMode,
                                    ).withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.inputBorderRadius),
                                  borderSide: BorderSide(
                                    color: AppColors.getThemeColor(
                                      AppColors.primaryDark,
                                      AppColors.darkPrimaryDark,
                                      isDarkMode,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                prefixIcon: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: AppDimensions.smallSpacing),
                                  width: 32,
                                  height: 32,
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
                                        AppColors.primaryDark,
                                        AppColors.darkPrimaryDark,
                                        isDarkMode,
                                      ).withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.grade_outlined,
                                    color: AppColors.getThemeColor(
                                      AppColors.primaryLight,
                                      AppColors.darkPrimaryLight,
                                      isDarkMode,
                                    ),
                                    size: AppDimensions.extraSmallIconSize,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.getThemeColor(
                                  AppColors.surface,
                                  AppColors.darkSurface,
                                  isDarkMode,
                                ),
                                hintStyle: TextStyle(
                                  color: AppColors.getThemeColor(
                                    AppColors.textHint,
                                    AppColors.darkTextHint,
                                    isDarkMode,
                                  ),
                                  fontSize: AppDimensions.smallBodyFontSize,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                                errorBorder: InputBorder.none,
                                errorStyle:
                                    const TextStyle(height: 0, fontSize: 0),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              style: TextStyle(
                                fontFamily: 'SYMBIOAR+LT',
                                fontSize: AppDimensions.smallBodyFontSize,
                                color: AppColors.getThemeColor(
                                  AppColors.textPrimary,
                                  AppColors.darkTextPrimary,
                                  isDarkMode,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // حقل عدد الساعات المنجزة
                  Expanded(
                    child: Container(
                      margin:
                          EdgeInsets.only(right: AppDimensions.smallSpacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            GPACalculatorStrings.completedHours,
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
                          SizedBox(height: AppDimensions.smallSpacing),
                          Container(
                            height: AppDimensions.inputFieldHeight,
                            child: TextFormField(
                              controller: completedHoursController,
                              decoration: InputDecoration(
                                hintText: '0',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.inputFieldPadding,
                                  vertical: AppDimensions.smallSpacing + 6,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.inputBorderRadius),
                                  borderSide: BorderSide(
                                    color: AppColors.getThemeColor(
                                      AppColors.primaryDark,
                                      AppColors.darkPrimaryDark,
                                      isDarkMode,
                                    ).withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.inputBorderRadius),
                                  borderSide: BorderSide(
                                    color: AppColors.getThemeColor(
                                      AppColors.primaryDark,
                                      AppColors.darkPrimaryDark,
                                      isDarkMode,
                                    ).withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.inputBorderRadius),
                                  borderSide: BorderSide(
                                    color: AppColors.getThemeColor(
                                      AppColors.primaryDark,
                                      AppColors.darkPrimaryDark,
                                      isDarkMode,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                prefixIcon: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: AppDimensions.smallSpacing),
                                  width: 32,
                                  height: 32,
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
                                        AppColors.primaryDark,
                                        AppColors.darkPrimaryDark,
                                        isDarkMode,
                                      ).withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.access_time_rounded,
                                    color: AppColors.getThemeColor(
                                      AppColors.primaryLight,
                                      AppColors.darkPrimaryLight,
                                      isDarkMode,
                                    ),
                                    size: AppDimensions.extraSmallIconSize,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.getThemeColor(
                                  AppColors.surface,
                                  AppColors.darkSurface,
                                  isDarkMode,
                                ),
                                hintStyle: TextStyle(
                                  color: AppColors.getThemeColor(
                                    AppColors.textHint,
                                    AppColors.darkTextHint,
                                    isDarkMode,
                                  ),
                                  fontSize: AppDimensions.smallBodyFontSize,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                                errorBorder: InputBorder.none,
                                errorStyle:
                                    const TextStyle(height: 0, fontSize: 0),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: TextStyle(
                                fontFamily: 'SYMBIOAR+LT',
                                fontSize: AppDimensions.smallBodyFontSize,
                                color: AppColors.getThemeColor(
                                  AppColors.textPrimary,
                                  AppColors.darkTextPrimary,
                                  isDarkMode,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
