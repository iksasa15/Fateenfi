import 'package:flutter/material.dart';
import '../constants/performance_indicators_constants.dart';
import '../controllers/performance_indicators_controller.dart';
import 'performance_card_widget.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

class PerformanceIndicatorsWidget extends StatelessWidget {
  final PerformanceIndicatorsController controller;

  const PerformanceIndicatorsWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;
    final double fontSize =
        isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0);
    final double horizontalPadding = screenSize.width * 0.04;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: EdgeInsets.only(
              bottom:
                  AppDimensions.getSpacing(context, size: SpacingSize.small),
            ),
            child: Text(
              PerformanceIndicatorsConstants.sectionTitle,
              style: TextStyle(
                fontSize: AppDimensions.smallTitleFontSize,
                fontWeight: FontWeight.bold,
                color: context
                    .colorTextPrimary, // استخدام الألوان من ملف AppColors
                fontFamily: PerformanceIndicatorsConstants.fontFamily,
                height: 1.2,
              ),
            ),
          ),

          // مؤشرات الأداء
          if (controller.isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.defaultSpacing),
                child: CircularProgressIndicator(
                  color: context.colorPrimary, // استخدام اللون الرئيسي للتطبيق
                ),
              ),
            )
          else if (controller.errorMessage != null)
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.defaultSpacing),
                child: Text(
                  controller.errorMessage!,
                  style: TextStyle(
                    color: context.colorError, // استخدام لون الخطأ من AppColors
                    fontSize: fontSize,
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppDimensions.smallSpacing,
                mainAxisSpacing: AppDimensions.smallSpacing,
                childAspectRatio: 1.6,
              ),
              itemCount: controller.indicators.length,
              itemBuilder: (context, index) {
                final indicator = controller.indicators[index];
                return PerformanceCardWidget(
                  title: indicator.title,
                  value: indicator.value,
                  icon: indicator.icon,
                  color: indicator.color,
                  description: indicator.description,
                  fontSize: fontSize,
                );
              },
            ),
        ],
      ),
    );
  }
}
