import 'package:flutter/material.dart';
import '../constants/performance_indicators_constants.dart';
import '../controllers/performance_indicators_controller.dart';
import 'performance_card_widget.dart';

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
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              PerformanceIndicatorsConstants.sectionTitle,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
                fontFamily: PerformanceIndicatorsConstants.fontFamily,
                height: 1.2,
              ),
            ),
          ),

          // مؤشرات الأداء
          if (controller.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (controller.errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  controller.errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: fontSize,
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio:
                    1.6, // تم تغييرها من 1.2 إلى 1.6 لجعل المربع أقصر
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
