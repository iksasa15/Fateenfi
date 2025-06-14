import 'package:flutter/material.dart';
import '../../constants/appColor.dart';
import '../../constants/app_dimensions.dart';

class EnhancedSelectionField extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final IconData icon;
  final VoidCallback onTap;
  final String? errorText;
  final bool isEditable;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const EnhancedSelectionField({
    Key? key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.icon,
    required this.onTap,
    this.errorText,
    this.isEditable = false,
    this.focusNode,
    this.validator,
  }) : super(key: key);

  @override
  State<EnhancedSelectionField> createState() => _EnhancedSelectionFieldState();
}

class _EnhancedSelectionFieldState extends State<EnhancedSelectionField> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.getSpacing(context, size: SpacingSize.small),
        horizontal: AppDimensions.getSpacing(context, size: SpacingSize.large),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(AppDimensions.getLargeRadius(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0.5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: widget.isEditable
            ? _buildTextField(context, isSmallScreen)
            : _buildReadOnlyField(context, isSmallScreen),
      ),
    );
  }

  // بناء حقل النص في حالة قابل للتحرير
  Widget _buildTextField(BuildContext context, bool isSmallScreen) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppDimensions.getBodyFontSize(context, small: isSmallScreen),
        fontFamily: 'SYMBIOAR+LT',
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.title,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(
          color: AppColors.textPrimary.withOpacity(0.7),
          fontSize:
              AppDimensions.getLabelFontSize(context, small: isSmallScreen),
          fontFamily: 'SYMBIOAR+LT',
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: AppColors.textHint,
          fontSize:
              AppDimensions.getLabelFontSize(context, small: isSmallScreen),
          fontFamily: 'SYMBIOAR+LT',
        ),
        prefixIcon: Icon(
          widget.icon,
          color: _isFocused ? AppColors.primaryLight : AppColors.textHint,
          size: AppDimensions.getIconSize(context, small: isSmallScreen),
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: AppColors.primaryLight,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(
          color: AppColors.accent,
          fontSize:
              AppDimensions.getLabelFontSize(context, small: isSmallScreen) - 1,
          fontFamily: 'SYMBIOAR+LT',
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical:
              AppDimensions.getInputFieldPadding(context, small: isSmallScreen),
          horizontal:
              AppDimensions.getSpacing(context, size: SpacingSize.medium),
        ),
        errorText: widget.errorText,
      ),
      validator: widget.validator,
    );
  }

  // بناء حقل للقراءة فقط للاختيار من القائمة المنسدلة
  Widget _buildReadOnlyField(BuildContext context, bool isSmallScreen) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      focusNode: _focusNode,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppDimensions.getBodyFontSize(context, small: isSmallScreen),
        fontFamily: 'SYMBIOAR+LT',
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        labelText: widget.title,
        hintText: widget.controller.text.isEmpty ? widget.hintText : null,
        floatingLabelBehavior: widget.controller.text.isEmpty
            ? FloatingLabelBehavior.auto
            : FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          color: _isFocused
              ? AppColors.primaryLight
              : AppColors.textPrimary.withOpacity(0.7),
          fontSize:
              AppDimensions.getLabelFontSize(context, small: isSmallScreen),
          fontFamily: 'SYMBIOAR+LT',
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: AppColors.textHint,
          fontSize:
              AppDimensions.getLabelFontSize(context, small: isSmallScreen),
          fontFamily: 'SYMBIOAR+LT',
        ),
        prefixIcon: Icon(
          widget.icon,
          color: _isFocused ? AppColors.primaryLight : AppColors.textHint,
          size: AppDimensions.getIconSize(context, small: isSmallScreen),
        ),
        suffixIcon: Icon(
          Icons.arrow_drop_down,
          color: _isFocused ? AppColors.primaryLight : AppColors.textHint,
          size: AppDimensions.getIconSize(context, small: isSmallScreen) + 4,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: AppColors.primaryLight,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.getLargeRadius(context)),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(
          color: AppColors.accent,
          fontSize:
              AppDimensions.getLabelFontSize(context, small: isSmallScreen) - 1,
          fontFamily: 'SYMBIOAR+LT',
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical:
              AppDimensions.getInputFieldPadding(context, small: isSmallScreen),
          horizontal:
              AppDimensions.getSpacing(context, size: SpacingSize.medium),
        ),
        errorText: widget.errorText,
      ),
      onTap: widget.onTap,
      validator: widget.validator,
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(() {});
    super.dispose();
  }
}
