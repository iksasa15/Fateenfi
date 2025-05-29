// components/courses_tab/course_stats_grid.dart

import 'package:flutter/material.dart';
import '../../constants/stats_colors.dart';
import '../../constants/stats_strings.dart';
import '../../../../../models/course_model.dart';

class CourseStatsGrid extends StatelessWidget {
  final Course course;

  const CourseStatsGrid({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avg = course.calculateAverage();
    final maxGrade = course.calculateMax();
    final minGrade = course.calculateMin();
    final sumGrade = course.calculateSum();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatCard(
          title: StatsStrings.highestGrade,
          value: maxGrade.toStringAsFixed(2),
          icon: Icons.trending_up,
          iconColor: Colors.green,
        ),
        _buildStatCard(
          title: StatsStrings.lowestGrade,
          value: minGrade.toStringAsFixed(2),
          icon: Icons.trending_down,
          iconColor: Colors.orange,
        ),
        _buildStatCard(
          title: StatsStrings.avgGrade,
          value: avg.toStringAsFixed(2),
          icon: Icons.calculate,
          iconColor: StatsColors.kMediumPurple,
        ),
        _buildStatCard(
          title: StatsStrings.sumGrade,
          value: sumGrade.toStringAsFixed(2),
          icon: Icons.summarize,
          iconColor: StatsColors.kDarkPurple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE3E0F8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.03),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
