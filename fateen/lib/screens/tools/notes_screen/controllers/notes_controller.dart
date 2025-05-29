import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../models/note_model.dart';
import '../services/firebaseServices/notes_firebase_service.dart';
import '../constants/notes_strings.dart';

class NotesController {
  final NotesFirebaseService _service = NotesFirebaseService();

  // الحالة
  bool isLoading = true;
  bool isSearching = false;
  bool isGridView = true;
  bool isSyncing = false;
  String searchText = '';
  String? selectedCategory;
  List<Note> notes = [];
  List<String> categories = [];

  // مستمع Stream
  StreamSubscription<List<Note>>? _notesSubscription;

  // مراقبون للتغييرات
  final ValueNotifier<bool> notesChanged = ValueNotifier<bool>(false);

  // الدوال الرئيسية

  // بدء المراقبة والتحميل
  void init() {
    loadNotes();
  }

  // تحميل الملاحظات
  Future<void> loadNotes() async {
    isLoading = true;
    _updateState();

    try {
      // إلغاء أي اشتراك سابق
      await _notesSubscription?.cancel();

      // جلب الفئات
      await loadCategories();

      // إنشاء مستمع للتغييرات في الملاحظات
      _notesSubscription = _service.getNotesStream().listen((loadedNotes) {
        notes = loadedNotes;

        isLoading = false;
        isSyncing = false;
        _updateState();
      }, onError: (error) {
        print('Error in notes stream: $error');
        notes = []; // استبدلنا البيانات التجريبية بقائمة فارغة
        isLoading = false;
        isSyncing = false;
        _updateState();
      });
    } catch (e) {
      print('Error loading notes: $e');
      notes = []; // استبدلنا البيانات التجريبية بقائمة فارغة
      isLoading = false;
      isSyncing = false;
      _updateState();
    }
  }

  // تحميل الفئات
  Future<void> loadCategories() async {
    try {
      final loadedCategories = await _service.getCategories();

      // تأكد من وجود فئة "عام" وترتيب الفئات أبجديًا
      final List<String> categoryList = [...loadedCategories];
      categoryList.sort();

      if (!categoryList.contains(NotesStrings.defaultCategory)) {
        categoryList.insert(0, NotesStrings.defaultCategory);
      }

      // إضافة خيار "الكل" في البداية
      categories = [NotesStrings.allCategories, ...categoryList];

      // إذا كان التصنيف المحدد حاليًا غير موجود، انتقل إلى "الكل"
      if (selectedCategory != null && !categories.contains(selectedCategory)) {
        selectedCategory = NotesStrings.allCategories;
      } else if (selectedCategory == null) {
        selectedCategory = NotesStrings.allCategories;
      }

      _updateState();
    } catch (e) {
      print('Error loading categories: $e');
      categories = [NotesStrings.allCategories, NotesStrings.defaultCategory];
      selectedCategory = NotesStrings.allCategories;
      _updateState();
    }
  }

  // حفظ فئة جديدة
  Future<void> saveCategory(String category) async {
    if (category.isEmpty) return;

    try {
      await _service.saveCategory(category);
      await loadCategories();
    } catch (e) {
      print('Error saving category: $e');
    }
  }

  // تصفية الملاحظات
  List<Note> getFilteredNotes() {
    return notes.where((note) {
      // تصفية حسب الفئة
      if (selectedCategory != null &&
          selectedCategory != NotesStrings.allCategories) {
        if (note.category != selectedCategory) return false;
      }

      // تصفية حسب البحث
      if (searchText.isNotEmpty) {
        return note.title.toLowerCase().contains(searchText.toLowerCase()) ||
            note.content.toLowerCase().contains(searchText.toLowerCase());
      }

      return true;
    }).toList();
  }

  // تغيير وضع العرض (قائمة/شبكة)
  void toggleViewMode() {
    isGridView = !isGridView;
    _updateState();
  }

  // تغيير حالة البحث
  void toggleSearch() {
    isSearching = !isSearching;
    if (!isSearching) {
      searchText = '';
    }
    _updateState();
  }

  // تغيير نص البحث
  void setSearchText(String text) {
    searchText = text;
    _updateState();
  }

  // تغيير الفئة المحددة
  void setSelectedCategory(String? category) {
    selectedCategory = category;
    _updateState();
  }

  // تبديل حالة المفضلة
  Future<void> toggleFavorite(Note note) async {
    try {
      isSyncing = true;
      _updateState();

      await _service.toggleFavorite(note.id, note.isFavorite);

      // التحديث سيأتي من خلال مستمع Firebase
    } catch (e) {
      print('Error toggling favorite: $e');
      isSyncing = false;
      _updateState();
      throw Exception('فشل في تحديث المفضلة: $e');
    }
  }

  // حذف ملاحظة
  Future<void> deleteNote(Note note) async {
    try {
      isSyncing = true;
      _updateState();

      await _service.deleteNote(note.id);

      // التحديث سيأتي من خلال مستمع Firebase
    } catch (e) {
      print('Error deleting note: $e');
      isSyncing = false;
      _updateState();
      throw Exception('فشل في حذف الملاحظة: $e');
    }
  }

  // نسخ ملاحظة
  Future<void> duplicateNote(Note note) async {
    try {
      isSyncing = true;
      _updateState();

      await _service.duplicateNote(note);

      // التحديث سيأتي من خلال مستمع Firebase
    } catch (e) {
      print('Error duplicating note: $e');
      isSyncing = false;
      _updateState();
      throw Exception('فشل في نسخ الملاحظة: $e');
    }
  }

  // تنظيف عند الإغلاق
  void dispose() {
    _notesSubscription?.cancel();
  }

  // إخطار المستمعين بالتغييرات
  void _updateState() {
    notesChanged.value = !notesChanged.value;
  }
}
