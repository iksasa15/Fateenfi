// components/stats/progress_bar.dart

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart'; // Updated import
import '../../../../../core/constants/appColor.dart'; // Updated import

class ProgressBar extends StatelessWidget {
  final double value;
  final bool isDarkMode;

  const ProgressBar({
    Key? key,
    required this.value,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.smallSpacing,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius / 2),
        color: AppColors.getThemeColor(
          AppColors.primaryPale,
          AppColors.darkPrimaryPale,
          isDarkMode,
        ),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.smallRadius / 2),
            color: AppColors.getThemeColor(
              AppColors.primary,
              AppColors.darkPrimary,
              isDarkMode,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.getThemeColor(
                  AppColors.primary,
                  AppColors.darkPrimary,
                  isDarkMode,
                ).withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
