import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/pomodoro_colors.dart';
import '../../constants/pomodoro_strings.dart';
import '../../controllers/pomodoro_controller.dart';

class TimerCircle extends StatelessWidget {
  final PomodoroController controller;
  final bool isDarkMode;
  final Animation<double> pulseAnimation;

  const TimerCircle({
    Key? key,
    required this.controller,
    required this.isDarkMode,
    required this.pulseAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // اللون حسب الوضع الحالي
    final progressColor = PomodoroColors.getTimerColor(
      isBreakTime: controller.isBreakTime,
      isLongBreak: controller.isLongBreak,
    );

    // ألوان متغيرة حسب الوضع
    final bgColor = PomodoroColors.getCardBackgroundColor(isDarkMode);
    final textColor =
        PomodoroColors.kDarkPurple; // تعديل للتوافق مع صفحة المعدل
    final subTextColor = Colors.grey[600]; // تعديل للتوافق مع صفحة المعدل

    return AnimatedBuilder(
      animation: Listenable.merge(
          [controller.timerAnimationController, pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: controller.isTimerRunning
              ? pulseAnimation.value
              : 1.0 + (controller.timerAnimationController.value * 0.05),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // دائرة التقدم المتحركة
          SizedBox(
            width: 240,
            height: 240,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: controller.progressValue),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // دائرة خلفية
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode
                            ? Colors.grey[850]
                            : PomodoroColors.kLightPurple.withOpacity(0.2),
                      ),
                    ),

                    // مؤشر التقدم
                    ShaderMask(
                      shaderCallback: (rect) {
                        return SweepGradient(
                          startAngle: 0.0,
                          endAngle: math.pi * 2,
                          stops: [value, value],
                          center: Alignment.center,
                          colors: [
                            progressColor,
                            Colors.transparent,
                          ],
                        ).createShader(rect);
                      },
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // دائرة داخلية (الفراغ في المنتصف)
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bgColor,
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[800]!
                              : Colors.grey[200]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // الوقت المتبقي
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.formatTime(controller.secondsRemaining),
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: PomodoroColors.kLightPurple,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  controller.isTimerRunning
                      ? PomodoroStrings.remainingTime
                      : PomodoroStrings.readyStatus,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
