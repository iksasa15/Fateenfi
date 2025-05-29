// components/course_item_component.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/gpa_calculator_constants.dart';
import '../constants/gpa_calculator_strings.dart';
import '../../../../models/course_item.dart';

class CourseItemComponent extends StatelessWidget {
  final int index;
  final CourseItem course;
  final Function(int) onRemove;
  final Function(int, String) onGradeChanged;

  const CourseItemComponent({
    Key? key,
    required this.index,
    required this.course,
    required this.onRemove,
    required this.onGradeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // اسم المقرر
          Expanded(
            flex: 6,
            child: Container(
              height: 45,
              child: TextFormField(
                controller: course.nameController,
                decoration: InputDecoration(
                  hintText: GPACalculatorStrings.courseNameHint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF4338CA).withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF4338CA).withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4338CA),
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // عدد الساعات
          Expanded(
            flex: 3,
            child: Container(
              height: 45,
              child: TextFormField(
                controller: course.creditsController,
                decoration: InputDecoration(
                  hintText: GPACalculatorStrings.creditHoursHint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF4338CA).withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF4338CA).withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4338CA),
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GPACalculatorStrings.requiredField;
                  }
                  return null;
                },
                style: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // التقدير
          Expanded(
            flex: 3,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4338CA).withOpacity(0.2),
                  width: 1.0,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: course.grade,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                  isExpanded: true,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  alignment: Alignment.center,
                  dropdownColor: Colors.white,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      onGradeChanged(index, newValue);
                    }
                  },
                  items: GPACalculatorConstants.gradePoints5.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      alignment: Alignment.center,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: GPACalculatorConstants.gradeColors[value] ??
                                const Color(0xFF374151),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // زر الحذف
          SizedBox(
            width: 30,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove,
                  color: Color(0xFFEC4899),
                  size: 16,
                ),
              ),
              onPressed: () => onRemove(index),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }
}
