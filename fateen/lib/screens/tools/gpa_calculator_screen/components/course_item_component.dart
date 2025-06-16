// components/course_item_component.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
import '../constants/gpa_calculator_constants.dart';
import '../constants/gpa_calculator_strings.dart';
import '../../../../models/course_item.dart';

class CourseItemComponent extends StatelessWidget {
  final int index;
  final CourseItem course;
  final Function(int) onRemove;
  final Function(int, String) onGradeChanged;

  const CourseItemComponent({
    Key? key,
    required this.index,
    required this.course,
    required this.onRemove,
    required this.onGradeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.defaultSpacing,
          vertical: AppDimensions.smallSpacing),
      child: Row(
        children: [
          // اسم المقرر
          Expanded(
            flex: 6,
            child: Container(
              height: AppDimensions.inputFieldHeight,
              child: TextFormField(
                controller: course.nameController,
                decoration: InputDecoration(
                  hintText: GPACalculatorStrings.courseNameHint,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.smallSpacing,
                    vertical: AppDimensions.smallSpacing + 6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.inputBorderRadius),
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
                    borderRadius:
                        BorderRadius.circular(AppDimensions.inputBorderRadius),
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
                    borderRadius:
                        BorderRadius.circular(AppDimensions.inputBorderRadius),
                    borderSide: BorderSide(
                      color: AppColors.getThemeColor(
                        AppColors.primaryDark,
                        AppColors.darkPrimaryDark,
                        isDarkMode,
                      ),
                      width: 1.5,
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
                ),
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.smallBodyFontSize,
                  color: AppColors.getThemeColor(
                    AppColors.textPrimary,
                    AppColors.darkTextPrimary,
                    isDarkMode,
                  ),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.smallSpacing),

          // عدد الساعات
          Expanded(
            flex: 3,
            child: Container(
              height: AppDimensions.inputFieldHeight,
              child: TextFormField(
                controller: course.creditsController,
                decoration: InputDecoration(
                  hintText: GPACalculatorStrings.creditHoursHint,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.smallSpacing,
                    vertical: AppDimensions.smallSpacing + 6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.inputBorderRadius),
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
                    borderRadius:
                        BorderRadius.circular(AppDimensions.inputBorderRadius),
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
                    borderRadius:
                        BorderRadius.circular(AppDimensions.inputBorderRadius),
                    borderSide: BorderSide(
                      color: AppColors.getThemeColor(
                        AppColors.primaryDark,
                        AppColors.darkPrimaryDark,
                        isDarkMode,
                      ),
                      width: 1.5,
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
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GPACalculatorStrings.requiredField;
                  }
                  return null;
                },
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
          ),
          SizedBox(width: AppDimensions.smallSpacing),

          // التقدير
          Expanded(
            flex: 3,
            child: Container(
              height: AppDimensions.inputFieldHeight,
              decoration: BoxDecoration(
                color: AppColors.getThemeColor(
                  AppColors.surface,
                  AppColors.darkSurface,
                  isDarkMode,
                ),
                borderRadius:
                    BorderRadius.circular(AppDimensions.inputBorderRadius),
                border: Border.all(
                  color: AppColors.getThemeColor(
                    AppColors.primaryDark,
                    AppColors.darkPrimaryDark,
                    isDarkMode,
                  ).withOpacity(0.2),
                  width: 1.0,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: course.grade,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.getThemeColor(
                      AppColors.primaryLight,
                      AppColors.darkPrimaryLight,
                      isDarkMode,
                    ),
                    size: AppDimensions.smallIconSize,
                  ),
                  isExpanded: true,
                  style: TextStyle(
                    color: AppColors.getThemeColor(
                      AppColors.textPrimary,
                      AppColors.darkTextPrimary,
                      isDarkMode,
                    ),
                    fontSize: AppDimensions.smallBodyFontSize,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  alignment: Alignment.center,
                  dropdownColor: AppColors.getThemeColor(
                    AppColors.surface,
                    AppColors.darkSurface,
                    isDarkMode,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      onGradeChanged(index, newValue);
                    }
                  },
                  items: GPACalculatorConstants.gradePoints5.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      alignment: Alignment.center,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: GPACalculatorConstants.gradeColors[value] ??
                                AppColors.getThemeColor(
                                  AppColors.textPrimary,
                                  AppColors.darkTextPrimary,
                                  isDarkMode,
                                ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // زر الحذف
          SizedBox(
            width: 30,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.getThemeColor(
                    AppColors.accent,
                    AppColors.darkAccent,
                    isDarkMode,
                  ).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove,
                  color: AppColors.getThemeColor(
                    AppColors.accent,
                    AppColors.darkAccent,
                    isDarkMode,
                  ),
                  size: AppDimensions.extraSmallIconSize,
                ),
              ),
              onPressed: () => onRemove(index),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: AppDimensions.smallIconSize,
            ),
          ),
        ],
      ),
    );
  }
}
