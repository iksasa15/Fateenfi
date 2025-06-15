// components/services_header_component_new.dart
import 'package:flutter/material.dart';
import '../constants/services_constants.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';
class ServicesHeaderComponent {
  /// بناء هيدر الخدمات مع وضع مساحة مخصصة تحاكي وجود أيقونة
  static Widget buildHeader(BuildContext context) {
    final buttonSize = 45.0; // حجم زر التبديل في هيدر

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.sectionPadding),
      color: context.colorSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // عنوان صفحة الخدمات
          Text(
            ServicesConstants.servicesTitle,
            style: TextStyle(
              fontSize: AppDimensions.smallTitleFontSize + 2,
              fontWeight: FontWeight.bold,
              color: context.colorTextPrimary,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),

          // مساحة فارغة بنفس حجم أيقونة التبديل في هيدر المقررات
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.transparent, // شفاف لكنه يحتل نفس المساحة
              borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
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
