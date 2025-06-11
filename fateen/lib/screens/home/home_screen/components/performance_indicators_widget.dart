import 'package:flutter/material.dart';
import '../controllers/performance_indicators_controller.dart';
import '../constants/performance_indicators_constants.dart';
import 'performance_card_widget.dart';

class PerformanceIndicatorsWidget extends StatelessWidget {
  final PerformanceIndicatorsController controller;

  const PerformanceIndicatorsWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة للتصميم المتجاوب
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    // حساب الأحجام النسبية
    final double horizontalPadding = screenSize.width * 0.04;
    final double smallSpacing = screenSize.height * 0.01;
    final double fontSize =
        isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0);

    // التحقق من حالة التحميل
    if (controller.isLoading) {
      return _buildLoadingState(horizontalPadding);
    }

    // عرض رسالة الخطأ إذا وجدت
    if (controller.errorMessage != null) {
      return _buildErrorState(controller.errorMessage!, horizontalPadding);
    }

    // الحصول على المؤشرات من وحدة التحكم
    final indicators = controller.indicators;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PerformanceIndicatorsConstants.sectionTitle,
            style: TextStyle(
              fontFamily: PerformanceIndicatorsConstants.fontFamily,
              fontSize: fontSize + 1,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: smallSpacing),

          // الصف الأول من المؤشرات
          Row(
            children: [
              Expanded(
                child: indicators.length > 0
                    ? PerformanceCardWidget(
                        title: indicators[0].title,
                        value: indicators[0].value,
                        icon: indicators[0].icon,
                        color: indicators[0].color,
                        description: indicators[0].description,
                        fontSize: fontSize,
                      )
                    : SizedBox.shrink(),
              ),
              SizedBox(width: horizontalPadding * 0.5),
              Expanded(
                child: indicators.length > 1
                    ? PerformanceCardWidget(
                        title: indicators[1].title,
                        value: indicators[1].value,
                        icon: indicators[1].icon,
                        color: indicators[1].color,
                        description: indicators[1].description,
                        fontSize: fontSize,
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),

          SizedBox(height: smallSpacing),

          // الصف الثاني من المؤشرات
          Row(
            children: [
              Expanded(
                child: indicators.length > 2
                    ? PerformanceCardWidget(
                        title: indicators[2].title,
                        value: indicators[2].value,
                        icon: indicators[2].icon,
                        color: indicators[2].color,
                        description: indicators[2].description,
                        fontSize: fontSize,
                      )
                    : SizedBox.shrink(),
              ),
              SizedBox(width: horizontalPadding * 0.5),
              Expanded(
                child: indicators.length > 3
                    ? PerformanceCardWidget(
                        title: indicators[3].title,
                        value: indicators[3].value,
                        icon: indicators[3].icon,
                        color: indicators[3].color,
                        description: indicators[3].description,
                        fontSize: fontSize,
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // حالة التحميل
  Widget _buildLoadingState(double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // حالة الخطأ
  Widget _buildErrorState(String errorMessage, double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontFamily: PerformanceIndicatorsConstants.fontFamily,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(
              fontFamily: PerformanceIndicatorsConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
