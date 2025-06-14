import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart'; // Updated import
import '../constants/verification_strings.dart';

class ResendSectionComponent extends StatelessWidget {
  final int countdown;
  final bool resendingEmail;
  final VoidCallback onResend;

  const ResendSectionComponent({
    Key? key,
    required this.countdown,
    required this.resendingEmail,
    required this.onResend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;
    final textSize = isSmallScreen ? 14.0 : 15.0;
    final buttonTextSize = isTablet ? 16.0 : (isSmallScreen ? 14.0 : 15.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // العنوان الرئيسي بخط أكبر ولون مميز
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.only(bottom: 8),
          child: Text(
            "لم توصلني رسالة تأكيد إيميل",
            style: TextStyle(
              fontSize: isTablet ? 18.0 : 16.0,
              fontWeight: FontWeight.w600,
              color: context.colorAccent.withOpacity(0.8), // استخدام Extension
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // نص للإشارة إلى الحلول المتاحة
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            "حل مشكلة",
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w500,
              color: context.colorTextPrimary, // استخدام Extension
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // قائمة بالحلول المحتملة في صندوق
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colorSurface, // استخدام Extension
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colorPrimaryLight
                  .withOpacity(0.3), // استخدام Extension
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: context.colorShadowColor
                    .withOpacity(0.1), // استخدام Extension
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSolutionItem(
                icon: Icons.folder_outlined,
                text: "تحقق من مجلد الرسائل غير المرغوبة (السبام)",
                context: context,
              ),
              _buildDivider(context),
              _buildSolutionItem(
                icon: Icons.email_outlined,
                text: "تأكد من صحة عنوان البريد الإلكتروني",
                context: context,
              ),
              _buildDivider(context),
              _buildSolutionItem(
                icon: Icons.refresh,
                text: "انتظر قليلاً، قد يستغرق وصول الرسالة بعض الوقت",
                context: context,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        // خيار إعادة الإرسال
        countdown > 0
            ? Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.colorPrimaryExtraLight, // استخدام Extension
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colorPrimaryLight
                        .withOpacity(0.2), // استخدام Extension
                    width: 1,
                  ),
                ),
                child: Text(
                  "يمكنك طلب إرسال رابط جديد بعد ${countdown} ثانية",
                  style: TextStyle(
                    fontSize: buttonTextSize,
                    color: context.colorPrimaryDark, // استخدام Extension
                    fontFamily: 'SYMBIOAR+LT',
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Container(
                width: double.infinity,
                height: isTablet ? 56.0 : 50.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorPrimaryDark
                          .withOpacity(0.1), // استخدام Extension
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: resendingEmail ? null : onResend,
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: context.colorSurface, // استخدام Extension
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.colorPrimaryLight, // استخدام Extension
                          width: 1.5,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: resendingEmail
                            ? Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: context
                                        .colorPrimaryLight, // استخدام Extension
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "إعادة إرسال رابط التأكيد",
                                      style: TextStyle(
                                        fontSize: buttonTextSize,
                                        fontWeight: FontWeight.bold,
                                        color: context
                                            .colorPrimaryLight, // استخدام Extension
                                        fontFamily: 'SYMBIOAR+LT',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.email_outlined,
                                      color: context
                                          .colorPrimaryLight, // استخدام Extension
                                      size: isTablet ? 22.0 : 20.0,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildSolutionItem({
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final textSize = isSmallScreen ? 13.0 : 14.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: context.colorPrimaryLight, // استخدام Extension
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: textSize,
                color: context.colorTextPrimary, // استخدام Extension
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        color: context.colorShadowColor.withOpacity(0.3), // استخدام Extension
        height: 1,
      ),
    );
  }
}
