import 'package:flutter/material.dart';
import '../controllers/profile_card_controller.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

class ProfileCardWidget extends StatelessWidget {
  final ProfileCardController controller;
  final VoidCallback? onSettingsPressed;

  const ProfileCardWidget({
    Key? key,
    required this.controller,
    this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام طرق الأبعاد المتجاوبة من AppDimensions
    final double horizontalPadding = AppDimensions.getSpacing(context);
    final double smallSpacing =
        AppDimensions.getSpacing(context, size: SpacingSize.small);
    final double fontSize = AppDimensions.getBodyFontSize(context, small: true);
    final double iconSize =
        AppDimensions.getIconSize(context, size: IconSize.small, small: true);
    final double smallIconSize = AppDimensions.getIconSize(context,
        size: IconSize.extraSmall, small: true);

    // التحقق من حالة التحميل
    if (controller.isLoading) {
      return _buildLoadingState(context, horizontalPadding);
    }

    // عرض رسالة الخطأ إذا وجدت
    if (controller.errorMessage != null) {
      return _buildErrorState(
          context, controller.errorMessage!, horizontalPadding);
    }

    // الحصول على التحية والتاريخ من وحدة التحكم
    final String greeting = controller.getTimeBasedGreeting();
    final String formattedDate = controller.getFormattedDate();

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // الجانب الأيمن: معلومات المستخدم (بدون صورة)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // أيقونة صغيرة بجانب الاسم
                          Icon(
                            Icons.person,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          SizedBox(
                              width: AppDimensions.getSpacing(context,
                                  size: SpacingSize.small)),
                          Text(
                            '$greeting ${controller.userName}',
                            style: TextStyle(
                              fontFamily: 'SYMBIOAR+LT',
                              fontSize: fontSize + 1,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: smallSpacing / 2),
                      Padding(
                        padding: EdgeInsets.only(
                            right: AppDimensions.getSpacing(context,
                                size: SpacingSize.large)),
                        child: Text(
                          controller.userMajor,
                          style: TextStyle(
                            fontFamily: 'SYMBIOAR+LT',
                            fontSize: fontSize - 2,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // الجانب الأيسر: التاريخ
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: smallIconSize,
                        ),
                        SizedBox(
                            width: AppDimensions.getSpacing(context,
                                    size: SpacingSize.small) /
                                2),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontFamily: 'SYMBIOAR+LT',
                            fontSize: fontSize - 3,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
