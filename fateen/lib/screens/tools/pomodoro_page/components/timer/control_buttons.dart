import 'package:flutter/material.dart';
import '../../constants/pomodoro_colors.dart';
import '../../constants/pomodoro_strings.dart';
import '../../controllers/pomodoro_controller.dart';

class ControlButtons extends StatelessWidget {
  final PomodoroController controller;
  final VoidCallback onResetPressed;
  final bool isDarkMode;

  const ControlButtons({
    Key? key,
    required this.controller,
    required this.onResetPressed,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // اللون حسب الوضع الحالي
    final progressColor = PomodoroColors.getTimerColor(
      isBreakTime: controller.isBreakTime,
      isLongBreak: controller.isLongBreak,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          onPressed: controller.isTimerRunning
              ? controller.stopTimer
              : controller.startTimer,
          icon: controller.isTimerRunning ? Icons.pause : Icons.play_arrow,
          text: controller.isTimerRunning
              ? PomodoroStrings.pauseButton
              : PomodoroStrings.startButton,
          isPrimary: true,
          bgColor:
              PomodoroColors.kMediumPurple, // تعديل للتوافق مع الألوان الموحدة
        ),
        const SizedBox(width: 16),
        _buildControlButton(
          onPressed: onResetPressed,
          icon: Icons.refresh,
          text: PomodoroStrings.resetButton,
          isPrimary: false,
          bgColor:
              PomodoroColors.kMediumPurple, // تعديل للتوافق مع الألوان الموحدة
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String text,
    required bool isPrimary,
    required Color bgColor,
  }) {
    final Color buttonBgColor =
        isPrimary ? bgColor : (isDarkMode ? Colors.grey[850]! : Colors.white);
    final Color textColor =
        isPrimary ? Colors.white : (isDarkMode ? Colors.white : bgColor);
    final Color borderColor = bgColor;

    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: bgColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBgColor,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: isPrimary ? 0 : 0, // تعديل الارتفاع
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isPrimary ? Colors.transparent : borderColor,
                width: 1.5,
              ),
            ),
          ),
          icon: Icon(icon, size: 24),
          label: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
      ),
    );
  }
}
