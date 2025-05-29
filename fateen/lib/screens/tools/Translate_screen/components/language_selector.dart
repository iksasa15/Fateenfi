// components/language_selector.dart

import 'package:flutter/material.dart';
import '../constants/translation_colors.dart';
import '../constants/translation_strings.dart';
import '../../../../models/language_model.dart';

class LanguageSelector extends StatelessWidget {
  final LanguageModel selectedSourceLanguage;
  final LanguageModel selectedTargetLanguage;
  final Function(LanguageModel) onSourceLanguageChanged;
  final Function(LanguageModel) onTargetLanguageChanged;
  final VoidCallback onSwapLanguages;
  final List<LanguageModel> availableLanguages;

  const LanguageSelector({
    Key? key,
    required this.selectedSourceLanguage,
    required this.selectedTargetLanguage,
    required this.onSourceLanguageChanged,
    required this.onTargetLanguageChanged,
    required this.onSwapLanguages,
    required this.availableLanguages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // لغة الهدف
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TranslationStrings.targetLanguage,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF221291),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                currentLanguage: selectedTargetLanguage,
                onChanged: onTargetLanguageChanged,
              ),
            ],
          ),
        ),

        // زر تبديل اللغات
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: IconButton(
            onPressed: onSwapLanguages,
            icon: const Icon(
              Icons.swap_horiz,
              color: Color(0xFF4338CA),
              size: 24,
            ),
            tooltip: TranslationStrings.switchLanguages,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),

        // لغة المصدر
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TranslationStrings.sourceLanguage,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF221291),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                currentLanguage: selectedSourceLanguage,
                onChanged: onSourceLanguageChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required LanguageModel currentLanguage,
    required Function(LanguageModel) onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE3E0F8),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LanguageModel>(
          isExpanded: true,
          value: currentLanguage,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF221291),
            size: 20,
          ),
          dropdownColor: Colors.white,
          items: availableLanguages.map((language) {
            return DropdownMenuItem<LanguageModel>(
              value: language,
              child: Text(
                language.name,
                style: const TextStyle(
                  color: Color(0xFF221291),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
