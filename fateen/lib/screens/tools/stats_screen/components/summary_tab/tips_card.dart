// components/summary_tab/tips_card.dart

import 'package:flutter/material.dart';
import '../../constants/stats_colors.dart';
import '../../constants/stats_strings.dart';

class TipsCard extends StatelessWidget {
  final String tipText;
  final bool showAiButton;
  final VoidCallback onAiAnalysisPressed;

  const TipsCard({
    Key? key,
    required this.tipText,
    required this.showAiButton,
    required this.onAiAnalysisPressed,
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
            blurRadius: 2,
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
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: StatsColors.kDarkPurple,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  StatsStrings.tipsTitle,
                  style: TextStyle(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipText,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[700],
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                if (showAiButton) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: StatsColors.kDarkPurple.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: onAiAnalysisPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StatsColors.kDarkPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.psychology,
                        size: 20,
                      ),
                      label: const Text(
                        StatsStrings.advancedAnalytics,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
