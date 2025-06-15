import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fateen/main.dart'; // استيراد AuthChecker و ThemeProvider
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  // دالة لفتح تطبيق البريد الإلكتروني
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ahmed2001devv@gmail.com',
      query: encodeQueryParameters({'subject': 'تواصل مع تطبيق نِكستد'}),
    );

    if (!await launchUrl(emailLaunchUri)) {
      throw Exception('Could not launch $emailLaunchUri');
    }
  }

  // مساعدة في ترميز معلمات الاستعلام
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: context.colorBackground,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.sectionPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإعدادات',
                  style: TextStyle(
                    fontSize: AppDimensions.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: context.colorPrimary,
                  ),
                ),
                SizedBox(height: AppDimensions.extraLargeSpacing - 2),

                // خيار تواصل معنا
                _buildSettingItem(
                  context,
                  icon: Icons.email_outlined,
                  title: 'تواصل معنا',
                  subtitle: 'أرسل لنا رسالة إلكترونية',
                  onTap: _launchEmail,
                ),

                const Spacer(),

                // زر تسجيل الخروج
                InkWell(
                  onTap: () async {
                    // تأكيد تسجيل الخروج
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تسجيل الخروج',
                            textAlign: TextAlign.right),
                        content: const Text(
                            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
                            textAlign: TextAlign.right),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('تسجيل الخروج',
                                style: TextStyle(color: context.colorError)),
                          ),
                        ],
                      ),
                    );

                    // استخدام دالة AuthChecker.signOut المتكاملة
                    if (result == true) {
                      await AuthChecker.signOut(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.defaultSpacing - 1),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.mediumRadius),
                      border: Border.all(
                          color: context.colorError.withOpacity(0.6)),
                    ),
                    child: Center(
                      child: Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          fontSize: AppDimensions.bodyFontSize,
                          fontWeight: FontWeight.bold,
                          color: context.colorError,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // تم تعديل هذه الدالة لدعم إضافة عناصر مخصصة (مثل Switch) بدلاً من السهم
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.smallSpacing + 4),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.smallSpacing + 2),
              decoration: BoxDecoration(
                color: context.colorPrimary.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppDimensions.smallRadius + 2),
              ),
              child: Icon(
                icon,
                color: context.colorPrimary,
                size: AppDimensions.iconSize,
              ),
            ),
            SizedBox(width: AppDimensions.defaultSpacing - 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppDimensions.bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: context.colorTextPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppDimensions.smallBodyFontSize,
                      color: context.colorTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // استخدام العنصر المخصص إذا كان موجودًا، وإلا استخدام السهم الافتراضي
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: AppDimensions.extraSmallIconSize - 2,
                  color: context.colorTextHint,
                ),
          ],
        ),
      ),
    );
  }
}
