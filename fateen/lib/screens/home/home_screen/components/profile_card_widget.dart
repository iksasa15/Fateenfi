import 'package:flutter/material.dart';
import '../controllers/profile_card_controller.dart';
import '../constants/profile_card_constants.dart';

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

    // الحصول على التحية والتاريخ من وحدة التحكم
    final String greeting = controller.getTimeBasedGreeting();
    final String formattedDate = controller.getFormattedDate();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ProfileCardConstants.gradientStartColor,
            ProfileCardConstants.gradientEndColor
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(ProfileCardConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: ProfileCardConstants.cardShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(ProfileCardConstants.cardBorderRadius),
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
                          // أيقونة صغيرة بجانب الاسم بدلاً من الدائرة الكبيرة
                          Icon(
                            Icons.person,
                            color: ProfileCardConstants.textColor,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '$greeting ${controller.userName}',
                            style: TextStyle(
                              fontFamily: ProfileCardConstants.fontFamily,
                              fontSize: fontSize + 1,
                              fontWeight: FontWeight.bold,
                              color: ProfileCardConstants.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(right: 26),
                        child: Text(
                          controller.userMajor,
                          style: TextStyle(
                            fontFamily: ProfileCardConstants.fontFamily,
                            fontSize: fontSize - 2,
                            color:
                                ProfileCardConstants.textColor.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // الجانب الأيسر: التاريخ
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ProfileCardConstants.badgeBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: ProfileCardConstants.textColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontFamily: ProfileCardConstants.fontFamily,
                            fontSize: fontSize - 3,
                            color: ProfileCardConstants.textColor,
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
  Widget _buildLoadingState(double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ProfileCardConstants.gradientStartColor.withOpacity(0.7),
            ProfileCardConstants.gradientEndColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(ProfileCardConstants.cardBorderRadius),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            color: ProfileCardConstants.textColor,
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
            BorderRadius.circular(ProfileCardConstants.cardBorderRadius),
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
                      fontFamily: ProfileCardConstants.fontFamily,
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
                    fontFamily: ProfileCardConstants.fontFamily,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(
              fontFamily: ProfileCardConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
