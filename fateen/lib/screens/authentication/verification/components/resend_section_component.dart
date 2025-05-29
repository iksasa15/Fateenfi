import 'package:flutter/material.dart';
import '../constants/verification_colors.dart';
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
              color: VerificationColors.accentColor.withOpacity(0.8),
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
              color: VerificationColors.textColor,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: VerificationColors.mediumPurple.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: VerificationColors.shadowColor.withOpacity(0.1),
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
              _buildDivider(),
              _buildSolutionItem(
                icon: Icons.email_outlined,
                text: "تأكد من صحة عنوان البريد الإلكتروني",
                context: context,
              ),
              _buildDivider(),
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
                  color: VerificationColors.lightPurple,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: VerificationColors.mediumPurple.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  "يمكنك طلب إرسال رابط جديد بعد ${countdown} ثانية",
                  style: TextStyle(
                    fontSize: buttonTextSize,
                    color: VerificationColors.darkPurple,
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
                      color: VerificationColors.darkPurple.withOpacity(0.1),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: VerificationColors.mediumPurple,
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
                                    color: VerificationColors.mediumPurple,
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
                                        color: VerificationColors.mediumPurple,
                                        fontFamily: 'SYMBIOAR+LT',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.email_outlined,
                                      color: VerificationColors.mediumPurple,
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
            color: VerificationColors.mediumPurple,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: textSize,
                color: VerificationColors.textColor,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        color: VerificationColors.shadowColor.withOpacity(0.3),
        height: 1,
      ),
    );
  }
}
