// course_files_screen.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../models/course.dart';
import '../../../../models/app_file.dart';
import '../components/course_add_components.dart';
import '../constants/course_files_constants.dart';
import '../controllers/course_files_controller.dart';
import '../../../editors/pdf_editor_screen/pdf_editor_screen.dart';
import '../../../editors/image_editor_screen/image_editor_screen.dart';

class CourseFilesScreen extends StatefulWidget {
  final Course course;
  final Function? onFilesUpdated;

  const CourseFilesScreen({
    Key? key,
    required this.course,
    this.onFilesUpdated,
  }) : super(key: key);

  @override
  _CourseFilesScreenState createState() => _CourseFilesScreenState();
}

class _CourseFilesScreenState extends State<CourseFilesScreen> {
  late CourseFilesController _controller;
  bool _isLoading = false;

  // ألوان التطبيق الموحدة
  final Color kDarkPurple = const Color(0xFF4338CA);
  final Color kMediumPurple = const Color(0xFF6366F1);
  final Color kLightPurple = const Color(0xFFF5F3FF);
  final Color kAccentColor = const Color(0xFFEC4899);
  final Color kBackgroundColor = const Color(0xFFFDFDFF);
  final Color kShadowColor = const Color(0x0D221291);
  final Color kTextColor = const Color(0xFF374151);
  final Color kHintColor = const Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    _controller = CourseFilesController();
  }

  // استعراض ملف
  void _viewFile(AppFile file) {
    if (file.filePath == null || file.filePath!.isEmpty) {
      _showErrorSnackBar(CourseFilesConstants.noPathError);
      return;
    }

    // تنفيذ فتح الملف حسب نوعه
    if (file.fileType.contains('PDF')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PDFEditorScreen(
            filePath: file.filePath!,
            onSaved: (newPath) {
              // تحديث مسار الملف إذا تم تغييره
              _controller.updateFilePath(widget.course, file, newPath);
              // تحديث الواجهة وإخطار الشاشة الأم بالتحديث
              setState(() {});
              if (widget.onFilesUpdated != null) {
                widget.onFilesUpdated!();
              }
            },
          ),
        ),
      );
    } else if (file.fileType.contains('JPG') ||
        file.fileType.contains('PNG') ||
        file.fileType.contains('IMAGE')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageEditorScreen(
            imagePath: file.filePath!,
            onSaved: (newPath) {
              // تحديث مسار الملف إذا تم تغييره
              _controller.updateFilePath(widget.course, file, newPath);
              // تحديث الواجهة وإخطار الشاشة الأم بالتحديث
              setState(() {});
              if (widget.onFilesUpdated != null) {
                widget.onFilesUpdated!();
              }
            },
          ),
        ),
      );
    } else {
      // لأنواع الملفات الأخرى التي لا يوجد لها عارض خاص
      _showInfoSnackBar("جاري فتح الملف باستخدام عارض النظام...");
      // يمكن إضافة منطق فتح الملف باستخدام عارض النظام هنا
    }
  }

  // تعديل ملف
  void _editFile(AppFile file) {
    if (file.filePath == null || file.filePath!.isEmpty) {
      _showErrorSnackBar(CourseFilesConstants.noPathError);
      return;
    }

    // الانتقال إلى محرر الملف المناسب حسب النوع
    if (file.fileType.contains('PDF')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PDFEditorScreen(
            filePath: file.filePath!,
            onSaved: (newPath) {
              // تحديث مسار الملف بعد التعديل
              _controller.updateFilePath(widget.course, file, newPath);
              // تحديث الواجهة وإخطار الشاشة الأم بالتحديث
              setState(() {});
              if (widget.onFilesUpdated != null) {
                widget.onFilesUpdated!();
              }

              // عرض رسالة نجاح
              _showSuccessSnackBar(CourseFilesConstants.editSavedSuccess);
            },
          ),
        ),
      );
    } else if (file.fileType.contains('JPG') ||
        file.fileType.contains('PNG') ||
        file.fileType.contains('IMAGE')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageEditorScreen(
            imagePath: file.filePath!,
            onSaved: (newPath) {
              // تحديث مسار الملف بعد التعديل
              _controller.updateFilePath(widget.course, file, newPath);
              // تحديث الواجهة وإخطار الشاشة الأم بالتحديث
              setState(() {});
              if (widget.onFilesUpdated != null) {
                widget.onFilesUpdated!();
              }

              // عرض رسالة نجاح
              _showSuccessSnackBar(CourseFilesConstants.editSavedSuccess);
            },
          ),
        ),
      );
    } else {
      _showErrorSnackBar(CourseFilesConstants.unsupportedFileError);
    }
  }

  // حذف ملف
  void _deleteFile(AppFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأكيد الحذف',
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontWeight: FontWeight.bold,
            fontSize: 16, // تصغير حجم الخط
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف الملف "${file.fileName}"؟',
          style: const TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontSize: 14, // تصغير حجم الخط
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: kHintColor,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _isLoading = true;
              });

              final success = await _controller.deleteFile(widget.course, file);

              setState(() {
                _isLoading = false;
              });

              if (success && mounted) {
                _showSuccessSnackBar('تم حذف الملف "${file.fileName}" بنجاح');

                if (widget.onFilesUpdated != null) {
                  widget.onFilesUpdated!();
                }
              }
            },
            child: Text(
              'حذف',
              style: TextStyle(
                color: kAccentColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }

  // إضافة ملف جديد
  Future<void> _addNewFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _controller.pickFile();
      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;

        // إنشاء كائن ملف جديد
        final newFile = AppFile(
          id: 'file_${DateTime.now().millisecondsSinceEpoch}',
          fileName: platformFile.name,
          fileType: platformFile.extension?.toUpperCase() ?? 'UNKNOWN',
          fileSize: platformFile.size ~/ 1024,
          filePath: platformFile.path,
          createdAt: DateTime.now(),
        );

        final success = await _controller.addFile(widget.course, newFile);

        if (success && mounted) {
          _showSuccessSnackBar(
            CourseFilesConstants.fileAddedSuccess
                .replaceAll("%s", newFile.fileName),
          );

          if (widget.onFilesUpdated != null) {
            widget.onFilesUpdated!();
          }
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // بناء بطاقة ملف بتصميم متناسق مع صفحة المقررات
  Widget _buildFileCard(AppFile file) {
    // تحديد أيقونة الملف بناءً على نوعه
    IconData fileIcon;
    Color iconColor;

    if (file.fileType.contains('PDF')) {
      fileIcon = Icons.picture_as_pdf_outlined;
      iconColor = Colors.red;
    } else if (file.fileType.contains('DOC')) {
      fileIcon = Icons.description_outlined;
      iconColor = Colors.blue;
    } else if (file.fileType.contains('XLS')) {
      fileIcon = Icons.table_chart_outlined;
      iconColor = Colors.green;
    } else if (file.fileType.contains('PPT')) {
      fileIcon = Icons.slideshow_outlined;
      iconColor = Colors.orange;
    } else if (file.fileType.contains('JPG') ||
        file.fileType.contains('PNG') ||
        file.fileType.contains('JPEG') ||
        file.fileType.contains('IMAGE')) {
      fileIcon = Icons.image_outlined;
      iconColor = Colors.purple;
    } else {
      fileIcon = Icons.insert_drive_file_outlined;
      iconColor = Colors.grey;
    }

    // اختصار اسم الملف إذا كان طويلاً
    String displayFileName = file.fileName;
    if (displayFileName.length > 20) {
      // الحصول على امتداد الملف
      final dotIndex = displayFileName.lastIndexOf('.');
      String extension = '';
      String baseName = displayFileName;

      if (dotIndex != -1 && dotIndex > 0) {
        extension = displayFileName.substring(dotIndex);
        baseName = displayFileName.substring(0, dotIndex);
      }

      // اختصار الاسم الأساسي مع الحفاظ على الامتداد
      if (baseName.length > 17) {
        // 17 حرف + 3 نقاط "..." = 20 حرف
        displayFileName = baseName.substring(0, 17) + "..." + extension;
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8), // تقليل المساحة
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14), // تقليل نصف القطر
        boxShadow: [
          BoxShadow(
            color: kShadowColor,
            blurRadius: 6, // تقليل التأثير
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14), // تقليل نصف القطر
        child: InkWell(
          borderRadius: BorderRadius.circular(14), // تقليل نصف القطر
          onTap: () => _viewFile(file),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // تقليل المساحة
            child: Row(
              children: [
                // أيقونة الملف في حاوية دائرية
                Container(
                  width: 40, // تصغير الحجم
                  height: 40, // تصغير الحجم
                  decoration: BoxDecoration(
                    color: kLightPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      fileIcon,
                      size: 20, // تصغير حجم الأيقونة
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10), // تقليل المساحة

                // معلومات الملف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // اسم الملف
                      Text(
                        displayFileName,
                        style: TextStyle(
                          fontSize: 14, // تصغير حجم الخط
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2), // تقليل المساحة

                      // معلومات الملف
                      Row(
                        children: [
                          // نوع الملف
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2), // تقليل المساحة
                            decoration: BoxDecoration(
                              color: kLightPurple,
                              borderRadius:
                                  BorderRadius.circular(4), // تقليل نصف القطر
                            ),
                            child: Text(
                              file.fileType,
                              style: TextStyle(
                                fontSize: 10, // تصغير حجم الخط
                                fontWeight: FontWeight.bold,
                                color: kDarkPurple,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),
                          const SizedBox(width: 6), // تقليل المساحة

                          // حجم الملف
                          Text(
                            "${file.fileSize} KB",
                            style: TextStyle(
                              fontSize: 10, // تصغير حجم الخط
                              color: kHintColor,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // أزرار الإجراءات
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // زر التعديل
                    _buildCircularActionButton(
                      icon: Icons.edit_outlined,
                      onTap: () => _editFile(file),
                    ),

                    // زر الحذف
                    _buildCircularActionButton(
                      icon: Icons.delete_outline,
                      color: kAccentColor,
                      onTap: () => _deleteFile(file),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء زر دائري
  Widget _buildCircularActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 34, // تصغير الحجم
        height: 34, // تصغير الحجم
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: color ?? kDarkPurple,
            size: 18, // تصغير حجم الأيقونة
          ),
        ),
      ),
    );
  }

  // بناء شريط العنوان بتصميم متناسق مع صفحة المقررات
  Widget _buildToolbar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الصف الأول: زر الرجوع والعنوان
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // زر الرجوع
            _buildBackButton(),

            // العنوان
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6), // تقليل المساحة
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), // تقليل نصف القطر
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1.0,
                ),
              ),
              child: Text(
                CourseFilesConstants.filesTabTitle,
                style: TextStyle(
                  fontSize: 14, // تصغير حجم الخط
                  fontWeight: FontWeight.bold,
                  color: kDarkPurple,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ),

            // مساحة فارغة للمحاذاة
            SizedBox(width: 34), // تقليل المساحة
          ],
        ),
        const SizedBox(height: 12), // تقليل المساحة

        // قسم المعلومات
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10), // تقليل المساحة
          decoration: BoxDecoration(
            color: kLightPurple,
            borderRadius: BorderRadius.circular(10), // تقليل نصف القطر
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: kDarkPurple,
                size: 16, // تصغير حجم الأيقونة
              ),
              const SizedBox(width: 8), // تقليل المساحة
              Expanded(
                child: Text(
                  "قم بإدارة ملفات مقرر ${widget.course.courseName} من هنا",
                  style: TextStyle(
                    fontSize: 12, // تصغير حجم الخط
                    fontWeight: FontWeight.w500,
                    color: kTextColor,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), // تقليل المساحة
      ],
    );
  }

  // بناء زر الرجوع
  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(10), // تقليل نصف القطر
      child: Container(
        width: 34, // تصغير الحجم
        height: 34, // تصغير الحجم
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // تقليل نصف القطر
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.0,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.close,
            color: kDarkPurple,
            size: 18, // تصغير حجم الأيقونة
          ),
        ),
      ),
    );
  }

  // بناء زر إضافة ملف متوافق مع الألوان الموحدة للتطبيق
  Widget _buildAddFileButton() {
    return Container(
      width: double.infinity,
      height: 42, // تقليل الارتفاع
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // تقليل نصف القطر
        boxShadow: [
          BoxShadow(
            color: kDarkPurple.withOpacity(0.2), // تقليل الظل
            blurRadius: 6, // تقليل التأثير
            offset: const Offset(0, 2), // تقليل الإزاحة
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _addNewFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkPurple,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // تقليل نصف القطر
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14), // تقليل المساحة
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 18, // تصغير الحجم
                  height: 18, // تصغير الحجم
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0, // تقليل عرض الخط
                  ),
                )
              else
                const Icon(
                  Icons.add,
                  size: 16, // تصغير حجم الأيقونة
                ),
              const SizedBox(width: 6), // تقليل المساحة
              Text(
                _isLoading
                    ? 'جاري التحميل...'
                    : CourseFilesConstants.addFileButton,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13, // تصغير حجم الخط
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // عرض رسالة عدم وجود ملفات في المنتصف
  Widget _buildEmptyFilesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, // تصغير الحجم
            height: 100, // تصغير الحجم
            decoration: BoxDecoration(
              color: kLightPurple,
              borderRadius: BorderRadius.circular(16), // تقليل نصف القطر
            ),
            child: Icon(
              Icons.folder_outlined,
              size: 48, // تصغير حجم الأيقونة
              color: kMediumPurple,
            ),
          ),
          const SizedBox(height: 16), // تقليل المساحة
          Text(
            "لا توجد ملفات لهذا المقرر بعد",
            style: TextStyle(
              fontSize: 16, // تصغير حجم الخط
              fontWeight: FontWeight.bold,
              color: kDarkPurple,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 6), // تقليل المساحة
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24), // تقليل المساحة
            child: Text(
              "قم بإضافة ملفات للمقرر من خلال الزر أدناه",
              style: TextStyle(
                fontSize: 13, // تصغير حجم الخط
                color: kHintColor,
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // عرض رسالة خطأ
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
        ),
        backgroundColor: kAccentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // تقليل نصف القطر
        ),
      ),
    );
  }

  // عرض رسالة نجاح
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // تقليل نصف القطر
        ),
      ),
    );
  }

  // عرض رسالة معلومات
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
        ),
        backgroundColor: kMediumPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // تقليل نصف القطر
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // تحديد أفضل موضع للنافذة
    final screenHeight = MediaQuery.of(context).size.height;
    final double topInset =
        screenHeight * 0.15; // ترك مساحة علوية بنسبة 15% من ارتفاع الشاشة

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: topInset, // وضع النافذة في موضع أفضل من الأعلى
        bottom: 16,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.65, // تقليل الارتفاع الأقصى من 0.75 إلى 0.65
        ),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(16), // تقليل نصف القطر
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // تقليل شفافية الظل
              blurRadius: 12, // تقليل التأثير
              spreadRadius: 0,
              offset: const Offset(0, 3), // تقليل الإزاحة
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16), // تقليل نصف القطر
          child: Column(
            children: [
              // علامة السحب
              Padding(
                padding: const EdgeInsets.only(top: 8), // تقليل المساحة
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4, // تقليل سمك علامة السحب
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2), // تقليل نصف القطر
                    ),
                  ),
                ),
              ),

              // المحتوى الرئيسي
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // تقليل المساحة
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // شريط العنوان بتصميم متناسق مع صفحة المقررات
                      _buildToolbar(),

                      // محتوى الملفات أو رسالة فارغة
                      Expanded(
                        child: widget.course.files.isEmpty
                            ? _buildEmptyFilesView()
                            : ListView.builder(
                                itemCount: widget.course.files.length,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  final file = widget.course.files[index];
                                  return _buildFileCard(file);
                                },
                              ),
                      ),

                      // زر إضافة ملف جديد
                      const SizedBox(height: 12), // تقليل المساحة
                      _buildAddFileButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
