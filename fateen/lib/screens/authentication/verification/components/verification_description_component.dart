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
        color: AppColors.primaryExtraLight, // Updated
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1), // Updated
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
                  ? AppColors.success // Updated
                  : AppColors.textPrimary, // Updated
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
                  color: AppColors.shadow, // Updated
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.accent.withOpacity(0.7), // Updated
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "يرجى التحقق من صندوق الوارد والبريد العشوائي",
                      style: TextStyle(
                        fontSize: subtextSize - 1,
                        color:
                            AppColors.textPrimary.withOpacity(0.8), // Updated
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
                color: AppColors.primaryLight.withOpacity(0.1), // Updated
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    color: AppColors.primaryLight, // Updated
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "نتحقق تلقائيًا من تأكيد بريدك...",
                    style: TextStyle(
                      fontSize: subtextSize,
                      color: AppColors.primaryLight, // Updated
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
