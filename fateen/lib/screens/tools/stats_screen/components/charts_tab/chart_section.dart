// components/charts_tab/chart_section.dart

import 'package:flutter/material.dart';
import '../../constants/stats_colors.dart';

class ChartSection extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData icon;

  const ChartSection({
    Key? key,
    required this.title,
    required this.child,
    this.icon = Icons.pie_chart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4.0, // Replace with an appropriate value
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE3E0F8),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: StatsColors.kDarkPurple.withOpacity(0.1),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: StatsColors.kDarkPurple,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
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
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE3E0F8),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }
}
