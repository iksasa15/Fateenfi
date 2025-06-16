// components/gpa_system_toggle.dart

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
import '../constants/gpa_calculator_strings.dart';
import '../controllers/gpa_calculator_controller.dart';

class GPASystemToggle extends StatelessWidget {
  final GPACalculatorController controller;

  const GPASystemToggle({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
                    Icons.calculate_outlined,
                    color: AppColors.getThemeColor(
                      AppColors.primaryLight,
                      AppColors.darkPrimaryLight,
                      isDarkMode,
                    ),
                    size: AppDimensions.extraSmallIconSize,
                  ),
                ),
                SizedBox(width: AppDimensions.smallSpacing),
                Text(
                  GPACalculatorStrings.gpaSystem,
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

          // أزرار التبديل بين الأنظمة
          Padding(
            padding: EdgeInsets.all(AppDimensions.defaultSpacing),
            child: Row(
              children: [
                Expanded(
                  child: _buildSystemButton(
                    context: context, // Corregido: usando argumento con nombre
                    label: GPACalculatorStrings.gpaSystem5,
                    isSelected: controller.isSystem5,
                    onTap: () => controller.toggleGPASystem(true),
                  ),
                ),
                SizedBox(width: AppDimensions.defaultSpacing),
                Expanded(
                  child: _buildSystemButton(
                    context: context, // Corregido: usando argumento con nombre
                    label: GPACalculatorStrings.gpaSystem4,
                    isSelected: !controller.isSystem5,
                    onTap: () => controller.toggleGPASystem(false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.smallSpacing + 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.getThemeColor(
                  AppColors.primaryDark,
                  AppColors.darkPrimaryDark,
                  isDarkMode,
                )
              : AppColors.getThemeColor(
                  AppColors.surface,
                  AppColors.darkSurface,
                  isDarkMode,
                ),
          borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
          border: Border.all(
            color: isSelected
                ? AppColors.getThemeColor(
                    AppColors.primaryDark,
                    AppColors.darkPrimaryDark,
                    isDarkMode,
                  )
                : AppColors.getThemeColor(
                    AppColors.divider,
                    AppColors.darkDivider,
                    isDarkMode,
                  ),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.getThemeColor(
                      AppColors.primaryDark,
                      AppColors.darkPrimaryDark,
                      isDarkMode,
                    ).withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.smallBodyFontSize,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : AppColors.getThemeColor(
                    AppColors.textPrimary,
                    AppColors.darkTextPrimary,
                    isDarkMode,
                  ),
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ),
    );
  }
}
