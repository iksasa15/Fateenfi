// components/deepl_option.dart

import 'package:flutter/material.dart';
import '../constants/translation_strings.dart';

// رغم أننا لا نعرض هذا المكون في الواجهة، سنبقيه جاهزاً في حال تغيرت المتطلبات
class DeeplOption extends StatelessWidget {
  final bool useDeeplFormatting;
  final bool hasApiKey;
  final VoidCallback onToggleDeeplFormatting;
  final VoidCallback onSetupApiKey;

  const DeeplOption({
    Key? key,
    required this.useDeeplFormatting,
    required this.hasApiKey,
    required this.onToggleDeeplFormatting,
    required this.onSetupApiKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFE3E0F8),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF221291),
                size: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  TranslationStrings.deeplInfo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF221291),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                TranslationStrings.deeplOption,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF221291),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
            Switch(
              value: true, // دائمًا مفعل
              onChanged: null, // لا يمكن تغييره
              activeColor: const Color(0xFF4338CA),
            ),
          ],
        ),
        if (!hasApiKey) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFCCCC),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationStrings.apiKeyRequired,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B6B),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        TranslationStrings.apiKeySetup,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onSetupApiKey,
              icon: const Icon(Icons.vpn_key_outlined, size: 14),
              label: Text(
                TranslationStrings.apiKeySettingsTitle,
                style: const TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: 12,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF221291),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
