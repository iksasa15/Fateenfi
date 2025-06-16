import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
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
    // اللون حسب الوضع الحالي (نستخدم ألوان محددة من AppColors)
    final progressColor = controller.isBreakTime
        ? (controller.isLongBreak
            ? AppColors.getThemeColor(
                AppColors.success, AppColors.darkSuccess, isDarkMode)
            : AppColors.getThemeColor(
                AppColors.primary, AppColors.darkPrimary, isDarkMode))
        : AppColors.getThemeColor(
            AppColors.accent, AppColors.darkAccent, isDarkMode);

    // ألوان متغيرة حسب الوضع
    final bgColor = AppColors.getThemeColor(
      AppColors.surface,
      AppColors.darkSurface,
      isDarkMode,
    );
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
                            ? AppColors.darkSurfaceLight
                            : AppColors.primaryPale,
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
                          color: AppColors.getThemeColor(
                            AppColors.border,
                            AppColors.darkBorder,
                            isDarkMode,
                          ),
                          width: 2,
                        ),
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
                  fontSize: AppDimensions.titleFontSize *
                      1.8, // تكبير للتناسب مع الحجم السابق
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              SizedBox(height: AppDimensions.smallSpacing),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.defaultSpacing,
                  vertical: AppDimensions.smallSpacing / 1.5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.getThemeColor(
                    AppColors.primaryPale,
                    AppColors.darkPrimaryPale,
                    isDarkMode,
                  ),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.extraLargeRadius),
                ),
                child: Text(
                  controller.isTimerRunning
                      ? PomodoroStrings.remainingTime
                      : PomodoroStrings.readyStatus,
                  style: TextStyle(
                    fontSize: AppDimensions.bodyFontSize,
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
