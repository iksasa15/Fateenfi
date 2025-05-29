import 'package:flutter/material.dart';
import '../../constants/grades/course_grades_constants.dart';
import '../../constants/grades/course_grades_colors.dart';

class CourseGradesEmptyView extends StatelessWidget {
  const CourseGradesEmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 60,
            color: CourseGradesColors.lightPurple,
          ),
          const SizedBox(height: 16),
          const Text(
            CourseGradesConstants.noGradesMessage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CourseGradesColors.darkPurple,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            CourseGradesConstants.addGradesHint,
            style: TextStyle(
              fontSize: 14,
              color: CourseGradesColors.textLightColor,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
