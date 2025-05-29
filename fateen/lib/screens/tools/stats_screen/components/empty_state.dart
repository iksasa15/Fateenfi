// components/empty_state.dart

import 'package:flutter/material.dart';
import '../constants/stats_colors.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    Key? key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.bar_chart_outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: const Color(0xFFE3E0F8),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: StatsColors.kDarkPurple,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
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
