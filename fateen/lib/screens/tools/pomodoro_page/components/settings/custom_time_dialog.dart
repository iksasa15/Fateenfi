import 'package:flutter/material.dart';
import '../../../../../core/constants/app_dimensions.dart'; // Updated import
import '../../../../../core/constants/appColor.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // تحديد العنوان حسب نوع الإعداد
    final String title = isSession
        ? PomodoroStrings.customFocusTimeTitle
        : (isLongBreak
            ? PomodoroStrings.customLongBreakTimeTitle
            : PomodoroStrings.customShortBreakTimeTitle);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.defaultSpacing,
          vertical: AppDimensions.largeSpacing),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getThemeColor(
            AppColors.surface,
            AppColors.darkSurface,
            isDarkMode,
          ),
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
                      Icons.access_time,
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
                    title,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    PomodoroStrings.customTimeInstructions,
                    style: TextStyle(
                      color: AppColors.getThemeColor(
                        AppColors.textSecondary,
                        AppColors.darkTextSecondary,
                        isDarkMode,
                      ),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                  SizedBox(height: AppDimensions.defaultSpacing),
                  TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: PomodoroStrings.customTimeHint,
                      fillColor: AppColors.getThemeColor(
                        AppColors.surface,
                        AppColors.darkSurface,
                        isDarkMode,
                      ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                        borderSide: BorderSide(
                          color: AppColors.getThemeColor(
                            AppColors.border,
                            AppColors.darkBorder,
                            isDarkMode,
                          ),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                        borderSide: BorderSide(
                          color: AppColors.getThemeColor(
                            AppColors.border,
                            AppColors.darkBorder,
                            isDarkMode,
                          ),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                        borderSide: BorderSide(
                          color: AppColors.getThemeColor(
                            AppColors.primary,
                            AppColors.darkPrimary,
                            isDarkMode,
                          ),
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.inputFieldPadding,
                        vertical: AppDimensions.smallSpacing,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppDimensions.bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getThemeColor(
                        AppColors.textPrimary,
                        AppColors.darkTextPrimary,
                        isDarkMode,
                      ),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                  SizedBox(height: AppDimensions.defaultSpacing),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
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
                        PomodoroStrings.customTimeConfirm,
                        style: TextStyle(
                          fontSize: AppDimensions.buttonFontSize,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        backgroundColor: AppColors.getThemeColor(
          AppColors.error,
          AppColors.darkError,
          isDarkMode,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        ),
      ),
    );
  }
}
