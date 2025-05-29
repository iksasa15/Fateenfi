import 'package:flutter/material.dart';
import '../controllers/mode_controller.dart';
import '../constants/translation_strings.dart';
import '../../../../models/translation_mode.dart'; // إضافة استيراد لـ TranslationMode

class ModeSelectionTab extends StatelessWidget {
  final TranslationMode currentMode;
  final Function(TranslationMode) onModeChanged;

  const ModeSelectionTab({
    Key? key,
    required this.currentMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تعديل لجعل الأزرار متناسقة مع باقي الصفحة
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius:
                BorderRadius.circular(12), // تغيير من 24 إلى 12 للتناسق
            border: Border.all(
              color: const Color(0xFFE3E0F8),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              // زر وضع النصوص
              Expanded(
                child: _buildModeButton(
                  label: TranslationStrings.textMode,
                  isSelected: currentMode == TranslationMode.text,
                  icon: Icons.text_fields_rounded,
                  onTap: () => onModeChanged(TranslationMode.text),
                ),
              ),

              // زر وضع الملفات
              Expanded(
                child: _buildModeButton(
                  label: TranslationStrings.fileMode,
                  isSelected: currentMode == TranslationMode.file,
                  icon: Icons.insert_drive_file_outlined,
                  onTap: () => onModeChanged(TranslationMode.file),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4338CA) : Colors.transparent,
          borderRadius: BorderRadius.circular(8), // تغيير من 20 إلى 8 للتناسق
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFF6C63FF),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : const Color(0xFF6C63FF),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
