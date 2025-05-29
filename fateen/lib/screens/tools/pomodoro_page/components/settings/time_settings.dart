import 'package:flutter/material.dart';
import '../../constants/pomodoro_colors.dart';
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
    final textColor = PomodoroColors.kDarkPurple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PomodoroColors.getCardBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: PomodoroColors.kLightPurple,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PomodoroColors.kLightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: textColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                PomodoroStrings.settingsTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // مدة جلسة التركيز
          _buildSessionSetting(
            title: PomodoroStrings.settingsFocusDuration,
            value: controller.selectedSessionValue,
            options: PomodoroDurations.sessionDurations,
            onCustomSelected: () => onCustomTimeRequested(true),
          ),
          const SizedBox(height: 16),

          // مدة الاستراحة القصيرة
          _buildSessionSetting(
            title: PomodoroStrings.settingsShortBreakDuration,
            value: controller.selectedBreakValue,
            options: PomodoroDurations.breakDurations,
            onCustomSelected: () => onCustomTimeRequested(false),
          ),
          const SizedBox(height: 16),

          // مدة الاستراحة الطويلة
          _buildSessionSetting(
            title: PomodoroStrings.settingsLongBreakDuration,
            value: controller.selectedLongBreakValue,
            options: PomodoroDurations.longBreakDurations,
            onCustomSelected: () =>
                onCustomTimeRequested(false, isLongBreak: true),
          ),
          const SizedBox(height: 16),

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
    final textColor = PomodoroColors.getTextColor(isDarkMode);
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
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.w500,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[300]!,
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
              dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
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
    final textColor = PomodoroColors.getTextColor(isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.w500,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[300]!,
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
              dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
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
