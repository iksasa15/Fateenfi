import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/stats_colors.dart';
import '../../../../../models/course_model.dart';

class CourseAverageChart extends StatelessWidget {
  final List<Course> courses;
  final int selectedChartIndex;
  final Function(int)? onBarTap; // جعلها اختيارية

  const CourseAverageChart({
    Key? key,
    required this.courses,
    this.selectedChartIndex = -1, // جعلها قيمة افتراضية غير محددة
    this.onBarTap, // جعلها اختيارية
  }) : super(key: key);

  // حساب مجموع الدرجات الفعلية لمقرر معين
  double _calculateCourseTotalGrades(Course course) {
    if (course.grades == null || course.grades.isEmpty) {
      return 0.0;
    }

    // حساب مجموع الدرجات الفعلية
    double total = 0.0;
    course.grades.forEach((_, gradeValue) {
      total += gradeValue;
    });

    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مقررات لعرضها',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    // حساب أقصى مجموع للدرجات بين جميع المقررات لتحديد مقياس المحور Y
    double maxTotalGrades = 0.0;
    for (var course in courses) {
      final total = _calculateCourseTotalGrades(course);
      if (total > maxTotalGrades) {
        maxTotalGrades = total;
      }
    }

    // جعل الحد الأقصى للمحور Y أكبر بقليل من أعلى قيمة لضمان رؤية الشريط
    double maxY = maxTotalGrades > 0 ? (maxTotalGrades * 1.1) : 100.0;

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(12),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final course = courses[groupIndex];
                final totalGrades = _calculateCourseTotalGrades(course);

                return BarTooltipItem(
                  '${course.courseName}\n'
                  'مجموع الدرجات: ${totalGrades.toStringAsFixed(2)}\n'
                  'عدد التقييمات: ${course.grades.length}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              },
            ),
            // إلغاء الاستجابة عند النقر
            touchCallback: null, // عدم الاستجابة للنقر
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval:
                maxY > 100 ? 50 : 25, // تعديل الفواصل حسب الحد الأقصى
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= courses.length) {
                    return const SizedBox();
                  }
                  final courseName = courses[idx].courseName;
                  final shortName = courseName.length > 8
                      ? '${courseName.substring(0, 8)}...'
                      : courseName;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      shortName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StatsColors.kDarkPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();

                  // تحديد الفواصل المناسبة للعرض على المحور Y
                  double interval = maxY > 200 ? 50 : (maxY > 100 ? 25 : 10);
                  if (value % interval < 0.01 ||
                      (value % interval > interval - 0.01)) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: StatsColors.kDarkPurple.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: List.generate(
            courses.length,
            (i) {
              final course = courses[i];
              final totalGrades = _calculateCourseTotalGrades(course);

              // تحديد لون الشريط - عدم استخدام selectedChartIndex لتلوين الشريط المحدد
              Color barColor;
              if (course.grades.isEmpty) {
                barColor = Colors.grey;
              } else if (totalGrades > 70) {
                barColor = Colors.green;
              } else if (totalGrades > 50) {
                barColor = Colors.lightGreen;
              } else if (totalGrades > 30) {
                barColor = Colors.amber;
              } else if (totalGrades > 20) {
                barColor = Colors.orange;
              } else {
                barColor = Colors.red;
              }

              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: totalGrades,
                    color: barColor,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
