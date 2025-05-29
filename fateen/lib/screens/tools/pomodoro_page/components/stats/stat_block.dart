// components/stats/stat_block.dart

import 'package:flutter/material.dart';
import '../../constants/pomodoro_colors.dart';

class StatBlock extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDarkMode;

  const StatBlock({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تقليل الهوامش والحشو بصورة أكبر لتجنب أي تجاوز للحدود
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = 16.0 * 2;
    final edgePadding = 14.0 * 2;
    final internalSpacing = 10.0; // المسافة بين البلوكات

    // إعادة حساب عرض البلوك مع هامش أمان أكبر
    final availableWidth =
        screenWidth - cardPadding - edgePadding - (internalSpacing * 2);
    final width = (availableWidth / 3) - 4.0; // هامش أمان إضافي

    return Container(
      width: width,
      height: 80, // تقليل الارتفاع أكثر
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة البلوك - تقليل الحجم أكثر
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 3),

          // قيمة الإحصائية
          FittedBox(
            // استخدام FittedBox لتقليص النص إذا كان كبيرًا جدًا
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: PomodoroColors.kDarkPurple,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          const SizedBox(height: 2),

          // عنوان الإحصائية
          FittedBox(
            // استخدام FittedBox لتقليص النص إذا كان كبيرًا جدًا
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
