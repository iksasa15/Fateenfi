// lib/features/step_form/components/enhanced_input_field.dart

import 'package:flutter/material.dart';
import '../../../../../core/constants/appColor.dart'; // Updated import

class EnhancedInputField extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final String? helperText;
  final Function(String)? onChanged;
  final bool showPasswordStrength;
  final VoidCallback? onLoginPressed;

  const EnhancedInputField({
    Key? key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.onSubmitted,
    this.helperText,
    this.onChanged,
    this.showPasswordStrength = false,
    this.onLoginPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام قيم نسبية للحجم
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام حسب حجم الشاشة
    final fontSize = isTablet ? 16.0 : (isSmallScreen ? 14.0 : 15.0);
    final labelSize = isTablet ? 14.0 : (isSmallScreen ? 12.0 : 13.0);
    final iconSize = isTablet ? 24.0 : (isSmallScreen ? 20.0 : 22.0);
    final helperTextSize = isTablet ? 12.0 : (isSmallScreen ? 10.0 : 11.0);

    // الحصول على نص الخطأ من خلال validator
    final error = validator(controller.text);
    final bool isLoginError = error != null && error.contains("تسجيل الدخول؟");

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: size.height * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // حقل الإدخال المحسن
          FormField<String>(
            validator: (_) => isLoginError ? " " : error, // فقط لتشغيل الصلاحية
            autovalidateMode: AutovalidateMode.onUserInteraction,
            builder: (FormFieldState<String> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    textAlign: TextAlign.right,
                    textInputAction: textInputAction,
                    onFieldSubmitted: onSubmitted,
                    onTap: () {
                      // تضمن فتح لوحة المفاتيح عند الضغط على الحقل
                      FocusScope.of(context).requestFocus(focusNode);
                    },
                    onChanged: (value) {
                      state.didChange(value);
                      if (onChanged != null) {
                        onChanged!(value);
                      }
                    },
                    style: TextStyle(
                      color: AppColors.textPrimary, // Updated
                      fontSize: fontSize,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      labelText: title,
                      labelStyle: TextStyle(
                        color: focusNode.hasFocus
                            ? AppColors.primaryLight // Updated
                            : AppColors.textPrimary.withOpacity(0.7), // Updated
                        fontSize: labelSize,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      hintStyle: TextStyle(
                        color: AppColors.textHint, // Updated
                        fontSize: labelSize,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      prefixIcon: Icon(
                        icon,
                        color: focusNode.hasFocus || controller.text.isNotEmpty
                            ? AppColors.primaryLight // Updated
                            : AppColors.textHint, // Updated
                        size: iconSize,
                      ),
                      suffixIcon: suffixIcon,
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
                          color: AppColors.primaryLight, // Updated
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.accent, // Updated
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.accent, // Updated
                          width: 1.5,
                        ),
                      ),
                      // لا نعرض رسالة خطأ هنا للتحكم فيها يدويًا
                      errorStyle: TextStyle(
                        height: 0,
                        color: Colors.transparent,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical:
                            isTablet ? 20.0 : (isSmallScreen ? 16.0 : 18.0),
                        horizontal: 20,
                      ),
                    ),
                    validator: (_) => null, // لا نستخدم التحقق الداخلي
                  ),

                  // عرض رسالة الخطأ العادية
                  if (state.hasError && !isLoginError)
                    Padding(
                      padding: EdgeInsets.only(
                        top: 4.0,
                        right: 12.0,
                      ),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: AppColors.accent, // Updated
                          fontSize: 12,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),

                  // عرض رسالة خطأ مخصصة مع زر تسجيل الدخول إذا كان الخطأ متعلق بحساب موجود
                  if (isLoginError && onLoginPressed != null)
                    Padding(
                      padding: EdgeInsets.only(
                        top: 4.0, // نفس المسافة تمامًا مثل رسائل الخطأ العادية
                        right: 12.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.accent, // Updated
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            error!.split("تسجيل الدخول؟")[0].trim(),
                            style: TextStyle(
                              color: AppColors.accent, // Updated
                              fontSize: 12,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          SizedBox(width: 4),
                          GestureDetector(
                            onTap: onLoginPressed,
                            child: Text(
                              "تسجيل الدخول",
                              style: TextStyle(
                                color: AppColors.primaryLight, // Updated
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 12,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),

          // نص المساعدة إذا كان موجودًا
          if (helperText != null &&
              (!showPasswordStrength || controller.text.isEmpty))
            Padding(
              padding: EdgeInsets.only(
                top: size.height * 0.01,
                right: screenWidth * 0.03,
              ),
              child: Text(
                helperText!,
                style: TextStyle(
                  color: AppColors.textHint, // Updated
                  fontSize: helperTextSize,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}
