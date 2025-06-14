import 'package:flutter/material.dart';
import '../../../../../core/constants/appColor.dart';
import '../../../../../core/constants/app_dimensions.dart';

class ErrorMessageComponent extends StatelessWidget {
  final String errorMessage;

  const ErrorMessageComponent({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: EdgeInsets.fromLTRB(
          AppDimensions.getSpacing(context, size: SpacingSize.large),
          0,
          AppDimensions.getSpacing(context, size: SpacingSize.large),
          AppDimensions.getSpacing(context, size: SpacingSize.medium)),
      padding: EdgeInsets.all(
          AppDimensions.getSpacing(context, size: SpacingSize.small)),
      decoration: BoxDecoration(
        color: context.colorAccent.withOpacity(0.08), // استخدام Extension
        borderRadius:
            BorderRadius.circular(AppDimensions.getLargeRadius(context)),
        border: Border.all(
          color: context.colorAccent.withOpacity(0.2), // استخدام Extension
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(
                AppDimensions.getSpacing(context, size: SpacingSize.small) / 2),
            decoration: BoxDecoration(
              color: context.colorAccent.withOpacity(0.1), // استخدام Extension
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: context.colorAccent, // استخدام Extension
              size: AppDimensions.getIconSize(context, small: isSmallScreen),
            ),
          ),
          SizedBox(
              width:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: context.colorAccent, // استخدام Extension
                fontSize: AppDimensions.getBodyFontSize(context,
                    small: isSmallScreen),
                fontFamily: 'SYMBIOAR+LT',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
