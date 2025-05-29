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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // أيقونة المستخدم
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ProfileConstants.kDarkPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: ProfileConstants.kDarkPurple,
              ),
            ),

            const SizedBox(height: 16),

            // اسم المستخدم
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ProfileConstants.kDarkPurple,
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // التخصص
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ProfileConstants.kLightPurple,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                major,
                style: TextStyle(
                  fontSize: 16,
                  color: ProfileConstants.kMediumPurple,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // البريد الإلكتروني
            if (email.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: ProfileConstants.kHintColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
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
  }

  /// بناء قسم في الإعدادات
  static Widget buildSettingsSection({
    required String title,
    required List<Widget> children,
    bool isFirst = false,
  }) {
    return Container(
      margin: EdgeInsets.only(
        top: isFirst ? 0 : 20,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding:
                const EdgeInsets.only(bottom: 12.0, right: 16.0, left: 16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
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
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                // أيقونة العنصر
                Container(
                  padding: const EdgeInsets.all(8),
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
                    size: 22,
                  ),
                ),

                const SizedBox(width: 16),

                // النص والوصف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDanger
                              ? ProfileConstants.dangerColor
                              : ProfileConstants.kTextColor,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
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
                  size: 16,
                ),
              ],
            ),
          ),

          // خط فاصل
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              indent: 56,
              endIndent: 0,
              color: Colors.grey[100],
            ),
        ],
      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تسمية الحقل
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
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
            style: const TextStyle(
              color: ProfileConstants.kTextColor,
              fontSize: ProfileConstants.inputTextFontSize,
              fontFamily: 'SYMBIOAR+LT',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: ProfileConstants.kHintColor,
                fontSize: 14,
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
              errorStyle: const TextStyle(
                color: ProfileConstants.kAccentColorPink,
                fontSize: 12,
                fontFamily: 'SYMBIOAR+LT',
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
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
    final Color buttonColor = isDanger
        ? ProfileConstants.dangerColor
        : (isPrimary ? ProfileConstants.kDarkPurple : Colors.grey[300]!);

    final Color textColor =
        isPrimary || isDanger ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      height: ProfileConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(icon, size: 20),
                    ),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: ProfileConstants.buttonTextFontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
      ),
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
            fontFamily: 'SYMBIOAR+LT',
          ),
          textAlign: TextAlign.right,
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final padding = isSmallScreen ? 10.0 : 12.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          const SizedBox(width: 10),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: ProfileConstants.kDarkPurple,
          ),
          if (message != null) const SizedBox(height: 16),
          if (message != null)
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
        ],
      ),
    );
  }
}
