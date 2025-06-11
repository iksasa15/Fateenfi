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
      padding: EdgeInsets.all(horizontalPadding * 0.8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ProfileCardConstants.gradientStartColor,
            ProfileCardConstants.gradientEndColor
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ProfileCardConstants.accentColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // أيقونة المستخدم / الحرف الأول من اسمه
              _buildUserAvatar(controller.userName),

              SizedBox(width: horizontalPadding * 0.8),

              // معلومات المستخدم (الاسم والتخصص)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$greeting ${controller.userName}',
                      style: TextStyle(
                        fontFamily: ProfileCardConstants.fontFamily,
                        fontSize: fontSize + 2,
                        fontWeight: FontWeight.bold,
                        color: ProfileCardConstants.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      controller.userMajor,
                      style: TextStyle(
                        fontFamily: ProfileCardConstants.fontFamily,
                        fontSize: fontSize - 2,
                        color: ProfileCardConstants.textColor.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // زر الإعدادات
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: ProfileCardConstants.textColor.withOpacity(0.9),
                ),
                onPressed: onSettingsPressed,
              ),
            ],
          ),
          SizedBox(height: smallSpacing),

          // عرض التاريخ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ProfileCardConstants.textColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
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
                    fontSize: fontSize - 2,
                    color: ProfileCardConstants.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // صورة المستخدم (الحرف الأول من اسمه)
  Widget _buildUserAvatar(String userName) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: ProfileCardConstants.iconBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: ProfileCardConstants.iconBackgroundColor,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Center(
          child: Text(
            userName.isNotEmpty
                ? userName[0].toUpperCase()
                : ProfileCardConstants.unknownCharacter,
            style: TextStyle(
              fontFamily: ProfileCardConstants.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ProfileCardConstants.accentColor,
            ),
          ),
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
        color: ProfileCardConstants.gradientStartColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: ProfileCardConstants.gradientStartColor,
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
