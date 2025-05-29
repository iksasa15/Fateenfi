// components/grade_guide_component.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/gpa_calculator_constants.dart';
import '../constants/gpa_calculator_strings.dart';
import '../controllers/gpa_calculator_controller.dart';

class GradeGuideComponent extends StatelessWidget {
  final GPACalculatorController controller;

  const GradeGuideComponent({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSystem5 = controller.isSystem5;

    return FadeIn(
      duration: const Duration(milliseconds: 500),
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
                      Icons.table_chart_outlined,
                      color: Color(0xFF6366F1),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    GPACalculatorStrings.gradesTable,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                      fontFamily: 'SYMBIOAR+LT',
                    ),
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

            // الجدول
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Table(
                border: TableBorder.all(
                  color: const Color(0xFFE3E0F8),
                  width: 1,
                  borderRadius: BorderRadius.circular(8),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1.0),
                  1: FlexColumnWidth(1.0),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(2.0),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Color(0xFF4338CA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    children: [
                      _buildTableHeaderCell('التقدير'),
                      _buildTableHeaderCell('النقاط'),
                      _buildTableHeaderCell('الدرجة'),
                      _buildTableHeaderCell('التقدير اللفظي'),
                    ],
                  ),
                  ...GPACalculatorConstants.gradeTable
                      .map((item) => _buildGradeTableRow(
                            item['grade'],
                            isSystem5 ? item['points5'] : item['points4'],
                            item['range'],
                            item['verbal'],
                            GPACalculatorConstants.gradeColors[item['grade']]!,
                          ))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // خلية عنوان الجدول
  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
    );
  }

  // صف في جدول التقديرات
  TableRow _buildGradeTableRow(
    String grade,
    String points,
    String range,
    String verbal,
    Color color,
  ) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      children: [
        _buildTableGradeCell(grade, color),
        _buildTableCell(points),
        _buildTableCell(range),
        _buildTableCell(verbal),
      ],
    );
  }

  // خلية في الجدول
  Widget _buildTableCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF374151),
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
    );
  }

  // خلية تقدير في الجدول
  Widget _buildTableGradeCell(String grade, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          grade,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ),
    );
  }
}
