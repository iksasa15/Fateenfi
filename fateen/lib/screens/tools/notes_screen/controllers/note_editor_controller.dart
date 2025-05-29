import 'package:flutter/material.dart';
import '../../../../models/note_model.dart';
import '../services/firebaseServices/notes_firebase_service.dart';
import '../constants/notes_colors.dart';

class NoteEditorController {
  final NotesFirebaseService _service = NotesFirebaseService();

  // متحكمات الإدخال
  late TextEditingController titleController;
  late TextEditingController contentController;

  // حالة المحرر
  bool isLoading = false;
  bool hasChanges = false;
  late String selectedCategory;
  late Color selectedColor;
  late bool isFavorite;

  // مراقبون للتغييرات
  final ValueNotifier<bool> stateChanged = ValueNotifier<bool>(false);

  // تهيئة المتحكم
  void init(Note? note, List<String> categories) {
    // تعيين متحكمات النص
    titleController = TextEditingController(text: note?.title ?? '');
    contentController = TextEditingController(text: note?.content ?? '');

    // التأكد من وجود قائمة التصنيفات قبل الاختيار منها
    final List<String> availableCategories =
        categories.isNotEmpty ? categories : ['عام'];

    // تعيين البيانات الأولية
    selectedCategory = note?.category ??
        (availableCategories.contains('عام')
            ? 'عام'
            : availableCategories.first);
    selectedColor = note?.color ?? NotesColors.noteColorOptions.first;
    isFavorite = note?.isFavorite ?? false;

    // إضافة مستمعين للتغييرات
    titleController.addListener(_onTextChanged);
    contentController.addListener(_onTextChanged);
  }

  // تنظيف الموارد
  void dispose() {
    titleController.removeListener(_onTextChanged);
    contentController.removeListener(_onTextChanged);
    titleController.dispose();
    contentController.dispose();
  }

  // الاستماع للتغييرات في النص
  void _onTextChanged() {
    hasChanges = true;
    _updateState();
  }

  // تغيير الفئة المحددة
  void setCategory(String category) {
    selectedCategory = category;
    hasChanges = true;
    _updateState();
  }

  // تغيير اللون المحدد
  void setColor(Color color) {
    selectedColor = color;
    hasChanges = true;
    _updateState();
  }

  // تبديل حالة المفضلة
  void toggleFavorite() {
    isFavorite = !isFavorite;
    hasChanges = true;
    _updateState();
  }

  // حفظ الملاحظة
  Future<bool> saveNote(Note? existingNote) async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty) {
      return false;
    }

    isLoading = true;
    _updateState();

    try {
      final data = {
        'title': title,
        'content': content,
        'category': selectedCategory,
        'color': selectedColor.value,
        'isFavorite': isFavorite,
      };

      if (existingNote == null) {
        // إضافة ملاحظة جديدة
        await _service.addNote(data);
      } else {
        // تحديث ملاحظة موجودة
        await _service.updateNote(existingNote.id, data);
      }

      isLoading = false;
      hasChanges = false;
      _updateState();

      return true;
    } catch (e) {
      print('Error saving note: $e');
      isLoading = false;
      _updateState();

      return false;
    }
  }

  // حساب عدد الكلمات والأحرف
  String getWordCount() {
    final text = contentController.text;
    final wordCount =
        text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final charCount = text.replaceAll(RegExp(r'\s+'), '').length;

    return '$wordCount كلمة، $charCount حرف';
  }

  // إخطار المستمعين بالتغييرات
  void _updateState() {
    stateChanged.value = !stateChanged.value;
  }
}
