// lib/screens/notes/components/notes_header_component.dart

import 'package:flutter/material.dart';
import '../constants/notes_strings.dart';
import '../../../../core/constants/appColor.dart'; // Add this import
import '../../../../core/constants/app_dimensions.dart'; // Add this import

class NotesHeaderComponent extends StatelessWidget {
  final VoidCallback onBackPressed;

  const NotesHeaderComponent({
    Key? key,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام نفس قياسات هيدر حاسبة المعدل بالضبط
    final titleSize =
        AppDimensions.smallTitleFontSize; // تصغير حجم الخط ليناسب المركز
    final padding = AppDimensions.sectionPadding;
    final buttonSize = 45.0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          color: context.colorSurface,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // زر الرجوع في الجهة اليمنى
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: onBackPressed,
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: context.colorPrimaryPale,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.largeRadius),
                    ),
                    child: Icon(
                      Icons.arrow_back, // سهم الرجوع
                      color: context.colorPrimaryDark,
                      size: AppDimensions.smallIconSize,
                    ),
                  ),
                ),
              ),

              // عنوان صفحة الملاحظات (في المنتصف تماماً)
              Text(
                NotesStrings.title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: context.colorTextPrimary,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ),

        // خط فاصل
        Container(
          height: 1,
          width: double.infinity,
          color: context.colorBorder,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
