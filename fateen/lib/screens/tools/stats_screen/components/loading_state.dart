// components/loading_state.dart

import 'package:flutter/material.dart';
import '../constants/stats_colors.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: StatsColors.kDarkPurple,
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل البيانات...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ],
      ),
    );
  }
}
