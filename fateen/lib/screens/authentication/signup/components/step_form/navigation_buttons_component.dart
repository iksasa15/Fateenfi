// lib/features/step_form/components/navigation_buttons_component.dart

import 'package:flutter/material.dart';
import '../../../../../core/constants/appColor.dart'; // Updated import
import '../../signup_controller/controllers/signup_controller.dart';

class NavigationButtonsComponent extends StatelessWidget {
  final SignupController controller;
  final VoidCallback onPrevPressed;
  final VoidCallback onNextPressed;
  final VoidCallback onSubmitPressed;

  const NavigationButtonsComponent({
    Key? key,
    required this.controller,
    required this.onPrevPressed,
    required this.onNextPressed,
    required this.onSubmitPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isFirstStep = controller.currentStep == SignupStep.name;
    final isLastStep = controller.currentStep == SignupStep.terms;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenHeight * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع - مع تأثير متحرك عند الظهور والاختفاء
          _buildBackButton(isFirstStep, screenWidth, screenHeight),

          // زر التالي أو الإنهاء - مع تأثير نبض عندما يكون جاهزًا
          _buildActionButton(
              isFirstStep, isLastStep, screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildBackButton(
      bool isFirstStep, double screenWidth, double screenHeight) {
    return AnimatedOpacity(
      opacity: isFirstStep ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isFirstStep ? 0 : screenWidth * 0.25,
        child: isFirstStep
            ? const SizedBox.shrink()
            : TextButton(
                onPressed: controller.isLoading ? null : onPrevPressed,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.textHint.withOpacity(0.3), // Updated
                      width: 1,
                    ),
                  ),
                  foregroundColor: AppColors.textHint, // Updated
                  disabledForegroundColor:
                      AppColors.textHint.withOpacity(0.4), // Updated
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: screenWidth * 0.035,
                      color: AppColors.textHint, // Updated
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      'رجوع',
                      style: TextStyle(
                        color: AppColors.textHint, // Updated
                        fontFamily: 'SYMBIOAR+LT',
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButton(bool isFirstStep, bool isLastStep,
      double screenWidth, double screenHeight) {
    // تعطيل الزر أثناء حالة التحميل أو عندما تكون البيانات غير صالحة
    final isButtonEnabled =
        controller.canMoveToNextStep && !controller.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isFirstStep ? screenWidth * 0.88 : screenWidth * 0.6,
      height: screenHeight * 0.06,
      child: ElevatedButton(
        onPressed: isButtonEnabled
            ? (isLastStep ? onSubmitPressed : onNextPressed)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLastStep
              ? AppColors.primaryDark
              : AppColors.primaryLight, // Updated
          foregroundColor: Colors.white,
          disabledBackgroundColor: (isLastStep
                  ? AppColors.primaryDark
                  : AppColors.primaryLight) // Updated
              .withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
          elevation: isButtonEnabled ? 4 : 0,
          shadowColor: AppColors.primaryLight.withOpacity(0.5), // Updated
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.015,
          ),
        ),
        child: isLastStep && controller.isLoading
            ? _buildLoadingContent(screenWidth)
            : _buildButtonContent(isLastStep, screenWidth),
      ),
    );
  }

  // عرض محتوى الزر في حالة التحميل
  Widget _buildLoadingContent(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: screenWidth * 0.05,
          height: screenWidth * 0.05,
          child: const CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        Text(
          'جاري التسجيل...',
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.04,
          ),
        ),
      ],
    );
  }

  // عرض محتوى الزر العادي
  Widget _buildButtonContent(bool isLastStep, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLastStep ? 'إنشاء الحساب' : 'التالي',
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.04,
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Icon(
          isLastStep ? Icons.check_circle_outline : Icons.arrow_forward_ios,
          size: screenWidth * 0.04,
        ),
      ],
    );
  }
}
