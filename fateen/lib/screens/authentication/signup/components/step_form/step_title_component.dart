// lib/features/step_form/components/step_title_component.dart

import 'package:flutter/material.dart';
import '../../constants/signup_colors.dart';
import '../../signup_controller/controllers/signup_controller.dart';

class StepTitleComponent extends StatelessWidget {
  final SignupController controller;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const StepTitleComponent({
    Key? key,
    required this.controller,
    required this.fadeAnimation,
    required this.slideAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenWidth * 0.02,
          ),
          child: Column(
            children: [
              Text(
                controller.getCurrentStepTitle(),
                style: TextStyle(
                  color: SignupColors.darkPurple,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
              // سطر صغير تحت العنوان
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.02,
                  horizontal: screenWidth * 0.25,
                ),
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SignupColors.mediumPurple.withOpacity(0.2),
                      SignupColors.mediumPurple,
                      SignupColors.mediumPurple.withOpacity(0.2),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
