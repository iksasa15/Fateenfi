import 'package:flutter/material.dart';
import '../constants/services_constants.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';
class ServicesHeaderComponent extends StatelessWidget {
  const ServicesHeaderComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان الكبير
        Text(
          ServicesConstants.servicesTitle,
          style: TextStyle(
            fontSize: AppDimensions.titleFontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        SizedBox(height: AppDimensions.smallSpacing),

        // وصف صغير
        Text(
          ServicesConstants.servicesDescription,
          style: TextStyle(
            fontSize: AppDimensions.smallBodyFontSize,
            color: context.colorTextSecondary,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }
}
