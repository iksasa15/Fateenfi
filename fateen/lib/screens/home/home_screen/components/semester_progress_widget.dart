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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            SemesterProgressConstants.gradientStartColor,
            SemesterProgressConstants.gradientEndColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(SemesterProgressConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: SemesterProgressConstants.cardShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(SemesterProgressConstants.cardBorderRadius),
        child: Stack(
          children: [
            // النمط الزخرفي في الخلفية
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // المحتوى الرئيسي
            Padding(
              padding: EdgeInsets.all(horizontalPadding * 0.8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان وقيمة النسبة المئوية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: SemesterProgressConstants.textColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            SemesterProgressConstants.title,
                            style: TextStyle(
                              fontFamily: SemesterProgressConstants.fontFamily,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: SemesterProgressConstants.textColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: SemesterProgressConstants.badgeBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          controller.getFormattedPercentage(),
                          style: TextStyle(
                            fontFamily: SemesterProgressConstants.fontFamily,
                            fontSize: fontSize - 2,
                            fontWeight: FontWeight.bold,
                            color: SemesterProgressConstants.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: smallSpacing * 1.2),

                  // شريط التقدم
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // بطاقة للأيام المتبقية
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: SemesterProgressConstants.badgeBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          controller.getFormattedDaysRemaining(),
                          style: TextStyle(
                            fontFamily: SemesterProgressConstants.fontFamily,
                            fontSize: fontSize - 2,
                            fontWeight: FontWeight.bold,
                            color: SemesterProgressConstants.textColor,
                          ),
                        ),
                      ),

                      // شريط التقدم
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            SemesterProgressConstants.progressBarBorderRadius),
                        child: LinearProgressIndicator(
                          value: controller.progressPercentage,
                          backgroundColor: SemesterProgressConstants
                              .progressBarBackgroundColor,
                          color: SemesterProgressConstants.progressBarColor,
                          minHeight:
                              SemesterProgressConstants.progressBarHeight,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: smallSpacing * 1.2),

                  // تواريخ بداية ونهاية الفصل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // بداية الفصل
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            SemesterProgressConstants.semesterStartLabel,
                            style: TextStyle(
                              fontFamily: SemesterProgressConstants.fontFamily,
                              fontSize: fontSize - 3,
                              color: SemesterProgressConstants.textColor
                                  .withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            controller.getFormattedStartDate(),
                            style: TextStyle(
                              fontFamily: SemesterProgressConstants.fontFamily,
                              fontSize: fontSize - 2,
                              fontWeight: FontWeight.bold,
                              color: SemesterProgressConstants.textColor,
                            ),
                          ),
                        ],
                      ),

                      // نهاية الفصل
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            SemesterProgressConstants.semesterEndLabel,
                            style: TextStyle(
                              fontFamily: SemesterProgressConstants.fontFamily,
                              fontSize: fontSize - 3,
                              color: SemesterProgressConstants.textColor
                                  .withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                controller.getFormattedEndDate(),
                                style: TextStyle(
                                  fontFamily:
                                      SemesterProgressConstants.fontFamily,
                                  fontSize: fontSize - 2,
                                  fontWeight: FontWeight.bold,
                                  color: SemesterProgressConstants.textColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // زر تعديل تاريخ النهاية
                              InkWell(
                                onTap: () => _showDatePickerDialog(context),
                                borderRadius: BorderRadius.circular(
                                    SemesterProgressConstants
                                        .editButtonBorderRadius),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: SemesterProgressConstants
                                        .editButtonColor,
                                    borderRadius: BorderRadius.circular(
                                        SemesterProgressConstants
                                            .editButtonBorderRadius),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: SemesterProgressConstants.textColor,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // عرض رسالة النجاح إذا وجدت
            if (controller.successMessage != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color:
                      SemesterProgressConstants.successColor.withOpacity(0.8),
                  child: Text(
                    controller.successMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: SemesterProgressConstants.fontFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // عرض مؤشر التحميل أثناء التحديث
            if (controller.isUpdating)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // عرض مربع حوار اختيار التاريخ
  Future<void> _showDatePickerDialog(BuildContext context) async {
    // تاريخ اليوم
    final now = DateTime.now();

    // تاريخ البداية الافتراضي لمنع اختيار تاريخ قبل البداية
    final defaultStartDate = controller.startDate ?? DateTime(now.year, 1, 1);

    // تاريخ النهاية الحالي أو تاريخ افتراضي (نهاية العام الحالي)
    final currentEndDate = controller.endDate ?? DateTime(now.year, 12, 31);

    // عرض منتقي التاريخ
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentEndDate,
      firstDate: defaultStartDate, // لا يمكن اختيار تاريخ قبل تاريخ البداية
      lastDate: DateTime(
          now.year + 2, 12, 31), // يمكن اختيار تاريخ حتى نهاية العام بعد القادم
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: SemesterProgressConstants.gradientStartColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: SemesterProgressConstants.gradientStartColor,
              ),
            ),
            textTheme: const TextTheme(
              // ضبط الخط للعناصر العربية
              titleMedium: TextStyle(
                fontFamily: SemesterProgressConstants.fontFamily,
              ),
              bodyMedium: TextStyle(
                fontFamily: SemesterProgressConstants.fontFamily,
              ),
              labelSmall: TextStyle(
                fontFamily: SemesterProgressConstants.fontFamily,
              ),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl, // لدعم العربية في منتقي التاريخ
            child: child!,
          ),
        );
      },
    );

    // إذا تم اختيار تاريخ، قم بتحديثه
    if (pickedDate != null && pickedDate != currentEndDate) {
      await controller.updateEndDate(pickedDate);
    }
  }

  // حالة التحميل
  Widget _buildLoadingState(double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SemesterProgressConstants.gradientStartColor.withOpacity(0.7),
            SemesterProgressConstants.gradientEndColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(SemesterProgressConstants.cardBorderRadius),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            color: SemesterProgressConstants.textColor,
          ),
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
        borderRadius:
            BorderRadius.circular(SemesterProgressConstants.cardBorderRadius),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'حدث خطأ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontFamily: SemesterProgressConstants.fontFamily,
                    ),
                  ),
                ],
              ),
              // زر لمحاولة إعادة التحميل
              TextButton(
                onPressed: () => controller.refresh(),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
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
