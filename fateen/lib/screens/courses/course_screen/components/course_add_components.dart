// components/course_add_components.dart
import 'package:flutter/material.dart';
import '../constants/course_add_constants.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class CourseAddComponents {
  static final CourseAddConstants constants = CourseAddConstants();

  // بناء حقل إدخال بتصميم مخصص ومحسّن متناسق مع التصميم العام
  static Widget buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    String? errorText,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الحقل - بدون أيقونة
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              labelText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colorTextPrimary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          // حقل الإدخال - تم تعديل الحدود لتظهر بشكل صحيح
          Container(
            height: 50, // ارتفاع ثابت لكل الحقول للتناسق
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? context.colorAccent
                    : context.colorPrimaryDark.withOpacity(0.2),
                width: 1.0, // تخفيف سمك الحدود للحصول على مظهر متساوٍ
              ),
            ),
            child: Row(
              children: [
                // أيقونة حقل الإدخال
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.colorPrimaryDark.withOpacity(0.1),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    icon ?? Icons.text_fields,
                    color: controller.text.isEmpty
                        ? context.colorPrimaryLight
                        : context.colorPrimaryDark,
                    size: 16,
                  ),
                ),

                // حقل الإدخال نفسه
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: 14,
                      color: context.colorTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        color: context.colorTextHint,
                        fontSize: 14,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      errorText: null,
                      errorStyle: const TextStyle(
                        height: 0,
                        fontSize: 0,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: context.colorSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // عرض رسالة الخطأ إن وجدت
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                errorText,
                style: TextStyle(
                  color: context.colorAccent,
                  fontSize: 12,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
        ],
      ),
    );
  }

  // بناء صف يحتوي على حقلين متجاورين (مثل: اسم المقرر وعدد الساعات)
  static Widget buildRowFields({
    required BuildContext context,
    required TextEditingController mainController,
    required String mainLabel,
    String? mainError,
    IconData? mainIcon,
    required TextEditingController secondaryController,
    required String secondaryLabel,
    String? secondaryError,
    TextInputType? secondaryKeyboardType,
    IconData? secondaryIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صف العناوين
          Row(
            children: [
              // عنوان الحقل الرئيسي
              Expanded(
                flex: 7, // نسبة أكبر للحقل الرئيسي
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6, right: 4),
                  child: Text(
                    mainLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colorTextPrimary,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // عنوان الحقل الثانوي
              Expanded(
                flex: 3, // نسبة أصغر للحقل الثانوي
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6, right: 4),
                  child: Text(
                    secondaryLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colorTextPrimary,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ),
            ],
          ),

          // صف الحقول
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الحقل الرئيسي (مثل اسم المقرر)
              Expanded(
                flex: 7, // نسبة أكبر للحقل الرئيسي
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: mainError != null
                          ? context.colorAccent
                          : context.colorPrimaryDark.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // أيقونة الحقل الرئيسي
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.colorSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: context.colorPrimaryDark.withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          mainIcon ?? Icons.text_fields,
                          color: mainController.text.isEmpty
                              ? context.colorPrimaryLight
                              : context.colorPrimaryDark,
                          size: 16,
                        ),
                      ),

                      // الحقل الرئيسي نفسه
                      Expanded(
                        child: TextField(
                          controller: mainController,
                          style: TextStyle(
                            fontFamily: 'SYMBIOAR+LT',
                            fontSize: 14,
                            color: context.colorTextPrimary,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: context.colorTextHint,
                              fontSize: 14,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                            errorText: null,
                            errorStyle: const TextStyle(
                              height: 0,
                              fontSize: 0,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            border: InputBorder.none,
                            errorBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: true,
                            fillColor: context.colorSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // الحقل الثانوي (مثل عدد الساعات)
              Expanded(
                flex: 3, // نسبة أصغر للحقل الثانوي
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: secondaryError != null
                          ? context.colorAccent
                          : context.colorPrimaryDark.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // أيقونة الحقل الثانوي
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.colorSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: context.colorPrimaryDark.withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          secondaryIcon ?? Icons.hourglass_empty,
                          color: secondaryController.text.isEmpty
                              ? context.colorPrimaryLight
                              : context.colorPrimaryDark,
                          size: 16,
                        ),
                      ),

                      // الحقل الثانوي نفسه
                      Expanded(
                        child: TextField(
                          controller: secondaryController,
                          keyboardType:
                              secondaryKeyboardType ?? TextInputType.number,
                          style: TextStyle(
                            fontFamily: 'SYMBIOAR+LT',
                            fontSize: 14,
                            color: context.colorTextPrimary,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: context.colorTextHint,
                              fontSize: 14,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                            errorText: null,
                            errorStyle: const TextStyle(
                              height: 0,
                              fontSize: 0,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            border: InputBorder.none,
                            errorBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: true,
                            fillColor: context.colorSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // عرض رسائل الخطأ
          if (mainError != null || secondaryError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mainError != null)
                    Expanded(
                      flex: 7,
                      child: Text(
                        mainError,
                        style: TextStyle(
                          color: context.colorAccent,
                          fontSize: 12,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                  if (mainError != null) const SizedBox(width: 10),
                  if (secondaryError != null)
                    Expanded(
                      flex: 3,
                      child: Text(
                        secondaryError,
                        style: TextStyle(
                          color: context.colorAccent,
                          fontSize: 12,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // بناء رقاقة اختيار بتصميم محسّن
  static Widget buildChoiceChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontSize: 13,
            color: isSelected
                ? context.colorPrimaryDark
                : context.colorTextPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: context.colorSurface,
        backgroundColor: context.colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected
                ? context.colorPrimaryLight
                : context.isDarkMode
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onSelected: onSelected,
      ),
    );
  }

  // بناء زر رئيسي بتصميم محسّن
  static Widget buildPrimaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.colorPrimaryDark.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorPrimaryDark,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              context.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // بناء علامة السحب بتصميم محسّن
  static Widget buildDragHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: context.isDarkMode
                ? Colors.grey.shade700
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  // بناء شريط العنوان بتصميم محسّن
  static Widget buildToolbar({
    required BuildContext context,
    required String title,
    required VoidCallback onBackPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الصف الأول: زر الرجوع والعنوان
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // زر الرجوع
            GestureDetector(
              onTap: onBackPressed,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.colorSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  Icons.close,
                  color: context.colorPrimaryDark,
                  size: 18,
                ),
              ),
            ),
            // العنوان
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: context.colorSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade200,
                  width: 1.0,
                ),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.colorPrimaryDark,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
            // مساحة فارغة للمحاذاة
            const SizedBox(width: 36),
          ],
        ),
        const SizedBox(height: 16),
        // وصف مع أيقونة
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.colorPrimaryDark.withOpacity(0.1),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: context.colorPrimaryDark,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "قم بإدخال بيانات المقرر الدراسي بشكل كامل",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colorTextSecondary,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // دالة محسّنة لبناء منتقي الوقت بتصميم أكثر جاذبية
  static Widget buildTimePicker({
    required BuildContext context,
    required String? selectedTime,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4),
          child: Text(
            constants.timeLabel,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.colorTextPrimary,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedTime != null
                    ? context.colorPrimaryLight
                    : context.colorPrimaryDark.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    border: Border.all(
                      color: context.colorPrimaryDark.withOpacity(0.1),
                      width: 1.0,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.access_time_filled,
                      size: 20,
                      color: context.colorPrimaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        constants.timeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colorTextSecondary,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedTime ?? constants.selectTimeHint,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: selectedTime != null
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: selectedTime != null
                              ? context.colorPrimaryDark
                              : context.colorTextHint,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: selectedTime != null
                        ? context.colorPrimaryDark
                        : context.colorTextHint,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // قسم أيام الأسبوع المحسّن
  static Widget buildDaysSection({
    required BuildContext context,
    required List<String> selectedDays,
    required Function(String, bool) onDaySelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4),
          child: Text(
            constants.daysLabel,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.colorTextPrimary,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colorPrimaryDark.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                'الأحد',
                'الإثنين',
                'الثلاثاء',
                'الأربعاء',
                'الخميس',
              ].map((day) {
                final isSelected = selectedDays.contains(day);
                return Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: buildChoiceChip(
                    context: context,
                    label: day,
                    isSelected: isSelected,
                    onSelected: (selected) => onDaySelected(day, selected),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
