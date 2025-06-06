// lib/features/step_form/components/input_fields/name_field_component.dart

import 'package:flutter/material.dart';
import '../../../constants/signup_colors.dart';
import '../enhanced_input_field.dart';

class NameFieldComponent extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?) validator;
  final Function(String) onSubmitted;

  const NameFieldComponent({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnhancedInputField(
      title: 'الاسم الكامل',
      hintText: 'أدخل اسمك الكامل',
      controller: controller,
      focusNode: focusNode,
      icon: Icons.person_outline,
      validator: validator,
      textInputAction: TextInputAction.next,
      onSubmitted: onSubmitted,
      helperText: 'مثال: محمد عبدالله العنزي',
    );
  }
}
