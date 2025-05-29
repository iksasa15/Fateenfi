import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/ai_description_constants.dart';

class AiDescriptionComponent extends StatelessWidget {
  const AiDescriptionComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
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
                      Icons.lightbulb_outline,
                      color: Color(0xFF6366F1),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AiDescriptionConstants.descriptionText,
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

            // وصف إضافي (اختياري)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "استخدم أدوات الذكاء الاصطناعي لتحسين تجربة التعلم الخاصة بك",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
