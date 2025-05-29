// lib/screens/notes/screens/notes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'controllers/notes_controller.dart';
import '../../../models/note_model.dart';
import 'components/notes_header_component.dart';
import 'components/empty_notes_state.dart';
import 'components/note_list.dart';
import 'components/note_grid.dart';
import 'components/note_editor.dart';
import 'components/note_options_menu.dart';
import 'components/category_filter.dart';
import 'constants/notes_strings.dart';
import 'constants/notes_colors.dart';
import 'constants/notes_icons.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NotesController _controller = NotesController();
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false; // تتبّع إذا تم تهيئة البيانات

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
  }

  // تهيئة البيانات بشكل آمن
  Future<void> _initializeData() async {
    try {
      _controller.init();
      _controller.notesChanged.addListener(_onNotesChanged);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print("خطأ في تهيئة البيانات: $e");
      // يمكن عرض رسالة خطأ للمستخدم هنا
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    // التحقق قبل إزالة المستمع
    if (_isInitialized) {
      _controller.notesChanged.removeListener(_onNotesChanged);
    }
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onNotesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged() {
    if (_isInitialized) {
      _controller.setSearchText(_searchController.text);
    }
  }

  void _toggleSearching() {
    if (!_isInitialized) return;

    setState(() {
      _controller.toggleSearch();
      if (!_controller.isSearching) {
        _searchController.clear();
      }
    });
  }

  void _onAddNote() {
    if (!_isInitialized) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteEditor(
        categories: _controller.categories.skip(1).toList(), // تخطي "الكل"
        saveCategory: _controller.saveCategory,
        onSaveComplete: (success) {
          // سيتم التحديث تلقائياً عبر notesChanged
        },
      ),
    );
  }

  void _onEditNote(Note note) {
    if (!_isInitialized) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteEditor(
        note: note,
        categories: _controller.categories.skip(1).toList(), // تخطي "الكل"
        saveCategory: _controller.saveCategory,
        onSaveComplete: (success) {
          // سيتم التحديث تلقائياً عبر notesChanged
        },
      ),
    );
  }

  void _showNoteOptions(Note note) {
    if (!_isInitialized) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return TaskOptionsMenu(
          note: note,
          onEdit: () {
            Navigator.pop(context);
            _onEditNote(note);
          },
          onToggleFavorite: () async {
            Navigator.pop(context);
            try {
              await _controller.toggleFavorite(note);
              // التحديث سيتم تلقائياً عبر مستمع Firebase
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          },
          onDuplicate: () async {
            Navigator.pop(context);
            try {
              await _controller.duplicateNote(note);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    NotesStrings.duplicateSuccess,
                    style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          },
          onShare: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  NotesStrings.shareSuccess,
                  style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          onDelete: () {
            Navigator.pop(context);
            _confirmDeleteNote(note);
          },
        );
      },
    );
  }

  // تأكيد حذف الملاحظة مطابق لتأكيد حذف المهام
  Future<void> _confirmDeleteNote(Note note) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: NotesColors.kAccentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: NotesColors.kAccentColor,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                NotesStrings.deleteNote,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                NotesStrings.deleteConfirmation,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: const Text(
                        NotesStrings.cancel,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontFamily: 'SYMBIOAR+LT',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: NotesColors.kAccentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        NotesStrings.deleteNote,
                        style: TextStyle(
                          fontFamily: 'SYMBIOAR+LT',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmDelete == true) {
      try {
        await _controller.deleteNote(note);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                NotesStrings.deleteSuccess,
                style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                NotesStrings.deleteError,
                style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    }
  }

  // عرض مربع حوار الفلاتر
  void _showCategoryFilterDialog(BuildContext context) {
    if (!_isInitialized) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // مقبض السحب
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(top: 12, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  // شريط العنوان
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر الإغلاق
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
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
                          child: const Text(
                            NotesStrings.chooseCategory,
                            style: TextStyle(
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
                  ),

                  const SizedBox(height: 12),

                  // وصف مع أيقونة
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
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
                              "اختر تصفية الملاحظات حسب الفئة",
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
                  ),

                  const SizedBox(height: 12),

                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFE3E0F8)),

                  // قائمة الفئات
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _controller.categories.length,
                      itemBuilder: (context, index) {
                        final category = _controller.categories[index];
                        final isAllCategory =
                            category == NotesStrings.allCategories;

                        final categoryColor = isAllCategory
                            ? NotesColors.kMediumPurple
                            : NotesColors.categoryColors[category] ??
                                NotesColors.kMediumPurple;

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF4338CA).withOpacity(0.1),
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              isAllCategory
                                  ? NotesIcons.allInclusive
                                  : NotesIcons.getCategoryIcon(category),
                              color: categoryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            category,
                            style: TextStyle(
                              fontWeight:
                                  _controller.selectedCategory == category
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color: const Color(0xFF4338CA),
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          trailing: _controller.selectedCategory == category
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF6366F1),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                )
                              : null,
                          onTap: () {
                            _controller.setSelectedCategory(category);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // بداية بإظهار مؤشر التحميل حتى تكتمل تهيئة البيانات
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // رأس الصفحة
              NotesHeaderComponent(
                onBackPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: NotesColors.kMediumPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredNotes = _controller.getFilteredNotes();
    final isFiltering = _controller.searchText.isNotEmpty ||
        (_controller.selectedCategory != null &&
            _controller.selectedCategory != NotesStrings.allCategories);
    final notesCount = filteredNotes.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // هيدر الصفحة
              NotesHeaderComponent(
                onBackPressed: () => Navigator.pop(context),
              ),

              // شريط البحث
              if (_controller.isSearching)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE3E0F8),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
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
                        child: const Icon(
                          Icons.search,
                          color: Color(0xFF6366F1),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: NotesStrings.searchHint,
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF4338CA),
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                          onChanged: _controller.setSearchText,
                          autofocus: true,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                        onPressed: _toggleSearching,
                        constraints:
                            const BoxConstraints(maxWidth: 40, maxHeight: 40),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

              // شريط الفلتر
              if (_controller.selectedCategory != null &&
                  _controller.selectedCategory != NotesStrings.allCategories &&
                  !_controller.isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CategoryFilter(
                    selectedCategory: _controller.selectedCategory!,
                    categories: _controller.categories.skip(1).toList(),
                    onCategorySelected: (category) {
                      _controller.setSelectedCategory(category);
                    },
                    onFilterCleared: () {
                      _controller
                          .setSelectedCategory(NotesStrings.allCategories);
                    },
                  ),
                ),

              // عدد الملاحظات والنتائج
              if (_controller.searchText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE3E0F8),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${NotesStrings.searchResults}${filteredNotes.length}${NotesStrings.noteCountSuffix}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4338CA),
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),
                ),

              // شريط التحكم - مطابق لشاشة المهام
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // إضافة عنوان على اليمين
                    const Text(
                      "عرض الملاحظات",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4338CA),
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),

                    // أزرار التحكم على اليسار
                    Row(
                      children: [
                        // زر الفلترة
                        if (!_controller.isSearching)
                          GestureDetector(
                            onTap: () => _showCategoryFilterDialog(context),
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE3E0F8),
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.filter_list_rounded,
                                  color: Color(0xFF4338CA),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(width: 8),

                        // زر تبديل العرض (قائمة/شبكة)
                        GestureDetector(
                          onTap: _controller.toggleViewMode,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE3E0F8),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _controller.isGridView
                                    ? Icons.view_list_rounded
                                    : Icons.grid_view_rounded,
                                color: const Color(0xFF4338CA),
                                size: 22,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // زر البحث
                        if (!_controller.isSearching)
                          GestureDetector(
                            onTap: _toggleSearching,
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE3E0F8),
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF4338CA),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // عرض الملاحظات
              Expanded(
                child: _controller.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF6366F1)),
                      )
                    : _controller.notes.isEmpty
                        ? EmptyNotesState(
                            isFiltering: isFiltering,
                            onAddNote: _onAddNote,
                          )
                        : filteredNotes.isEmpty
                            ? EmptyNotesState(
                                isFiltering: true,
                                onAddNote: _onAddNote,
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: _controller.isGridView
                                    ? NotesGrid(
                                        notes: filteredNotes,
                                        isSearching: isFiltering,
                                        onNoteTap: _onEditNote,
                                        onNoteLongPress: _showNoteOptions,
                                      )
                                    : NotesList(
                                        notes: filteredNotes,
                                        isSearching: isFiltering,
                                        onNoteTap: _onEditNote,
                                        onNoteLongPress: _showNoteOptions,
                                      ),
                              ),
              ),
            ],
          ),
        ),
      ),
      // زر إضافة الملاحظات - مطابق لزر صفحة المهام
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddNote,
        backgroundColor: const Color(0xFF4338CA),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
