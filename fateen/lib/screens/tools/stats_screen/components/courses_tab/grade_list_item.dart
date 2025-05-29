// components/courses_tab/grade_list_item.dart

import 'package:flutter/material.dart';
import '../../constants/stats_colors.dart';

class GradeListItem extends StatelessWidget {
  final String title; // اسم التقييم
  final double value; // الدرجة الفعلية
  final double maxValue; // الدرجة القصوى

  const GradeListItem({
    Key? key,
    required this.title,
    required this.value,
    required this.maxValue, // الدرجة القصوى مطلوبة
  }) : super(key: key);

  // تحديد لون الدرجة حسب القواعد المطلوبة
  Color _getGradeColor() {
    if (maxValue <= 0)
      return Colors.grey; // للتعامل مع الدرجات القصوى غير الصالحة

    // حساب النسبة المئوية
    final percentage = (value / maxValue) * 100;

    if (value == maxValue) {
      return Colors.green; // لون أخضر إذا كانت الدرجة = الدرجة القصوى
    } else if (percentage >= 75) {
      return Colors
          .orange; // لون برتقالي إذا كانت الدرجة ≥ 75% من الدرجة القصوى
    } else {
      return Colors.red; // لون أحمر للنسب الأقل
    }
  }

  // تحديد أيقونة مناسبة لكل نسبة درجة
  IconData _getGradeIcon() {
    if (maxValue <= 0)
      return Icons.error_outline; // للتعامل مع الدرجات القصوى غير الصالحة

    // حساب النسبة المئوية
    final percentage = (value / maxValue) * 100;

    if (value == maxValue) {
      return Icons.emoji_events; // كأس للنتيجة المثالية
    } else if (percentage >= 75) {
      return Icons.thumb_up; // إعجاب للنتيجة الجيدة
    } else {
      return Icons.warning; // تحذير للنتيجة المنخفضة
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = _getGradeColor();
    final gradeIcon = _getGradeIcon();
    final percentage = maxValue > 0 ? (value / maxValue) * 100 : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  gradeIcon,
                  color: gradeColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                    // إضافة الدرجة القصوى مع فاصل
                    Text(
                      "/${maxValue.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // إضافة شريط التقدم لتمثيل النسبة المئوية بين الدرجة الفعلية والدرجة القصوى
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: maxValue > 0 ? value / maxValue : 0,
              backgroundColor: Colors.grey.withOpacity(0.2),
              color: gradeColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${percentage.toStringAsFixed(1)}%",
              style: TextStyle(
                fontSize: 12,
                color: gradeColor,
                fontWeight: FontWeight.w500,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
