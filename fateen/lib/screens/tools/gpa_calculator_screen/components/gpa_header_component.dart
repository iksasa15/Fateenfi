// components/gpa_header_component.dart

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
import '../constants/gpa_calculator_strings.dart';

class GPAHeaderComponent extends StatelessWidget {
  const GPAHeaderComponent({Key? key}) : super(key: key);

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
                      Icons.arrow_back, // سهم الرجوع
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

              // عنوان صفحة حاسبة المعدل (في المنتصف تماماً)
              Text(
                GPACalculatorStrings.title,
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
