// lib/features/step_form/components/input_fields/username_field_component.dart

import 'package:flutter/material.dart';
import '../../../constants/signup_colors.dart';
import '../enhanced_input_field.dart';

class UsernameFieldComponent extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?) validator;
  final Function(String) onSubmitted;
  final bool isCheckingUsername;
  final String? usernameError;
  final Function(String) onChanged;
  final VoidCallback? onLoginPressed;

  const UsernameFieldComponent({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.onSubmitted,
    required this.isCheckingUsername,
    required this.usernameError,
    required this.onChanged,
    this.onLoginPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnhancedInputField(
      title: 'اسم المستخدم',
      hintText: 'أدخل اسم المستخدم',
      controller: controller,
      focusNode: focusNode,
      icon: Icons.alternate_email,
      validator: _customValidator,
      textInputAction: TextInputAction.next,
      onSubmitted: onSubmitted,
      onChanged: onChanged, // استخدام دالة onChanged التي تم تمريرها بالفعل
      suffixIcon: isCheckingUsername
          ? Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: SignupColors.mediumPurple,
              ),
            )
          : usernameError != null
              ? Icon(
                  Icons.error_outline,
                  color: SignupColors.accentColor,
                  size: 20,
                )
              : null,
      helperText: 'سيظهر للمستخدمين الآخرين، ويستخدم لتسجيل الدخول',
      onLoginPressed: onLoginPressed,
    );
  }

  // دالة مخصصة للتحقق من صحة اسم المستخدم
  String? _customValidator(String? value) {
    // استخدام دالة التحقق الأصلية
    final originalError = validator(value);

    // إذا كان هناك خطأ في اسم المستخدم يتعلق بحساب موجود
    if (usernameError != null && usernameError!.contains("مستخدم بالفعل")) {
      return "اسم المستخدم موجود بالفعل. تسجيل الدخول؟";
    }

    // إذا كان هناك خطأ اسم مستخدم آخر، نعيده كما هو
    if (usernameError != null) {
      return usernameError;
    }

    // وإلا نستخدم رسالة التحقق الأصلية
    return originalError;
  }
}
