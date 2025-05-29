// lib/screens/notes/components/note_editor.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/note_model.dart';
import '../controllers/note_editor_controller.dart';
import '../constants/notes_colors.dart';
import '../constants/notes_strings.dart';
import '../constants/notes_icons.dart';

class NoteEditor extends StatefulWidget {
  final Note? note;
  final List<String> categories;
  final Function(String) saveCategory;
  final Function(bool) onSaveComplete;

  const NoteEditor({
    Key? key,
    this.note,
    required this.categories,
    required this.saveCategory,
    required this.onSaveComplete,
  }) : super(key: key);

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late NoteEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NoteEditorController();
    _controller.init(widget.note, widget.categories);

    _controller.stateChanged.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller.stateChanged.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // تحديد حجم النافذة ليكون مناسبًا
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مؤشر السحب
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 10),
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

            // محتوى النافذة
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شريط العنوان
                    _buildToolbar(
                      title: widget.note == null
                          ? NotesStrings.addNote
                          : NotesStrings.editNote,
                      onBackPressed: () => Navigator.pop(context),
                    ),

                    // المحتوى القابل للتمرير
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // حقل العنوان
                            _buildTextField(
                              controller: _controller.titleController,
                              labelText: NotesStrings.noteTitle,
                              errorText:
                                  _controller.titleController.text.isEmpty &&
                                          _controller.hasChanges
                                      ? NotesStrings.emptyTitleError
                                      : null,
                              icon: NotesIcons.getCategoryIcon(''),
                            ),

                            // حقل التصنيف
                            _buildCategorySelector(),

                            // حقل محتوى الملاحظة
                            _buildContentField(),
                          ],
                        ),
                      ),
                    ),

                    // أزرار الحفظ والمفضلة
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // زر المفضلة
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.0,
                              ),
                            ),
                            child: IconButton(
                              onPressed: _controller.toggleFavorite,
                              icon: Icon(
                                _controller.isFavorite
                                    ? NotesIcons.favorite
                                    : NotesIcons.notFavorite,
                                color: _controller.isFavorite
                                    ? Colors.amber
                                    : Colors.grey.shade400,
                                size: 24,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),

                          const SizedBox(width: 15),

                          // زر الحفظ
                          Expanded(
                            child: _buildPrimaryButton(
                              text: NotesStrings.save,
                              onPressed: _saveNote,
                              icon: NotesIcons.save,
                              isLoading: _controller.isLoading,
                            ),
                          ),
                        ],
                      ),
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

  // حفظ الملاحظة
  Future<void> _saveNote() async {
    final success = await _controller.saveNote(widget.note);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            NotesStrings.saveSuccess,
            style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.pop(context, true);
      widget.onSaveComplete(true);
    } else {
      // إظهار رسالة خطأ إذا كان العنوان فارغاً
      if (_controller.titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              NotesStrings.emptyTitleError,
              style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              NotesStrings.saveError,
              style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  // إضافة تصنيف جديد
  void _addNewCategory() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            NotesStrings.newCategory,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4338CA),
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: NotesStrings.categoryName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            autofocus: true,
            style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                NotesStrings.cancel,
                style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newCategory = controller.text.trim();
                if (newCategory.isNotEmpty) {
                  if (!widget.categories.contains(newCategory)) {
                    // حفظ التصنيف الجديد في Firestore
                    widget.saveCategory(newCategory);

                    // إضافته لقائمة التصنيفات محليًا
                    widget.categories.add(newCategory);
                    widget.categories.sort();
                  }

                  _controller.setCategory(newCategory);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4338CA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                NotesStrings.add,
                style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
            ),
          ],
        );
      },
    );
  }

  // بناء حقل إدخال
  Widget _buildTextField({
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
          // عنوان الحقل
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              labelText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          // حقل الإدخال
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? const Color(0xFFEC4899)
                    : const Color(0xFF4338CA).withOpacity(0.2),
                width: 1.0,
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
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF4338CA),
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
                      color: Color(0xFF374151),
                    ),
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
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
          // عرض رسالة الخطأ إن وجدت
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Color(0xFFEC4899),
                  fontSize: 12,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
        ],
      ),
    );
  }

  // بناء حقل المحتوى
  Widget _buildContentField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الحقل
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              NotesStrings.noteContent,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),

          // حقل المحتوى باللون الأبيض بالكامل
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white, // تم تعيين لون الخلفية للأبيض
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6366F1),
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: _controller.contentController,
              decoration: const InputDecoration(
                hintText: NotesStrings.noteContentHint,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white, // تأكيد أن لون الحقل أبيض
              ),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF374151),
                fontFamily: 'SYMBIOAR+LT',
              ),
              maxLines: null,
              minLines: 5,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),

          // عداد الكلمات
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                _controller.getWordCount(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء منتقي التصنيف
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان الحقل
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6, right: 4),
              child: Text(
                NotesStrings.category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _addNewCategory,
              icon: const Icon(NotesIcons.addCircle,
                  size: 16, color: Color(0xFF6366F1)),
              label: const Text(
                NotesStrings.addCategory,
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 12,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),

        // منتقي التصنيف
        GestureDetector(
          onTap: () => _showCategoryPicker(),
          child: Container(
            height: 72,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4338CA).withOpacity(0.2),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // أيقونة التصنيف
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF4338CA).withOpacity(0.1),
                      width: 1.0,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      NotesIcons.getCategoryIcon(_controller.selectedCategory),
                      size: 20,
                      color: const Color(0xFF4338CA),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // تفاصيل التصنيف
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        NotesStrings.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _controller.selectedCategory,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4338CA),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        overflow: TextOverflow.ellipsis,
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
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF4338CA),
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

  // إظهار منتقي التصنيف
  void _showCategoryPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            NotesStrings.category,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4338CA),
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: widget.categories.map((category) {
                final categoryColor = NotesColors.categoryColors[category] ??
                    const Color(0xFF6366F1);
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      NotesIcons.getCategoryIcon(category),
                      color: categoryColor,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    category,
                    style: TextStyle(
                      fontWeight: _controller.selectedCategory == category
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                  trailing: _controller.selectedCategory == category
                      ? const Icon(Icons.check, color: Color(0xFF6366F1))
                      : null,
                  onTap: () {
                    _controller.setCategory(category);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  // بناء شريط العنوان
  Widget _buildToolbar({
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
                  widget.note == null
                      ? "قم بإدخال بيانات الملاحظة الجديدة بشكل كامل"
                      : "قم بتعديل بيانات الملاحظة بشكل كامل",
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

  // بناء زر رئيسي
  Widget _buildPrimaryButton({
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
            color: const Color(0xFF4338CA).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4338CA),
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
}
