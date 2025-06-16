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
import '../../../core/constants/appColor.dart'; // Add this import
import '../../../core/constants/app_dimensions.dart'; // Add this import

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.largeRadius)),
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
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius),
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
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius),
                  ),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius),
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
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius),
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
        insetPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.sectionPadding,
            vertical: AppDimensions.largeSpacing),
        child: Container(
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
            boxShadow: [
              BoxShadow(
                color: context.colorShadowColor,
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(AppDimensions.sectionPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.colorAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: context.colorAccent,
                  size: 30,
                ),
              ),
              SizedBox(height: AppDimensions.defaultSpacing),
              Text(
                NotesStrings.deleteNote,
                style: TextStyle(
                  fontSize: AppDimensions.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: context.colorTextPrimary,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.smallSpacing),
              Text(
                NotesStrings.deleteConfirmation,
                style: TextStyle(
                  fontSize: AppDimensions.smallSubtitleFontSize,
                  color: context.colorTextSecondary,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.largeSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.smallSpacing),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.mediumRadius),
                        ),
                        side: BorderSide(
                          color: context.colorBorder,
                        ),
                      ),
                      child: Text(
                        NotesStrings.cancel,
                        style: TextStyle(
                          color: context.colorTextSecondary,
                          fontFamily: 'SYMBIOAR+LT',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.smallSpacing),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.smallSpacing),
                        backgroundColor: context.colorAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.mediumRadius),
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
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius)),
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
                  borderRadius:
                      BorderRadius.circular(AppDimensions.smallRadius)),
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
          insetPadding: EdgeInsets.symmetric(
              horizontal: AppDimensions.sectionPadding,
              vertical: AppDimensions.largeSpacing),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
              boxShadow: [
                BoxShadow(
                  color: context.colorShadowColor,
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // مقبض السحب
                  Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.only(
                        top: AppDimensions.smallSpacing, bottom: 10),
                    decoration: BoxDecoration(
                      color: context.colorBorder,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  // شريط العنوان
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.defaultSpacing),
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
                              color: context.colorSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: context.colorBorder,
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              color: context.colorPrimaryDark,
                              size: AppDimensions.extraSmallIconSize,
                            ),
                          ),
                        ),

                        // العنوان
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: context.colorSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: context.colorBorder,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            NotesStrings.chooseCategory,
                            style: TextStyle(
                              fontSize: AppDimensions.smallSubtitleFontSize,
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
                  ),

                  SizedBox(height: AppDimensions.smallSpacing),

                  // وصف مع أيقونة
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.defaultSpacing),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.smallSpacing, vertical: 10),
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
                            size: AppDimensions.extraSmallIconSize,
                          ),
                          SizedBox(width: AppDimensions.smallSpacing),
                          Expanded(
                            child: Text(
                              "اختر تصفية الملاحظات حسب الفئة",
                              style: TextStyle(
                                fontSize: AppDimensions.smallLabelFontSize,
                                fontWeight: FontWeight.w500,
                                color: context.colorTextPrimary,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppDimensions.smallSpacing),

                  Divider(
                      height: 1,
                      thickness: 1,
                      color: context.colorPrimaryExtraLight),

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
                            ? context.colorMediumPurple
                            : NotesColors.categoryColors[category] ??
                                context.colorMediumPurple;

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    context.colorPrimaryDark.withOpacity(0.1),
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              isAllCategory
                                  ? NotesIcons.allInclusive
                                  : NotesIcons.getCategoryIcon(category),
                              color: categoryColor,
                              size: AppDimensions.smallIconSize,
                            ),
                          ),
                          title: Text(
                            category,
                            style: TextStyle(
                              fontWeight:
                                  _controller.selectedCategory == category
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color: context.colorPrimaryDark,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          trailing: _controller.selectedCategory == category
                              ? Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.colorPrimaryLight,
                                  ),
                                  child: Icon(
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
        backgroundColor: context.colorSurface,
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
                    color: context.colorMediumPurple,
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
      backgroundColor: context.colorBackground,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: context.colorSurface,
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
                  padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.smallSpacing,
                      vertical: AppDimensions.smallSpacing),
                  margin: EdgeInsets.symmetric(
                      horizontal: AppDimensions.defaultSpacing,
                      vertical: AppDimensions.smallSpacing),
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.mediumRadius),
                    border: Border.all(
                      color: context.colorPrimaryExtraLight,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
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
                          Icons.search,
                          color: context.colorPrimaryLight,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: AppDimensions.smallSpacing),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: NotesStrings.searchHint,
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: context.colorTextHint,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                          style: TextStyle(
                            color: context.colorPrimaryDark,
                            fontFamily: 'SYMBIOAR+LT',
                          ),
                          onChanged: _controller.setSearchText,
                          autofocus: true,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: context.colorPrimaryLight,
                          size: AppDimensions.smallIconSize,
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
                  padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.defaultSpacing),
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
                  padding: EdgeInsets.all(AppDimensions.defaultSpacing),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.colorPrimaryPale,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.smallRadius),
                      border: Border.all(
                        color: context.colorPrimaryExtraLight,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${NotesStrings.searchResults}${filteredNotes.length}${NotesStrings.noteCountSuffix}',
                      style: TextStyle(
                        fontSize: AppDimensions.smallSubtitleFontSize,
                        fontWeight: FontWeight.bold,
                        color: context.colorPrimaryDark,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),
                ),

              // شريط التحكم - مطابق لشاشة المهام
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.defaultSpacing,
                    vertical: AppDimensions.smallSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // إضافة عنوان على اليمين
                    Text(
                      "عرض الملاحظات",
                      style: TextStyle(
                        fontSize: AppDimensions.subtitleFontSize,
                        fontWeight: FontWeight.bold,
                        color: context.colorPrimaryDark,
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
                                color: context.colorPrimaryPale,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.mediumRadius),
                                border: Border.all(
                                  color: context.colorPrimaryExtraLight,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.filter_list_rounded,
                                  color: context.colorPrimaryDark,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),

                        SizedBox(width: AppDimensions.smallSpacing),

                        // زر تبديل العرض (قائمة/شبكة)
                        GestureDetector(
                          onTap: _controller.toggleViewMode,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: context.colorPrimaryPale,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.mediumRadius),
                              border: Border.all(
                                color: context.colorPrimaryExtraLight,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _controller.isGridView
                                    ? Icons.view_list_rounded
                                    : Icons.grid_view_rounded,
                                color: context.colorPrimaryDark,
                                size: 22,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: AppDimensions.smallSpacing),

                        // زر البحث
                        if (!_controller.isSearching)
                          GestureDetector(
                            onTap: _toggleSearching,
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: context.colorPrimaryPale,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.mediumRadius),
                                border: Border.all(
                                  color: context.colorPrimaryExtraLight,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.search_rounded,
                                  color: context.colorPrimaryDark,
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
                    ? Center(
                        child: CircularProgressIndicator(
                            color: context.colorPrimaryLight),
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppDimensions.defaultSpacing),
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
        backgroundColor: context.colorPrimaryDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
