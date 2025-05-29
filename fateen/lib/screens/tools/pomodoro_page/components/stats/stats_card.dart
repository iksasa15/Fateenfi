// components/stats/stats_card.dart

import 'package:flutter/material.dart';
import '../../constants/pomodoro_colors.dart';
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
    final textColor = PomodoroColors.kDarkPurple;
    final subTextColor = Colors.grey[600];

    // حساب الإحصائيات
    final totalSessionMinutes =
        controller.completedSessions * controller.sessionDuration;
    final longBreaks =
        controller.completedSessions ~/ controller.sessionsUntilLongBreak;
    final shortBreaks = controller.completedSessions - longBreaks;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 14), // تقليل الحشو الداخلي أكثر
      decoration: BoxDecoration(
        color: PomodoroColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: PomodoroColors.kLightPurple,
          width: 1, // تقليل عرض الحدود
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PomodoroColors.kLightPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: textColor,
                  size: 16, // تصغير الأيقونة أكثر
                ),
              ),
              const SizedBox(width: 8),
              Text(
                PomodoroStrings.statsTitle,
                style: TextStyle(
                  fontSize: 14, // تقليل حجم الخط أكثر
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // استخدام Row مع عرض مدروس واستخدام mainAxisAlignment
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatBlock(
                title: PomodoroStrings.statsLongBreaks,
                value: '$longBreaks',
                icon: Icons.weekend,
                color: PomodoroColors.kGreenColor,
                isDarkMode: isDarkMode,
              ),
              SizedBox(width: 5), // مسافة صغيرة محددة
              StatBlock(
                title: PomodoroStrings.statsShortBreaks,
                value: '$shortBreaks',
                icon: Icons.coffee,
                color: PomodoroColors.kDarkPurple,
                isDarkMode: isDarkMode,
              ),
              SizedBox(width: 5), // مسافة صغيرة محددة
              StatBlock(
                title: PomodoroStrings.statsFocusTime,
                value: '$totalSessionMinutes د',
                icon: Icons.timer,
                color: PomodoroColors.kAccentColor,
                isDarkMode: isDarkMode,
              ),
            ],
          ),

          // تقدم الدورة الحالية
          if (controller.completedSessions > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10), // تقليل الحشو أكثر
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PomodoroStrings.statsCurrentProgress,
                    style: TextStyle(
                      fontSize: 12, // تقليل حجم الخط أكثر
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 6), // تقليل المسافة أكثر

                  // شريط التقدم
                  ProgressBar(
                    value: (controller.completedSessions %
                            controller.sessionsUntilLongBreak) /
                        controller.sessionsUntilLongBreak,
                    isDarkMode: isDarkMode,
                  ),

                  const SizedBox(height: 4), // تقليل المسافة أكثر
                  FittedBox(
                    // استخدام FittedBox للتأكد من تناسب النص
                    fit: BoxFit.scaleDown,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        '${PomodoroStrings.statsCompletedLabel} ${controller.completedSessions % controller.sessionsUntilLongBreak} ${PomodoroStrings.statsFromLabel} ${controller.sessionsUntilLongBreak} ${PomodoroStrings.statsSessionsLabel}',
                        style: TextStyle(
                          fontSize: 10, // تقليل حجم الخط أكثر
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
