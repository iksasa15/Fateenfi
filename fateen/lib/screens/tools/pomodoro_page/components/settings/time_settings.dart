import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart'; // Updated import
import '../../../../../core/constants/appColor.dart'; // Added import
import '../../constants/pomodoro_strings.dart';
import '../../constants/pomodoro_durations.dart';
import '../../controllers/pomodoro_controller.dart';

class TimeSettings extends StatelessWidget {
  final PomodoroController controller;
  final bool isDarkMode;
  final Function(bool, {bool isLongBreak}) onCustomTimeRequested;

  const TimeSettings({
    Key? key,
    required this.controller,
    required this.isDarkMode,
    required this.onCustomTimeRequested,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ألوان متغيرة حسب الوضع
    final textColor = AppColors.getThemeColor(
      AppColors.textPrimary,
      AppColors.darkTextPrimary,
      isDarkMode,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.sectionPadding),
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
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.getThemeColor(
            AppColors.primaryLight,
            AppColors.darkPrimaryLight,
            isDarkMode,
          ),
          width: 2,
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
                  Icons.timer_outlined,
                  color: textColor,
                  size: AppDimensions.iconSize,
                ),
              ),
              SizedBox(width: AppDimensions.smallSpacing),
              Text(
                PomodoroStrings.settingsTitle,
                style: TextStyle(
                  fontSize: AppDimensions.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.largeSpacing),

          // مدة جلسة التركيز
          _buildSessionSetting(
            title: PomodoroStrings.settingsFocusDuration,
            value: controller.selectedSessionValue,
            options: PomodoroDurations.sessionDurations,
            onCustomSelected: () => onCustomTimeRequested(true),
          ),
          SizedBox(height: AppDimensions.defaultSpacing),

          // مدة الاستراحة القصيرة
          _buildSessionSetting(
            title: PomodoroStrings.settingsShortBreakDuration,
            value: controller.selectedBreakValue,
            options: PomodoroDurations.breakDurations,
            onCustomSelected: () => onCustomTimeRequested(false),
          ),
          SizedBox(height: AppDimensions.defaultSpacing),

          // مدة الاستراحة الطويلة
          _buildSessionSetting(
            title: PomodoroStrings.settingsLongBreakDuration,
            value: controller.selectedLongBreakValue,
            options: PomodoroDurations.longBreakDurations,
            onCustomSelected: () =>
                onCustomTimeRequested(false, isLongBreak: true),
          ),
          SizedBox(height: AppDimensions.defaultSpacing),

          // عدد الجلسات قبل الاستراحة الطويلة
          _buildTimeSetting(
            title: PomodoroStrings.settingsSessionsCount,
            value: controller.selectedSessionsValue,
            options: PomodoroDurations.sessionsOptions
                .map((e) => e.toString())
                .toList(),
            onChange: (value) {
              controller.updateSessionsUntilLongBreak(value);
            },
          ),
        ],
      ),
    );
  }

  // مكون جديد للتعامل مع الإعدادات المخصصة
  Widget _buildSessionSetting({
    required String title,
    required String value,
    required List<int> options,
    required VoidCallback onCustomSelected,
  }) {
    final textColor = AppColors.getThemeColor(
      AppColors.textPrimary,
      AppColors.darkTextPrimary,
      isDarkMode,
    );
    final stringOptions = options.map((e) => e.toString()).toList();

    // التحقق مما إذا كانت القيمة الحالية موجودة ضمن الخيارات المتاحة
    final isCustomValue =
        !stringOptions.contains(value) && value != PomodoroStrings.customOption;

    // إضافة القيمة الحالية المخصصة إذا كانت غير موجودة ضمن الخيارات
    final displayOptions = [...stringOptions];

    if (isCustomValue) {
      // عرض القيمة المخصصة الحالية
      displayOptions.add(value);
    }

    // إضافة خيار "مخصص" للسماح بإضافة قيم جديدة
    displayOptions.add(PomodoroStrings.customOption);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppDimensions.bodyFontSize,
            color: textColor,
            fontWeight: FontWeight.w500,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        SizedBox(height: AppDimensions.smallSpacing),
        Container(
          width: double.infinity,
          padding:
              EdgeInsets.symmetric(horizontal: AppDimensions.defaultSpacing),
          decoration: BoxDecoration(
            color: AppColors.getThemeColor(
              AppColors.surface,
              AppColors.darkSurface,
              isDarkMode,
            ),
            borderRadius:
                BorderRadius.circular(AppDimensions.inputBorderRadius),
            border: Border.all(
              color: AppColors.getThemeColor(
                AppColors.border,
                AppColors.darkBorder,
                isDarkMode,
              ),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: textColor,
              ),
              dropdownColor: AppColors.getThemeColor(
                AppColors.surface,
                AppColors.darkSurface,
                isDarkMode,
              ),
              style: TextStyle(
                color: textColor,
                fontSize: AppDimensions.bodyFontSize,
                fontFamily: 'SYMBIOAR+LT',
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  if (newValue == PomodoroStrings.customOption) {
                    // فتح حوار لتعيين وقت مخصص
                    onCustomSelected();
                  } else {
                    // تحديث القيمة ضمن الخيارات المتاحة
                    if (title == PomodoroStrings.settingsFocusDuration) {
                      controller.updateSessionDuration(newValue);
                    } else if (title ==
                        PomodoroStrings.settingsShortBreakDuration) {
                      controller.updateBreakDuration(newValue);
                    } else if (title ==
                        PomodoroStrings.settingsLongBreakDuration) {
                      controller.updateLongBreakDuration(newValue);
                    }
                  }
                }
              },
              items: displayOptions.map<DropdownMenuItem<String>>((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(
                    val == PomodoroStrings.customOption
                        ? PomodoroStrings.customOption
                        : '${val} ${PomodoroStrings.minutesSuffix}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight:
                          val == value ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSetting({
    required String title,
    required String value,
    required List<String> options,
    required Function(String) onChange,
  }) {
    final textColor = AppColors.getThemeColor(
      AppColors.textPrimary,
      AppColors.darkTextPrimary,
      isDarkMode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppDimensions.bodyFontSize,
            color: textColor,
            fontWeight: FontWeight.w500,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        SizedBox(height: AppDimensions.smallSpacing),
        Container(
          width: double.infinity,
          padding:
              EdgeInsets.symmetric(horizontal: AppDimensions.defaultSpacing),
          decoration: BoxDecoration(
            color: AppColors.getThemeColor(
              AppColors.surface,
              AppColors.darkSurface,
              isDarkMode,
            ),
            borderRadius:
                BorderRadius.circular(AppDimensions.inputBorderRadius),
            border: Border.all(
              color: AppColors.getThemeColor(
                AppColors.border,
                AppColors.darkBorder,
                isDarkMode,
              ),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: textColor,
              ),
              dropdownColor: AppColors.getThemeColor(
                AppColors.surface,
                AppColors.darkSurface,
                isDarkMode,
              ),
              style: TextStyle(
                color: textColor,
                fontSize: AppDimensions.bodyFontSize,
                fontFamily: 'SYMBIOAR+LT',
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChange(newValue);
                }
              },
              items: options.map<DropdownMenuItem<String>>((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(
                    val,
                    style: TextStyle(
                      color: textColor,
                      fontWeight:
                          val == value ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
