import 'package:flutter/material.dart';
import '../../constants/pomodoro_colors.dart';
import '../../constants/pomodoro_strings.dart';
import '../../constants/pomodoro_durations.dart';
import '../../controllers/pomodoro_controller.dart';

class CustomTimeDialog extends StatelessWidget {
  final PomodoroController controller;
  final bool isSession;
  final bool isLongBreak;

  const CustomTimeDialog({
    Key? key,
    required this.controller,
    required this.isSession,
    this.isLongBreak = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    // تحديد العنوان حسب نوع الإعداد
    final String title = isSession
        ? PomodoroStrings.customFocusTimeTitle
        : (isLongBreak
            ? PomodoroStrings.customLongBreakTimeTitle
            : PomodoroStrings.customShortBreakTimeTitle);

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
                      Icons.access_time,
                      color: PomodoroColors.kDarkPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    PomodoroStrings.customTimeInstructions,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: PomodoroStrings.customTimeHint,
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: PomodoroColors.kMediumPurple,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PomodoroColors.kDarkPurple,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (textController.text.isNotEmpty) {
                          try {
                            final customValue = int.parse(textController.text);
                            if (customValue >=
                                    PomodoroDurations.minCustomDuration &&
                                customValue <=
                                    PomodoroDurations.maxCustomDuration) {
                              // مهم: تحديد ما إذا كانت القيمة موجودة بالفعل في قائمة الخيارات المتاحة
                              final valueStr = customValue.toString();
                              final List<String> existingOptions;

                              if (isSession) {
                                existingOptions = PomodoroDurations
                                    .sessionDurations
                                    .map((e) => e.toString())
                                    .toList();
                                if (existingOptions.contains(valueStr)) {
                                  // إذا كانت القيمة موجودة في الخيارات الأساسية، استخدمها مباشرة
                                  controller.updateSessionDuration(valueStr);
                                } else {
                                  // إلا، قم بإضافتها كقيمة مخصصة
                                  controller
                                      .updateSessionDurationWithCustomValue(
                                          customValue);
                                }
                              } else if (isLongBreak) {
                                existingOptions = PomodoroDurations
                                    .longBreakDurations
                                    .map((e) => e.toString())
                                    .toList();
                                if (existingOptions.contains(valueStr)) {
                                  controller.updateLongBreakDuration(valueStr);
                                } else {
                                  controller
                                      .updateLongBreakDurationWithCustomValue(
                                          customValue);
                                }
                              } else {
                                existingOptions = PomodoroDurations
                                    .breakDurations
                                    .map((e) => e.toString())
                                    .toList();
                                if (existingOptions.contains(valueStr)) {
                                  controller.updateBreakDuration(valueStr);
                                } else {
                                  controller.updateBreakDurationWithCustomValue(
                                      customValue);
                                }
                              }

                              Navigator.pop(context);
                            } else {
                              _showErrorSnackBar(
                                  context, PomodoroStrings.customTimeError);
                            }
                          } catch (e) {
                            _showErrorSnackBar(
                                context, PomodoroStrings.customTimeNumberError);
                          }
                        }
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
                        PomodoroStrings.customTimeConfirm,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عرض رسالة خطأ
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        backgroundColor: PomodoroColors.kAccentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
