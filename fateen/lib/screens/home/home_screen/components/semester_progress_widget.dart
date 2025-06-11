import 'package:flutter/material.dart';
import '../controllers/semester_progress_controller.dart';
import '../constants/semester_progress_constants.dart';

class SemesterProgressWidget extends StatelessWidget {
  final SemesterProgressController controller;

  const SemesterProgressWidget({
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            SemesterProgressConstants.gradientStartColor,
            SemesterProgressConstants.gradientEndColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: SemesterProgressConstants.gradientEndColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان وقيمة النسبة المئوية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                SemesterProgressConstants.title,
                style: TextStyle(
                  fontFamily: SemesterProgressConstants.fontFamily,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: SemesterProgressConstants.textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SemesterProgressConstants.textColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  controller.getFormattedPercentage(),
                  style: TextStyle(
                    fontFamily: SemesterProgressConstants.fontFamily,
                    fontSize: fontSize - 3,
                    fontWeight: FontWeight.bold,
                    color: SemesterProgressConstants.textColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: smallSpacing),

          // شريط التقدم
          LinearProgressIndicator(
            value: controller.progressPercentage,
            backgroundColor:
                SemesterProgressConstants.progressBarBackgroundColor,
            color: SemesterProgressConstants.progressBarColor,
            minHeight: SemesterProgressConstants.progressBarHeight,
            borderRadius: BorderRadius.circular(
                SemesterProgressConstants.progressBarBorderRadius),
          ),

          SizedBox(height: smallSpacing),

          // عناوين بداية ونهاية الفصل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                SemesterProgressConstants.semesterStartLabel,
                style: TextStyle(
                  fontFamily: SemesterProgressConstants.fontFamily,
                  fontSize: fontSize - 3,
                  color: SemesterProgressConstants.textColor.withOpacity(0.8),
                ),
              ),
              Text(
                SemesterProgressConstants.semesterEndLabel,
                style: TextStyle(
                  fontFamily: SemesterProgressConstants.fontFamily,
                  fontSize: fontSize - 3,
                  color: SemesterProgressConstants.textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),

          SizedBox(height: smallSpacing * 0.5),

          // تواريخ بداية ونهاية الفصل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                SemesterProgressConstants.semesterStartDate,
                style: TextStyle(
                  fontFamily: SemesterProgressConstants.fontFamily,
                  fontSize: fontSize - 3,
                  fontWeight: FontWeight.bold,
                  color: SemesterProgressConstants.textColor,
                ),
              ),
              Text(
                SemesterProgressConstants.semesterEndDate,
                style: TextStyle(
                  fontFamily: SemesterProgressConstants.fontFamily,
                  fontSize: fontSize - 3,
                  fontWeight: FontWeight.bold,
                  color: SemesterProgressConstants.textColor,
                ),
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
      decoration: BoxDecoration(
        color: SemesterProgressConstants.gradientStartColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: SemesterProgressConstants.gradientStartColor,
        ),
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
                    fontFamily: SemesterProgressConstants.fontFamily,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(
              fontFamily: SemesterProgressConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
