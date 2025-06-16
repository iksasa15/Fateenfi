import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
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
        ),
        SizedBox(width: AppDimensions.defaultSpacing),
        _buildControlButton(
          onPressed: onResetPressed,
          icon: Icons.refresh,
          text: PomodoroStrings.resetButton,
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String text,
    required bool isPrimary,
  }) {
    final Color buttonBgColor = isPrimary
        ? AppColors.getThemeColor(
            AppColors.primary,
            AppColors.darkPrimary,
            isDarkMode,
          )
        : AppColors.getThemeColor(
            AppColors.surface,
            AppColors.darkSurface,
            isDarkMode,
          );

    final Color textColor = isPrimary
        ? Colors.white
        : AppColors.getThemeColor(
            AppColors.primary,
            AppColors.darkPrimary,
            isDarkMode,
          );

    final Color borderColor = AppColors.getThemeColor(
      AppColors.primary,
      AppColors.darkPrimary,
      isDarkMode,
    );

    return Expanded(
      child: Container(
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.getThemeColor(
                      AppColors.shadow,
                      AppColors.darkShadow,
                      isDarkMode,
                    ),
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
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.defaultSpacing,
              vertical: AppDimensions.smallSpacing + 4,
            ),
            elevation: isPrimary ? 0 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
              side: BorderSide(
                color: isPrimary ? Colors.transparent : borderColor,
                width: 1.5,
              ),
            ),
          ),
          icon: Icon(icon, size: AppDimensions.iconSize),
          label: Text(
            text,
            style: TextStyle(
              fontSize: AppDimensions.buttonFontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
      ),
    );
  }
}
