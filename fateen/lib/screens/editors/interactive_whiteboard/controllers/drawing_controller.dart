import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../models/drawn_line_model.dart';
import '../../../../models/sticker_model.dart';
import '../../../../models/drawing_file_model.dart';
import '../constants/whiteboard_values.dart';
import '../utils/file_utils.dart';

// كلاس للاحتفاظ ببيانات السبورة (الصفحة)
class WhiteboardPage {
  final String id;
  final List<DrawnLine> lines;
  final List<DrawnLine> undoneLines;
  final List<Sticker> stickers;
  final int pageNumber;

  WhiteboardPage({
    required this.id,
    required this.pageNumber,
    List<DrawnLine>? lines,
    List<DrawnLine>? undoneLines,
    List<Sticker>? stickers,
  })  : lines = lines ?? [],
        undoneLines = undoneLines ?? [],
        stickers = stickers ?? [];

  WhiteboardPage copyWith({
    String? id,
    List<DrawnLine>? lines,
    List<DrawnLine>? undoneLines,
    List<Sticker>? stickers,
    int? pageNumber,
  }) {
    return WhiteboardPage(
      id: id ?? this.id,
      lines: lines ?? this.lines,
      undoneLines: undoneLines ?? this.undoneLines,
      stickers: stickers ?? this.stickers,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class DrawingController extends ChangeNotifier {
  /// الوضع الحالي: هل المستخدم في وضع الملصقات أم الرسم؟
  bool _isStickerMode = false;
  bool get isStickerMode => _isStickerMode;

  /// قائمة صفحات السبورة (متعددة)
  List<WhiteboardPage> _pages = [];
  List<WhiteboardPage> get pages => _pages;

  /// الصفحة الحالية النشطة
  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;
  WhiteboardPage get currentPage => _pages[_currentPageIndex];

  /// قائمة الخطوط المرسومة في الصفحة الحالية
  List<DrawnLine> get lines => _pages[_currentPageIndex].lines;

  /// قائمة الخطوط التي تم التراجع عنها في الصفحة الحالية
  List<DrawnLine> get undoneLines => _pages[_currentPageIndex].undoneLines;

  /// الخط الحالي قيد الرسم
  DrawnLine? _currentLine;
  DrawnLine? get currentLine => _currentLine;

  /// قائمة الملصقات الموجودة على السبورة في الصفحة الحالية
  List<Sticker> get stickers => _pages[_currentPageIndex].stickers;

  /// قائمة الملصقات المزالة (للتراجع)
  List<Sticker> _removedStickers = [];
  List<Sticker> get removedStickers => _removedStickers;

  /// الملصق المحدد حاليًا (إذا وجد)
  int? _selectedStickerIndex;
  int? get selectedStickerIndex => _selectedStickerIndex;

  /// اللون المحدد حالياً
  Color _selectedColor = Colors.black;
  Color get selectedColor => _selectedColor;

  /// سماكة القلم الحالية
  double _strokeWidth = WhiteboardValues.defaultStrokeWidth;
  double get strokeWidth => _strokeWidth;

  /// نمط القلم الحالي
  StrokeCap _strokeCap = StrokeCap.round;
  StrokeCap get strokeCap => _strokeCap;

  /// هل تم التعديل على الملف؟
  bool _hasUnsavedChanges = false;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  /// معلومات الملف الحالي
  String _currentFileId = '';
  String get currentFileId => _currentFileId;

  String _currentFileName = '';
  String get currentFileName => _currentFileName;

  DateTime _creationDate = DateTime.now();
  DateTime get creationDate => _creationDate;

  // الإعداد الأولي
  DrawingController() {
    _initNewFile();
  }

  // إعداد ملف جديد
  void _initNewFile() {
    _currentFileId = _generateUniqueId();
    _currentFileName = 'رسمة جديدة';
    _creationDate = DateTime.now();
    _hasUnsavedChanges = false;
    _currentPageIndex = 0;
    _pages = [
      WhiteboardPage(
        id: _generateUniqueId(),
        pageNumber: 1, // نبدأ بالصفحة الأولى
      )
    ];
  }

  // إنشاء معرف فريد
  String _generateUniqueId() {
    return FileUtils.generateUniqueId();
  }

  // تغيير وضع الرسم/الملصقات
  void toggleDrawingMode() {
    _isStickerMode = !_isStickerMode;
    _selectedStickerIndex = null;
    notifyListeners();
  }

  // إضافة خط جديد
  void startLine(Offset point) {
    if (_isStickerMode) return;

    _currentLine = DrawnLine(
      points: [point],
      color: _selectedColor,
      width: _strokeWidth,
      strokeCap: _strokeCap,
    );
    notifyListeners();
  }

  // تحديث الخط الحالي أثناء الرسم
  void updateLine(Offset point) {
    if (_isStickerMode || _currentLine == null) return;

    _currentLine = _currentLine!.copyWith(
      points: [..._currentLine!.points, point],
    );
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  // إنهاء رسم الخط الحالي
  void endLine() {
    if (_isStickerMode || _currentLine == null) return;

    // تحديث الصفحة الحالية بإضافة الخط الجديد
    _updateCurrentPage(
      lines: [...lines, _currentLine!],
      undoneLines: [], // مسح قائمة الخطوط التي تم التراجع عنها
    );

    _currentLine = null;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  // تحديث الصفحة الحالية
  void _updateCurrentPage({
    List<DrawnLine>? lines,
    List<DrawnLine>? undoneLines,
    List<Sticker>? stickers,
  }) {
    final updatedPage = _pages[_currentPageIndex].copyWith(
      lines: lines,
      undoneLines: undoneLines,
      stickers: stickers,
    );

    _pages[_currentPageIndex] = updatedPage;
  }

  // التراجع - تعديل لإعادة قيمة توضح حدوث تغيير
  bool undo() {
    if (lines.isEmpty) return false;

    final currentLines = List<DrawnLine>.from(lines);
    final currentUndoneLines = List<DrawnLine>.from(undoneLines);

    final lastLine = currentLines.removeLast();
    currentUndoneLines.add(lastLine);

    _updateCurrentPage(
      lines: currentLines,
      undoneLines: currentUndoneLines,
    );

    _hasUnsavedChanges = true;
    notifyListeners();
    return true;
  }

  // إعادة - تعديل لإعادة قيمة توضح حدوث تغيير
  bool redo() {
    if (undoneLines.isEmpty) return false;

    final currentLines = List<DrawnLine>.from(lines);
    final currentUndoneLines = List<DrawnLine>.from(undoneLines);

    final lastUndoneLine = currentUndoneLines.removeLast();
    currentLines.add(lastUndoneLine);

    _updateCurrentPage(
      lines: currentLines,
      undoneLines: currentUndoneLines,
    );

    _hasUnsavedChanges = true;
    notifyListeners();
    return true;
  }

  // مسح كل شيء في الصفحة الحالية
  void clearCurrentPage() {
    _updateCurrentPage(
      lines: [],
      undoneLines: [],
      stickers: [],
    );
    _removedStickers.clear();
    _selectedStickerIndex = null;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  // مسح كل شيء في كل الصفحات
  void clearAll() {
    _pages = [
      WhiteboardPage(
        id: _generateUniqueId(),
        pageNumber: 1,
      )
    ];
    _currentPageIndex = 0;
    _removedStickers.clear();
    _selectedStickerIndex = null;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  // تغيير اللون
  void changeColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  // تغيير سماكة القلم
  void changeStrokeWidth(double width) {
    _strokeWidth = width;
    notifyListeners();
  }

  // تغيير نمط القلم
  void changeStrokeCap(StrokeCap cap) {
    _strokeCap = cap;
    notifyListeners();
  }

  // إعداد ملف جديد
  void newFile() {
    _initNewFile();
    _removedStickers.clear();
    _selectedStickerIndex = null;
    notifyListeners();
  }

  // تحميل ملف موجود (للتوافق مع الإصدار القديم)
  void loadFile(
      DrawingFile file, List<DrawnLine> lines, List<Sticker> loadedStickers) {
    // تحميل كملف بصفحة واحدة
    _pages = [
      WhiteboardPage(
        id: _generateUniqueId(),
        pageNumber: 1,
        lines: lines,
        stickers: loadedStickers,
      )
    ];
    _currentPageIndex = 0;
    _removedStickers = [];
    _selectedStickerIndex = null;
    _currentFileId = file.id;
    _currentFileName = file.name;
    _creationDate = file.creationDate;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  // تحميل ملف بصفحات متعددة
  void loadFileWithPages(DrawingFile file, List<WhiteboardPage> pages) {
    _pages = pages;
    _currentPageIndex = 0;
    _removedStickers = [];
    _selectedStickerIndex = null;
    _currentFileId = file.id;
    _currentFileName = file.name;
    _creationDate = file.creationDate;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  // تغيير اسم الملف
  void renameFile(String newName) {
    if (newName.trim().isEmpty) return;

    _currentFileName = newName.trim();
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  // تعيين حالة التغييرات
  void setHasUnsavedChanges(bool value) {
    _hasUnsavedChanges = value;
    notifyListeners();
  }

  // تحديث بيانات ملف
  void updateFileData(String fileId, String fileName, DateTime creationDate) {
    _currentFileId = fileId;
    _currentFileName = fileName;
    _creationDate = creationDate;
    notifyListeners();
  }

  // تعيين الخطوط في الصفحة الحالية
  void setLines(List<DrawnLine> newLines) {
    // إنشاء نسخ عميقة من الخطوط
    final List<DrawnLine> copyLines = [];
    for (var line in newLines) {
      copyLines.add(DrawnLine(
        points: List.from(line.points),
        color: line.color,
        width: line.width,
        strokeCap: line.strokeCap,
      ));
    }

    _updateCurrentPage(
      lines: copyLines,
      undoneLines: [],
    );

    notifyListeners();
  }

  // تعيين الملصقات في الصفحة الحالية
  void setStickers(List<Sticker> newStickers) {
    _updateCurrentPage(
      stickers: newStickers,
    );
    notifyListeners();
  }

  // مسح قوائم التراجع والإعادة
  void clearUndoRedoStacks() {
    _updateCurrentPage(
      undoneLines: [],
    );
    _removedStickers.clear();
    notifyListeners();
  }

  // إضافة صفحة جديدة
  void addNewPage() {
    final newPageNumber = _pages.length + 1;
    final newPage = WhiteboardPage(
      id: _generateUniqueId(),
      pageNumber: newPageNumber,
    );

    _pages.add(newPage);
    _currentPageIndex = _pages.length - 1; // الانتقال للصفحة الجديدة
    _selectedStickerIndex = null;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  // الانتقال إلى صفحة محددة
  void goToPage(int pageIndex) {
    if (pageIndex >= 0 &&
        pageIndex < _pages.length &&
        pageIndex != _currentPageIndex) {
      _currentPageIndex = pageIndex;
      _selectedStickerIndex = null;
      notifyListeners();
    }
  }

  // الانتقال إلى الصفحة التالية
  void goToNextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      _currentPageIndex++;
      _selectedStickerIndex = null;
      notifyListeners();
    } else {
      // إذا كنا في آخر صفحة، نضيف صفحة جديدة
      addNewPage();
    }
  }

  // الانتقال إلى الصفحة السابقة
  void goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      _selectedStickerIndex = null;
      notifyListeners();
    }
  }

  // حذف الصفحة الحالية
  void deleteCurrentPage() {
    if (_pages.length <= 1) {
      // لا يمكن حذف الصفحة الوحيدة، بدلاً من ذلك نمسحها
      clearCurrentPage();
      return;
    }

    _pages.removeAt(_currentPageIndex);

    // تحديث أرقام الصفحات
    for (int i = 0; i < _pages.length; i++) {
      _pages[i] = _pages[i].copyWith(pageNumber: i + 1);
    }

    // التأكد من أن مؤشر الصفحة الحالية صالح
    if (_currentPageIndex >= _pages.length) {
      _currentPageIndex = _pages.length - 1;
    }

    _hasUnsavedChanges = true;
    notifyListeners();
  }

  // هل يمكن التراجع؟
  bool canUndo() {
    return lines.isNotEmpty;
  }

  // هل يمكن الإعادة؟
  bool canRedo() {
    return undoneLines.isNotEmpty || _removedStickers.isNotEmpty;
  }

  // هل السبورة الحالية فارغة؟
  bool isCurrentPageEmpty() {
    return lines.isEmpty && stickers.isEmpty;
  }

  // عدد الصفحات
  int get pageCount => _pages.length;
}
