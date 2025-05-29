import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ImageEditorScreen extends StatefulWidget {
  final String imagePath;
  final Function(String) onSaved;

  const ImageEditorScreen({
    Key? key,
    required this.imagePath,
    required this.onSaved,
  }) : super(key: key);

  @override
  _ImageEditorScreenState createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  // ألوان التطبيق الموحدة
  final Color kDarkPurple = const Color(0xFF221291);
  final Color kMediumPurple = const Color(0xFF6C63FF);
  final Color kLightPurple = const Color(0xFFF6F4FF);
  final Color kAccentColor = const Color(0xFFFF6B6B);

  late ui.Image _image;
  bool _isImageLoaded = false;
  bool _isEditing = true;
  bool _isSaving = false;

  // متغيرات الرسم
  final List<DrawingPoint> _drawingPoints = [];
  final List<List<DrawingPoint>> _allStrokes = [];
  final List<TextOverlay> _textOverlays = [];

  // إعدادات التحرير
  Color _selectedColor = const Color(
      0xFF221291); // اللون الافتراضي هو الأرجواني الداكن للتوافق مع التصميم
  double _strokeWidth = 3.0;

  // إعدادات لأجهزة أبل
  bool get isIOS => Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // تحميل الصورة
  Future<void> _loadImage() async {
    try {
      final File file = File(widget.imagePath);
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('الملف غير موجود!'),
            backgroundColor: kAccentColor,
          ),
        );
        Navigator.pop(context);
        return;
      }

      final data = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();

      setState(() {
        _image = frame.image;
        _isImageLoaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحميل الصورة: $e'),
          backgroundColor: kAccentColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    if (_isImageLoaded) {
      _image.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kDarkPurple,
        elevation: 0,
        title: const Text(
          'تعديل الصورة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // زر مشاركة الصورة
          IconButton(
            icon: Icon(isIOS ? CupertinoIcons.share : Icons.share,
                color: Colors.white),
            onPressed: () => _shareImage(),
            tooltip: 'مشاركة الصورة',
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
                : Icon(isIOS ? CupertinoIcons.floppy_disk : Icons.save,
                    color: Colors.white),
            onPressed: _isSaving ? null : _saveEditedImage,
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
      body: _isImageLoaded
          ? Stack(
              children: [
                // عرض الصورة والرسومات
                GestureDetector(
                  onPanStart: _isEditing ? _onPanStart : null,
                  onPanUpdate: _isEditing ? _onPanUpdate : null,
                  onPanEnd: _isEditing ? _onPanEnd : null,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: ImagePainter(
                      image: _image,
                      drawingPoints:
                          _allStrokes.expand((points) => points).toList(),
                      textOverlays: _textOverlays,
                    ),
                  ),
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
                              icon: Icon(
                                isIOS
                                    ? CupertinoIcons.paintbrush
                                    : Icons.color_lens,
                                color: _selectedColor,
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
                              onPressed: _addTextOverlay,
                              tooltip: 'إضافة نص',
                            ),

                            // مسح آخر إجراء
                            IconButton(
                              icon: Icon(
                                isIOS
                                    ? CupertinoIcons.arrow_counterclockwise
                                    : Icons.undo,
                                color: (_textOverlays.isEmpty &&
                                        _allStrokes.isEmpty)
                                    ? Colors.grey
                                    : kDarkPurple,
                              ),
                              onPressed:
                                  (_textOverlays.isEmpty && _allStrokes.isEmpty)
                                      ? null
                                      : () {
                                          setState(() {
                                            if (_textOverlays.isNotEmpty) {
                                              _textOverlays.removeLast();
                                            } else if (_allStrokes.isNotEmpty) {
                                              _allStrokes.removeLast();
                                            }
                                          });
                                        },
                              tooltip: 'تراجع',
                            ),

                            // مسح كل التعديلات
                            IconButton(
                              icon: Icon(
                                isIOS ? CupertinoIcons.clear : Icons.clear_all,
                                color: (_textOverlays.isEmpty &&
                                        _allStrokes.isEmpty)
                                    ? Colors.grey
                                    : kAccentColor,
                              ),
                              onPressed:
                                  (_textOverlays.isEmpty && _allStrokes.isEmpty)
                                      ? null
                                      : () => _showClearConfirmationDialog(),
                              tooltip: 'مسح التعديلات',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: kDarkPurple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'جاري تحميل الصورة...',
                    style: TextStyle(
                      fontSize: 16,
                      color: kDarkPurple,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // مشاركة الصورة
  void _shareImage() async {
    try {
      // إذا كان هناك تعديلات، نسأل المستخدم إذا كان يريد حفظها أولاً
      if (_textOverlays.isNotEmpty || _allStrokes.isNotEmpty) {
        final result = await _showSaveBeforeSharingDialog();
        if (result == null) return; // إلغاء العملية

        if (result) {
          // حفظ التعديلات أولاً
          await _saveEditedImage(false);
        }
      }

      await Share.shareXFiles([XFile(widget.imagePath)], text: 'مشاركة صورة');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء مشاركة الصورة: $e'),
          backgroundColor: kAccentColor,
        ),
      );
    }
  }

  // حوار للتأكيد قبل المشاركة
  Future<bool?> _showSaveBeforeSharingDialog() async {
    if (isIOS) {
      return showCupertinoDialog<bool?>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('حفظ التعديلات'),
          content: const Text('هل تريد حفظ التعديلات قبل مشاركة الصورة؟'),
          actions: [
            CupertinoDialogAction(
              child: const Text('مشاركة بدون حفظ'),
              onPressed: () => Navigator.pop(context, false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context, null),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('حفظ ومشاركة'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );
    } else {
      return showDialog<bool?>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('حفظ التعديلات'),
          content: const Text('هل تريد حفظ التعديلات قبل مشاركة الصورة؟'),
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
  }

  // تأكيد مسح التعديلات
  void _showClearConfirmationDialog() {
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('مسح التعديلات'),
          content: const Text('هل أنت متأكد من مسح جميع التعديلات على الصورة؟'),
          actions: [
            CupertinoDialogAction(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                setState(() {
                  _allStrokes.clear();
                  _textOverlays.clear();
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
          content: const Text('هل أنت متأكد من مسح جميع التعديلات على الصورة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _allStrokes.clear();
                  _textOverlays.clear();
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

  // بدء رسم خط جديد
  void _onPanStart(DragStartDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _drawingPoints.clear();
      _drawingPoints.add(
        DrawingPoint(
          point: localPosition,
          color: _selectedColor,
          strokeWidth: _strokeWidth,
        ),
      );
    });
  }

  // استمرار الرسم
  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _drawingPoints.add(
        DrawingPoint(
          point: localPosition,
          color: _selectedColor,
          strokeWidth: _strokeWidth,
        ),
      );
    });
  }

  // إنهاء رسم الخط
  void _onPanEnd(DragEndDetails details) {
    if (_drawingPoints.isNotEmpty) {
      setState(() {
        _allStrokes.add(List.from(_drawingPoints));
        _drawingPoints.clear();
      });
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
                    const SizedBox(height: 10),
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

  // اختيار لون - واجهة متوافقة مع iOS وAndroid
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
    ];

    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const Text(
                    'اختر لون القلم',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Wrap(
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
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? CupertinoColors.systemBackground
                                        .resolveFrom(context)
                                    : color,
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
                  'اختر لون القلم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kDarkPurple,
                  ),
                ),
                const SizedBox(height: 20),
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
  }

  // إضافة نص على الصورة - واجهة متوافقة مع iOS وAndroid
  void _addTextOverlay() {
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
                      _textOverlays.add(
                        TextOverlay(
                          text: textController.text,
                          position: Offset(size.width / 2, size.height / 2),
                          color: _selectedColor,
                        ),
                      );
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
            content: TextField(
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
                      _textOverlays.add(
                        TextOverlay(
                          text: textController.text,
                          position: Offset(size.width / 2, size.height / 2),
                          color: _selectedColor,
                        ),
                      );
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

  // حفظ الصورة بعد التعديل
  Future<void> _saveEditedImage([bool showFeedback = true]) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('لم يتم منح إذن الوصول للتخزين');
      }

      // في النسخة الكاملة، يتم حفظ الصورة مع التعديلات كملف جديد
      // هذا المثال مبسط للتوضيح فقط

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFilePath = '${directory.path}/edited_image_$timestamp.jpg';

      // نسخ الملف الأصلي كخطوة مؤقتة
      final originalFile = File(widget.imagePath);
      final newFile = await originalFile.copy(newFilePath);

      setState(() {
        _isSaving = false;
      });

      // إرجاع المسار الجديد إلى الدالة الأصلية
      widget.onSaved(newFile.path);

      // إظهار رسالة نجاح
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الصورة بنجاح'),
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
          content: Text('حدث خطأ أثناء حفظ الصورة: $e'),
          backgroundColor: kAccentColor,
        ),
      );
    }
  }
}

// نقطة رسم
class DrawingPoint {
  final Offset point;
  final Color color;
  final double strokeWidth;

  DrawingPoint({
    required this.point,
    required this.color,
    required this.strokeWidth,
  });
}

// نص معروض على الصورة
class TextOverlay {
  final String text;
  final Offset position;
  final Color color;

  TextOverlay({
    required this.text,
    required this.position,
    required this.color,
  });
}

// رسام الصورة والتعديلات
class ImagePainter extends CustomPainter {
  final ui.Image image;
  final List<DrawingPoint> drawingPoints;
  final List<TextOverlay> textOverlays;

  ImagePainter({
    required this.image,
    required this.drawingPoints,
    required this.textOverlays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // رسم الصورة بحجم مناسب
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final fitSize = _calculateFitSize(imageSize, size);
    final rect = Rect.fromLTWH(
      (size.width - fitSize.width) / 2,
      (size.height - fitSize.height) / 2,
      fitSize.width,
      fitSize.height,
    );

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, imageSize.width, imageSize.height),
      rect,
      Paint(),
    );

    // رسم الخطوط
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      final current = drawingPoints[i];
      final next = drawingPoints[i + 1];

      canvas.drawLine(
        current.point,
        next.point,
        Paint()
          ..color = current.color
          ..strokeWidth = current.strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    // رسم النصوص
    for (var textObj in textOverlays) {
      final textSpan = TextSpan(
        text: textObj.text,
        style: TextStyle(
          color: textObj.color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white.withOpacity(0.7),
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          textObj.position.dx - (textPainter.width / 2),
          textObj.position.dy - (textPainter.height / 2),
        ),
      );
    }
  }

  // حساب الحجم المناسب للصورة
  Size _calculateFitSize(Size imageSize, Size canvasSize) {
    final double aspectRatio = imageSize.width / imageSize.height;

    if (canvasSize.width / canvasSize.height > aspectRatio) {
      return Size(canvasSize.height * aspectRatio, canvasSize.height);
    } else {
      return Size(canvasSize.width, canvasSize.width / aspectRatio);
    }
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) => true;
}
