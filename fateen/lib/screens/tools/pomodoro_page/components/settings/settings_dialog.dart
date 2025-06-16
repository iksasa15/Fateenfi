import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart'; // Updated import
import '../../../../../core/constants/appColor.dart';
import '../../constants/pomodoro_strings.dart';
import '../../controllers/pomodoro_controller.dart';

class SettingsDialog extends StatefulWidget {
  final PomodoroController controller;

  const SettingsDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _autoStartBreaks;
  late bool _autoStartSessions;
  late bool _enableSounds;
  late bool _enableVibration;
  late bool _showNotifications;

  @override
  void initState() {
    super.initState();
    _autoStartBreaks = widget.controller.autoStartBreaks;
    _autoStartSessions = widget.controller.autoStartSessions;
    _enableSounds = widget.controller.enableSounds;
    _enableVibration = widget.controller.enableVibration;
    _showNotifications = widget.controller.showNotifications;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.defaultSpacing,
          vertical: AppDimensions.largeSpacing),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getThemeColor(
              AppColors.surface, AppColors.darkSurface, isDarkMode),
          borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.getThemeColor(
                AppColors.shadowColor,
                AppColors.darkShadowColor,
                isDarkMode,
              ),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // عنوان الحوار
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.defaultSpacing,
                AppDimensions.defaultSpacing,
                AppDimensions.defaultSpacing,
                AppDimensions.smallSpacing,
              ),
              child: Row(
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
                      Icons.settings,
                      color: AppColors.getThemeColor(
                        AppColors.primary,
                        AppColors.darkPrimary,
                        isDarkMode,
                      ),
                      size: AppDimensions.smallIconSize,
                    ),
                  ),
                  SizedBox(width: AppDimensions.smallSpacing),
                  Text(
                    PomodoroStrings.settingsTitle,
                    style: TextStyle(
                      color: AppColors.getThemeColor(
                        AppColors.textPrimary,
                        AppColors.darkTextPrimary,
                        isDarkMode,
                      ),
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimensions.subtitleFontSize,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.getThemeColor(
                        AppColors.textSecondary,
                        AppColors.darkTextSecondary,
                        isDarkMode,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              color: AppColors.getThemeColor(
                AppColors.divider,
                AppColors.darkDivider,
                isDarkMode,
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppDimensions.defaultSpacing),
              child: Column(
                children: [
                  _buildSettingsSwitchTile(
                    title: PomodoroStrings.settingsAutoStartBreaks,
                    subtitle: PomodoroStrings.settingsAutoStartBreaksDesc,
                    value: _autoStartBreaks,
                    onChanged: (value) {
                      setState(() => _autoStartBreaks = value);
                    },
                  ),
                  _buildSettingsSwitchTile(
                    title: PomodoroStrings.settingsAutoStartSessions,
                    subtitle: PomodoroStrings.settingsAutoStartSessionsDesc,
                    value: _autoStartSessions,
                    onChanged: (value) {
                      setState(() => _autoStartSessions = value);
                    },
                  ),
                  _buildSettingsSwitchTile(
                    title: PomodoroStrings.settingsEnableSounds,
                    subtitle: PomodoroStrings.settingsEnableSoundsDesc,
                    value: _enableSounds,
                    onChanged: (value) {
                      setState(() => _enableSounds = value);
                    },
                  ),
                  _buildSettingsSwitchTile(
                    title: PomodoroStrings.settingsEnableVibration,
                    subtitle: PomodoroStrings.settingsEnableVibrationDesc,
                    value: _enableVibration,
                    onChanged: (value) {
                      setState(() => _enableVibration = value);
                    },
                  ),
                  _buildSettingsSwitchTile(
                    title: PomodoroStrings.settingsShowNotifications,
                    subtitle: PomodoroStrings.settingsShowNotificationsDesc,
                    value: _showNotifications,
                    onChanged: (value) {
                      setState(() => _showNotifications = value);
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppDimensions.defaultSpacing),
              child: SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    // تحديث الإعدادات
                    widget.controller.updateSettings(
                      autoStartBreaks: _autoStartBreaks,
                      autoStartSessions: _autoStartSessions,
                      enableSounds: _enableSounds,
                      enableVibration: _enableVibration,
                      showNotifications: _showNotifications,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getThemeColor(
                      AppColors.primary,
                      AppColors.darkPrimary,
                      isDarkMode,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.mediumRadius),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    PomodoroStrings.settingsSaveButton,
                    style: TextStyle(
                      fontSize: AppDimensions.buttonFontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء عنصر في حوار الإعدادات
  Widget _buildSettingsSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.smallSpacing),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimensions.bodyFontSize,
                    color: AppColors.getThemeColor(
                      AppColors.textPrimary,
                      AppColors.darkTextPrimary,
                      isDarkMode,
                    ),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                SizedBox(height: AppDimensions.smallSpacing / 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.getThemeColor(
                      AppColors.textSecondary,
                      AppColors.darkTextSecondary,
                      isDarkMode,
                    ),
                    fontSize: AppDimensions.smallLabelFontSize,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.getThemeColor(
              AppColors.primary,
              AppColors.darkPrimary,
              isDarkMode,
            ),
          ),
        ],
      ),
    );
  }
}
