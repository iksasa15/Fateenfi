import 'package:flutter/material.dart';

/// نموذج بيانات لمقرر واحد
class CourseItem {
  final TextEditingController nameController;
  final TextEditingController creditsController;
  String grade;

  CourseItem({
    required this.nameController,
    required this.creditsController,
    required this.grade,
  });
}
