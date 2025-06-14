import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart'; // Updated import
import '../constants/reset_password_strings.dart';
import '../../shared/helpers/responsive_helper.dart';

class ResetSubheaderComponent extends StatelessWidget {
  const ResetSubheaderComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLandscape = ResponsiveHelper.isLandscape(context);
    final isTinyScreen = ResponsiveHelper.isTinyMobile(context);
    final titleSize = ResponsiveHelper.getResponsiveFontSize(context,
        smallSize: isTinyScreen ? 16 : (isLandscape ? 16 : 18),
        mediumSize: isLandscape ? 20 : 22,
        largeSize: 24);

    // تقليل الهوامش في الوضع الأفقي
    final verticalPadding = isLandscape ? 5.0 : 10.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Center(
        child: Text(
          ResetPasswordStrings.forgotPasswordHeader,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark, // Updated
            fontFamily: 'SYMBIOAR+LT',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
