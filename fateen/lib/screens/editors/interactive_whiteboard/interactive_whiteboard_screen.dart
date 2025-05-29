import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'controllers/drawing_controller.dart';
import 'controllers/stickers_controller.dart';
import 'controllers/files_controller.dart';
import 'controllers/export_controller.dart';
import 'components/drawing_board_component.dart';
import 'components/drawing_tools_component.dart';
import 'components/stickers_panel_component.dart';
import 'components/sticker_tools_component.dart';
import 'components/sticker_controls_component.dart';
import 'components/tools_header_component.dart';
import 'components/file_info_component.dart';
import 'components/file_panel_component.dart';
import 'components/loading_overlay_component.dart';
import 'constants/whiteboard_colors.dart';
import 'constants/whiteboard_strings.dart';
import 'constants/whiteboard_values.dart';
import '../../../models/drawing_file_model.dart';
import '../../../models/drawn_line_model.dart';
import '../../../models/sticker_model.dart';
import 'utils/file_utils.dart';
import 'utils/drawing_painter.dart';
import 'dart:io' show Platform;

class InteractiveWhiteboardScreen extends StatefulWidget {
  const InteractiveWhiteboardScreen({Key? key}) : super(key: key);

  @override
  State<InteractiveWhiteboardScreen> createState() =>
      _InteractiveWhiteboardScreenState();
}

class _InteractiveWhiteboardScreenState
    extends State<InteractiveWhiteboardScreen> with TickerProviderStateMixin {
  // المتحكمات
  late DrawingController _drawingController;
  late StickersController _stickersController;
  late FilesController _filesController;

  // مفتاح GlobalKey لتصدير السبورة
  final GlobalKey _boardKey = GlobalKey();

  // متحكم الرسوم المتحركة لقائمة الملصقات
  late AnimationController _stickerPanelController;
  late Animation<double> _stickerPanelAnimation;

  // متحكم الرسوم المتحركة للأدوات
  late AnimationController _toolsController;
  late Animation<double> _toolsAnimation;

  // متحكم الرسوم المتحركة لقائمة الملفات
  late AnimationController _filesPanelAnimationController;
  late Animation<double> _filesPanelAnimation;

  // حالة الأدوات
  bool _isToolsOpen = true;

  // حالة التحميل المحلية
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // إنشاء المتحكمات
    _drawingController = DrawingController();
    _stickersController = StickersController();
    _filesController = FilesController();

    // طباعة معلومات النظام للمساعدة في التصحيح
    print('إعداد السبورة التفاعلية على نظام: ${Platform.operatingSystem}');

    // إعداد متحكم الرسوم المتحركة لقائمة الملصقات
    _stickerPanelController = AnimationController(
      vsync: this,
      duration: WhiteboardValues.animationDuration,
    );

    _stickerPanelAnimation = CurvedAnimation(
      parent: _stickerPanelController,
      curve: Curves.easeInOut,
    );

    // إعداد متحكم الرسوم المتحركة للأدوات
    _toolsController = AnimationController(
      vsync: this,
      duration: WhiteboardValues.animationDuration,
      value: 1.0, // البدء بحالة مفتوحة
    );

    _toolsAnimation = CurvedAnimation(
      parent: _toolsController,
      curve: Curves.easeInOut,
    );

    // متحكم قائمة الملفات
    _filesPanelAnimationController = AnimationController(
      vsync: this,
      duration: WhiteboardValues.animationDuration,
    );

    _filesPanelAnimation = CurvedAnimation(
      parent: _filesPanelAnimationController,
      curve: Curves.easeInOut,
    );

    // الاستماع لتغييرات المتحكمات
    _subscribeToControllers();
  }

  @override
  void dispose() {
    // تحرير الموارد
    _stickerPanelController.dispose();
    _toolsController.dispose();
    _filesPanelAnimationController.dispose();
    super.dispose();
  }

  // الاشتراك في أحداث المتحكمات
  void _subscribeToControllers() {
    // استماع لتغيير وضع الملصقات
    _drawingController.addListener(() {
      if (mounted) setState(() {});
    });

    // استماع لتغييرات الملصقات
    _stickersController.addListener(() {
      if (_stickersController.isStickerPanelOpen !=
          _stickerPanelController.isCompleted) {
        if (_stickersController.isStickerPanelOpen) {
          _stickerPanelController.forward();
        } else {
          _stickerPanelController.reverse();
        }
      }

      if (mounted) setState(() {});
    });

    // استماع لتغييرات الملفات
    _filesController.addListener(() {
      if (_filesController.isFilesPanelOpen !=
          _filesPanelAnimationController.isCompleted) {
        if (_filesController.isFilesPanelOpen) {
          _filesPanelAnimationController.forward();
        } else {
          _filesPanelAnimationController.reverse();
        }
      }

      if (mounted) setState(() {});
    });
  }

  // التبديل بين فتح وإغلاق لوحة الأدوات
  void _toggleTools() {
    setState(() {
      _isToolsOpen = !_isToolsOpen;
      if (_isToolsOpen) {
        _toolsController.forward();
      } else {
        _toolsController.reverse();
      }
    });
  }

  // عرض رسالة توضيحية
  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
        backgroundColor: isError
            ? WhiteboardColors.kAccentColor
            : WhiteboardColors.kDarkPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // مسح السبورة بشكل مباشر
  void _clearBoardImmediate() {
    _drawingController.clearCurrentPage();
    _stickersController.clearAllStickers();
    setState(() {});
    _showSnackBar(WhiteboardStrings.boardCleared, isError: false);
  }

  // مسح السبورة مع تأكيد
  void _clearBoard() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            WhiteboardStrings.clearBoardTitle,
            style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          content: const Text(
            WhiteboardStrings.clearBoardMessage,
            style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                WhiteboardStrings.cancel,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _clearBoardImmediate();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WhiteboardColors.kDarkPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                WhiteboardStrings.clearButton,
                style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
            ),
          ],
        );
      },
    );
  }

  // شريط التنقل بين الصفحات - نسخة أصغر
  Widget _buildCompactPageNavigationBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : WhiteboardColors.kLightPurple,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: WhiteboardColors.kShadowColor,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // زر الصفحة السابقة
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
              size: 16,
            ),
            onPressed: _drawingController.currentPageIndex > 0
                ? _drawingController.goToPreviousPage
                : null,
            tooltip: 'الصفحة السابقة',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            visualDensity: VisualDensity.compact,
          ),

          // رقم الصفحة الحالية
          Expanded(
            child: GestureDetector(
              onTap: _showPageSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'صفحة ${_drawingController.currentPageIndex + 1} من ${_drawingController.pageCount}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white
                            : WhiteboardColors.kDarkPurple,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDarkMode
                          ? WhiteboardColors.kMediumPurple
                          : WhiteboardColors.kDarkPurple,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // زر إضافة صفحة جديدة
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
              size: 18,
            ),
            onPressed: _addNewPage,
            tooltip: 'إضافة صفحة جديدة',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            visualDensity: VisualDensity.compact,
          ),

          // زر الصفحة التالية
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
              size: 16,
            ),
            onPressed: _drawingController.currentPageIndex <
                    _drawingController.pageCount - 1
                ? _drawingController.goToNextPage
                : _addNewPage,
            tooltip: 'الصفحة التالية',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  // أدوات التحكم المصغرة
  Widget _buildCompactTools() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : WhiteboardColors.kLightPurple,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: WhiteboardColors.kShadowColor,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر التراجع
          IconButton(
            icon: const Icon(
              Icons.undo,
              size: 20,
            ),
            onPressed: _canUndo() ? _undo : null,
            tooltip: WhiteboardStrings.undo,
            color: isDarkMode
                ? WhiteboardColors.kMediumPurple
                : WhiteboardColors.kDarkPurple,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            visualDensity: VisualDensity.compact,
          ),

          // زر الإعادة
          IconButton(
            icon: const Icon(
              Icons.redo,
              size: 20,
            ),
            onPressed: _canRedo() ? _redo : null,
            tooltip: WhiteboardStrings.redo,
            color: isDarkMode
                ? WhiteboardColors.kMediumPurple
                : WhiteboardColors.kDarkPurple,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            visualDensity: VisualDensity.compact,
          ),

          // زر المسح
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: WhiteboardColors.kAccentColor,
            ),
            onPressed: (_drawingController.lines.isNotEmpty ||
                    _stickersController.stickers.isNotEmpty)
                ? _clearBoard
                : null,
            tooltip: WhiteboardStrings.clear,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            visualDensity: VisualDensity.compact,
          ),

          // زر الادوات
          IconButton(
            icon: Icon(
              _isToolsOpen
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
            ),
            onPressed: _toggleTools,
            tooltip: _isToolsOpen
                ? WhiteboardStrings.hideTools
                : WhiteboardStrings.showTools,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            visualDensity: VisualDensity.compact,
          ),

          // القائمة المنسدلة
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 20,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
            ),
            onSelected: _handleMenuItemSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.create_new_folder_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(WhiteboardStrings.newFile),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_outlined, size: 20),
                    SizedBox(width: 8),
                    Text("نسخ الرسمة الحالية"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(WhiteboardStrings.save),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(WhiteboardStrings.share),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(WhiteboardStrings.rename),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'files',
                child: Row(
                  children: [
                    Icon(Icons.folder_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(WhiteboardStrings.savedFiles),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'deletePage',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 20),
                    SizedBox(width: 8),
                    Text("حذف الصفحة الحالية"),
                  ],
                ),
              ),
            ],
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  // دالة لإضافة صفحة جديدة
  void _addNewPage() {
    _drawingController.addNewPage();
    _showSnackBar('تم إضافة صفحة جديدة', isError: false);
  }

  // دالة لعرض منتقي الصفحات
  void _showPageSelector() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر صفحة'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _drawingController.pageCount,
              itemBuilder: (context, index) {
                final isCurrentPage =
                    index == _drawingController.currentPageIndex;
                return ListTile(
                  title: Text('صفحة ${index + 1}'),
                  selected: isCurrentPage,
                  tileColor:
                      isCurrentPage ? WhiteboardColors.kLightPurple : null,
                  leading: Icon(
                    Icons.file_copy_outlined,
                    color: isCurrentPage ? WhiteboardColors.kDarkPurple : null,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _drawingController.goToPage(index);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  // دالة لحذف الصفحة الحالية
  void _deleteCurrentPage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف الصفحة'),
          content: Text(
            _drawingController.pageCount > 1
                ? 'هل أنت متأكد من حذف الصفحة الحالية؟'
                : 'هذه هي الصفحة الوحيدة، سيتم مسح محتوياتها فقط.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WhiteboardColors.kAccentColor,
              ),
              onPressed: () {
                Navigator.pop(context);
                _drawingController.deleteCurrentPage();
                _showSnackBar(
                    _drawingController.pageCount > 1
                        ? 'تم حذف الصفحة'
                        : 'تم مسح محتوى الصفحة',
                    isError: false);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  // عرض حوار إعادة تسمية الملف
  void _showRenameDialog() {
    final TextEditingController nameController =
        TextEditingController(text: _drawingController.currentFileName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(WhiteboardStrings.renameFileTitle),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: WhiteboardStrings.fileNameLabel,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(WhiteboardStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                _drawingController.renameFile(newName);
                Navigator.pop(context);
                _showSnackBar(WhiteboardStrings.fileRenamed, isError: false);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: WhiteboardColors.kDarkPurple),
            child: const Text(WhiteboardStrings.change),
          ),
        ],
      ),
    );
  }

  // إنشاء ملف جديد
  void _newFile() async {
    if (_drawingController.hasUnsavedChanges) {
      final shouldProceed = await _confirmUnsavedChanges();

      if (shouldProceed == null) {
        return; // تم إلغاء العملية
      }

      if (shouldProceed) {
        await _saveDrawing(); // حفظ الرسم الحالي
      }
    }

    _drawingController.newFile();
    _stickersController.clearAllStickers();
    setState(() {});
    _showSnackBar(WhiteboardStrings.newFileCreated, isError: false);
  }

  // دالة مبسطة لإنشاء نسخة من الرسمة الحالية
  void _duplicateDrawing() {
    try {
      // إنشاء معرف جديد للملف
      final newFileId = DateTime.now().millisecondsSinceEpoch.toString();
      final newFileName = "${_drawingController.currentFileName} - نسخة";
      final now = DateTime.now();

      // نسخ الخطوط الحالية
      final List<DrawnLine> copiedLines = [];
      for (var line in _drawingController.lines) {
        copiedLines.add(DrawnLine(
          points: List.from(line.points),
          color: line.color,
          width: line.width,
          strokeCap: line.strokeCap,
        ));
      }

      // نسخ الملصقات الحالية
      final List<Sticker> copiedStickers = [];
      for (var sticker in _drawingController.stickers) {
        copiedStickers.add(Sticker(
          id: FileUtils.generateUniqueId(),
          imagePath: sticker.imagePath,
          offset: sticker.offset,
          scale: sticker.scale,
          rotation: sticker.rotation,
        ));
      }

      // تعيين بيانات الملف الجديد
      _drawingController.updateFileData(newFileId, newFileName, now);

      // تعيين الخطوط والملصقات المنسوخة
      _drawingController.setLines(copiedLines);
      _stickersController.setStickers(copiedStickers);

      // تعيين تغييرات غير محفوظة
      _drawingController.setHasUnsavedChanges(true);

      setState(() {});
      _showSnackBar("تم إنشاء نسخة جديدة من الرسمة الحالية", isError: false);
    } catch (e) {
      print('خطأ في نسخ الرسمة: $e');
      _showSnackBar("حدث خطأ أثناء إنشاء نسخة جديدة: $e");
    }
  }

  // تأكيد التغييرات غير المحفوظة
  Future<bool?> _confirmUnsavedChanges() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(WhiteboardStrings.unsavedChangesTitle),
        content: const Text(WhiteboardStrings.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // لا تحفظ، متابعة
            child: const Text(WhiteboardStrings.dontSave),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null), // إلغاء العملية
            child: const Text(WhiteboardStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // حفظ ومتابعة
            style: ElevatedButton.styleFrom(
                backgroundColor: WhiteboardColors.kDarkPurple),
            child: const Text(WhiteboardStrings.saveAndContinue),
          ),
        ],
      ),
    );
  }

  // حفظ الرسم الحالي - نسخة محسنة لدعم الصفحات المتعددة
  Future<bool> _saveDrawing() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // طلب الأذونات قبل الحفظ (خاصة على نظام iOS)
      final hasPermission = await FileUtils.requestStoragePermission();
      if (!hasPermission) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(WhiteboardStrings.storagePermissionError);
        return false;
      }

      // تصدير الرسم كصورة (الصفحة الحالية)
      final exportScale = ExportController.calculateExportScale(context);
      final imageData =
          await ExportController.exportWidgetToImage(_boardKey, exportScale);

      if (imageData == null) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(WhiteboardStrings.exportError);
        return false;
      }

      // حفظ الرسم (كل الصفحات)
      final result = await _filesController.saveDrawing(
        fileId: _drawingController.currentFileId,
        fileName: _drawingController.currentFileName,
        creationDate: _drawingController.creationDate,
        pages: _drawingController.pages,
        imageData: imageData,
      );

      setState(() {
        _isLoading = false;
      });

      if (result) {
        _drawingController.setHasUnsavedChanges(false);
        _showSnackBar(WhiteboardStrings.drawingSaved, isError: false);
        return true;
      } else {
        _showSnackBar(
            _filesController.errorMessage ?? WhiteboardStrings.saveError);
        return false;
      }
    } catch (e) {
      print('خطأ في حفظ الرسم: $e');
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('${WhiteboardStrings.saveError} $e');
      return false;
    }
  }

  // فتح ملف محفوظ
  Future<void> _openFile(DrawingFile file) async {
    if (_drawingController.hasUnsavedChanges) {
      final shouldProceed = await _confirmUnsavedChanges();

      if (shouldProceed == null) {
        return; // تم إلغاء العملية
      }

      if (shouldProceed) {
        await _saveDrawing(); // حفظ الرسم الحالي
      }
    }

    try {
      setState(() {
        _isLoading = true;
      });

      print('فتح الملف: ${file.name}');
      final result = await _filesController.openFile(file);

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        if (result.containsKey('pages')) {
          // تحميل الملف بالصفحات المتعددة
          final pages = result['pages'] as List<WhiteboardPage>;
          print('تم تحميل ${pages.length} صفحة من الملف');

          // تحديث بيانات الملف في المتحكم
          _drawingController.loadFileWithPages(
            file,
            pages,
          );
        } else {
          // التوافق مع الملفات القديمة (صفحة واحدة)
          print('تحميل ملف بتنسيق قديم (صفحة واحدة)');
          _drawingController.loadFile(
              file, result['lines'], result['stickers']);

          // تحديث الملصقات
          _stickersController.setStickers(result['stickers']);
          _stickersController.setRemovedStickers([]);
        }

        // إغلاق قائمة الملفات
        _filesController.toggleFilesPanel();

        setState(() {});

        _showSnackBar(WhiteboardStrings.fileOpened, isError: false);
      } else {
        _showSnackBar(
            _filesController.errorMessage ?? WhiteboardStrings.openFileError);
      }
    } catch (e) {
      print('خطأ في فتح الملف: $e');
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('${WhiteboardStrings.openFileError} $e');
    }
  }

  // حذف ملف مع تأكيد
  void _deleteFile(DrawingFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(WhiteboardStrings.deleteFileTitle),
        content: Text('${WhiteboardStrings.deleteFileMessage}${file.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(WhiteboardStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WhiteboardColors.kAccentColor,
            ),
            child: const Text(WhiteboardStrings.deleteButton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      final result = await _filesController.deleteFile(file);

      setState(() {
        _isLoading = false;
      });

      if (result) {
        _showSnackBar(WhiteboardStrings.fileDeleted, isError: false);
      } else {
        _showSnackBar(
            _filesController.errorMessage ?? WhiteboardStrings.deleteFileError);
      }
    }
  }

  // مشاركة الرسم
  Future<void> _shareDrawing() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // تصدير الرسم كصورة
      final exportScale = ExportController.calculateExportScale(context);
      final imageData =
          await ExportController.exportWidgetToImage(_boardKey, exportScale);

      if (imageData == null) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(WhiteboardStrings.exportError);
        return;
      }

      final result = await _filesController.shareDrawingImage(
          imageData, _drawingController.currentFileName);

      setState(() {
        _isLoading = false;
      });

      if (result) {
        _showSnackBar(WhiteboardStrings.drawingShared, isError: false);
      } else {
        _showSnackBar(
            _filesController.errorMessage ?? WhiteboardStrings.shareError);
      }
    } catch (e) {
      print('خطأ في مشاركة الرسم: $e');
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(WhiteboardStrings.shareError);
    }
  }

  // مشاركة ملف محفوظ
  void _shareFile(DrawingFile file) async {
    if (file.thumbnailPath == null) {
      _showSnackBar(WhiteboardStrings.shareError);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // التحقق من وجود الملف قبل المشاركة
      final fileExists = await FileUtils.fileExists(file.thumbnailPath!);
      if (!fileExists) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar("الصورة المصغرة غير موجودة");
        return;
      }

      await Share.shareXFiles(
        [XFile(file.thumbnailPath!)],
        text: '${WhiteboardStrings.shareText}${file.name}',
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('خطأ في مشاركة الملف: $e');
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(WhiteboardStrings.shareError);
    }
  }

  // تنفيذ التراجع بشكل متكامل (Undo)
  void _undo() {
    bool changed = false;

    // معالجة الملصقات أولا إذا كان هناك ملصق محدد
    if (_drawingController.isStickerMode &&
        _stickersController.selectedStickerIndex != null) {
      changed = _stickersController.deleteSelectedSticker();
    }
    // التراجع عن آخر ملصق
    else if (_stickersController.stickers.isNotEmpty) {
      changed = _stickersController.undoLastAddedSticker();
    }
    // التراجع عن آخر خط
    else if (_drawingController.lines.isNotEmpty) {
      changed = _drawingController.undo();
    }

    if (changed) {
      _drawingController.setHasUnsavedChanges(true);
      setState(() {});
    }
  }

  // تنفيذ الإعادة بشكل متكامل (Redo)
  void _redo() {
    bool changed = false;

    // إعادة آخر ملصق تم حذفه
    if (_stickersController.removedStickers.isNotEmpty) {
      changed = _stickersController.redoLastRemovedSticker();
    }
    // إعادة آخر خط تم التراجع عنه
    else if (_drawingController.undoneLines.isNotEmpty) {
      changed = _drawingController.redo();
    }

    if (changed) {
      _drawingController.setHasUnsavedChanges(true);
      setState(() {});
    }
  }

  // تحديث فحص إمكانية التراجع
  bool _canUndo() {
    return _drawingController.lines.isNotEmpty ||
        _stickersController.stickers.isNotEmpty ||
        (_drawingController.isStickerMode &&
            _stickersController.selectedStickerIndex != null);
  }

  // تحديث فحص إمكانية الإعادة
  bool _canRedo() {
    return _drawingController.undoneLines.isNotEmpty ||
        _stickersController.removedStickers.isNotEmpty;
  }

  // معالجة اختيار العناصر من القائمة
  void _handleMenuItemSelected(String value) {
    switch (value) {
      case 'new':
        _newFile();
        break;
      case 'duplicate':
        _duplicateDrawing();
        break;
      case 'save':
        _saveDrawing();
        break;
      case 'share':
        _shareDrawing();
        break;
      case 'rename':
        _showRenameDialog();
        break;
      case 'files':
        _filesController.toggleFilesPanel();
        break;
      case 'deletePage':
        _deleteCurrentPage();
        break;
    }
  }

  // بناء صف معلومات الملف المختصر مع أزرار الإجراءات
  Widget _buildFileInfoWithActions() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // معلومات الملف
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _drawingController.currentFileName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDarkMode
                          ? WhiteboardColors.kMediumPurple
                          : WhiteboardColors.kDarkPurple,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_drawingController.hasUnsavedChanges) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: WhiteboardColors.kAccentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // أزرار الإجراءات
          _buildCompactTools(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl, // ضبط اتجاه النص من اليمين إلى اليسار
      child: Scaffold(
        backgroundColor: WhiteboardColors.getBackgroundColor(isDarkMode),
        body: SafeArea(
          child: Stack(
            children: [
              // المحتوى الرئيسي
              Column(
                children: [
                  // هيدر الصفحة
                  ToolsHeaderComponent(
                    isStickerMode: _drawingController.isStickerMode,
                    onToggleDrawingMode: _drawingController.toggleDrawingMode,
                  ),

                  // معلومات الملف وأزرار الإجراءات في صف واحد
                  _buildFileInfoWithActions(),

                  // شريط التنقل بين الصفحات (مصغر)
                  _buildCompactPageNavigationBar(),

                  // أدوات التحكم حسب الوضع الحالي (عندما تكون الأدوات مفتوحة)
                  if (_isToolsOpen)
                    SizeTransition(
                      sizeFactor: _toolsAnimation,
                      axisAlignment: -1.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        child: _drawingController.isStickerMode
                            ? (_stickersController.selectedStickerIndex != null
                                ? StickerToolsComponent(
                                    onEnlarge: () {
                                      _stickersController.scaleSelectedSticker(
                                          WhiteboardValues.scaleUpFactor);
                                      setState(() {});
                                    },
                                    onShrink: () {
                                      _stickersController.scaleSelectedSticker(
                                          WhiteboardValues.scaleDownFactor);
                                      setState(() {});
                                    },
                                    onRotateLeft: () {
                                      _stickersController.rotateSelectedSticker(
                                          -WhiteboardValues.rotationIncrement);
                                      setState(() {});
                                    },
                                    onRotateRight: () {
                                      _stickersController.rotateSelectedSticker(
                                          WhiteboardValues.rotationIncrement);
                                      setState(() {});
                                    },
                                    onDelete: () {
                                      if (_stickersController
                                          .deleteSelectedSticker()) {
                                        _drawingController
                                            .setHasUnsavedChanges(true);
                                        setState(() {});
                                        _showSnackBar(
                                            WhiteboardStrings.stickerDeleted,
                                            isError: false);
                                      }
                                    },
                                  )
                                : StickerControlsComponent(
                                    stickersCount:
                                        _stickersController.stickers.length,
                                    isStickerPanelOpen:
                                        _stickersController.isStickerPanelOpen,
                                    onToggleStickerPanel: () {
                                      _stickersController.toggleStickerPanel();
                                      setState(() {});
                                    },
                                  ))
                            : DrawingToolsComponent(
                                selectedColor: _drawingController.selectedColor,
                                strokeWidth: _drawingController.strokeWidth,
                                strokeCap: _drawingController.strokeCap,
                                onColorChanged: (color) {
                                  _drawingController.changeColor(color);
                                  setState(() {});
                                },
                                onStrokeWidthChanged: (width) {
                                  _drawingController.changeStrokeWidth(width);
                                  setState(() {});
                                },
                                onStrokeCapChanged: (cap) {
                                  _drawingController.changeStrokeCap(cap);
                                  setState(() {});
                                },
                              ),
                      ),
                    ),

                  // مساحة الرسم والملصقات (مكبرة)
                  Expanded(
                    child: Stack(
                      children: [
                        // لوحة الرسم
                        Container(
                          margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          decoration: BoxDecoration(
                            color: Colors.white, // السبورة دائمًا بيضاء
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isDarkMode
                                  ? WhiteboardColors.kMediumPurple
                                      .withOpacity(0.3)
                                  : WhiteboardColors.kLightPurple,
                              width: 2,
                            ),
                          ),
                          child: RepaintBoundary(
                            key: _boardKey,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: GestureDetector(
                                onTap: () {
                                  if (_drawingController.isStickerMode) {
                                    _stickersController.selectSticker(null);
                                    setState(() {});
                                  }
                                },
                                onPanStart: !_drawingController.isStickerMode
                                    ? (details) => _drawingController
                                        .startLine(details.localPosition)
                                    : null,
                                onPanUpdate: !_drawingController.isStickerMode
                                    ? (details) => _drawingController
                                        .updateLine(details.localPosition)
                                    : null,
                                onPanEnd: !_drawingController.isStickerMode
                                    ? (_) => _drawingController.endLine()
                                    : null,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // خلفية بيضاء
                                    Container(color: Colors.white),

                                    // رسم الخطوط
                                    CustomPaint(
                                      painter: DrawingPainter(
                                        lines: _drawingController.lines,
                                        currentLine:
                                            _drawingController.currentLine,
                                      ),
                                      size: Size.infinite,
                                    ),

                                    // الملصقات
                                    if (_drawingController.stickers.isNotEmpty)
                                      Stack(
                                        children: _drawingController.stickers
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final index = entry.key;
                                          final sticker = entry.value;
                                          final isSelected = _stickersController
                                                      .selectedStickerIndex ==
                                                  index &&
                                              _drawingController.isStickerMode;

                                          return Positioned(
                                            left: sticker.offset.dx,
                                            top: sticker.offset.dy,
                                            child: GestureDetector(
                                              onTap: _drawingController
                                                      .isStickerMode
                                                  ? () => _stickersController
                                                      .selectSticker(index)
                                                  : null,
                                              onPanUpdate: _drawingController
                                                      .isStickerMode
                                                  ? (details) {
                                                      _stickersController
                                                          .moveSelectedSticker(
                                                              details.delta);
                                                      _drawingController
                                                          .setHasUnsavedChanges(
                                                              true);
                                                      setState(() {});
                                                    }
                                                  : null,
                                              child: Transform.scale(
                                                scale: sticker.scale,
                                                child: Transform.rotate(
                                                  angle: sticker.rotation,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: isSelected
                                                          ? Border.all(
                                                              color: WhiteboardColors
                                                                  .kAccentColor,
                                                              width: 2,
                                                              strokeAlign:
                                                                  BorderSide
                                                                      .strokeAlignOutside,
                                                            )
                                                          : null,
                                                      borderRadius: isSelected
                                                          ? BorderRadius
                                                              .circular(8)
                                                          : null,
                                                      boxShadow: (isSelected)
                                                          ? [
                                                              BoxShadow(
                                                                color: WhiteboardColors
                                                                    .kAccentColor
                                                                    .withOpacity(
                                                                        0.3),
                                                                blurRadius: 8,
                                                                spreadRadius: 2,
                                                                offset:
                                                                    const Offset(
                                                                        0, 0),
                                                              ),
                                                            ]
                                                          : (_drawingController
                                                                  .isStickerMode)
                                                              ? [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.1),
                                                                    blurRadius:
                                                                        4,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            2),
                                                                  ),
                                                                ]
                                                              : null,
                                                    ),
                                                    child: Image.asset(
                                                      sticker.imagePath,
                                                      width: WhiteboardValues
                                                          .defaultStickerSize,
                                                      height: WhiteboardValues
                                                          .defaultStickerSize,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        print(
                                                            'خطأ في تحميل الملصق: $error');
                                                        return Container(
                                                          width: WhiteboardValues
                                                              .defaultStickerSize,
                                                          height: WhiteboardValues
                                                              .defaultStickerSize,
                                                          color:
                                                              Colors.grey[300],
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // لوحة الملصقات فوق لوحة الرسم
                        if (_drawingController.isStickerMode &&
                            _stickersController.isStickerPanelOpen)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: SizeTransition(
                              sizeFactor: _stickerPanelAnimation,
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: StickersPanelComponent(
                                  onStickerSelected: (stickerPath) {
                                    _stickersController.addSticker(stickerPath,
                                        MediaQuery.of(context).size);
                                    _drawingController
                                        .setHasUnsavedChanges(true);
                                    setState(() {});
                                    _showSnackBar(
                                        WhiteboardStrings.stickerAdded,
                                        isError: false);
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // قائمة الملفات المحفوظة - تم تحديثها لإصلاح مشكلة iOS
              if (_filesController.isFilesPanelOpen)
                SizeTransition(
                  sizeFactor: _filesPanelAnimation,
                  child: FilePanelComponent(
                    files: _filesController.savedFiles,
                    onClose: _filesController.toggleFilesPanel,
                    onFileOpen: _openFile,
                    onFileShare: _shareFile,
                    onFileDelete: _deleteFile,
                    errorMessage: _filesController.errorMessage,
                  ),
                ),

              // مؤشر التحميل
              if (_filesController.isLoading || _isLoading)
                const LoadingOverlayComponent(),
            ],
          ),
        ),
      ),
    );
  }
}
