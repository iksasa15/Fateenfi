import 'package:flutter/material.dart';
import '../constants/reset_password_colors.dart';
import '../constants/reset_password_strings.dart';
import '../controllers/reset_password_controller.dart';

class ResetFormComponent extends StatelessWidget {
  final ResetPasswordController controller;
  final String? Function(String?) validator;

  const ResetFormComponent({
    Key? key,
    required this.controller,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تحديد أحجام الخط
    final fontSize = isTablet ? 16.0 : (isSmallScreen ? 14.0 : 15.0);
    final labelSize = isTablet ? 14.0 : (isSmallScreen ? 12.0 : 13.0);
    final iconSize = isTablet ? 24.0 : 22.0;

    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: ResetPasswordColors.textColor,
        fontSize: fontSize,
        fontFamily: 'SYMBIOAR+LT',
      ),
      decoration: InputDecoration(
        hintText: ResetPasswordStrings.emailHint,
        labelText: ResetPasswordStrings.emailLabel,
        labelStyle: TextStyle(
          color: ResetPasswordColors.textColor.withOpacity(0.7),
          fontSize: labelSize,
          fontFamily: 'SYMBIOAR+LT',
        ),
        hintStyle: TextStyle(
          color: ResetPasswordColors.hintColor,
          fontSize: labelSize,
          fontFamily: 'SYMBIOAR+LT',
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: controller.emailController.text.isEmpty
              ? ResetPasswordColors.hintColor
              : ResetPasswordColors.mediumPurple,
          size: iconSize,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ResetPasswordColors.mediumPurple,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ResetPasswordColors.accentColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ResetPasswordColors.accentColor,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(
          color: ResetPasswordColors.accentColor,
          fontSize: isSmallScreen ? 10 : 12,
          fontFamily: 'SYMBIOAR+LT',
        ),
        contentPadding: EdgeInsets.symmetric(
            vertical: isTablet ? 20.0 : 16.0, horizontal: 20),
      ),
      validator: validator,
    );
  }
}
