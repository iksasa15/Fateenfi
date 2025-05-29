// components/course_add_components.dart
import 'package:flutter/material.dart';
import '../constants/course_add_constants.dart';

class CourseAddComponents {
  static final CourseAddConstants constants = CourseAddConstants();

  // بناء حقل إدخال بتصميم مخصص ومحسّن متناسق مع التصميم العام
  static Widget buildTextField({
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151), // kTextColor
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          // حقل الإدخال - تم تعديل الحدود لتظهر بشكل صحيح
          Container(
            height: 50, // ارتفاع ثابت لكل الحقول للتناسق
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? const Color(0xFFEC4899) // kAccentColor
                    : const Color(0xFF4338CA).withOpacity(0.2),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF4338CA).withOpacity(0.1),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    icon ?? Icons.text_fields,
                    color: controller.text.isEmpty
                        ? const Color(0xFF6366F1) // kMediumPurple
                        : const Color(0xFF4338CA), // kDarkPurple
                    size: 16,
                  ),
                ),

                // حقل الإدخال نفسه
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: const TextStyle(
                      fontFamily: 'SYMBIOAR+LT',
                      fontSize: 14,
                      color: Color(0xFF374151), // kTextColor
                    ),
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF), // kHintColor
                        fontSize: 14,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      errorText:
                          null, // تغيير لإزالة الفجوة التي يمكن أن تسببها رسالة الخطأ
                      errorStyle: const TextStyle(
                        height: 0, // إزالة المساحة التي تشغلها رسالة الخطأ
                        color: Color(0xFFEC4899), // kAccentColor
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
                      fillColor: Colors.white,
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
                style: const TextStyle(
                  color: Color(0xFFEC4899), // kAccentColor
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151), // kTextColor
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151), // kTextColor
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: mainError != null
                          ? const Color(0xFFEC4899) // kAccentColor
                          : const Color(0xFF4338CA).withOpacity(0.2),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF4338CA).withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          mainIcon ?? Icons.text_fields,
                          color: mainController.text.isEmpty
                              ? const Color(0xFF6366F1) // kMediumPurple
                              : const Color(0xFF4338CA), // kDarkPurple
                          size: 16,
                        ),
                      ),

                      // الحقل الرئيسي نفسه
                      Expanded(
                        child: TextField(
                          controller: mainController,
                          style: const TextStyle(
                            fontFamily: 'SYMBIOAR+LT',
                            fontSize: 14,
                            color: Color(0xFF374151), // kTextColor
                          ),
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF), // kHintColor
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
                            fillColor: Colors.white,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: secondaryError != null
                          ? const Color(0xFFEC4899) // kAccentColor
                          : const Color(0xFF4338CA).withOpacity(0.2),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF4338CA).withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          secondaryIcon ?? Icons.hourglass_empty,
                          color: secondaryController.text.isEmpty
                              ? const Color(0xFF6366F1) // kMediumPurple
                              : const Color(0xFF4338CA), // kDarkPurple
                          size: 16,
                        ),
                      ),

                      // الحقل الثانوي نفسه
                      Expanded(
                        child: TextField(
                          controller: secondaryController,
                          keyboardType:
                              secondaryKeyboardType ?? TextInputType.number,
                          style: const TextStyle(
                            fontFamily: 'SYMBIOAR+LT',
                            fontSize: 14,
                            color: Color(0xFF374151), // kTextColor
                          ),
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF), // kHintColor
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
                            fillColor: Colors.white,
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
                        style: const TextStyle(
                          color: Color(0xFFEC4899), // kAccentColor
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
                        style: const TextStyle(
                          color: Color(0xFFEC4899), // kAccentColor
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
                ? const Color(0xFF4338CA) // kDarkPurple
                : const Color(0xFF374151), // kTextColor
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.white,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF6366F1) // kMediumPurple
                : Colors.grey.shade300,
            width: 1.0, // تخفيف سمك الحدود
          ),
        ),
        elevation: 0, // إزالة الارتفاع لتجنب مشاكل الظل مع الحدود
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onSelected: onSelected,
      ),
    );
  }

  // بناء زر رئيسي بتصميم محسّن
  static Widget buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 48, // ارتفاع أصغر للزر
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4338CA), // kDarkPurple
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
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
  static Widget buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  // بناء شريط العنوان بتصميم محسّن
  static Widget buildToolbar({
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF4338CA), // kDarkPurple
                  size: 18,
                ),
              ),
            ),
            // العنوان
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1.0,
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4338CA), // kDarkPurple
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF4338CA).withOpacity(0.1),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF4338CA),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "قم بإدخال بيانات المقرر الدراسي بشكل كامل",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
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

  // دالة محسّنة لبناء منتقي الوقت بتصميم أكثر جاذبية - مع إصلاح مشكلة التدفق الزائد
  static Widget buildTimePicker({
    required String? selectedTime,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان الحقل - بدون أيقونة
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4),
          child: Text(
            constants.timeLabel,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151), // kTextColor
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),

        // الحقل نفسه - تم تعديله لإصلاح مشكلة التدفق الزائد
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 72, // زيادة الارتفاع قليلاً
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedTime != null
                    ? const Color(0xFF6366F1) // kMediumPurple
                    : const Color(0xFF4338CA).withOpacity(0.2),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // تعديل الحشو
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // ضمان المحاذاة المركزية
              children: [
                // أيقونة الساعة
                Container(
                  width: 38,
                  height: 38, // تقليل الحجم قليلاً
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF4338CA).withOpacity(0.1),
                      width: 1.0,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.access_time_filled,
                      size: 20, // تصغير الأيقونة
                      color: Color(0xFF4338CA),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // تفاصيل الوقت
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // مهم لمنع التدفق الزائد
                    children: [
                      // عنوان
                      Text(
                        constants.timeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      const SizedBox(height: 2), // تقليل المسافة

                      // الوقت المختار أو رسالة لاختيار الوقت
                      Text(
                        selectedTime ?? constants.selectTimeHint,
                        style: TextStyle(
                          fontSize: 15, // تقليل حجم الخط
                          fontWeight: selectedTime != null
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: selectedTime != null
                              ? const Color(0xFF4338CA)
                              : const Color(0xFF9CA3AF),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        overflow: TextOverflow.ellipsis, // منع النص من التدفق
                      ),
                    ],
                  ),
                ),

                // أيقونة السهم
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: selectedTime != null
                        ? const Color(0xFF4338CA)
                        : Colors.grey.shade400,
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

  // قسم أيام الأسبوع المحسّن - تم تعديله لعرض الأيام في صف واحد
  static Widget buildDaysSection({
    required List<String> selectedDays,
    required Function(String, bool) onDaySelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم - بدون أيقونة
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4),
          child: Text(
            constants.daysLabel,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151), // kTextColor
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ),

        // بطاقة تحوي أيام الأسبوع - تم تعديلها لإصلاح مشكلة الارتفاع والحدود
        Container(
          width: double.infinity,
          height: 60, // ضبط ارتفاع محدد
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF4338CA).withOpacity(0.2),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 8), // تقليل الحشو العمودي
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // ضمان المحاذاة المركزية
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
