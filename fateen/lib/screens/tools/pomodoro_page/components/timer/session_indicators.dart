import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
import '../../controllers/pomodoro_controller.dart';

class SessionIndicators extends StatelessWidget {
  final PomodoroController controller;

  const SessionIndicators({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // اللون حسب الوضع الحالي
    final progressColor = controller.isBreakTime
        ? (controller.isLongBreak
            ? AppColors.getThemeColor(
                AppColors.success, AppColors.darkSuccess, isDarkMode)
            : AppColors.getThemeColor(
                AppColors.primary, AppColors.darkPrimary, isDarkMode))
        : AppColors.getThemeColor(
            AppColors.accent, AppColors.darkAccent, isDarkMode);

    return SizedBox(
      height: AppDimensions.smallIconSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(controller.sessionsUntilLongBreak, (index) {
          final isActive = index <
              (controller.completedSessions %
                  controller.sessionsUntilLongBreak);
          final isCurrent = index ==
              (controller.completedSessions %
                  controller.sessionsUntilLongBreak);

          return Container(
            width: AppDimensions.extraSmallIconSize - 2,
            height: AppDimensions.extraSmallIconSize - 2,
            margin: EdgeInsets.symmetric(
                horizontal: AppDimensions.smallSpacing / 2),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.getThemeColor(
                      AppColors.accent, AppColors.darkAccent, isDarkMode)
                  : (isCurrent
                      ? progressColor.withOpacity(0.5)
                      : AppColors.getThemeColor(
                          AppColors.border,
                          AppColors.darkBorder,
                          isDarkMode,
                        ).withOpacity(0.2)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? progressColor : Colors.transparent,
                width: 2,
              ),
            ),
          );
        }),
      ),
    );
  }
}
