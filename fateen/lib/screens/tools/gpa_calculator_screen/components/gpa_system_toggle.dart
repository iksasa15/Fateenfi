// components/gpa_system_toggle.dart

import 'package:flutter/material.dart';
import '../constants/gpa_calculator_strings.dart';
import '../controllers/gpa_calculator_controller.dart';

class GPASystemToggle extends StatelessWidget {
  final GPACalculatorController controller;

  const GPASystemToggle({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE3E0F8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // رأس القسم
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // أيقونة
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF4338CA).withOpacity(0.1),
                      width: 1.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.calculate_outlined,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  GPACalculatorStrings.gpaSystem,
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

          // خط فاصل
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFFE3E0F8),
          ),

          // أزرار التبديل بين الأنظمة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildSystemButton(
                    label: GPACalculatorStrings.gpaSystem5,
                    isSelected: controller.isSystem5,
                    onTap: () => controller.toggleGPASystem(true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSystemButton(
                    label: GPACalculatorStrings.gpaSystem4,
                    isSelected: !controller.isSystem5,
                    onTap: () => controller.toggleGPASystem(false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4338CA) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4338CA)
                : const Color(0xFFE3E0F8),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4338CA).withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF374151),
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ),
    );
  }
}