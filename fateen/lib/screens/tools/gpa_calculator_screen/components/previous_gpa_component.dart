// components/previous_gpa_component.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/gpa_calculator_strings.dart';

class PreviousGPAComponent extends StatelessWidget {
  final TextEditingController currentGpaController;
  final TextEditingController completedHoursController;

  const PreviousGPAComponent({
    Key? key,
    required this.currentGpaController,
    required this.completedHoursController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE3E0F8),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // رأس القسم
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // أيقونة
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF4338CA).withOpacity(0.1),
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.history_edu_rounded,
                      color: Color(0xFF6366F1),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        GPACalculatorStrings.previousGPA,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        GPACalculatorStrings.previousGPASubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // خط فاصل
            Divider(
              height: 1,
              thickness: 1,
              color: const Color(0xFFE3E0F8),
            ),

            // حقول الإدخال
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // حقل المعدل السابق
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            GPACalculatorStrings.cumulativeGPA,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 50,
                            child: TextFormField(
                              controller: currentGpaController,
                              decoration: InputDecoration(
                                hintText: '0.00',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF4338CA)
                                        .withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF4338CA)
                                        .withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF4338CA),
                                    width: 1.5,
                                  ),
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF4338CA)
                                          .withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.grade_outlined,
                                    color: Color(0xFF6366F1),
                                    size: 16,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                                errorBorder: InputBorder.none,
                                errorStyle:
                                    const TextStyle(height: 0, fontSize: 0),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              style: const TextStyle(
                                fontFamily: 'SYMBIOAR+LT',
                                fontSize: 14,
                                color: Color(0xFF374151),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // حقل عدد الساعات المنجزة
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            GPACalculatorStrings.completedHours,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 50,
                            child: TextFormField(
                              controller: completedHoursController,
                              decoration: InputDecoration(
                                hintText: '0',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF4338CA)
                                        .withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF4338CA)
                                        .withOpacity(0.2),
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
                                prefixIcon: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF4338CA)
                                          .withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.access_time_rounded,
                                    color: Color(0xFF6366F1),
                                    size: 16,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                                errorBorder: InputBorder.none,
                                errorStyle:
                                    const TextStyle(height: 0, fontSize: 0),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontFamily: 'SYMBIOAR+LT',
                                fontSize: 14,
                                color: Color(0xFF374151),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
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
}
