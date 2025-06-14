import 'package:flutter/material.dart';
import '../../constants/signup_colors.dart';
import '../../constants/signup_strings.dart';
import '../../../../../core/constants/app_dimensions.dart';

class SignupUniversityField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isOtherUniversity;
  final VoidCallback onTap;
  final String? errorText;

  const SignupUniversityField({
    Key? key,
    required this.controller,
    this.focusNode,
    required this.isOtherUniversity,
    required this.onTap,
    this.errorText,
  }) : super(key: key);

  @override
  State<SignupUniversityField> createState() => _SignupUniversityFieldState();
}

class _SignupUniversityFieldState extends State<SignupUniversityField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      widget.focusNode!.addListener(() {
        setState(() {
          _isFocused = widget.focusNode!.hasFocus;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 360;
        final isTablet = screenWidth > 600;

        final fontSize = isTablet
            ? 17.0
            : (isSmallScreen
                ? AppDimensions.smallBodyFontSize
                : AppDimensions.bodyFontSize);
        final labelSize = isTablet ? 16.0 : (isSmallScreen ? 13.0 : 14.0);
        final iconSize = isTablet ? 26.0 : (isSmallScreen ? 20.0 : 22.0);
        final verticalPadding = isTablet ? 24.0 : (isSmallScreen ? 16.0 : 18.0);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: SignupColors.shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.isOtherUniversity
                ? _buildTextField(fontSize, labelSize, iconSize,
                    verticalPadding, isSmallScreen)
                : _buildReadOnlyField(fontSize, labelSize, iconSize,
                    verticalPadding, isSmallScreen),
          ),
        );
      },
    );
  }

  // بناء حقل النص في حالة "أخرى"
  Widget _buildTextField(double fontSize, double labelSize, double iconSize,
      double verticalPadding, bool isSmallScreen) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: SignupColors.textColor,
        fontSize: fontSize,
        fontFamily: 'SYMBIOAR+LT',
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        hintText: SignupStrings.universityNameHint,
        labelText: SignupStrings.universityNameLabel,
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
          Icons.account_balance_outlined,
          color:
              _isFocused ? SignupColors.mediumPurple : SignupColors.hintColor,
          size: iconSize,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
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
        errorText: widget.errorText,
      ),
    );
  }

  // بناء حقل للقراءة فقط للاختيار من القائمة المنسدلة
  Widget _buildReadOnlyField(double fontSize, double labelSize, double iconSize,
      double verticalPadding, bool isSmallScreen) {
    // نستخدم TextFormField عادي مع تعطيل الكتابة فيه ولكن إظهار قيمته
    return TextFormField(
      controller: widget.controller, // استخدام نفس وحدة التحكم الأصلية
      readOnly: true, // جعله للقراءة فقط بدلاً من تعطيله تمامًا
      textAlign: TextAlign.right,
      style: TextStyle(
        color: SignupColors.textColor,
        fontSize: fontSize,
        fontFamily: 'SYMBIOAR+LT',
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        labelText: SignupStrings.universityNameLabel,
        hintText: widget.controller.text.isEmpty
            ? SignupStrings.universityNameHint
            : null,
        floatingLabelBehavior: widget.controller.text.isEmpty
            ? FloatingLabelBehavior.auto
            : FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          color: _isFocused
              ? SignupColors.mediumPurple
              : SignupColors.textColor.withOpacity(0.7),
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
          Icons.account_balance_outlined,
          color:
              _isFocused ? SignupColors.mediumPurple : SignupColors.hintColor,
          size: iconSize,
        ),
        suffixIcon: Icon(
          Icons.arrow_drop_down,
          color:
              _isFocused ? SignupColors.mediumPurple : SignupColors.hintColor,
          size: iconSize + 4,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
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
        errorText: widget.errorText,
      ),
      onTap: widget.onTap, // استخدام نفس الدالة للضغط
    );
  }

  @override
  void dispose() {
    if (widget.focusNode != null) {
      widget.focusNode!.removeListener(() {});
    }
    super.dispose();
  }
}
