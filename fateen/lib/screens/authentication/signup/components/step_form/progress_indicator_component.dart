// lib/features/step_form/components/progress_indicator_component.dart

import 'package:flutter/material.dart';
import '../../constants/signup_colors.dart';
import '../../signup_controller/controllers/signup_controller.dart';

class StepProgressIndicator extends StatelessWidget {
  final SignupController controller;
  final int currentStepNumber;

  const StepProgressIndicator({
    Key? key,
    required this.controller,
    required this.currentStepNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final progressValue = controller.getProgressPercentage();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenWidth * 0.04,
      ),
      child: Column(
        children: [
          // نص لطيف يوضح رقم الخطوة
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'الخطوة $currentStepNumber من 7',
                style: TextStyle(
                  color: SignupColors.hintColor,
                  fontSize: screenWidth * 0.035,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // مؤشر تقدم محسن
          Stack(
            children: [
              // مؤشر الخلفية
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: SignupColors.lightPurple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // مؤشر التقدم المتحرك
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                height: 8,
                width: screenWidth * 0.88 * progressValue,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SignupColors.mediumPurple,
                      SignupColors.darkPurple,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: SignupColors.mediumPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
