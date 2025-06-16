import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
import 'constants/pomodoro_strings.dart';
import 'controllers/pomodoro_controller.dart';
import 'components/timer/timer_circle.dart';
import 'components/timer/control_buttons.dart';
import 'components/timer/session_indicators.dart';
import 'components/timer/status_label.dart';
import 'components/settings/time_settings.dart';
import 'components/settings/settings_dialog.dart';
import 'components/settings/custom_time_dialog.dart';
import 'components/stats/stats_card.dart';
import 'components/pomodoro_header_component.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with TickerProviderStateMixin {
  // متحكم الحالة للميزة بالكامل
  late PomodoroController _controller;

  @override
  void initState() {
    super.initState();
    // تهيئة متحكم البوموردورو
    _controller = PomodoroController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl, // تعيين اتجاه النص للصفحة بالكامل
      child: Scaffold(
        backgroundColor: AppColors.getThemeColor(
          AppColors.background,
          AppColors.darkBackground,
          isDarkMode,
        ),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // استخدام مكون الهيدر الجديد
                  PomodoroHeaderComponent(
                    onSettingsPressed: _showSettingsDialog,
                  ),

                  // محتوى الصفحة
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.smallSpacing,
                        vertical: AppDimensions.smallSpacing,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // قسم المؤقت
                          _buildTimerSection(),
                          SizedBox(height: AppDimensions.defaultSpacing - 2),

                          // قسم الإعدادات
                          TimeSettings(
                            controller: _controller,
                            isDarkMode: isDarkMode,
                            onCustomTimeRequested: _showCustomTimeDialog,
                          ),
                          SizedBox(height: AppDimensions.defaultSpacing - 2),

                          // قسم الإحصائيات
                          StatsCard(
                            controller: _controller,
                            isDarkMode: isDarkMode,
                          ),
                          SizedBox(height: AppDimensions.defaultSpacing - 2),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // بناء قسم المؤقت مع تحسينات لتجنب تجاوز الحدود
  Widget _buildTimerSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.defaultSpacing - 2),
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
              AppColors.shadow,
              AppColors.darkShadow,
              isDarkMode,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.getThemeColor(
            AppColors.primaryPale,
            AppColors.darkPrimaryPale,
            isDarkMode,
          ),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // مؤشرات الدورة
          SessionIndicators(controller: _controller),
          SizedBox(height: AppDimensions.smallSpacing - 2),

          // حالة المؤقت
          StatusLabel(
            controller: _controller,
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: AppDimensions.smallSpacing),

          // المؤقت الدائري - يحتاج تعديل لكي لا يتأثر باتجاه النص
          Directionality(
            textDirection:
                TextDirection.ltr, // إعادة تعيين اتجاه النص للمؤقت الدائري
            child: Container(
              // تحديد حجم للحاوية لمنع تجاوز الحدود
              height: MediaQuery.of(context).size.width * 0.5,
              width: MediaQuery.of(context).size.width * 0.5,
              child: TimerCircle(
                controller: _controller,
                isDarkMode: isDarkMode,
                pulseAnimation: _controller.pulseAnimation,
              ),
            ),
          ),
          SizedBox(height: AppDimensions.defaultSpacing),

          // أزرار التحكم - ضمان أن تظهر بشكل صحيح مع اتجاه النص
          Directionality(
            textDirection: TextDirection.ltr, // إعادة تعيين اتجاه النص للأزرار
            child: ControlButtons(
              controller: _controller,
              onResetPressed: _showResetConfirmation,
              isDarkMode: isDarkMode,
            ),
          ),

          // عدد الجلسات المكتملة - تعديل لتناسب مع الشاشة
          if (_controller.completedSessions > 0) ...[
            SizedBox(height: AppDimensions.defaultSpacing - 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompletionInfo(
                  icon: Icons.check_circle_outline,
                  title: PomodoroStrings.statsSessionsLabel.split(' ')[0],
                  value: _controller.completedSessions.toString(),
                  color: AppColors.success,
                ),
                Container(
                  height: AppDimensions.extraSmallIconSize - 2,
                  width: 1,
                  color: AppColors.getThemeColor(
                    AppColors.border,
                    AppColors.darkBorder,
                    isDarkMode,
                  ),
                  margin: EdgeInsets.symmetric(
                      horizontal: AppDimensions.smallSpacing - 2),
                ),
                _buildCompletionInfo(
                  icon: Icons.repeat,
                  title: PomodoroStrings.statsFromLabel.split(' ')[1],
                  value: _controller.currentCycle.toString(),
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // بناء معلومات الإكمال - تم تحسين الأحجام لمنع تجاوز الحدود
  Widget _buildCompletionInfo({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: AppDimensions.extraSmallIconSize - 4,
            ),
            SizedBox(width: AppDimensions.smallSpacing / 3),
            Text(
              title,
              style: TextStyle(
                color: AppColors.getThemeColor(
                  AppColors.textSecondary,
                  AppColors.darkTextSecondary,
                  isDarkMode,
                ),
                fontSize: AppDimensions.smallLabelFontSize - 2,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.smallSpacing / 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.getThemeColor(
              AppColors.primary,
              AppColors.darkPrimary,
              isDarkMode,
            ),
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.smallLabelFontSize,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  // عرض حوار الإعدادات - تم تعديله لدعم RTL
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl, // ضمان اتجاه النص في الحوار
        child: SettingsDialog(controller: _controller),
      ),
    );
  }

  // عرض حوار الوقت المخصص - تم تعديله لدعم RTL
  void _showCustomTimeDialog(bool isSession, {bool isLongBreak = false}) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl, // ضمان اتجاه النص في الحوار
        child: CustomTimeDialog(
          controller: _controller,
          isSession: isSession,
          isLongBreak: isLongBreak,
        ),
      ),
    );
  }

  // عرض حوار تأكيد إعادة الضبط - تم تعديله لدعم RTL
  void _showResetConfirmation() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl, // ضمان اتجاه النص في الحوار
        child: AlertDialog(
          title: Text(
            PomodoroStrings.resetTimerTitle,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontWeight: FontWeight.bold,
              color: AppColors.getThemeColor(
                AppColors.primary,
                AppColors.darkPrimary,
                isDarkMode,
              ),
              fontSize: AppDimensions.smallBodyFontSize,
            ),
          ),
          content: Text(
            PomodoroStrings.resetTimerContent,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: AppDimensions.smallLabelFontSize,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
          ),
          backgroundColor: AppColors.getThemeColor(
            AppColors.surface,
            AppColors.darkSurface,
            isDarkMode,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                PomodoroStrings.resetTimerCancel,
                style: TextStyle(
                  color: AppColors.getThemeColor(
                    AppColors.textSecondary,
                    AppColors.darkTextSecondary,
                    isDarkMode,
                  ),
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.smallLabelFontSize,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _controller.resetTimer();
                _showSuccessSnackBar(PomodoroStrings.resetTimerSuccess);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getThemeColor(
                  AppColors.primaryDark,
                  AppColors.darkPrimaryDark,
                  isDarkMode,
                ),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius),
                ),
              ),
              child: Text(
                PomodoroStrings.resetTimerConfirm,
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: AppDimensions.smallLabelFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عرض رسالة نجاح - تم تعديلها لدعم RTL
  void _showSuccessSnackBar(String message) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl, // ضمان اتجاه النص في الإشعار
          child: Text(
            message,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: AppDimensions.smallLabelFontSize,
            ),
          ),
        ),
        backgroundColor: AppColors.getThemeColor(
          AppColors.primaryDark,
          AppColors.darkPrimaryDark,
          isDarkMode,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppDimensions.smallSpacing,
          vertical: AppDimensions.smallSpacing / 1.5,
        ),
      ),
    );
  }

  // عرض رسالة عند انتهاء المؤقت - تم تعديلها لدعم RTL
  void showCompletionSnackBar() {
    if (!_controller.showNotifications) return;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final message = _controller.getCompletionMessage();
    final backgroundColor = _controller.isBreakTime
        ? AppColors.getThemeColor(
            AppColors.primary, AppColors.darkPrimary, isDarkMode)
        : AppColors.getThemeColor(
            AppColors.accent, AppColors.darkAccent, isDarkMode);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl, // ضمان اتجاه النص في الإشعار
          child: Row(
            children: [
              Icon(
                _controller.isBreakTime ? Icons.free_breakfast : Icons.work,
                color: Colors.white,
                size: AppDimensions.extraSmallIconSize - 4,
              ),
              SizedBox(width: AppDimensions.smallSpacing - 2),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimensions.smallLabelFontSize - 2,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppDimensions.smallSpacing,
          vertical: AppDimensions.smallSpacing / 1.5,
        ),
        duration: const Duration(seconds: 4),
        action: _controller.isBreakTime && !_controller.autoStartBreaks
            ? SnackBarAction(
                label: PomodoroStrings.startButtonLabel,
                textColor: Colors.white,
                onPressed: _controller.startTimer,
              )
            : null,
      ),
    );
  }
}
