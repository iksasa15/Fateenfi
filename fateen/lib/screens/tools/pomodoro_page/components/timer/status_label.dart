import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
import '../../controllers/pomodoro_controller.dart';

class StatusLabel extends StatelessWidget {
  final PomodoroController controller;
  final bool isDarkMode;

  const StatusLabel({
    Key? key,
    required this.controller,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // اللون حسب الوضع الحالي
    final progressColor = controller.isBreakTime
        ? (controller.isLongBreak
            ? AppColors.getThemeColor(
                AppColors.success, AppColors.darkSuccess, isDarkMode)
            : AppColors.getThemeColor(
                AppColors.primary, AppColors.darkPrimary, isDarkMode))
        : AppColors.getThemeColor(
            AppColors.accent, AppColors.darkAccent, isDarkMode);

    // الأيقونة حسب نوع المؤقت
    IconData icon;
    if (controller.isBreakTime) {
      icon = controller.isLongBreak ? Icons.weekend : Icons.free_breakfast;
    } else {
      icon = Icons.psychology;
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.defaultSpacing,
            vertical: AppDimensions.smallSpacing,
          ),
          decoration: BoxDecoration(
            color: _getStatusBackgroundColor(isDarkMode, progressColor),
            borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.getThemeColor(
                  AppColors.shadow,
                  AppColors.darkShadow,
                  isDarkMode,
                ),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: progressColor,
                size: AppDimensions.smallIconSize,
              ),
              SizedBox(width: AppDimensions.smallSpacing),
              Text(
                controller.statusMessage,
                style: TextStyle(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.bodyFontSize,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.smallSpacing + 4),

        // معلومات الجلسة القادمة
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.defaultSpacing,
            vertical: AppDimensions.smallSpacing,
          ),
          decoration: BoxDecoration(
            color: AppColors.getThemeColor(
              AppColors.surfaceLight,
              AppColors.darkSurfaceLight,
              isDarkMode,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
          ),
          child: Text(
            controller.nextSessionInfo,
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
        ),
      ],
    );
  }

  // الحصول على لون خلفية حالة المؤقت
  Color _getStatusBackgroundColor(bool isDarkMode, Color progressColor) {
    if (isDarkMode) {
      return progressColor.withOpacity(0.2);
    } else {
      if (controller.isBreakTime) {
        return controller.isLongBreak
            ? AppColors.success.withOpacity(0.1)
            : AppColors.primaryPale;
      } else {
        return AppColors.accent.withOpacity(0.1);
      }
    }
  }
}
