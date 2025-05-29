import 'package:flutter/material.dart';
import '../../constants/course_grades_constants.dart';

class CourseGradesComponents {
  // بناء شاشة كاملة
  static Widget buildScreenContainer({
    required BuildContext context,
    required String toolbarTitle,
    required String toolbarSubtitle,
    required VoidCallback onBackPressed,
    required bool isEmpty,
    required Widget emptyView,
    required Widget Function(BuildContext) contentBuilder,
    required String addButtonText,
    required bool isAddButtonLoading,
    required VoidCallback onAddPressed,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // علامة السحب
            Padding(
              padding: const EdgeInsets.only(top: 10),
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
            ),

            // المحتوى الرئيسي
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شريط العنوان
                    buildToolbar(
                      title: toolbarTitle,
                      subtitle: toolbarSubtitle,
                      onBackPressed: onBackPressed,
                    ),

                    // محتوى الدرجات أو رسالة فارغة
                    Expanded(
                      child: isEmpty ? emptyView : contentBuilder(context),
                    ),

                    // زر إضافة درجة جديدة
                    const SizedBox(height: 16),
                    buildPrimaryButton(
                      text: addButtonText,
                      onPressed: onAddPressed,
                      icon: Icons.add,
                      isLoading: isAddButtonLoading,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عرض رسالة عدم وجود درجات في المنتصف
  static Widget buildEmptyGradesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 60,
            color: const Color(0xFFF5F3FF),
          ),
          const SizedBox(height: 16),
          const Text(
            CourseGradesConstants.noGradesMessage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4338CA),
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            CourseGradesConstants.addGradesHint,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ],
      ),
    );
  }

  // بناء شريط العنوان
  static Widget buildToolbar({
    required String title,
    required String subtitle,
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
                  color: Color(0xFF4338CA),
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
                  color: Color(0xFF4338CA),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
            // مساحة فارغة للمحاذاة
            const SizedBox(width: 36),
          ],
        ),
        const SizedBox(height: 12),
        // وصف مع أيقونة
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
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
        const SizedBox(height: 12),
      ],
    );
  }

  // بناء بطاقة درجة - تم تحديث الألوان ووضوح العناصر
  static Widget buildGradeCard({
    required String assignment,
    required double gradeValue,
    required double maxGrade,
    required Color gradeColor,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    // حساب الدرجة الفعلية
    final actualGrade = (gradeValue / 100) * maxGrade;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white, // تغيير اللون إلى أبيض
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD8D2FF),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.assignment_outlined,
                size: 20,
                color: const Color(0xFF4338CA),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${actualGrade.toStringAsFixed(1)} / $maxGrade',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // زر التعديل
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_outlined,
              color: const Color(0xFF4338CA),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
          // زر الحذف
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              color: const Color(0xFFEC4899),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ],
      ),
    );
  }

  // بناء نموذج إضافة أو تعديل درجة
  static Widget buildGradeDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String assignmentTypeLabel,
    required List<String> assignmentTypes,
    required String? selectedAssignmentType,
    required TextEditingController gradeController,
    required TextEditingController maxGradeController,
    required String? assignmentError,
    required String? gradeError,
    required String? maxGradeError,
    required String gradeLabel,
    required String maxGradeLabel,
    required String saveButtonText,
    required bool isLoading,
    required bool isEditMode,
    required Function(String?, StateSetter) onAssignmentSelected,
    required VoidCallback onSave,
    required VoidCallback onCancel,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // علامة السحب
            Padding(
              padding: const EdgeInsets.only(top: 10),
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
            ),

            const SizedBox(height: 10),

            // شريط العنوان
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صف العنوان والزر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر الرجوع
                      GestureDetector(
                        onTap: onCancel,
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
                            color: Color(0xFF4338CA),
                            size: 18,
                          ),
                        ),
                      ),
                      // العنوان
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
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
                            color: Color(0xFF4338CA),
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                        ),
                      ),
                      // مساحة فارغة للمحاذاة
                      const SizedBox(width: 36),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // وصف مع أيقونة
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
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
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // محتوى النموذج
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StatefulBuilder(
                builder: (context, setStateLocal) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // قسم نوع الدرجة
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // عنوان القسم
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, right: 4),
                            child: Text(
                              assignmentTypeLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),

                          // قائمة أنواع الدرجات - تم تحسينها لتستجيب فوراً
                          buildAssignmentTypeChips(
                            assignmentTypes: assignmentTypes,
                            selectedType: selectedAssignmentType,
                            assignmentError: assignmentError,
                            onSelected: (type) {
                              onAssignmentSelected(type, setStateLocal);
                            },
                          ),

                          // عرض رسالة الخطأ
                          if (assignmentError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, right: 4),
                              child: Text(
                                assignmentError,
                                style: const TextStyle(
                                  color: Color(0xFFEC4899),
                                  fontSize: 12,
                                  fontFamily: 'SYMBIOAR+LT',
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // صف الدرجات
                      buildRowFields(
                        mainController: gradeController,
                        mainLabel: gradeLabel,
                        mainError: gradeError,
                        mainIcon: Icons.grade_outlined,
                        secondaryController: maxGradeController,
                        secondaryLabel: maxGradeLabel,
                        secondaryError: maxGradeError,
                        secondaryKeyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        secondaryIcon: Icons.assignment_outlined,
                      ),

                      const SizedBox(height: 16),

                      // زر الحفظ
                      buildPrimaryButton(
                        text: saveButtonText,
                        onPressed: onSave,
                        icon: Icons.save_outlined,
                        isLoading: isLoading,
                      ),

                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء رقاقات اختيار نوع التقييم - تم تحسين الاستجابة للاختيار
  static Widget buildAssignmentTypeChips({
    required List<String> assignmentTypes,
    required String? selectedType,
    required String? assignmentError,
    required Function(String?) onSelected,
  }) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: assignmentError != null
              ? const Color(0xFFEC4899)
              : const Color(0xFF4338CA).withOpacity(0.2),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: assignmentTypes.map((type) {
            final bool isSelected = selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // استخدام InkWell بدلاً من GestureDetector للحصول على تأثير الضغط
                    // وسرعة الاستجابة: عند الضغط يتم تغيير نوع التقييم فوراً
                    onSelected(isSelected ? '' : type);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: buildChoiceChip(
                    label: type,
                    isSelected: isSelected,
                    onSelected: (selected) {
                      onSelected(selected ? type : '');
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // بناء رقاقة اختيار - تم تحديث لتغيير لون الخلفية عند الاختيار
  static Widget buildChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'SYMBIOAR+LT',
          color: isSelected
              ? Colors.white
              : Colors.black87, // تغيير لون النص إلى أبيض عند الاختيار
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(
          0xFF4338CA), // لون الخلفية عند الاختيار - البنفسجي من هوية التطبيق
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? const Color(0xFF4338CA) : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      onSelected: onSelected,
      elevation: isSelected ? 1 : 0, // إضافة ارتفاع بسيط للعنصر المحدد
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // بناء زر رئيسي
  static Widget buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4338CA),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // بناء صف من حقول الإدخال - تحديث لتكون بخلفية بيضاء
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الحقل الأول
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 4),
                child: Text(
                  mainLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: mainError != null
                        ? const Color(0xFFEC4899)
                        : const Color(0xFF4338CA).withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: mainController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
                  decoration: InputDecoration(
                    icon: mainIcon != null
                        ? Icon(
                            mainIcon,
                            color: const Color(0xFF4338CA),
                            size: 20,
                          )
                        : null,
                    border: InputBorder.none,
                    hintText: mainLabel,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ),
              if (mainError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(
                    mainError,
                    style: const TextStyle(
                      color: Color(0xFFEC4899),
                      fontSize: 12,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // الحقل الثاني
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 4),
                child: Text(
                  secondaryLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: secondaryError != null
                        ? const Color(0xFFEC4899)
                        : const Color(0xFF4338CA).withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: secondaryController,
                  keyboardType: secondaryKeyboardType,
                  style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
                  decoration: InputDecoration(
                    icon: secondaryIcon != null
                        ? Icon(
                            secondaryIcon,
                            color: const Color(0xFF4338CA),
                            size: 20,
                          )
                        : null,
                    border: InputBorder.none,
                    hintText: secondaryLabel,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
              ),
              if (secondaryError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(
                    secondaryError,
                    style: const TextStyle(
                      color: Color(0xFFEC4899),
                      fontSize: 12,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // بناء بطاقات عرض الدرجات في الملخص
  static Widget buildGradeDisplayItem({
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // القيمة
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),

          // الأيقونة
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
