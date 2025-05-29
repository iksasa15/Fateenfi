import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/stats_colors.dart';
import '../../constants/stats_strings.dart';
import 'badge.dart' as CustomBadge;

class GradeDistributionChart extends StatelessWidget {
  final Map<String, int> distribution;
  final int? touchedIndex;
  final Function(int?) onTouch;

  const GradeDistributionChart({
    Key? key,
    required this.distribution,
    required this.touchedIndex,
    required this.onTouch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
              sections: _buildSections(),
              pieTouchData: PieTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.touchedSection == null) {
                    if (touchedIndex != null) {
                      onTouch(null);
                    }
                    return;
                  }
                  if (event is FlTapUpEvent) {
                    final newIndex =
                        response.touchedSection!.touchedSectionIndex;
                    if (newIndex < 0) {
                      if (touchedIndex != null) {
                        onTouch(null);
                      }
                    } else if (newIndex != touchedIndex) {
                      onTouch(newIndex);
                    }
                  }
                },
              ),
            ),
          ),
          // عنوان في المنتصف
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  StatsStrings.total,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${distribution.values.fold(0, (p, c) => p + c)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const Text(
                  StatsStrings.gradeWord,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final sections = <PieChartSectionData>[];
    final totalCount = distribution.values.fold(0, (p, c) => p + c);

    if (totalCount == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: 'لا يوجد بيانات',
          radius: 50,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ];
    }

    for (int i = 0; i < StatsStrings.gradeRanges.length; i++) {
      final rangeLabel = StatsStrings.gradeRanges[i];
      final value = distribution[rangeLabel] ?? 0;
      if (value == 0) continue;

      // عرض القيمة الفعلية بدلاً من النسبة المئوية
      final isTouched = (i == touchedIndex);

      sections.add(
        PieChartSectionData(
          color:
              StatsColors.pieChartColors[i % StatsColors.pieChartColors.length],
          value: value.toDouble(),
          // عرض القيمة الفعلية بدلاً من النسبة المئوية
          title: '$value',
          radius: isTouched ? 60 : 50,
          titleStyle: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          badgeWidget: isTouched
              ? CustomBadge.Badge(
                  rangeLabel,
                  size: 40,
                  borderColor: StatsColors
                      .pieChartColors[i % StatsColors.pieChartColors.length],
                )
              : null,
          badgePositionPercentageOffset: 1.1,
        ),
      );
    }
    return sections;
  }
}
