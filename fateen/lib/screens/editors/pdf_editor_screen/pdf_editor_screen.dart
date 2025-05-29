import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image/image.dart' as img;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncpdf;

class PDFEditorScreen extends StatefulWidget {
  final String filePath;
  final Function(String) onSaved;

  const PDFEditorScreen({
    Key? key,
    required this.filePath,
    required this.onSaved,
  }) : super(key: key);

  @override
  _PDFEditorScreenState createState() => _PDFEditorScreenState();
}

class _PDFEditorScreenState extends State<PDFEditorScreen> {
  // ألوان التطبيق الموحدة
  final Color kDarkPurple = const Color(0xFF221291);
  final Color kMediumPurple = const Color(0xFF6C63FF);
  final Color kLightPurple = const Color(0xFFF6F4FF);
  final Color kAccentColor = const Color(0xFFFF6B6B);

  late PDFViewController _pdfViewController;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoading = true;
  bool _hasUnsavedChanges = false;

  // رسومات وملاحظات المستخدم
  List<Map<String, dynamic>> _annotations = [];
  Color _selectedColor = const Color(0xFF221291);
  double _strokeWidth = 3.0;
  String _fileId = '';

  // حفظ موضع النصوص
  Map<String, Offset> _textPositions = {};

  // مقياس الصفحة للتعامل مع أحجام الشاشات المختلفة
  double _pageScale = 1.0;
  Size _screenSize = Size.zero;

  // إعدادات لأجهزة أبل
  bool get isIOS => Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _fileId = path.basename(widget.filePath).split('.').first;
    _loadSavedAnnotations();
  }

  // تحميل التعليقات المحفوظة
  Future<void> _loadSavedAnnotations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAnnotations = prefs.getString('annotations_$_fileId');

      if (savedAnnotations != null) {
        final List<dynamic> decoded = jsonDecode(savedAnnotations);

        setState(() {
          _annotations = decoded.map<Map<String, dynamic>>((item) {
            if (item['type'] == 'line') {
              // تحويل إحداثيات النقاط من JSON للكائنات
              item['point'] = Offset(
                (item['point_x'] as num).toDouble(),
                (item['point_y'] as num).toDouble(),
              );
            } else if (item['type'] == 'text') {
              // تحويل إحداثيات النص من JSON للكائنات
              item['position'] = Offset(
                (item['position_x'] as num).toDouble(),
                (item['position_y'] as num).toDouble(),
              );

              // حفظ موضع النص
              _textPositions[item['text']] = item['position'];
            }
            return item;
          }).toList();
        });

        print('تم تحميل ${_annotations.length} تعليق');
      }
    } catch (e) {
      print('خطأ في تحميل التعليقات المحفوظة: $e');
    }
  }

  // حفظ التعليقات لاستعادتها لاحقاً
  Future<void> _saveAnnotations() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // تحويل البيانات لتناسب التخزين في JSON
      final annotationsToSave = _annotations.map((item) {
        Map<String, dynamic> jsonItem = Map<String, dynamic>.from(item);

        if (item['type'] == 'line') {
          // تخزين إحداثيات النقطة كأرقام مباشرة
          final point = item['point'] as Offset;
          jsonItem['point_x'] = point.dx;
          jsonItem['point_y'] = point.dy;
          jsonItem.remove('point');
        } else if (item['type'] == 'text') {
          // تخزين إحداثيات النص كأرقام مباشرة
          final position = item['position'] as Offset;
          jsonItem['position_x'] = position.dx;
          jsonItem['position_y'] = position.dy;
          jsonItem.remove('position');
        }

        return jsonItem;
      }).toList();

      final encodedData = jsonEncode(annotationsToSave);
      await prefs.setString('annotations_$_fileId', encodedData);

      print('تم حفظ ${_annotations.length} تعليق');

      setState(() {
        _hasUnsavedChanges = false;
      });
    } catch (e) {
      print('خطأ في حفظ التعليقات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: kDarkPurple,
          elevation: 0,
          title: const Text(
            'تعديل المستند',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // زر مشاركة الملف
            IconButton(
              icon: Icon(isIOS ? CupertinoIcons.share : Icons.share,
                  color: Colors.white),
              onPressed: () => _shareFile(),
              tooltip: 'مشاركة الملف',
            ),

            // زر الحفظ
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Icon(
                          isIOS ? CupertinoIcons.floppy_disk : Icons.save,
                          color: Colors.white,
                        ),
                        if (_hasUnsavedChanges)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: kAccentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
              onPressed: _isSaving ? null : _savePDFWithAnnotations,
              tooltip: 'حفظ التعديلات',
            ),

            // زر تبديل وضع التعديل
            IconButton(
              icon: Icon(
                _isEditing
                    ? isIOS
                        ? CupertinoIcons.pen
                        : Icons.edit_off
                    : isIOS
                        ? CupertinoIcons.pencil
                        : Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              tooltip: _isEditing ? 'إيقاف التعديل' : 'بدء التعديل',
            ),
          ],
        ),
        body: Stack(
          children: [
            // عرض شاشة تحميل إذا كان المستند يتم تحميله
            if (_isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: kDarkPurple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'جاري تحميل المستند...',
                      style: TextStyle(
                        fontSize: 16,
                        color: kDarkPurple,
                      ),
                    ),
                  ],
                ),
              ),

            // عرض PDF
            PDFView(
              filePath: widget.filePath,
              enableSwipe: !_isEditing, // تعطيل التمرير في وضع التعديل
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              defaultPage: _currentPage,
              onRender: (_pages) {
                setState(() {
                  _totalPages = _pages!;
                  _isLoading = false;
                });
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _pdfViewController = pdfViewController;
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  _currentPage = page!;
                });
              },
              onError: (error) {
                setState(() {
                  _isLoading = false;
                });
                print('خطأ في عرض PDF: $error');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('حدث خطأ أثناء عرض المستند: $error'),
                  backgroundColor: kAccentColor,
                ));
              },
            ),

            // طبقة الرسم للتعديل
            if (_isEditing)
              GestureDetector(
                onPanStart: (details) {
                  _addPoint(details.localPosition);
                },
                onPanUpdate: (details) {
                  _addPoint(details.localPosition);
                },
                onPanEnd: (_) {
                  _startNewLine();
                },
                // التقاط الضغط المزدوج على النص لتحريكه
                onDoubleTap: () {
                  _showContextMenu();
                },
                child: CustomPaint(
                  size: Size.infinite,
                  painter: AnnotationPainter(
                    annotations: _annotations,
                    currentPage: _currentPage,
                    onMoveText: _moveTextAnnotation,
                  ),
                ),
              ),

            // طبقة النصوص القابلة للتحريك
            if (_isEditing)
              Stack(
                children: _buildDraggableTexts(),
              ),

            // أدوات التعديل
            if (_isEditing)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // سماكة الخط
                          IconButton(
                            icon: Icon(
                              isIOS
                                  ? CupertinoIcons.line_horizontal_3
                                  : Icons.line_weight,
                              color: kDarkPurple,
                            ),
                            onPressed: _showStrokeWidthPicker,
                            tooltip: 'سماكة الخط',
                          ),

                          // لون الخط
                          IconButton(
                            icon: Container(
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              width: 24,
                              height: 24,
                            ),
                            onPressed: _showColorPicker,
                            tooltip: 'لون القلم',
                          ),

                          // إضافة نص
                          IconButton(
                            icon: Icon(
                              isIOS
                                  ? CupertinoIcons.text_badge_plus
                                  : Icons.text_fields,
                              color: kDarkPurple,
                            ),
                            onPressed: _addTextAnnotation,
                            tooltip: 'إضافة نص',
                          ),

                          // إضافة شكل
                          IconButton(
                            icon: Icon(
                              isIOS
                                  ? CupertinoIcons.square_stack_3d_down_right
                                  : Icons.category,
                              color: kDarkPurple,
                            ),
                            onPressed: _showShapesMenu,
                            tooltip: 'إضافة شكل',
                          ),

                          // أداة المحاية
                          IconButton(
                            icon: Icon(
                              Icons.auto_fix_high,
                              color: kDarkPurple,
                            ),
                            onPressed: _toggleEraser,
                            tooltip: 'محاية',
                          ),

                          // التراجع عن آخر إجراء
                          IconButton(
                            icon: Icon(
                              isIOS
                                  ? CupertinoIcons.arrow_counterclockwise
                                  : Icons.undo,
                              color: _annotations.isEmpty
                                  ? Colors.grey
                                  : kDarkPurple,
                            ),
                            onPressed: _annotations.isEmpty
                                ? null
                                : () {
                                    setState(() {
                                      // مسح آخر خط أو آخر نص
                                      if (_annotations.isNotEmpty) {
                                        final lastItem = _annotations.last;
                                        if (lastItem['type'] == 'line') {
                                          _annotations.removeWhere((item) =>
                                              item['lineId'] ==
                                                  lastItem['lineId'] &&
                                              item['page'] == _currentPage);
                                        } else {
                                          _annotations.removeLast();
                                        }
                                        _hasUnsavedChanges = true;
                                      }
                                    });
                                  },
                            tooltip: 'تراجع',
                          ),

                          // مسح كل التعديلات على الصفحة الحالية
                          IconButton(
                            icon: Icon(
                              isIOS ? CupertinoIcons.clear : Icons.clear_all,
                              color: kAccentColor,
                            ),
                            onPressed: () => _showClearConfirmationDialog(),
                            tooltip: 'مسح التعديلات',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // مؤشر ورقم الصفحة وأزرار التنقل
            Positioned(
              bottom: _isEditing ? 90 : 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kDarkPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // زر الصفحة السابقة
                      if (_currentPage > 0)
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            _pdfViewController.setPage(_currentPage - 1);
                          },
                          tooltip: 'الصفحة السابقة',
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),

                      Text(
                        '${_currentPage + 1} / $_totalPages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // زر الصفحة التالية
                      if (_currentPage < _totalPages - 1)
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            _pdfViewController.setPage(_currentPage + 1);
                          },
                          tooltip: 'الصفحة التالية',
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // مؤشر الحفظ الآلي
            if (_hasUnsavedChanges)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kAccentColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.save_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'يوجد تغييرات غير محفوظة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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

  // إنشاء نصوص قابلة للسحب
  List<Widget> _buildDraggableTexts() {
    List<Widget> textWidgets = [];

    for (var annotation in _annotations) {
      if (annotation['type'] == 'text' && annotation['page'] == _currentPage) {
        final position = annotation['position'] as Offset;
        final color = Color(annotation['color']);
        final text = annotation['text'];

        textWidgets.add(
          Positioned(
            left: position.dx - 100, // مركز النص
            top: position.dy - 20,
            child: Draggable(
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              onDragEnd: (details) {
                _moveTextAnnotation(text, details.offset);
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ),
        );
      }
    }

    return textWidgets;
  }

  // تحريك النص المعلق
  void _moveTextAnnotation(String text, Offset newPosition) {
    setState(() {
      for (int i = 0; i < _annotations.length; i++) {
        if (_annotations[i]['type'] == 'text' &&
            _annotations[i]['text'] == text &&
            _annotations[i]['page'] == _currentPage) {
          _annotations[i]['position'] = newPosition;
          _hasUnsavedChanges = true;
          break;
        }
      }
    });
  }

  // حساب مقياس الصفحة
  void _calculatePageScale() {
    // مقياس بسيط بناءً على عرض الشاشة
    final standardWidth = 595.0; // عرض A4 القياسي بالنقاط
    _pageScale = _screenSize.width / standardWidth;
  }

  // تبديل وضع المحاية
  void _toggleEraser() {
    // تنفيذ وضع المحاية
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('اسحب لمحو التعليقات'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // إظهار قائمة سياقية للنص
  void _showContextMenu() {
    // عرض قائمة بالخيارات المتاحة للنص المحدد
  }

  // عرض قائمة الأشكال
  void _showShapesMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر شكلاً',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kDarkPurple,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShapeButton(Icons.crop_square, 'مربع', () {
                    _addShape('rectangle');
                    Navigator.pop(context);
                  }),
                  _buildShapeButton(Icons.circle, 'دائرة', () {
                    _addShape('circle');
                    Navigator.pop(context);
                  }),
                  _buildShapeButton(Icons.change_history, 'مثلث', () {
                    _addShape('triangle');
                    Navigator.pop(context);
                  }),
                  _buildShapeButton(Icons.linear_scale, 'خط', () {
                    _addShape('line');
                    Navigator.pop(context);
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // بناء زر الشكل
  Widget _buildShapeButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: kLightPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: kDarkPurple,
                size: 30,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: kDarkPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // إضافة شكل
  void _addShape(String shapeType) {
    final center = Offset(_screenSize.width / 2, _screenSize.height / 2);

    setState(() {
      _annotations.add({
        'type': 'shape',
        'shape': shapeType,
        'position': center,
        'size': 100.0, // حجم افتراضي
        'color': _selectedColor.value,
        'strokeWidth': _strokeWidth,
        'page': _currentPage,
      });
      _hasUnsavedChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة شكل $shapeType'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // مشاركة الملف
  void _shareFile() async {
    try {
      // إذا كان هناك تعديلات، نسأل المستخدم إذا كان يريد حفظها أولاً
      if (_hasUnsavedChanges) {
        final result = await _showSaveBeforeSharingDialog();
        if (result == null) return; // إلغاء العملية

        if (result) {
          // حفظ التعديلات أولاً
          await _savePDFWithAnnotations(false);
        }
      }

      await Share.shareXFiles([XFile(widget.filePath)], text: 'مستند PDF معدل');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء مشاركة الملف: $e'),
          backgroundColor: kAccentColor,
        ),
      );
    }
  }

  // حوار للتأكيد قبل المشاركة
  Future<bool?> _showSaveBeforeSharingDialog() async {
    return showDialog<bool?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حفظ التعديلات'),
        content: const Text('هل تريد حفظ التعديلات قبل مشاركة الملف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('مشاركة بدون حفظ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kDarkPurple,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حفظ ومشاركة'),
          ),
        ],
      ),
    );
  }

  // تأكيد مسح التعديلات
  void _showClearConfirmationDialog() {
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('مسح التعديلات'),
          content: const Text(
              'هل أنت متأكد من مسح جميع التعديلات على الصفحة الحالية؟'),
          actions: [
            CupertinoDialogAction(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                setState(() {
                  _annotations
                      .removeWhere((item) => item['page'] == _currentPage);
                  _hasUnsavedChanges = true;
                });
                Navigator.pop(context);
              },
              child: const Text('مسح'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('مسح التعديلات'),
          content: const Text(
              'هل أنت متأكد من مسح جميع التعديلات على الصفحة الحالية؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _annotations
                      .removeWhere((item) => item['page'] == _currentPage);
                  _hasUnsavedChanges = true;
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: kAccentColor,
              ),
              child: const Text('مسح'),
            ),
          ],
        ),
      );
    }
  }

  // إضافة نقطة للرسم
  void _addPoint(Offset point) {
    setState(() {
      // إنشاء معرف فريد للخط الحالي إذا كان جديدًا
      String lineId;
      if (_annotations.isEmpty ||
          _annotations.last['type'] != 'line' ||
          _annotations.last['lineId'] != 'current') {
        lineId = 'current';
      } else {
        lineId = _annotations.last['lineId'];
      }

      _annotations.add({
        'type': 'line',
        'point': point,
        'color': _selectedColor.value,
        'strokeWidth': _strokeWidth,
        'page': _currentPage,
        'lineId': lineId,
      });

      _hasUnsavedChanges = true;
    });
  }

  // بدء خط جديد
  void _startNewLine() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    for (var i = 0; i < _annotations.length; i++) {
      if (_annotations[i]['lineId'] == 'current') {
        _annotations[i]['lineId'] = timestamp;
      }
    }
  }

  // اختيار سماكة الخط - واجهة متوافقة مع iOS وAndroid
  void _showStrokeWidthPicker() {
    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return Container(
            height: 250,
            padding: const EdgeInsets.only(top: 20),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const Text(
                    'اختر سماكة الخط',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: CupertinoSlider(
                      value: _strokeWidth,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      onChanged: (value) {
                        setState(() {
                          _strokeWidth = value;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // نماذج للسماكات المختلفة
                      for (double width in [1.0, 3.0, 5.0, 8.0, 10.0])
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _strokeWidth = width;
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 40,
                              height: width * 3,
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                borderRadius: BorderRadius.circular(width),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('تم'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'اختر سماكة الخط',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kDarkPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.line_weight, color: kDarkPurple, size: 16),
                        Expanded(
                          child: Slider(
                            value: _strokeWidth,
                            min: 1.0,
                            max: 10.0,
                            divisions: 9,
                            activeColor: kDarkPurple,
                            label: _strokeWidth.toStringAsFixed(1),
                            onChanged: (value) {
                              setModalState(() {
                                _strokeWidth = value;
                              });
                              setState(() {
                                _strokeWidth = value;
                              });
                            },
                          ),
                        ),
                        Icon(Icons.line_weight, color: kDarkPurple, size: 24),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // نماذج للسماكات المختلفة
                        for (double width in [1.0, 3.0, 5.0, 8.0, 10.0])
                          InkWell(
                            onTap: () {
                              setState(() {
                                _strokeWidth = width;
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 40,
                              height: width * 3,
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                borderRadius: BorderRadius.circular(width),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('تأكيد'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  // اختيار لون - واجهة متوافقة مع iOS وAndroid مع استخدام مكتبة ColorPicker
  void _showColorPicker() {
    final List<Color> colors = [
      kDarkPurple,
      kMediumPurple,
      kAccentColor,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.black,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر لون القلم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kDarkPurple,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                child: ColorPicker(
                  pickerColor: _selectedColor,
                  onColorChanged: (color) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: false,
                  displayThumbColor: true,
                  paletteType: PaletteType.hsvWithHue,
                  labelTypes: const [],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'ألوان مقترحة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kDarkPurple,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // إضافة ملاحظة نصية - واجهة متوافقة مع iOS وAndroid
  void _addTextAnnotation() {
    final TextEditingController textController = TextEditingController();
    final FocusNode textFocusNode = FocusNode();

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('إضافة نص'),
            content: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: CupertinoTextField(
                controller: textController,
                focusNode: textFocusNode,
                textAlign: TextAlign.right,
                placeholder: 'أدخل النص هنا...',
                maxLines: 3,
                autofocus: true,
                padding: const EdgeInsets.all(12),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                isDestructiveAction: true,
                child: const Text('إلغاء'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  if (textController.text.trim().isNotEmpty) {
                    setState(() {
                      // إضافة النص في منتصف الشاشة
                      final size = MediaQuery.of(context).size;
                      _annotations.add({
                        'type': 'text',
                        'text': textController.text,
                        'position': Offset(size.width / 2, size.height / 2),
                        'color': _selectedColor.value,
                        'page': _currentPage,
                      });
                      _hasUnsavedChanges = true;
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      ).then((_) {
        textFocusNode.dispose();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'إضافة نص',
              style: TextStyle(color: kDarkPurple),
              textAlign: TextAlign.right,
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    focusNode: textFocusNode,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'أدخل النص هنا...',
                      hintTextDirection: TextDirection.rtl,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: kDarkPurple),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: kDarkPurple, width: 2),
                      ),
                      filled: true,
                      fillColor: kLightPurple.withOpacity(0.3),
                    ),
                    maxLines: 3,
                    autofocus: true,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لون النص',
                    style: TextStyle(
                      color: kDarkPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // قائمة ألوان مختصرة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Colors.black,
                      kDarkPurple,
                      kAccentColor,
                      Colors.green,
                      Colors.blue,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == color
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (textController.text.trim().isNotEmpty) {
                    setState(() {
                      // إضافة النص في منتصف الشاشة
                      final size = MediaQuery.of(context).size;
                      _annotations.add({
                        'type': 'text',
                        'text': textController.text,
                        'position': Offset(size.width / 2, size.height / 2),
                        'color': _selectedColor.value,
                        'page': _currentPage,
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                      });
                      _hasUnsavedChanges = true;
                    });
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      ).then((_) {
        textFocusNode.dispose();
      });
    }
  }

  // سؤال المستخدم عند الرجوع إذا كان هناك تغييرات غير محفوظة
  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديلات غير محفوظة'),
          content: Text('لديك تعديلات لم يتم حفظها. هل تريد حفظها قبل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false), // البقاء في الصفحة
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // الخروج بدون حفظ
              child: Text('تجاهل التعديلات'),
              style: TextButton.styleFrom(foregroundColor: kAccentColor),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // إغلاق الحوار
                await _savePDFWithAnnotations(); // حفظ التعديلات
              },
              style: ElevatedButton.styleFrom(backgroundColor: kDarkPurple),
              child: Text('حفظ وخروج'),
            ),
          ],
        );
      },
    );

    return shouldPop ?? false;
  }

  // حفظ الملف PDF مع التعليقات
  Future<void> _savePDFWithAnnotations([bool showFeedback = true]) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('لم يتم منح إذن الوصول للتخزين');
      }

      // حفظ التعليقات في التفضيلات
      await _saveAnnotations();

      // إنشاء ملف PDF جديد مع التعليقات
      final outputFile = await _createAnnotatedPdfCopy();

      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = false;
      });

      // إرجاع المسار الجديد إلى الدالة الأصلية
      widget.onSaved(outputFile.path);

      // إظهار رسالة نجاح إذا كان showFeedback صحيحًا
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ المستند بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        // إغلاق الشاشة
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حفظ المستند: $e'),
          backgroundColor: kAccentColor,
        ),
      );
    }
  }

  // إنشاء نسخة من الملف مع التعليقات
  Future<File> _createAnnotatedPdfCopy() async {
    // الحصول على مسار مجلد التطبيق
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = path.basenameWithoutExtension(widget.filePath);
    final newFilePath = '${directory.path}/${fileName}_edited_$timestamp.pdf';

    // نسخ الملف الأصلي للملف الجديد
    final originalFile = File(widget.filePath);
    final newFile = await originalFile.copy(newFilePath);

    // استخدام مكتبة Syncfusion لإضافة التعليقات
    final syncpdf.PdfDocument document =
        syncpdf.PdfDocument(inputBytes: await originalFile.readAsBytes());

    // مجموعة من الصفحات والتعليقات عليها
    Map<int, List<Map<String, dynamic>>> annotationsByPage = {};

    // تنظيم التعليقات حسب الصفحات
    for (var annotation in _annotations) {
      int page = annotation['page'];
      if (!annotationsByPage.containsKey(page)) {
        annotationsByPage[page] = [];
      }
      annotationsByPage[page]!.add(annotation);
    }

    // معالجة كل صفحة تحتوي على تعليقات
    for (var pageEntry in annotationsByPage.entries) {
      int pageIndex = pageEntry.key;
      List<Map<String, dynamic>> pageAnnotations = pageEntry.value;

      // التأكد من أن الصفحة موجودة
      if (pageIndex < document.pages.count) {
        // إضافة التعليقات المرئية كطبقة فوق الصفحة
        syncpdf.PdfPage page = document.pages[pageIndex];
        syncpdf.PdfGraphics graphics = page.graphics;

        // رسم جميع التعليقات
        for (var annotation in pageAnnotations) {
          if (annotation['type'] == 'text') {
            // إضافة التعليقات النصية
            Offset position = annotation['position'] as Offset;
            syncpdf.PdfFont font =
                syncpdf.PdfStandardFont(syncpdf.PdfFontFamily.helvetica, 14);

            // تصحيح المشكلة: استخدام syncpdf.Rect بدلاً من Rect
          } else if (annotation['type'] == 'line') {
            // رسم الخطوط في PDF
            try {
              if (annotation['lineId'] != 'current') {
                // فقط رسم الخطوط المكتملة (غير الحالية)
                // بحث عن كل نقاط الخط بنفس المعرف
                List<Map<String, dynamic>> linePoints = _annotations
                    .where((item) =>
                        item['type'] == 'line' &&
                        item['lineId'] == annotation['lineId'] &&
                        item['page'] == pageIndex)
                    .toList();

                if (linePoints.length > 1) {
                  // إذا كان هناك أكثر من نقطة، نرسم خط
                  syncpdf.PdfPen pen = syncpdf.PdfPen(
                      _pdfColorFromInt(annotation['color']),
                      width: annotation['strokeWidth']);

                  for (int i = 0; i < linePoints.length - 1; i++) {
                    Offset point1 = linePoints[i]['point'] as Offset;
                    Offset point2 = linePoints[i + 1]['point'] as Offset;

                    graphics.drawLine(pen, Offset(point1.dx, point1.dy),
                        Offset(point2.dx, point2.dy));
                  }
                }
              }
            } catch (e) {
              print('خطأ في رسم الخط: $e');
            }
          } else if (annotation['type'] == 'shape') {
            // رسم الأشكال في PDF
            Offset position = annotation['position'] as Offset;
            double size = annotation['size'] as double;

            // الدائرة تحتاج إلى معالجة خاصة
            // المثلث معقد نوعاً ما ويمكن تنفيذه لاحقاً
          }
        }
      }
    }

    // حفظ الملف المعدل
    final List<int> bytes = await document.save();
    await newFile.writeAsBytes(bytes);
    document.dispose();

    return newFile;
  }

  // تحويل لون من Int إلى PdfColor
  syncpdf.PdfColor _pdfColorFromInt(int colorValue) {
    Color color = Color(colorValue);
    return syncpdf.PdfColor(color.red, color.green, color.blue, color.alpha);
  }

  @override
  void dispose() {
    // حفظ التعليقات قبل الخروج إذا كانت هناك تغييرات
    if (_hasUnsavedChanges) {
      _saveAnnotations();
    }
    super.dispose();
  }
}

// رسام التعليقات
class AnnotationPainter extends CustomPainter {
  final List<Map<String, dynamic>> annotations;
  final int currentPage;
  final Function(String, Offset) onMoveText;

  AnnotationPainter({
    required this.annotations,
    required this.currentPage,
    required this.onMoveText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // رسم الخطوط
    Map<String, List<Map<String, dynamic>>> lines = {};

    // تجميع النقاط حسب معرف الخط
    for (var annotation in annotations) {
      if (annotation['type'] == 'line' && annotation['page'] == currentPage) {
        String lineId = annotation['lineId'];
        if (!lines.containsKey(lineId)) {
          lines[lineId] = [];
        }
        lines[lineId]!.add(annotation);
      }
    }

    // رسم كل خط
    lines.forEach((lineId, points) {
      if (points.isEmpty) return;

      final path = Path();
      final paint = Paint()
        ..color = Color(points.first['color'])
        ..strokeWidth = points.first['strokeWidth']
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (points.length > 1) {
        path.moveTo(points.first['point'].dx, points.first['point'].dy);

        for (var i = 1; i < points.length; i++) {
          path.lineTo(points[i]['point'].dx, points[i]['point'].dy);
        }

        canvas.drawPath(path, paint);
      } else {
        // نقطة واحدة - رسم دائرة صغيرة
        canvas.drawCircle(
          points.first['point'],
          points.first['strokeWidth'] / 2,
          Paint()..color = Color(points.first['color']),
        );
      }
    });

    // رسم الأشكال
    final shapeAnnotations = annotations
        .where((a) => a['type'] == 'shape' && a['page'] == currentPage)
        .toList();

    for (var shape in shapeAnnotations) {
      final position = shape['position'] as Offset;
      final size = shape['size'] as double;
      final paint = Paint()
        ..color = Color(shape['color'])
        ..strokeWidth = shape['strokeWidth']
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      switch (shape['shape']) {
        case 'rectangle':
          final rect = Rect.fromCenter(
            center: position,
            width: size,
            height: size * 0.7,
          );
          canvas.drawRect(rect, paint);
          break;
        case 'circle':
          canvas.drawCircle(position, size / 2, paint);
          break;
        case 'triangle':
          final path = Path();
          final halfSize = size / 2;
          path.moveTo(position.dx, position.dy - halfSize);
          path.lineTo(position.dx - halfSize, position.dy + halfSize);
          path.lineTo(position.dx + halfSize, position.dy + halfSize);
          path.close();
          canvas.drawPath(path, paint);
          break;
        case 'line':
          canvas.drawLine(
            Offset(position.dx - size / 2, position.dy),
            Offset(position.dx + size / 2, position.dy),
            paint,
          );
          break;
      }
    }

    // رسم النصوص - يتم الآن في قائمة النصوص القابلة للسحب
    // تم نقله إلى _buildDraggableTexts()
  }

  @override
  bool shouldRepaint(AnnotationPainter oldDelegate) => true;
}
