import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/appColor.dart';
import '../../constants/app_dimensions.dart';

class EnhancedInputField extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?) validator;
  final FocusNode focusNode;
  final GlobalKey<FormFieldState> formFieldKey;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final bool isError;
  final Function()? onTap;
  final Function(String)? onChanged;

  const EnhancedInputField({
    Key? key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.icon,
    required this.validator,
    required this.focusNode,
    required this.formFieldKey,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.isError = false,
    this.onTap,
    this.onChanged,
  }) : super(key: key);

  @override
  State<EnhancedInputField> createState() => _EnhancedInputFieldState();
}

class _EnhancedInputFieldState extends State<EnhancedInputField> {
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    // استخدام دوال الأبعاد
    final fontSize =
        AppDimensions.getBodyFontSize(context, small: isSmallScreen);
    final labelSize =
        AppDimensions.getLabelFontSize(context, small: isSmallScreen);
    final iconSize = AppDimensions.getIconSize(context, small: isSmallScreen);

    // استخدام النسب المئوية لضبط الهوامش بناءً على عرض الشاشة
    final horizontalPadding =
        AppDimensions.getSpacing(context, size: SpacingSize.large);

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical:
              AppDimensions.getSpacing(context, size: SpacingSize.small) + 2,
          horizontal: horizontalPadding),
      child: TextFormField(
        key: widget.formFieldKey,
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        textAlign: TextAlign.right,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted,
        enabled: widget.enabled,
        onTap: () {
          if (widget.enabled) {
            // تطبيق تأثير حسي عند الضغط
            HapticFeedback.selectionClick();
            // استدعاء دالة onTap المخصصة إذا تم تمريرها
            if (widget.onTap != null) {
              widget.onTap!();
            }
          }
        },
        onChanged: (value) {
          // عند تغيير النص، قم بإعادة التحقق من الحقل وإزالة رسالة الخطأ إذا كان النص صحيحاً
          if (widget.formFieldKey.currentState != null &&
              widget.formFieldKey.currentState!.hasError) {
            // إعادة التحقق فقط إذا كان هناك خطأ
            if (widget.validator(value) == null) {
              widget.formFieldKey.currentState!.validate();
            }
          }

          // استدعاء دالة onChanged المخصصة إذا تم تمريرها
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        style: TextStyle(
          color: widget.enabled
              ? context.colorTextPrimary
              : context.colorTextPrimary.withOpacity(0.6),
          fontSize: fontSize,
          fontFamily: 'SYMBIOAR+LT',
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.title,
          labelStyle: TextStyle(
            color: !widget.enabled
                ? context.colorTextPrimary.withOpacity(0.4)
                : widget.isError
                    ? context.colorAccent
                    : (widget.focusNode.hasFocus
                        ? context.colorPrimaryLight
                        : context.colorTextPrimary.withOpacity(0.7)),
            fontSize: labelSize,
            fontFamily: 'SYMBIOAR+LT',
          ),
          hintStyle: TextStyle(
            color:
                context.colorTextHint.withOpacity(widget.enabled ? 1.0 : 0.5),
            fontSize: labelSize,
            fontFamily: 'SYMBIOAR+LT',
          ),
          prefixIcon: Icon(
            widget.icon,
            color: !widget.enabled
                ? context.colorTextHint.withOpacity(0.5)
                : widget.isError
                    ? context.colorAccent
                    : (widget.focusNode.hasFocus ||
                            widget.controller.text.isNotEmpty
                        ? context.colorPrimaryLight
                        : context.colorTextHint),
            size: iconSize,
          ),
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: widget.enabled
              ? context.colorSurface
              : context.colorSurface.withOpacity(0.9),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.getMediumRadius(context)),
            borderSide: BorderSide(
              color: widget.isError
                  ? context.colorAccent
                  : context.isDarkMode
                      ? context.colorBorder
                      : Colors.grey.shade200,
              width: widget.isError ? 1.5 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.getMediumRadius(context)),
            borderSide: BorderSide(
              color: widget.isError
                  ? context.colorAccent
                  : context.colorPrimaryLight,
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.getMediumRadius(context)),
            borderSide: BorderSide(
              color: context.isDarkMode
                  ? context.colorBorder
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.getMediumRadius(context)),
            borderSide: BorderSide(
              color: context.colorAccent,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.getMediumRadius(context)),
            borderSide: BorderSide(
              color: context.colorAccent,
              width: 1.5,
            ),
          ),
          errorStyle: TextStyle(
            color: context.colorAccent,
            fontSize: isSmallScreen ? 10 : 12,
            fontFamily: 'SYMBIOAR+LT',
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: AppDimensions.getInputFieldPadding(context,
                small: isSmallScreen),
            horizontal: 20,
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}
