// lib/features/step_form/components/input_fields/password_field_component.dart

import 'package:flutter/material.dart';
import '../../../../../../core/constants/appColor.dart'; // Updated import
import '../enhanced_input_field.dart';
import '../password_requirements_component.dart';

class PasswordFieldComponent extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?) validator;
  final Function(String) onSubmitted;
  final bool passwordVisible;
  final VoidCallback togglePasswordVisibility;
  final Function(String) calculatePasswordStrength;
  final Function(String) getPasswordStrengthText;

  const PasswordFieldComponent({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.onSubmitted,
    required this.passwordVisible,
    required this.togglePasswordVisibility,
    required this.calculatePasswordStrength,
    required this.getPasswordStrengthText,
  }) : super(key: key);

  @override
  _PasswordFieldComponentState createState() => _PasswordFieldComponentState();
}

class _PasswordFieldComponentState extends State<PasswordFieldComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EnhancedInputField(
          title: 'كلمة المرور',
          hintText: 'أنشئ كلمة مرور قوية',
          controller: widget.controller,
          focusNode: widget.focusNode,
          icon: Icons.lock_outline,
          validator: widget.validator,
          textInputAction: TextInputAction.next,
          obscureText: !widget.passwordVisible,
          onSubmitted: widget.onSubmitted,
          suffixIcon: IconButton(
            icon: Icon(
              widget.passwordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: widget.passwordVisible
                  ? AppColors.primaryLight // Updated
                  : AppColors.textHint, // Updated
            ),
            onPressed: widget.togglePasswordVisibility,
          ),
          helperText: 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل',
          onChanged: (value) {
            setState(() {});
          },
        ),
        if (widget.controller.text.isNotEmpty)
          PasswordRequirementsComponent(
            password: widget.controller.text,
            calculatePasswordStrength: widget.calculatePasswordStrength,
            getPasswordStrengthText: widget.getPasswordStrengthText,
          ),
      ],
    );
  }
}
