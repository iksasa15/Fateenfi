// components/stats_header_component.dart

import 'package:flutter/material.dart';
import '../constants/stats_strings.dart';
import '../constants/stats_colors.dart';

class StatsHeaderComponent extends StatelessWidget {
  const StatsHeaderComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // زر الرجوع في الجهة اليمنى
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: StatsColors.kDarkPurple,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // عنوان صفحة الإحصائيات (في المنتصف)
              const Text(
                StatsStrings.pageTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ),

        // خط فاصل
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.grey.shade200,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
