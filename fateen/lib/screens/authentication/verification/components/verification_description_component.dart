import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart'; // Updated import
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
        color: context.colorPrimaryExtraLight, // استخدام Extension
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorBorder, // استخدام Extension
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                context.colorShadowColor.withOpacity(0.1), // استخدام Extension
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
                  ? context.colorSuccess // استخدام Extension
                  : context.colorTextPrimary, // استخدام Extension
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
                color: context.colorSurface, // استخدام Extension
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.colorShadowColor, // استخدام Extension
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: context.colorAccent
                        .withOpacity(0.7), // استخدام Extension
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "يرجى التحقق من صندوق الوارد والبريد العشوائي",
                      style: TextStyle(
                        fontSize: subtextSize - 1,
                        color: context.colorTextPrimary
                            .withOpacity(0.8), // استخدام Extension
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
                color: context.colorPrimaryLight
                    .withOpacity(0.1), // استخدام Extension
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    color: context.colorPrimaryLight, // استخدام Extension
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "نتحقق تلقائيًا من تأكيد بريدك...",
                    style: TextStyle(
                      fontSize: subtextSize,
                      color: context.colorPrimaryLight, // استخدام Extension
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
