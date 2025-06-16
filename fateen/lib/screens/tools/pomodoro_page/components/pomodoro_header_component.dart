// components/pomodoro_header_component.dart

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
import '../constants/pomodoro_strings.dart';

class PomodoroHeaderComponent extends StatelessWidget {
  final Function() onSettingsPressed;

  const PomodoroHeaderComponent({
    Key? key,
    required this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppDimensions.sectionPadding),
          color: AppColors.getThemeColor(
            AppColors.surface,
            AppColors.darkSurface,
            isDarkMode,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // زر الإعدادات في الجهة اليسرى
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: onSettingsPressed,
                  child: Container(
                    width: AppDimensions.socialButtonSize,
                    height: AppDimensions.socialButtonSize,
                    decoration: BoxDecoration(
                      color: AppColors.getThemeColor(
                        AppColors.primaryPale,
                        AppColors.darkPrimaryPale,
                        isDarkMode,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.mediumRadius),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: AppColors.getThemeColor(
                        AppColors.primaryDark,
                        AppColors.darkPrimaryDark,
                        isDarkMode,
                      ),
                      size: AppDimensions.smallIconSize,
                    ),
                  ),
                ),
              ),

              // زر الرجوع في الجهة اليمنى
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: AppDimensions.socialButtonSize,
                    height: AppDimensions.socialButtonSize,
                    decoration: BoxDecoration(
                      color: AppColors.getThemeColor(
                        AppColors.primaryPale,
                        AppColors.darkPrimaryPale,
                        isDarkMode,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.mediumRadius),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.getThemeColor(
                        AppColors.primaryDark,
                        AppColors.darkPrimaryDark,
                        isDarkMode,
                      ),
                      size: AppDimensions.smallIconSize,
                    ),
                  ),
                ),
              ),

              // عنوان صفحة وقت المذاكرة (في المنتصف تماماً)
              Text(
                PomodoroStrings.appTitle,
                style: TextStyle(
                  fontSize: AppDimensions.subtitleFontSize,
                  fontWeight: FontWeight.bold,
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
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.getThemeColor(
            AppColors.divider,
            AppColors.darkDivider,
            isDarkMode,
          ),
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
