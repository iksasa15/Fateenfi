import 'package:flutter/material.dart';
import '../../constants/signup_colors.dart';
import '../../../../../core/constants/appDimensions.dart';

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
          SignupDimensions.getSpacing(context, size: SpacingSize.large),
          0,
          SignupDimensions.getSpacing(context, size: SpacingSize.large),
          SignupDimensions.getSpacing(context, size: SpacingSize.medium)),
      padding: EdgeInsets.all(
          SignupDimensions.getSpacing(context, size: SpacingSize.small)),
      decoration: BoxDecoration(
        color: SignupColors.accentColor.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(SignupDimensions.getLargeRadius(context)),
        border: Border.all(
          color: SignupColors.accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(
                SignupDimensions.getSpacing(context, size: SpacingSize.small) /
                    2),
            decoration: BoxDecoration(
              color: SignupColors.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: SignupColors.accentColor,
              size: SignupDimensions.getIconSize(context, small: isSmallScreen),
            ),
          ),
          SizedBox(
              width: SignupDimensions.getSpacing(context,
                  size: SpacingSize.small)),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: SignupColors.accentColor,
                fontSize: SignupDimensions.getBodyFontSize(context,
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
