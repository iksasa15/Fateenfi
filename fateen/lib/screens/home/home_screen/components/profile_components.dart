import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

/// مكونات الملف الشخصي
class ProfileComponents {
  /// بناء بطاقة معلومات المستخدم
  static Widget buildProfileCard({
    required String name,
    required String major,
    required String email,
    VoidCallback? onEditPressed,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // استخدام أبعاد التطبيق المتجاوبة
        final double iconSize = AppDimensions.getIconSize(context,
            size: IconSize.large, small: false);
        final double nameSize = AppDimensions.getTitleFontSize(context);
        final double majorSize = AppDimensions.getSubtitleFontSize(context);
        final double emailSize = AppDimensions.getBodyFontSize(context);

        return Card(
          elevation: AppDimensions.defaultElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
            child: Column(
              children: [
                // أيقونة المستخدم
                Container(
                  padding: EdgeInsets.all(AppDimensions.getSpacing(context,
                      size: SpacingSize.small)),
                  decoration: BoxDecoration(
                    color: context.colorPrimaryPale,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: iconSize,
                    color: context.colorPrimary,
                  ),
                ),

                SizedBox(
                    height: AppDimensions.getSpacing(context,
                        size: SpacingSize.medium)),

                // اسم المستخدم
                Text(
                  name,
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.bold,
                    color: context.colorPrimary,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(
                    height: AppDimensions.getSpacing(context,
                        size: SpacingSize.small)),

                // التخصص
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.getSpacing(context,
                        size: SpacingSize.small),
                    vertical: AppDimensions.getSpacing(context,
                            size: SpacingSize.small) /
                        2,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorPrimaryPale,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.mediumRadius),
                  ),
                  child: Text(
                    major,
                    style: TextStyle(
                      fontSize: majorSize,
                      color: context.colorPrimary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SYMBIOAR+LT',
                      height: 1.2,
                    ),
                  ),
                ),

                SizedBox(
                    height: AppDimensions.getSpacing(context,
                        size: SpacingSize.small)),

                // البريد الإلكتروني
                if (email.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: emailSize + 4,
                        color: context.colorTextHint,
                      ),
                      SizedBox(
                          width: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: emailSize,
                          color: context.colorTextHint,
                          fontFamily: 'SYMBIOAR+LT',
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// بناء قسم في الإعدادات
  static Widget buildSettingsSection({
    required String title,
    required List<Widget> children,
    bool isFirst = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double titleSize = AppDimensions.getSubtitleFontSize(context);

        return Container(
          margin: EdgeInsets.only(
            top: isFirst
                ? 0
                : AppDimensions.getSpacing(context, size: SpacingSize.large),
            bottom: AppDimensions.getSpacing(context, size: SpacingSize.small),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان القسم
              Padding(
                padding: EdgeInsets.only(
                  bottom: AppDimensions.getSpacing(context,
                      size: SpacingSize.small),
                  right: AppDimensions.getSpacing(context),
                  left: AppDimensions.getSpacing(context),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: context.colorPrimaryDark,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                ),
              ),

              // محتوى القسم
              Container(
                decoration: BoxDecoration(
                  color: context.colorSurface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorShadow,
                      spreadRadius: 0,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: children,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// بناء عنصر في قائمة الإعدادات
  static Widget buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    VoidCallback? onTap,
    bool showDivider = true,
    bool isDanger = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double titleSize = AppDimensions.getBodyFontSize(context);
        final double subtitleSize = AppDimensions.getLabelFontSize(context);
        final double iconSize = AppDimensions.getIconSize(context,
            size: IconSize.small, small: false);

        final Color defaultIconColor =
            isDanger ? context.colorError : context.colorPrimary;
        final Color textColor =
            isDanger ? context.colorError : context.colorTextPrimary;

        return InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.getSpacing(context),
                  vertical: AppDimensions.getSpacing(context,
                      size: SpacingSize.small),
                ),
                child: Row(
                  children: [
                    // أيقونة العنصر
                    Container(
                      padding: EdgeInsets.all(AppDimensions.getSpacing(context,
                              size: SpacingSize.small) /
                          2),
                      decoration: BoxDecoration(
                        color: (iconColor ?? defaultIconColor).withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor ?? defaultIconColor,
                        size: iconSize,
                      ),
                    ),

                    SizedBox(
                        width: AppDimensions.getSpacing(context,
                            size: SpacingSize.small)),

                    // النص والوصف
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                              fontFamily: 'SYMBIOAR+LT',
                              height: 1.2,
                            ),
                          ),
                          if (subtitle != null)
                            Padding(
                              padding: EdgeInsets.only(
                                top: AppDimensions.getSpacing(context,
                                        size: SpacingSize.small) /
                                    3,
                              ),
                              child: Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: context.colorTextHint,
                                  fontFamily: 'SYMBIOAR+LT',
                                  height: 1.2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // أيقونة السهم
                    Icon(
                      Icons.arrow_forward_ios,
                      color: context.colorTextHint,
                      size: iconSize - 4,
                    ),
                  ],
                ),
              ),

              // خط فاصل
              if (showDivider)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: AppDimensions.getWidth(context, percentage: 0.14),
                  endIndent: 0,
                  color: context.colorDivider,
                ),
            ],
          ),
        );
      },
    );
  }

  /// بناء حقل إدخال للنموذج
  static Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
    bool enabled = true,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double labelSize = AppDimensions.getBodyFontSize(context);
        final double inputSize = AppDimensions.getBodyFontSize(context);
        final double hintSize = AppDimensions.getLabelFontSize(context);
        final double iconSize = AppDimensions.getIconSize(context,
            size: IconSize.small, small: false);

        return Container(
          margin: EdgeInsets.only(
            bottom: AppDimensions.getSpacing(context, size: SpacingSize.medium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // تسمية الحقل
              Padding(
                padding: EdgeInsets.only(
                  bottom: AppDimensions.getSpacing(context,
                      size: SpacingSize.small),
                  right: AppDimensions.getSpacing(context,
                          size: SpacingSize.small) /
                      2,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: FontWeight.w500,
                    color: context.colorTextPrimary,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                ),
              ),

              // حقل الإدخال
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: context.colorTextPrimary,
                  fontSize: inputSize,
                  fontFamily: 'SYMBIOAR+LT',
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: context.colorTextHint,
                    fontSize: hintSize,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: controller.text.isEmpty
                        ? context.colorTextHint
                        : context.colorPrimary,
                    size: iconSize,
                  ),
                  suffixIcon: suffix,
                  filled: true,
                  fillColor: context.colorSurface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.inputBorderRadius),
                    borderSide: BorderSide(
                      color: context.colorBorder,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.inputBorderRadius),
                    borderSide: BorderSide(
                      color: context.colorPrimary,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.inputBorderRadius),
                    borderSide: BorderSide(
                      color: context.colorError,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.inputBorderRadius),
                    borderSide: BorderSide(
                      color: context.colorError,
                      width: 1.5,
                    ),
                  ),
                  errorStyle: TextStyle(
                    color: context.colorError,
                    fontSize: hintSize - 2,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: AppDimensions.getSpacing(context,
                        size: SpacingSize.small),
                    horizontal: AppDimensions.getSpacing(context),
                  ),
                ),
                maxLines: obscureText ? 1 : maxLines,
                maxLength: maxLength,
                enabled: enabled,
                validator: validator,
              ),
            ],
          ),
        );
      },
    );
  }

  /// بناء زر أساسي
  static Widget buildButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
    bool isLoading = false,
    bool isDanger = false,
    IconData? icon,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double buttonHeight = AppDimensions.getButtonHeight(
          context,
          size: ButtonSize.regular,
          small: false,
        );

        final double textSize = AppDimensions.getButtonFontSize(context);
        final double iconSize = textSize + 6;

        final Color buttonColor = isDanger
            ? context.colorError
            : (isPrimary ? context.colorPrimary : context.colorSurfaceLight);

        final Color textColor =
            isPrimary || isDanger ? Colors.white : context.colorTextPrimary;

        return SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: textColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
              ),
              padding: EdgeInsets.symmetric(
                vertical:
                    AppDimensions.getSpacing(context, size: SpacingSize.small),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: textColor,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null)
                        Padding(
                          padding: EdgeInsets.only(
                            left: AppDimensions.getSpacing(context,
                                    size: SpacingSize.small) /
                                2,
                          ),
                          child: Icon(icon, size: iconSize),
                        ),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: textSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SYMBIOAR+LT',
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// بناء مربع حوار تأكيد
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = "تأكيد",
    String cancelText = "إلغاء",
    bool isDanger = false,
  }) {
    final double titleSize = AppDimensions.getSubtitleFontSize(context);
    final double messageSize = AppDimensions.getBodyFontSize(context);
    final double buttonTextSize = AppDimensions.getLabelFontSize(context);

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: isDanger ? context.colorError : context.colorPrimary,
            fontWeight: FontWeight.bold,
            fontSize: titleSize,
            fontFamily: 'SYMBIOAR+LT',
            height: 1.2,
          ),
          textAlign: TextAlign.right,
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: messageSize,
            fontFamily: 'SYMBIOAR+LT',
            height: 1.2,
            color: context.colorTextPrimary,
          ),
          textAlign: TextAlign.right,
        ),
        actions: [
          // زر الإلغاء
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: context.colorTextSecondary,
                fontSize: buttonTextSize,
                fontFamily: 'SYMBIOAR+LT',
                height: 1.2,
              ),
            ),
          ),

          // زر التأكيد
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDanger ? context.colorError : context.colorPrimary,
            ),
            child: Text(
              confirmText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: buttonTextSize,
                fontFamily: 'SYMBIOAR+LT',
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء عنصر خطأ من السيرفر
  static Widget buildServerError(BuildContext context, String errorMessage) {
    final double fontSize = AppDimensions.getLabelFontSize(context);
    final double iconSize =
        AppDimensions.getIconSize(context, size: IconSize.small, small: true);
    final double padding =
        AppDimensions.getSpacing(context, size: SpacingSize.small);

    return Container(
      margin: EdgeInsets.only(
        bottom: AppDimensions.getSpacing(context, size: SpacingSize.medium),
      ),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: context.colorError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: context.colorError,
            size: iconSize,
          ),
          SizedBox(
              width:
                  AppDimensions.getSpacing(context, size: SpacingSize.small) /
                      2),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: context.colorError,
                fontSize: fontSize,
                fontFamily: 'SYMBIOAR+LT',
                height: 1.2,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء مؤشر التحميل
  static Widget buildLoadingIndicator({String? message}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double messageSize = AppDimensions.getBodyFontSize(context);
        final double indicatorSize = AppDimensions.getIconSize(context,
            size: IconSize.medium, small: false);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: indicatorSize,
                height: indicatorSize,
                child: CircularProgressIndicator(
                  color: context.colorPrimary,
                  strokeWidth: 3.0,
                ),
              ),
              if (message != null)
                SizedBox(
                    height: AppDimensions.getSpacing(context,
                        size: SpacingSize.small)),
              if (message != null)
                Text(
                  message,
                  style: TextStyle(
                    fontSize: messageSize,
                    color: context.colorTextSecondary,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
