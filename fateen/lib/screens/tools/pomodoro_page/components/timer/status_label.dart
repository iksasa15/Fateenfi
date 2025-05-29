import 'package:flutter/material.dart';
import '../../constants/pomodoro_colors.dart';
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
    final progressColor = PomodoroColors.getTimerColor(
      isBreakTime: controller.isBreakTime,
      isLongBreak: controller.isLongBreak,
    );

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _getStatusBackgroundColor(isDarkMode, progressColor),
            borderRadius: BorderRadius.circular(16), // تغيير نصف القطر للتوافق
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                controller.statusMessage,
                style: TextStyle(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15, // تعديل حجم الخط
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), // زيادة المسافة

        // معلومات الجلسة القادمة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            controller.nextSessionInfo,
            style: TextStyle(
              fontSize: 14,
              color: PomodoroColors.getSubTextColor(isDarkMode),
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
            ? PomodoroColors.kGreenColor.withOpacity(0.1)
            : PomodoroColors.kLightPurple;
      } else {
        return PomodoroColors.kAccentColor.withOpacity(0.1);
      }
    }
  }
}
