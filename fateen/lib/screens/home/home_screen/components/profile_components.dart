import 'package:flutter/material.dart';
import '../constants/profileConstants.dart';

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
        // استخدام MediaQuery للحصول على أبعاد الشاشة
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        // تعديل الأحجام بناءً على حجم الشاشة
        final double iconSize =
            isSmallScreen ? 55.0 : (isMediumScreen ? 60.0 : 65.0);
        final double nameSize =
            isSmallScreen ? 22.0 : (isMediumScreen ? 24.0 : 26.0);
        final double majorSize =
            isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);
        final double emailSize =
            isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              children: [
                // أيقونة المستخدم
                Container(
                  padding: EdgeInsets.all(screenSize.width * 0.03),
                  decoration: BoxDecoration(
                    color: ProfileConstants.kDarkPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: iconSize,
                    color: ProfileConstants.kDarkPurple,
                  ),
                ),

                SizedBox(height: screenSize.height * 0.02),

                // اسم المستخدم
                Text(
                  name,
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.bold,
                    color: ProfileConstants.kDarkPurple,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: screenSize.height * 0.01),

                // التخصص
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.03,
                    vertical: screenSize.height * 0.0075,
                  ),
                  decoration: BoxDecoration(
                    color: ProfileConstants.kLightPurple,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    major,
                    style: TextStyle(
                      fontSize: majorSize,
                      color: ProfileConstants.kMediumPurple,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SYMBIOAR+LT',
                      height: 1.2,
                    ),
                  ),
                ),

                SizedBox(height: screenSize.height * 0.015),

                // البريد الإلكتروني
                if (email.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: emailSize + 4,
                        color: ProfileConstants.kHintColor,
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: emailSize,
                          color: ProfileConstants.kHintColor,
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
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        final double titleSize =
            isSmallScreen ? 17.0 : (isMediumScreen ? 18.0 : 19.0);

        return Container(
          margin: EdgeInsets.only(
            top: isFirst ? 0 : screenSize.height * 0.025,
            bottom: screenSize.height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان القسم
              Padding(
                padding: EdgeInsets.only(
                  bottom: screenSize.height * 0.015,
                  right: screenSize.width * 0.04,
                  left: screenSize.width * 0.04,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: ProfileConstants.kDarkPurple,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                ),
              ),

              // محتوى القسم
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
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
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        final double titleSize =
            isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);
        final double subtitleSize =
            isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
        final double iconSize =
            isSmallScreen ? 22.0 : (isMediumScreen ? 23.0 : 24.0);

        return InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04,
                  vertical: screenSize.height * 0.015,
                ),
                child: Row(
                  children: [
                    // أيقونة العنصر
                    Container(
                      padding: EdgeInsets.all(screenSize.width * 0.02),
                      decoration: BoxDecoration(
                        color: (iconColor ?? ProfileConstants.kDarkPurple)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor ??
                            (isDanger
                                ? ProfileConstants.dangerColor
                                : ProfileConstants.kDarkPurple),
                        size: iconSize,
                      ),
                    ),

                    SizedBox(width: screenSize.width * 0.04),

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
                              color: isDanger
                                  ? ProfileConstants.dangerColor
                                  : ProfileConstants.kTextColor,
                              fontFamily: 'SYMBIOAR+LT',
                              height: 1.2,
                            ),
                          ),
                          if (subtitle != null)
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height * 0.005,
                              ),
                              child: Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: ProfileConstants.kHintColor,
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
                      color: ProfileConstants.kHintColor,
                      size: iconSize - 6,
                    ),
                  ],
                ),
              ),

              // خط فاصل
              if (showDivider)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: screenSize.width * 0.14,
                  endIndent: 0,
                  color: Colors.grey[100],
                ),
            ],
          ),
        );
      },
    );
  }

  /// بناء حقل إدخال للنموذج (مطابق للتصميم القديم)
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
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        final double labelSize =
            isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 17.0);
        final double inputSize =
            isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 17.0);
        final double hintSize =
            isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
        final double iconSize =
            isSmallScreen ? 22.0 : (isMediumScreen ? 23.0 : 24.0);

        return Container(
          margin: EdgeInsets.only(
            bottom: screenSize.height * 0.025,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // تسمية الحقل
              Padding(
                padding: EdgeInsets.only(
                  bottom: screenSize.height * 0.01,
                  right: screenSize.width * 0.01,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: FontWeight.w500,
                    color: ProfileConstants.kTextColor,
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
                  color: ProfileConstants.kTextColor,
                  fontSize: inputSize,
                  fontFamily: 'SYMBIOAR+LT',
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: ProfileConstants.kHintColor,
                    fontSize: hintSize,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: controller.text.isEmpty
                        ? ProfileConstants.kHintColor
                        : ProfileConstants.kMediumPurple,
                    size: iconSize,
                  ),
                  suffixIcon: suffix,
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ProfileConstants.kMediumPurple,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ProfileConstants.kAccentColorPink,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ProfileConstants.kAccentColorPink,
                      width: 1.5,
                    ),
                  ),
                  errorStyle: TextStyle(
                    color: ProfileConstants.kAccentColorPink,
                    fontSize: hintSize - 2,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.02,
                    horizontal: screenSize.width * 0.05,
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

  /// بناء زر أساسي (مطابق للتصميم القديم)
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
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        final double buttonHeight = isSmallScreen
            ? screenSize.height * 0.055
            : (isMediumScreen
                ? screenSize.height * 0.06
                : screenSize.height * 0.065);

        final double textSize =
            isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 17.0);

        final double iconSize = textSize + 6;

        final Color buttonColor = isDanger
            ? ProfileConstants.dangerColor
            : (isPrimary ? ProfileConstants.kDarkPurple : Colors.grey[300]!);

        final Color textColor =
            isPrimary || isDanger ? Colors.white : Colors.black87;

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
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(
                vertical: screenSize.height * 0.015,
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
                            left: screenSize.width * 0.02,
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
    String confirmText = ProfileConstants.confirmText,
    String cancelText = ProfileConstants.cancelText,
    bool isDanger = false,
  }) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    final double titleSize =
        isSmallScreen ? 17.0 : (isMediumScreen ? 18.0 : 19.0);
    final double messageSize =
        isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 17.0);
    final double buttonTextSize =
        isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: isDanger
                ? ProfileConstants.dangerColor
                : ProfileConstants.kDarkPurple,
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
                color: Colors.grey[700],
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
              foregroundColor: isDanger
                  ? ProfileConstants.dangerColor
                  : ProfileConstants.kDarkPurple,
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
    // تعديل الأحجام حسب حجم الشاشة
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    final double fontSize =
        isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0);
    final double iconSize =
        isSmallScreen ? 19.0 : (isMediumScreen ? 20.0 : 22.0);
    final double padding =
        isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 14.0);

    return Container(
      margin: EdgeInsets.only(
        bottom: screenSize.height * 0.025,
      ),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: ProfileConstants.kAccentColorPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: ProfileConstants.kAccentColorPink,
            size: iconSize,
          ),
          SizedBox(width: screenSize.width * 0.025),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: ProfileConstants.kAccentColorPink,
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
        final Size screenSize = MediaQuery.of(context).size;
        final bool isSmallScreen = screenSize.width < 360;
        final bool isMediumScreen =
            screenSize.width >= 360 && screenSize.width < 400;

        final double messageSize =
            isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 17.0);
        final double indicatorSize =
            isSmallScreen ? 25.0 : (isMediumScreen ? 28.0 : 30.0);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: indicatorSize,
                height: indicatorSize,
                child: const CircularProgressIndicator(
                  color: ProfileConstants.kDarkPurple,
                  strokeWidth: 3.0,
                ),
              ),
              if (message != null) SizedBox(height: screenSize.height * 0.02),
              if (message != null)
                Text(
                  message,
                  style: TextStyle(
                    fontSize: messageSize,
                    color: Colors.grey.shade600,
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
