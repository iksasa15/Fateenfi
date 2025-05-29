import 'package:flutter/material.dart';
import '../../constants/pomodoro_colors.dart';
import '../../controllers/pomodoro_controller.dart';

class SessionIndicators extends StatelessWidget {
  final PomodoroController controller;

  const SessionIndicators({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // اللون حسب الوضع الحالي
    final progressColor = PomodoroColors.getTimerColor(
      isBreakTime: controller.isBreakTime,
      isLongBreak: controller.isLongBreak,
    );

    return SizedBox(
      height: 20,
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
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? PomodoroColors.kAccentColor
                  : (isCurrent
                      ? progressColor.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.2)),
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
