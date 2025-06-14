import 'package:flutter/material.dart';
import '../constants/performance_indicators_constants.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

class PerformanceCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String description;
  final double fontSize;

  const PerformanceCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.description,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(PerformanceIndicatorsConstants.cardPadding),
      decoration: BoxDecoration(
        color: context.colorSurface, // استخدام لون السطح من AppColors
        borderRadius: BorderRadius.circular(
            AppDimensions.mediumRadius), // استخدام الزوايا من AppDimensions
        boxShadow: [
          BoxShadow(
            color: context.colorShadow, // استخدام لون الظل من AppColors
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: context.colorBorder, // استخدام لون الحدود من AppColors
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: PerformanceIndicatorsConstants.fontFamily,
                  fontSize: fontSize - 2,
                  color: context.colorTextSecondary, // استخدام لون النص الثانوي
                ),
              ),
              Icon(
                icon,
                color: color,
                size: AppDimensions
                    .smallIconSize, // استخدام حجم الأيقونة من AppDimensions
              ),
            ],
          ),
          SizedBox(height: AppDimensions.smallSpacing / 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: PerformanceIndicatorsConstants.fontFamily,
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold,
              color: context.colorTextPrimary, // استخدام لون النص الأساسي
            ),
          ),
          SizedBox(height: AppDimensions.smallSpacing / 2),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: PerformanceIndicatorsConstants.indicatorPadding,
                vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions
                  .smallRadius), // استخدام الزوايا من AppDimensions
            ),
            child: Text(
              description,
              style: TextStyle(
                fontFamily: PerformanceIndicatorsConstants.fontFamily,
                fontSize: fontSize - 4,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
