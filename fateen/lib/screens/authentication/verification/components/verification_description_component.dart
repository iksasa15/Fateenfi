import 'package:flutter/material.dart';
import '../constants/verification_colors.dart';
import '../constants/verification_strings.dart';

class VerificationDescriptionComponent extends StatelessWidget {
  final bool isVerified;
  final String email;

  const VerificationDescriptionComponent({
    Key? key,
    required this.isVerified,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;
    final textSize = isTablet ? 16.0 : (isSmallScreen ? 14.0 : 15.0);
    final subtextSize = isTablet ? 15.0 : (isSmallScreen ? 13.0 : 14.0);

    return Container(
      padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      decoration: BoxDecoration(
        color: VerificationColors.lightPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: VerificationColors.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0.5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isVerified
                ? "تم تأكيد بريدك الإلكتروني بنجاح! اضغط على زر تسجيل الدخول للمتابعة."
                : "أرسلنا رابط تأكيد إلى البريد الإلكتروني:\n$email",
            style: TextStyle(
              fontSize: textSize,
              color: isVerified
                  ? VerificationColors.successColor
                  : VerificationColors.textColor,
              fontFamily: 'SYMBIOAR+LT',
              height: 1.5,
              fontWeight: isVerified ? FontWeight.bold : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isVerified)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: VerificationColors.shadowColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: VerificationColors.accentColor.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "يرجى التحقق من صندوق الوارد والبريد العشوائي",
                      style: TextStyle(
                        fontSize: subtextSize - 1,
                        color: VerificationColors.textColor.withOpacity(0.8),
                        fontFamily: 'SYMBIOAR+LT',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!isVerified)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: VerificationColors.mediumPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    color: VerificationColors.mediumPurple,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "نتحقق تلقائيًا من تأكيد بريدك...",
                    style: TextStyle(
                      fontSize: subtextSize,
                      color: VerificationColors.mediumPurple,
                      fontFamily: 'SYMBIOAR+LT',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
