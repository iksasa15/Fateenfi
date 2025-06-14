import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart';
import '../constants/reset_password_strings.dart';
import '../controllers/reset_password_controller.dart';
import '../../../../core/components/Field/enhanced_input_field.dart'; // استيراد المكون الموحد

class ResetFormComponent extends StatefulWidget {
  final ResetPasswordController controller;
  final String? Function(String?) validator;

  const ResetFormComponent({
    Key? key,
    required this.controller,
    required this.validator,
  }) : super(key: key);

  @override
  State<ResetFormComponent> createState() => _ResetFormComponentState();
}

class _ResetFormComponentState extends State<ResetFormComponent> {
  // إضافة FocusNode للحقل
  final FocusNode _emailFocusNode = FocusNode();

  // إضافة GlobalKey للحقل
  final GlobalKey<FormFieldState> _emailFieldKey = GlobalKey<FormFieldState>();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedInputField(
      title: ResetPasswordStrings.emailLabel,
      hintText: ResetPasswordStrings.emailHint,
      controller: widget.controller.emailController,
      icon: Icons.email_outlined,
      validator: widget.validator,
      focusNode: _emailFocusNode,
      formFieldKey: _emailFieldKey,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      enabled: !widget.controller.isLoading,
      isError: widget.controller.serverError != null,
      onFieldSubmitted: (_) {
        // إخفاء لوحة المفاتيح عند الانتهاء
        FocusScope.of(context).unfocus();
      },
      onChanged: (value) {
        // مسح رسائل الخطأ عند الكتابة
        if (widget.controller.serverError != null) {
          setState(() {
            widget.controller.clearError();
          });
        }
      },
    );
  }
}
