// components/stats/stats_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart'; // Updated import
import '../../../../../core/constants/appColor.dart'; // Updated import
import '../../constants/pomodoro_strings.dart';
import '../../controllers/pomodoro_controller.dart';
import 'stat_block.dart';
import 'progress_bar.dart';

class StatsCard extends StatelessWidget {
  final PomodoroController controller;
  final bool isDarkMode;

  const StatsCard({
    Key? key,
    required this.controller,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getThemeColor(
      AppColors.textPrimary,
      AppColors.darkTextPrimary,
      isDarkMode,
    );

    final subTextColor = AppColors.getThemeColor(
      AppColors.textSecondary,
      AppColors.darkTextSecondary,
      isDarkMode,
    );

    // حساب الإحصائيات
    final totalSessionMinutes =
        controller.completedSessions * controller.sessionDuration;
    final longBreaks =
        controller.completedSessions ~/ controller.sessionsUntilLongBreak;
    final shortBreaks = controller.completedSessions - longBreaks;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.smallSpacing,
        vertical: AppDimensions.smallSpacing +
            6, // تعديل طفيف للتناسب مع التصميم السابق
      ),
      decoration: BoxDecoration(
        color: AppColors.getThemeColor(
          AppColors.surface,
          AppColors.darkSurface,
          isDarkMode,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.getThemeColor(
              AppColors.shadowColor,
              AppColors.darkShadowColor,
              isDarkMode,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.getThemeColor(
            AppColors.primaryLight,
            AppColors.darkPrimaryLight,
            isDarkMode,
          ),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.smallSpacing),
                decoration: BoxDecoration(
                  color: AppColors.getThemeColor(
                    AppColors.primaryPale,
                    AppColors.darkPrimaryPale,
                    isDarkMode,
                  ),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: textColor,
                  size: AppDimensions.extraSmallIconSize,
                ),
              ),
              SizedBox(width: AppDimensions.smallSpacing),
              Text(
                PomodoroStrings.statsTitle,
                style: TextStyle(
                  fontSize: AppDimensions.smallBodyFontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.smallSpacing),

          // استخدام Row مع عرض مدروس واستخدام mainAxisAlignment
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatBlock(
                title: PomodoroStrings.statsLongBreaks,
                value: '$longBreaks',
                icon: Icons.weekend,
                color: AppColors.success,
                isDarkMode: isDarkMode,
              ),
              SizedBox(width: AppDimensions.smallSpacing / 2),
              StatBlock(
                title: PomodoroStrings.statsShortBreaks,
                value: '$shortBreaks',
                icon: Icons.coffee,
                color: AppColors.primary,
                isDarkMode: isDarkMode,
              ),
              SizedBox(width: AppDimensions.smallSpacing / 2),
              StatBlock(
                title: PomodoroStrings.statsFocusTime,
                value: '$totalSessionMinutes د',
                icon: Icons.timer,
                color: AppColors.accent,
                isDarkMode: isDarkMode,
              ),
            ],
          ),

          // تقدم الدورة الحالية
          if (controller.completedSessions > 0) ...[
            SizedBox(height: AppDimensions.smallSpacing + 6),
            Container(
              padding: EdgeInsets.all(AppDimensions.smallSpacing),
              decoration: BoxDecoration(
                color: AppColors.getThemeColor(
                  AppColors.surfaceLight,
                  AppColors.darkSurfaceLight,
                  isDarkMode,
                ),
                borderRadius:
                    BorderRadius.circular(AppDimensions.smallRadius + 2),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PomodoroStrings.statsCurrentProgress,
                    style: TextStyle(
                      fontSize: AppDimensions.smallLabelFontSize,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: AppDimensions.smallSpacing / 2),

                  // شريط التقدم
                  ProgressBar(
                    value: (controller.completedSessions %
                            controller.sessionsUntilLongBreak) /
                        controller.sessionsUntilLongBreak,
                    isDarkMode: isDarkMode,
                  ),

                  SizedBox(height: AppDimensions.smallSpacing / 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        '${PomodoroStrings.statsCompletedLabel} ${controller.completedSessions % controller.sessionsUntilLongBreak} ${PomodoroStrings.statsFromLabel} ${controller.sessionsUntilLongBreak} ${PomodoroStrings.statsSessionsLabel}',
                        style: TextStyle(
                          fontSize: AppDimensions.smallLabelFontSize -
                              3, // خفض حجم الخط قليلاً للتناسب
                          color: subTextColor,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
