import 'package:flutter/material.dart';
import '../../constants/pomodoro_colors.dart';
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PomodoroColors.kLightPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: PomodoroColors.kDarkPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    PomodoroStrings.settingsTitle,
                    style: const TextStyle(
                      color: PomodoroColors.kDarkPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.all(20),
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
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
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
                    backgroundColor: PomodoroColors.kMediumPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    PomodoroStrings.settingsSaveButton,
                    style: const TextStyle(
                      fontSize: 16,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: PomodoroColors.kDarkPurple,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: PomodoroColors.kMediumPurple,
          ),
        ],
      ),
    );
  }
}
