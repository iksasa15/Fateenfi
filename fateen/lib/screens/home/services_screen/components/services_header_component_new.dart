// components/services_header_component_new.dart
import 'package:flutter/material.dart';
import '../constants/services_constants.dart';

class ServicesHeaderComponent {
  /// بناء هيدر الخدمات مع وضع مساحة مخصصة تحاكي وجود أيقونة
  static Widget buildHeader(BuildContext context) {
    // استخدام نفس قياسات هيدر المقررات بالضبط
    final titleSize = 26.0;
    final padding = 20.0;
    final buttonSize = 45.0; // حجم زر التبديل في هيدر

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // عنوان صفحة الخدمات
          Text(
            ServicesConstants.servicesTitle,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF374151),
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),

          // مساحة فارغة بنفس حجم أيقونة التبديل في هيدر المقررات
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.transparent, // شفاف لكنه يحتل نفس المساحة
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء خط فاصل بعد الهيدر
  static Widget buildDivider() {
    // استخدام نفس خصائص الخط في صفحة المقررات
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.grey.shade200,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
    );
  }
}
