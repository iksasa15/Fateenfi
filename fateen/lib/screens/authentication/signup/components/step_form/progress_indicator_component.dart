// lib/features/step_form/components/progress_indicator_component.dart

import 'package:flutter/material.dart';
import '../../../../../core/constants/appColor.dart'; // Updated import
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
                  color: context.colorTextHint, // استخدام Extension
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
                  color: context.colorPrimaryPale
                      .withOpacity(0.3), // استخدام Extension
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
                      context.colorPrimaryLight, // استخدام Extension
                      context.colorPrimaryDark, // استخدام Extension
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorPrimaryLight
                          .withOpacity(0.3), // استخدام Extension
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
