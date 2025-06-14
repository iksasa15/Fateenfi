import 'package:flutter/material.dart';
import '../controllers/semester_progress_controller.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

class SemesterProgressWidget extends StatelessWidget {
  final SemesterProgressController controller;

  const SemesterProgressWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام الأبعاد المتجاوبة من AppDimensions
    final double horizontalPadding = AppDimensions.getSpacing(context);
    final double smallSpacing =
        AppDimensions.getSpacing(context, size: SpacingSize.small);
    final double fontSize = AppDimensions.getBodyFontSize(context);

    // التحقق من حالة التحميل
    if (controller.isLoading) {
      return _buildLoadingState(context, horizontalPadding);
    }

    // عرض رسالة الخطأ إذا وجدت
    if (controller.errorMessage != null) {
      return _buildErrorState(
          context, controller.errorMessage!, horizontalPadding);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        gradient: context.gradientPrimary,
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
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
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.white,
                            size: AppDimensions.getIconSize(context,
                                size: IconSize.small, small: true),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "تقدم الفصل الدراسي",
                            style: TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.getSpacing(context,
                              size: SpacingSize.small),
                          vertical: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.smallRadius),
                        ),
                        child: Text(
                          controller.getFormattedPercentage(),
                          style: TextStyle(
                            fontFamily: 'SYMBIOAR+LT',
                            fontSize: fontSize - 2,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.getSpacing(context,
                              size: SpacingSize.small),
                          vertical: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small) /
                              2,
                        ),
                        margin: EdgeInsets.only(bottom: smallSpacing),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.smallRadius),
                        ),
                        child: Text(
                          controller.getFormattedDaysRemaining(),
                          style: TextStyle(
                            fontFamily: 'SYMBIOAR+LT',
                            fontSize: fontSize - 2,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // شريط التقدم
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.smallRadius),
                        child: LinearProgressIndicator(
                          value: controller.progressPercentage,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          color: Colors.white,
                          minHeight: 6.0,
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
                            "بداية الفصل",
                            style: TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              fontSize: fontSize - 3,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                controller.getFormattedStartDate(),
                                style: TextStyle(
                                  fontFamily: 'SYMBIOAR+LT',
                                  fontSize: fontSize - 2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // زر تعديل تاريخ البداية
                              InkWell(
                                onTap: () =>
                                    _showStartDatePickerDialog(context),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.smallRadius),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.smallRadius),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // نهاية الفصل
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "نهاية الفصل",
                            style: TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              fontSize: fontSize - 3,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                controller.getFormattedEndDate(),
                                style: TextStyle(
                                  fontFamily: 'SYMBIOAR+LT',
                                  fontSize: fontSize - 2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // زر تعديل تاريخ النهاية
                              InkWell(
                                onTap: () => _showEndDatePickerDialog(context),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.smallRadius),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.smallRadius),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
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
                  padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.getSpacing(context,
                          size: SpacingSize.small)),
                  color: context.colorSuccess.withOpacity(0.8),
                  child: Text(
                    controller.successMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
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

  // عرض مربع حوار اختيار تاريخ البداية
  Future<void> _showStartDatePickerDialog(BuildContext context) async {
    // تاريخ اليوم
    final now = DateTime.now();

    // تاريخ البداية الحالي أو تاريخ افتراضي (بداية العام الحالي)
    final currentStartDate = controller.startDate ?? DateTime(now.year, 1, 1);

    // تاريخ النهاية للتحقق من الصلاحية
    final endDate = controller.endDate ?? DateTime(now.year, 12, 31);

    // عرض منتقي التاريخ
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentStartDate,
      firstDate:
          DateTime(now.year - 1, 1, 1), // يمكن اختيار تاريخ من العام الماضي
      lastDate: endDate, // لا يمكن اختيار تاريخ بعد تاريخ النهاية
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colorPrimary,
              onPrimary: Colors.white,
              onSurface: context.colorTextPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: context.colorPrimary,
              ),
            ),
            textTheme: const TextTheme(
              // ضبط الخط للعناصر العربية
              titleMedium: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
              bodyMedium: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
              labelSmall: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
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
    if (pickedDate != null && pickedDate != currentStartDate) {
      await controller.updateStartDate(pickedDate);
    }
  }

  // عرض مربع حوار اختيار تاريخ النهاية
  Future<void> _showEndDatePickerDialog(BuildContext context) async {
    // تاريخ اليوم
    final now = DateTime.now();

    // تاريخ البداية للتحقق من الصلاحية
    final startDate = controller.startDate ?? DateTime(now.year, 1, 1);

    // تاريخ النهاية الحالي أو تاريخ افتراضي (نهاية العام الحالي)
    final currentEndDate = controller.endDate ?? DateTime(now.year, 12, 31);

    // عرض منتقي التاريخ
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentEndDate,
      firstDate: startDate, // لا يمكن اختيار تاريخ قبل تاريخ البداية
      lastDate: DateTime(
          now.year + 2, 12, 31), // يمكن اختيار تاريخ حتى نهاية العام بعد القادم
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colorPrimary,
              onPrimary: Colors.white,
              onSurface: context.colorTextPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: context.colorPrimary,
              ),
            ),
            textTheme: const TextTheme(
              // ضبط الخط للعناصر العربية
              titleMedium: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
              bodyMedium: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
              ),
              labelSmall: TextStyle(
                fontFamily: 'SYMBIOAR+LT',
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
  Widget _buildLoadingState(BuildContext context, double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colorPrimary.withOpacity(0.7),
            context.colorPrimaryDark.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // حالة الخطأ
  Widget _buildErrorState(
      BuildContext context, String errorMessage, double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      decoration: BoxDecoration(
        color: context.colorError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        border: Border.all(color: context.colorError.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline, color: context.colorError),
                  SizedBox(
                      width: AppDimensions.getSpacing(context,
                          size: SpacingSize.small)),
                  Text(
                    'حدث خطأ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.colorError,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
              // زر لمحاولة إعادة التحميل
              TextButton(
                onPressed: () => controller.refresh(),
                child: Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontFamily: 'SYMBIOAR+LT',
                    color: context.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
              height:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          Text(
            errorMessage,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              color: context.colorTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
