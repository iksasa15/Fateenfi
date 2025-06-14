// lib/features/step_form/components/input_fields/email_field_component.dart

import 'package:fateen/core/constants/appColor.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/constants/appColor.dart'; // Updated import
import '../enhanced_input_field.dart';

class EmailFieldComponent extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?) validator;
  final Function(String) onSubmitted;
  final bool isCheckingEmail;
  final String? emailError;
  final Function(String) onChanged;
  final VoidCallback? onLoginPressed;

  const EmailFieldComponent({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.onSubmitted,
    required this.isCheckingEmail,
    required this.emailError,
    required this.onChanged,
    this.onLoginPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnhancedInputField(
      title: 'البريد الإلكتروني',
      hintText: 'أدخل بريدك الإلكتروني',
      controller: controller,
      focusNode: focusNode,
      icon: Icons.email_outlined,
      validator: _customValidator,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      onSubmitted: onSubmitted,
      onChanged: onChanged, // استخدام دالة onChanged التي تم تمريرها بالفعل
      suffixIcon: isCheckingEmail
          ? Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryLight, // Updated
              ),
            )
          : emailError != null
              ? Icon(
                  Icons.error_outline,
                  color: AppColors.accent, // Updated
                  size: 20,
                )
              : null,
      helperText: 'سيتم استخدامه للتحقق من حسابك',
      onLoginPressed: onLoginPressed,
    );
  }

  // دالة مخصصة للتحقق من صحة البريد الإلكتروني
  String? _customValidator(String? value) {
    // استخدام دالة التحقق الأصلية
    final originalError = validator(value);

    // إذا كان هناك خطأ في البريد الإلكتروني يتعلق بحساب موجود
    if (emailError != null && emailError!.contains("مستخدم بالفعل")) {
      return "البريد الإلكتروني موجود بالفعل. تسجيل الدخول؟";
    }

    // إذا كان هناك خطأ بريد إلكتروني آخر، نعيده كما هو
    if (emailError != null) {
      return emailError;
    }

    // وإلا نستخدم رسالة التحقق الأصلية
    return originalError;
  }
}
