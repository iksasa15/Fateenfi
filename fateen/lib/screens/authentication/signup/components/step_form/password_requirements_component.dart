// lib/features/step_form/components/password_requirements_component.dart

import 'package:flutter/material.dart';
import '../../../../../core/constants/appColor.dart'; // Updated import

class PasswordRequirementsComponent extends StatelessWidget {
  final String password;
  final Function(String) calculatePasswordStrength;
  final Function(String) getPasswordStrengthText;

  const PasswordRequirementsComponent({
    Key? key,
    required this.password,
    required this.calculatePasswordStrength,
    required this.getPasswordStrengthText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;
    final helperTextSize = isTablet ? 12.0 : (isSmallScreen ? 10.0 : 11.0);

    // فحص متطلبات كلمة المرور
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasNoArabic = !RegExp(r'[\u0600-\u06FF]').hasMatch(password);

    return Padding(
      padding: EdgeInsets.only(
        top: size.height * 0.015,
        right: screenWidth * 0.09,
        left: screenWidth * 0.09,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // مؤشر قوة كلمة المرور
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قوة كلمة المرور: ${getPasswordStrengthText(password)}',
                style: TextStyle(
                  color: _getPasswordStrengthColor(password),
                  fontSize: helperTextSize,
                  fontFamily: 'SYMBIOAR+LT',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: calculatePasswordStrength(password),
              backgroundColor:
                  context.colorSurface.withOpacity(0.3), // استخدام Extension
              valueColor: AlwaysStoppedAnimation<Color>(
                  _getPasswordStrengthColor(password)),
              minHeight: 6,
            ),
          ),
          SizedBox(height: size.height * 0.015),

          // متطلبات كلمة المرور في صفوف منظمة
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.01),
            child: Column(
              children: [
                _buildPasswordRequirement(
                  context,
                  '٨ أحرف على الأقل',
                  hasMinLength,
                  helperTextSize,
                ),
                SizedBox(height: 4),
                _buildPasswordRequirement(
                  context,
                  'حرف كبير (A-Z)',
                  hasUppercase,
                  helperTextSize,
                ),
                SizedBox(height: 4),
                _buildPasswordRequirement(
                  context,
                  'حرف صغير (a-z)',
                  hasLowercase,
                  helperTextSize,
                ),
                SizedBox(height: 4),
                _buildPasswordRequirement(
                  context,
                  'رقم (0-9)',
                  hasDigit,
                  helperTextSize,
                ),
                SizedBox(height: 4),
                _buildPasswordRequirement(
                  context,
                  'رمز خاص (!@#\$%^&*)',
                  hasSpecialChar,
                  helperTextSize,
                ),
                SizedBox(height: 4),
                _buildPasswordRequirement(
                  context,
                  'لا تستخدم حروف عربية',
                  hasNoArabic,
                  helperTextSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة لبناء متطلب من متطلبات كلمة المرور
  Widget _buildPasswordRequirement(
      BuildContext context, String text, bool isFulfilled, double fontSize) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          isFulfilled ? Icons.check_circle : Icons.circle_outlined,
          color: isFulfilled
              ? Colors.green
              : context.colorTextHint.withOpacity(0.5), // استخدام Extension
          size: fontSize * 1.2,
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: isFulfilled
                ? context.colorTextPrimary
                : context.colorTextHint, // استخدام Extension
            fontSize: fontSize,
            fontFamily: 'SYMBIOAR+LT',
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  // دالة للحصول على لون قوة كلمة المرور
  Color _getPasswordStrengthColor(String password) {
    double strength = calculatePasswordStrength(password);

    if (strength < 0.3) return Colors.red;
    if (strength < 0.6) return Colors.orange;
    if (strength < 0.8) return Colors.blue;
    return Colors.green;
  }
}
