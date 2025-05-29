// lib/screens/notes/components/notes_header_component.dart

import 'package:flutter/material.dart';
import '../constants/notes_strings.dart';

class NotesHeaderComponent extends StatelessWidget {
  final VoidCallback onBackPressed;

  const NotesHeaderComponent({
    Key? key,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام نفس قياسات هيدر حاسبة المعدل بالضبط
    final titleSize = 20.0; // تصغير حجم الخط ليناسب المركز
    final padding = 20.0;
    final buttonSize = 45.0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          color: Colors.white,
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
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.arrow_back, // سهم الرجوع
                      color: Color(0xFF4338CA),
                      size: 20,
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
                  color: const Color(0xFF374151),
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
          color: Colors.grey.shade200,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
