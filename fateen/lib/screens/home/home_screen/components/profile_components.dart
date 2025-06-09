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

        // تعديل الأحجام بناءً على حجم الشاشة
        final double iconSize = isSmallScreen ? 50.0 : 60.0;
        final double nameSize = isSmallScreen ? 20.0 : 22.0;
        final double majorSize = isSmallScreen ? 14.0 : 16.0;
        final double emailSize = isSmallScreen ? 13.0 : 14.0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding:
                EdgeInsets.all(screenSize.width * 0.04), // 4% من عرض الشاشة
            child: Column(
              children: [
                // أيقونة المستخدم
                Container(
                  padding: EdgeInsets.all(
                      screenSize.width * 0.03), // 3% من عرض الشاشة
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

                SizedBox(
                    height: screenSize.height * 0.02), // 2% من ارتفاع الشاشة

                // اسم المستخدم
                Text(
                  name,
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.bold,
                    color: ProfileConstants.kDarkPurple,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(
                    height: screenSize.height * 0.01), // 1% من ارتفاع الشاشة

                // التخصص
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.03, // 3% من عرض الشاشة
                    vertical:
                        screenSize.height * 0.0075, // 0.75% من ارتفاع الشاشة
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
                    ),
                  ),
                ),

                SizedBox(
                    height: screenSize.height * 0.015), // 1.5% من ارتفاع الشاشة

                // البريد الإلكتروني
                if (email.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: emailSize + 4, // أكبر قليلاً من حجم النص
                        color: ProfileConstants.kHintColor,
                      ),
                      SizedBox(
                          width: screenSize.width * 0.02), // 2% من عرض الشاشة
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: emailSize,
                          color: ProfileConstants.kHintColor,
                          fontFamily: 'SYMBIOAR+LT',
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
        final double titleSize = isSmallScreen ? 16.0 : 18.0;

        return Container(
          margin: EdgeInsets.only(
            top: isFirst
                ? 0
                : screenSize.height * 0.025, // 2.5% من ارتفاع الشاشة
            bottom: screenSize.height * 0.01, // 1% من ارتفاع الشاشة
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان القسم
              Padding(
                padding: EdgeInsets.only(
                  bottom: screenSize.height * 0.015, // 1.5% من ارتفاع الشاشة
                  right: screenSize.width * 0.04, // 4% من عرض الشاشة
                  left: screenSize.width * 0.04, // 4% من عرض الشاشة
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: ProfileConstants.kDarkPurple,
                    fontFamily: 'SYMBIOAR+LT',
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
        final double titleSize = isSmallScreen ? 15.0 : 16.0;
        final double subtitleSize = isSmallScreen ? 13.0 : 14.0;
        final double iconSize = isSmallScreen ? 20.0 : 22.0;

        return InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04, // 4% من عرض الشاشة
                  vertical: screenSize.height * 0.015, // 1.5% من ارتفاع الشاشة
                ),
                child: Row(
                  children: [
                    // أيقونة العنصر
                    Container(
                      padding: EdgeInsets.all(
                          screenSize.width * 0.02), // 2% من عرض الشاشة
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

                    SizedBox(
                        width: screenSize.width * 0.04), // 4% من عرض الشاشة

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
                            ),
                          ),
                          if (subtitle != null)
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenSize.height *
                                    0.005, // 0.5% من ارتفاع الشاشة
                              ),
                              child: Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: ProfileConstants.kHintColor,
                                  fontFamily: 'SYMBIOAR+LT',
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
                      size: iconSize - 6, // أصغر من الأيقونة الأساسية
                    ),
                  ],
                ),
              ),

              // خط فاصل
              if (showDivider)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: screenSize.width * 0.14, // 14% من عرض الشاشة
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
        final double labelSize = isSmallScreen ? 14.0 : 15.0;
        final double inputSize =
            isSmallScreen ? 14.0 : ProfileConstants.inputTextFontSize;
        final double hintSize = isSmallScreen ? 13.0 : 14.0;

        return Container(
          margin: EdgeInsets.only(
            bottom: screenSize.height * 0.025, // 2.5% من ارتفاع الشاشة
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // تسمية الحقل
              Padding(
                padding: EdgeInsets.only(
                  bottom: screenSize.height * 0.01, // 1% من ارتفاع الشاشة
                  right: screenSize.width * 0.01, // 1% من عرض الشاشة
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: FontWeight.w500,
                    color: ProfileConstants.kTextColor,
                    fontFamily: 'SYMBIOAR+LT',
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
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: ProfileConstants.kHintColor,
                    fontSize: hintSize,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: controller.text.isEmpty
                        ? ProfileConstants.kHintColor
                        : ProfileConstants.kMediumPurple,
                    size: 22,
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
                    fontSize: hintSize - 2, // أصغر من حجم النص العادي
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.02, // 2% من ارتفاع الشاشة
                    horizontal: screenSize.width * 0.05, // 5% من عرض الشاشة
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
        final double buttonHeight = isSmallScreen
            ? screenSize.height * 0.055 // 5.5% من ارتفاع الشاشة للأجهزة الصغيرة
            : ProfileConstants.buttonHeight;
        final double textSize =
            isSmallScreen ? 14.0 : ProfileConstants.buttonTextFontSize;

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
                vertical: screenSize.height * 0.015, // 1.5% من ارتفاع الشاشة
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
                            left: screenSize.width * 0.02, // 2% من عرض الشاشة
                          ),
                          child: Icon(icon,
                              size: textSize + 6), // أكبر قليلاً من حجم النص
                        ),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: textSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SYMBIOAR+LT',
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
    final double titleSize = isSmallScreen ? 16.0 : 18.0;
    final double messageSize = isSmallScreen ? 14.0 : 16.0;
    final double buttonTextSize = isSmallScreen ? 13.0 : 14.0;

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
          ),
          textAlign: TextAlign.right,
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: messageSize,
            fontFamily: 'SYMBIOAR+LT',
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
    final double fontSize = isSmallScreen ? 12.0 : 14.0;
    final double iconSize = isSmallScreen ? 18.0 : 20.0;
    final double padding = isSmallScreen ? 10.0 : 12.0;

    return Container(
      margin: EdgeInsets.only(
        bottom: screenSize.height * 0.025, // 2.5% من ارتفاع الشاشة
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
          SizedBox(width: screenSize.width * 0.025), // 2.5% من عرض الشاشة
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: ProfileConstants.kAccentColorPink,
                fontSize: fontSize,
                fontFamily: 'SYMBIOAR+LT',
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
        final double messageSize = isSmallScreen ? 14.0 : 16.0;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: ProfileConstants.kDarkPurple,
              ),
              if (message != null)
                SizedBox(
                    height: screenSize.height * 0.02), // 2% من ارتفاع الشاشة
              if (message != null)
                Text(
                  message,
                  style: TextStyle(
                    fontSize: messageSize,
                    color: Colors.grey.shade600,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
