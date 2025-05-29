import 'package:flutter/material.dart';
import '../constants/translation_colors.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final Color iconColor;
  final Widget? content;
  final Widget? trailing;
  final bool isSimpleCard;

  const ServiceCard({
    Key? key,
    required this.title,
    required this.description,
    this.icon,
    required this.iconColor,
    this.content,
    this.trailing,
    this.isSimpleCard = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // إذا كانت بطاقة بسيطة (مثل شاشات الفراغ)
    if (isSimpleCard) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TranslationColors.kBorderColor, width: 1.5),
          boxShadow: [TranslationColors.kShadow],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // العنوان
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TranslationColors.kDarkPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // الوصف
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            // المحتوى (مثل الأيقونة المركزية والنص)
            if (content != null) content!,
          ],
        ),
      );
    }

    // النمط العادي للبطاقات
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TranslationColors.kBorderColor, width: 1.5),
        boxShadow: [TranslationColors.kShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان والوصف والأيقونة
          Row(
            children: [
              // أيقونة الخدمة بلون مخصص
              if (icon != null)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 30,
                  ),
                ),
              if (icon != null) const SizedBox(width: 16),

              // تفاصيل الخدمة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF221291),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // أيقونة اختيارية
              if (trailing != null) trailing!,
            ],
          ),

          // المحتوى الإضافي
          if (content != null) content!,
        ],
      ),
    );
  }
}
