import 'package:flutter/material.dart';
import '../../constants/signup_colors.dart';
import '../../constants/signup_strings.dart';
import '../../constants/signup_dimensions.dart';

class SignupMajorField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isOtherMajor;
  final VoidCallback onTap;
  final String? errorText;

  const SignupMajorField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.isOtherMajor,
    required this.onTap,
    this.errorText,
  }) : super(key: key);

  @override
  State<SignupMajorField> createState() => _SignupMajorFieldState();
}

class _SignupMajorFieldState extends State<SignupMajorField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = MediaQuery.of(context).size.width < 360;

        return Padding(
          padding: EdgeInsets.symmetric(
              vertical:
                  SignupDimensions.getSpacing(context, size: SpacingSize.small),
              horizontal: SignupDimensions.getSpacing(context,
                  size: SpacingSize.large)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  SignupDimensions.getLargeRadius(context)),
              boxShadow: [
                BoxShadow(
                  color: SignupColors.shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.isOtherMajor
                ? _buildTextField(context, isSmallScreen)
                : _buildReadOnlyField(context, isSmallScreen),
          ),
        );
      },
    );
  }

  // بناء حقل النص في حالة "أخرى"
  Widget _buildTextField(BuildContext context, bool isSmallScreen) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: SignupColors.textColor,
        fontSize:
            SignupDimensions.getBodyFontSize(context, small: isSmallScreen),
        fontFamily: 'SYMBIOAR+LT',
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        hintText: SignupStrings.majorHint,
        labelText: "التخصص",
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(
          color: SignupColors.textColor.withOpacity(0.7),
          fontSize:
              SignupDimensions.getLabelFontSize(context, small: isSmallScreen),
          fontFamily: 'SYMBIOAR+LT',
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: SignupColors.hintColor,
          fontSize:
              SignupDimensions.getLabelFontSize(context, small: isSmallScreen),
          fontFamily: 'SYMBIOAR+LT',
        ),
        prefixIcon: Icon(
          Icons.school_outlined,
          color:
              _isFocused ? SignupColors.mediumPurple : SignupColors.hintColor,
          size: SignupDimensions.getIconSize(context, small: isSmallScreen),
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignupDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignupDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: SignupColors.mediumPurple,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignupDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: SignupColors.accentColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignupDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: SignupColors.accentColor,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(
          color: SignupColors.accentColor,
          fontSize:
              SignupDimensions.getLabelFontSize(context, small: isSmallScreen) -
                  1,
          fontFamily: 'SYMBIOAR+LT',
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: SignupDimensions.getInputFieldPadding(context,
              small: isSmallScreen),
          horizontal:
              SignupDimensions.getSpacing(context, size: SpacingSize.medium),
        ),
        errorText: widget.errorText,
      ),
    );
  }

  // بناء حقل للقراءة فقط للاختيار من القائمة المنسدلة
  Widget _buildReadOnlyField(BuildContext context, bool isSmallScreen) {
    // نستخدم TextFormField عادي مع تعطيل الكتابة فيه ولكن إظهار قيمته
    return TextFormField(
      controller: widget.controller, // استخدام نفس وحدة التحكم الأصلية
      readOnly: true, // جعله للقراءة فقط بدلاً من تعطيله تمامًا
      textAlign: TextAlign.right,
      style: TextStyle(
        color: SignupColors.textColor,
        fontSize:
            SignupDimensions.getBodyFontSize(context, small: isSmallScreen),
        fontFamily: 'SYMBIOAR+LT',
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        labelText: "التخصص",
        hintText: widget.controller.text.isEmpty ? "اختر التخصص" : null,
        floatingLabelBehavior: widget.controller.text.isEmpty
            ? FloatingLabelBehavior.auto
            : FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          color: _isFocused
              ? SignupColors.mediumPurple
              : SignupColors.textColor.withOpacity(0.7),
          fontSize:
              SignupDimensions.getLabelFontSize(context, small: isSmallScreen),
          fontFamily: 'SYMBIOAR+LT',
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: SignupColors.hintColor,
          fontSize:
              SignupDimensions.getLabelFontSize(context, small: isSmallScreen),
          fontFamily: 'SYMBIOAR+LT',
        ),
        prefixIcon: Icon(
          Icons.school_outlined,
          color:
              _isFocused ? SignupColors.mediumPurple : SignupColors.hintColor,
          size: SignupDimensions.getIconSize(context, small: isSmallScreen),
        ),
        suffixIcon: Icon(
          Icons.arrow_drop_down,
          color:
              _isFocused ? SignupColors.mediumPurple : SignupColors.hintColor,
          size: SignupDimensions.getIconSize(context, small: isSmallScreen) + 4,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignupDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignupDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: SignupColors.mediumPurple,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignupDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: SignupColors.accentColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignupDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: SignupColors.accentColor,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(
          color: SignupColors.accentColor,
          fontSize:
              SignupDimensions.getLabelFontSize(context, small: isSmallScreen) -
                  1,
          fontFamily: 'SYMBIOAR+LT',
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: SignupDimensions.getInputFieldPadding(context,
              small: isSmallScreen),
          horizontal:
              SignupDimensions.getSpacing(context, size: SpacingSize.medium),
        ),
        errorText: widget.errorText,
      ),
      onTap: widget.onTap, // استخدام نفس الدالة للضغط
    );
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(() {});
    super.dispose();
  }
}
