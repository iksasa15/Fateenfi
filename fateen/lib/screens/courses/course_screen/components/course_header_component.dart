// components/course_header_component.dart
import 'package:flutter/material.dart';
import '../constants/course_header_constants.dart';
import '../controllers/course_header_controller.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class CourseHeaderComponent {
  /// بناء هيدر المقررات مع وضع مساحة مخصصة تحاكي وجود أيقونة الجدول
  static Widget buildHeader(
      BuildContext context, CourseHeaderController controller) {
    // استخدام نفس قياسات الجدول الدراسي بالضبط
    final titleSize = 26.0;
    final padding = 20.0;
    final buttonSize = 45.0; // حجم زر التبديل في هيدر الجدول

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      color: context.colorSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // عنوان صفحة المقررات
          Text(
            controller.isLoading
                ? CourseHeaderConstants.screenTitle
                : controller.screenTitle,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: context.colorTextPrimary,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),

          // مساحة فارغة بنفس حجم أيقونة التبديل في هيدر الجدول
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
  static Widget buildDivider(BuildContext context) {
    // استخدام نفس خصائص الخط في صفحة الجدول
    return Container(
      height: 1,
      width: double.infinity,
      color: context.colorDivider,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
    );
  }
}
