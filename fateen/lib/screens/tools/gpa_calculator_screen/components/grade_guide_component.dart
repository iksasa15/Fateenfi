// components/grade_guide_component.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/appColor.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isSystem5 = controller.isSystem5;

    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getThemeColor(
            AppColors.surface,
            AppColors.darkSurface,
            isDarkMode,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
          border: Border.all(
            color: AppColors.getThemeColor(
              AppColors.divider,
              AppColors.darkDivider,
              isDarkMode,
            ),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.getThemeColor(
                AppColors.shadow,
                AppColors.darkShadow,
                isDarkMode,
              ),
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
              padding: EdgeInsets.all(AppDimensions.defaultSpacing),
              child: Row(
                children: [
                  // أيقونة
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.getThemeColor(
                        AppColors.surface,
                        AppColors.darkSurface,
                        isDarkMode,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.smallRadius),
                      border: Border.all(
                        color: AppColors.getThemeColor(
                          AppColors.primaryDark,
                          AppColors.darkPrimaryDark,
                          isDarkMode,
                        ).withOpacity(0.1),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      Icons.table_chart_outlined,
                      color: AppColors.getThemeColor(
                        AppColors.primaryLight,
                        AppColors.darkPrimaryLight,
                        isDarkMode,
                      ),
                      size: AppDimensions.extraSmallIconSize,
                    ),
                  ),
                  SizedBox(width: AppDimensions.smallSpacing),
                  Text(
                    GPACalculatorStrings.gradesTable,
                    style: TextStyle(
                      fontSize: AppDimensions.smallBodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getThemeColor(
                        AppColors.textPrimary,
                        AppColors.darkTextPrimary,
                        isDarkMode,
                      ),
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
              color: AppColors.getThemeColor(
                AppColors.divider,
                AppColors.darkDivider,
                isDarkMode,
              ),
            ),

            // الجدول
            Padding(
              padding: EdgeInsets.all(AppDimensions.defaultSpacing),
              child: Table(
                border: TableBorder.all(
                  color: AppColors.getThemeColor(
                    AppColors.divider,
                    AppColors.darkDivider,
                    isDarkMode,
                  ),
                  width: 1,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1.0),
                  1: FlexColumnWidth(1.0),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(2.0),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.getThemeColor(
                        AppColors.primaryDark,
                        AppColors.darkPrimaryDark,
                        isDarkMode,
                      ),
                      borderRadius: const BorderRadius.only(
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
                            context,
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
      padding: EdgeInsets.symmetric(
          vertical: AppDimensions.smallSpacing,
          horizontal: AppDimensions.smallSpacing / 1.5),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: AppDimensions.smallLabelFontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
    );
  }

  // صف في جدول التقديرات
  TableRow _buildGradeTableRow(
    BuildContext context,
    String grade,
    String points,
    String range,
    String verbal,
    Color color,
  ) {
    return TableRow(
      decoration: BoxDecoration(
        color: AppColors.getThemeColor(
          AppColors.surface,
          AppColors.darkSurface,
          Theme.of(context).brightness == Brightness.dark,
        ),
      ),
      children: [
        _buildTableGradeCell(grade, color),
        _buildTableCell(context, points),
        _buildTableCell(context, range),
        _buildTableCell(context, verbal),
      ],
    );
  }

  // خلية في الجدول
  Widget _buildTableCell(BuildContext context, String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: AppDimensions.smallSpacing,
          horizontal: AppDimensions.smallSpacing / 1.5),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: AppDimensions.smallLabelFontSize,
          color: AppColors.getThemeColor(
            AppColors.textPrimary,
            AppColors.darkTextPrimary,
            isDarkMode,
          ),
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
    );
  }

  // خلية تقدير في الجدول
  Widget _buildTableGradeCell(String grade, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: AppDimensions.smallSpacing,
          horizontal: AppDimensions.smallSpacing / 1.5),
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: 2, horizontal: AppDimensions.smallSpacing),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          grade,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppDimensions.smallLabelFontSize,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ),
    );
  }
}
