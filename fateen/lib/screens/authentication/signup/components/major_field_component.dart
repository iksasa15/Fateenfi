import 'package:flutter/material.dart';
import '../constants/signup_colors.dart';
import '../constants/signup_strings.dart';
import '../constants/signup_dimensions.dart';

class MajorFieldComponent extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isOtherMajor;
  final VoidCallback onTap;

  const MajorFieldComponent({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.isOtherMajor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery بطريقة فعالة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام حسب حجم الشاشة
    final fontSize = isTablet
        ? 17.0
        : (isSmallScreen
            ? SignupDimensions.smallBodyFontSize
            : SignupDimensions.bodyFontSize);
    final labelSize = isTablet ? 16.0 : (isSmallScreen ? 13.0 : 14.0);
    final iconSize = isTablet ? 26.0 : (isSmallScreen ? 20.0 : 22.0);
    final verticalPadding = isTablet ? 24.0 : (isSmallScreen ? 16.0 : 18.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
      child: GestureDetector(
        onTap: isOtherMajor ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: SignupColors.shadowColor.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0.5,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: isOtherMajor
              ? TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  textAlign: TextAlign.right,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(
                    color: SignupColors.textColor,
                    fontSize: fontSize,
                    fontFamily: 'SYMBIOAR+LT',
                    letterSpacing: 0.2,
                  ),
                  decoration: InputDecoration(
                    hintText: SignupStrings.majorHint,
                    labelText: SignupStrings.majorLabel,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelStyle: TextStyle(
                      color: SignupColors.textColor.withOpacity(0.7),
                      fontSize: labelSize,
                      fontFamily: 'SYMBIOAR+LT',
                      fontWeight: FontWeight.w500,
                    ),
                    hintStyle: TextStyle(
                      color: SignupColors.hintColor,
                      fontSize: labelSize,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    prefixIcon: Icon(
                      Icons.category_outlined,
                      color: SignupColors.hintColor,
                      size: iconSize,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: SignupColors.mediumPurple,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: SignupColors.accentColor,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: SignupColors.accentColor,
                        width: 1.5,
                      ),
                    ),
                    errorStyle: TextStyle(
                      color: SignupColors.accentColor,
                      fontSize: isSmallScreen ? 10 : 12,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: verticalPadding,
                      horizontal: 20,
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: verticalPadding, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        color: SignupColors.hintColor,
                        size: iconSize,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              SignupStrings.majorLabel,
                              style: TextStyle(
                                color: SignupColors.textColor.withOpacity(0.7),
                                fontSize: labelSize,
                                fontFamily: 'SYMBIOAR+LT',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              controller.text.isEmpty
                                  ? SignupStrings.majorHint
                                  : controller.text,
                              style: TextStyle(
                                color: controller.text.isEmpty
                                    ? SignupColors.hintColor
                                    : SignupColors.textColor,
                                fontSize: fontSize,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_drop_down,
                        color: SignupColors.hintColor,
                        size: iconSize + 4,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
