// components/pomodoro_header_component.dart

import 'package:flutter/material.dart';
import '../constants/pomodoro_strings.dart';

class PomodoroHeaderComponent extends StatelessWidget {
  final Function() onSettingsPressed;

  const PomodoroHeaderComponent({
    Key? key,
    required this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام نفس قياسات هيدر السبورة بالضبط
    final titleSize = 20.0; // تصغير حجم الخط ليناسب المركز
    final padding = 20.0;
    final buttonSize = 45.0; // حجم زر التبديل في هيدر الجدول

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // زر الإعدادات في الجهة اليسرى
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: onSettingsPressed,
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Color(0xFF4338CA),
                      size: 20,
                    ),
                  ),
                ),
              ),

              // زر الرجوع في الجهة اليمنى
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF4338CA),
                      size: 20,
                    ),
                  ),
                ),
              ),

              // عنوان صفحة وقت المذاكرة (في المنتصف تماماً)
              Text(
                PomodoroStrings.appTitle,
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
