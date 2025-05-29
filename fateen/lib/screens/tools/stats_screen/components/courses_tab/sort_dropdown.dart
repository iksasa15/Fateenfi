// components/courses_tab/sort_dropdown.dart

import 'package:flutter/material.dart';
import '../../constants/stats_colors.dart';
import '../../constants/stats_strings.dart';

class SortDropdown extends StatelessWidget {
  final String currentValue;
  final Function(String?) onChanged;

  const SortDropdown({
    Key? key,
    required this.currentValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE3E0F8),
          width: 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          dropdownColor: Colors.white,
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: StatsColors.kDarkPurple,
            size: 20,
          ),
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(
            fontSize: 14,
            color: StatsColors.kDarkPurple,
            fontWeight: FontWeight.w500,
            fontFamily: 'SYMBIOAR+LT',
          ),
          items: const [
            DropdownMenuItem(
              value: 'name',
              child: Text(StatsStrings.sortByName),
            ),
            DropdownMenuItem(
              value: 'average',
              child: Text(StatsStrings.sortByAverage),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
