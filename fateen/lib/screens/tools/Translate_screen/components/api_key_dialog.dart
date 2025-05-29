// components/api_key_dialog.dart

import 'package:flutter/material.dart';
import '../constants/translation_strings.dart';

class ApiKeyDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;

  const ApiKeyDialog({
    Key? key,
    required this.controller,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        TranslationStrings.apiKeySettingsTitle,
        style: const TextStyle(
          color: Color(0xFF221291),
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationStrings.apiKeyDescription,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE3E0F8),
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: TranslationStrings.apiKeyHint,
                hintStyle: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: 12,
                ),
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
              ),
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'SYMBIOAR+LT',
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF4338CA),
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  TranslationStrings.apiKeyInfo,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            TranslationStrings.cancel,
            style: TextStyle(
              color: Colors.grey[700],
              fontFamily: 'SYMBIOAR+LT',
              fontSize: 12,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onSave();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4338CA),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            TranslationStrings.save,
            style: const TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
