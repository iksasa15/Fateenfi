import 'package:flutter/material.dart';
import '../../constants/pomodoro_colors.dart';

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
      height: 10,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: isDarkMode
            ? Colors.grey[800]
            : PomodoroColors.kLightPurple.withOpacity(0.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: PomodoroColors.kMediumPurple,
            boxShadow: [
              BoxShadow(
                color: PomodoroColors.kMediumPurple.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
