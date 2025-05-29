import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/translation_strings.dart';
import 'controllers/language_controller.dart';
import 'controllers/mode_controller.dart';
import 'controllers/translation_controller.dart';
import 'controllers/api_key_controller.dart';
import 'components/translate_header_component.dart';
import 'components/mode_selection_tab.dart';
import 'components/language_selector.dart';
import 'components/text_input_field.dart';
import 'components/file_selector.dart';
import 'components/translation_result.dart';
import 'components/loading_view.dart';
import 'components/empty_view.dart';
import 'package:open_file/open_file.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({Key? key}) : super(key: key);

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  // إنشاء المتحكمات
  final _languageController = LanguageController();
  final _modeController = ModeController();
  final _translationController = TranslationController();
  final _apiKeyController = ApiKeyController();
  final _scrollController = ScrollController();

  String? _errorMessage;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // معالجة ضغط زر الترجمة
  Future<void> _handleTranslatePressed() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      // تمرير المتحكمات حسب وضع الترجمة
      if (_modeController.isTextMode) {
        await _translationController.translateInputText(
          sourceLanguage: _languageController.selectedSourceLanguage,
          targetLanguage: _languageController.selectedTargetLanguage,
        );
      } else {
        // تحسين إدارة الأخطاء هنا
        bool success = false;
        try {
          success = await _translationController.pickAndTranslateFile(
            sourceLanguage: _languageController.selectedSourceLanguage,
            targetLanguage: _languageController.selectedTargetLanguage,
            useDeeplFormatting: false, // تعيين إلى false دائماً بعد إزالة DeepL
            context: context,
          );
        } catch (e) {
          debugPrint("خطأ أثناء ترجمة الملف: $e");
          rethrow; // إعادة رمي الاستثناء للتعامل معه في كتلة catch الخارجية
        }

        // فحص بعد الانتهاء أن كل شيء على ما يرام
        if (success && _translationController.translatedFilePath != null) {
          debugPrint("ملف مترجم: ${_translationController.translatedFilePath}");

          // تأكد من أن الملف موجود بالفعل
          if (!kIsWeb) {
            try {
              final fileExists =
                  await File(_translationController.translatedFilePath!)
                      .exists();
              debugPrint("هل الملف موجود؟ $fileExists");

              if (!fileExists) {
                throw Exception(
                    "لم يتم العثور على الملف المترجم رغم إتمام العملية");
              }
            } catch (e) {
              debugPrint("خطأ أثناء التحقق من وجود الملف: $e");
            }
          }

          // إضافة تأخير أطول لضمان اكتمال العملية
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            _showTranslationSuccessDialog();
          }
        }
      }

      // التمرير إلى أسفل لعرض النتيجة
      _scrollToBottom();
    } catch (e) {
      // تحسين رسالة الخطأ وتسجيلها
      final errorMsg = e.toString();
      debugPrint("خطأ مفصل: $errorMsg");

      setState(() {
        _errorMessage = errorMsg;
      });

      // إظهار رسالة خطأ معالجة بشكل أفضل
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "حدث خطأ: " +
                  (errorMsg.length > 100
                      ? errorMsg.substring(0, 100) + "..."
                      : errorMsg),
              style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'تفاصيل',
              onPressed: () {
                _showErrorDetailsDialog(errorMsg);
              },
            ),
          ),
        );
      }
    }
  }

  // عرض حوار نجاح الترجمة
  void _showTranslationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'تمت الترجمة بنجاح',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Color(0xFF221291),
            fontFamily: 'SYMBIOAR+LT',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تم ترجمة المستند بنجاح. ماذا تريد أن تفعل بالملف المترجم؟',
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
            ),
            const SizedBox(height: 8),
            if (_translationController.translatedFilePath != null)
              Text(
                'مسار الملف: ${_translationController.translatedFilePath}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: 13,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'إغلاق',
              style: TextStyle(fontFamily: 'SYMBIOAR+LT', color: Colors.grey),
            ),
          ),
          if (_translationController.translatedFilePath != null && !kIsWeb)
            ElevatedButton.icon(
              icon: const Icon(Icons.file_open),
              label: const Text(
                'فتح الملف',
                style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF221291),
              ),
              onPressed: () async {
                try {
                  await _openFile(_translationController.translatedFilePath!);
                  if (mounted) Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('حدث خطأ: $e')),
                  );
                }
              },
            ),
          if (_translationController.translatedFilePath != null &&
              !kIsWeb &&
              (Platform.isAndroid || Platform.isIOS))
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text(
                'مشاركة',
                style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                try {
                  await _translationController.shareTranslatedText();
                  if (mounted) Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('حدث خطأ: $e')),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  // عرض تفاصيل الخطأ
  void _showErrorDetailsDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل الخطأ', textAlign: TextAlign.right),
        content: SingleChildScrollView(
          child: Text(
            errorMessage,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'SYMBIOAR+LT'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // فتح الملف
  Future<void> _openFile(String filePath) async {
    try {
      debugPrint("محاولة فتح الملف: $filePath");

      // أولاً، تأكد من وجود الملف
      final fileExists = await File(filePath).exists();
      if (!fileExists) {
        throw Exception("الملف غير موجود: $filePath");
      }

      debugPrint("الملف موجود، جاري فتحه...");

      // محاولة فتح الملف باستخدام open_file
      final result = await OpenFile.open(filePath);

      debugPrint("نتيجة فتح الملف: ${result.type} - ${result.message}");

      if (result.type != ResultType.done) {
        // محاولة مشاركة الملف كحل بديل
        debugPrint("فشل فتح الملف، جاري محاولة المشاركة...");
        await _translationController.shareTranslatedText();
      }
    } catch (e) {
      debugPrint("استثناء عند فتح الملف: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ عند فتح الملف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // محاولة مشاركة الملف كحل بديل
      try {
        await _translationController.shareTranslatedText();
      } catch (shareError) {
        debugPrint("فشل أيضاً في مشاركة الملف: $shareError");
      }
    }
  }

  // التمرير إلى أسفل الصفحة
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // عرض رسالة حول الترجمة المحلية
  void _showApiKeyDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'يستخدم التطبيق ترجمة محلية على الجهاز، لا حاجة لمفتاح API.',
          style: TextStyle(fontFamily: 'SYMBIOAR+LT'),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // طلب الأذونات المطلوبة للتطبيق
  Future<void> _requestRequiredPermissions() async {
    // تعديل: استخدام مباشر لـ checkAndRequestPermissions
    if (!kIsWeb && mounted) {
      await _translationController.checkAndRequestPermissions(context);
    }
  }

  @override
  void initState() {
    super.initState();
    // طلب الأذونات عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestRequiredPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _languageController),
        ChangeNotifierProvider.value(value: _modeController),
        ChangeNotifierProvider.value(value: _translationController),
        ChangeNotifierProvider.value(value: _apiKeyController),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFFDFDFF),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // استخدام مكون الهيدر المطابق لتصميم وقت المذاكرة
                TranslateHeaderComponent(
                  onSettingsPressed: _showApiKeyDialog,
                ),

                // محتوى الصفحة
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // قسم أزرار اختيار وضع الترجمة (نص/ملف)
                        Consumer<ModeController>(
                          builder: (context, modeController, _) {
                            return _buildModeSelectionCard(modeController);
                          },
                        ),
                        const SizedBox(height: 14),

                        // قسم اختيار اللغات
                        Consumer3<LanguageController, ModeController,
                            TranslationController>(
                          builder: (context, languageController, modeController,
                              translationController, _) {
                            return _buildLanguageSelectionCard(
                                languageController,
                                modeController,
                                translationController);
                          },
                        ),
                        const SizedBox(height: 14),

                        // عرض رسالة الخطأ إذا وجدت
                        if (_errorMessage != null)
                          Card(
                            elevation: 0,
                            color: Colors.red[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.red[200]!,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red[700]),
                                      const SizedBox(width: 8),
                                      Text(
                                        'خطأ في الترجمة',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'SYMBIOAR+LT',
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _errorMessage!.length > 200
                                        ? _errorMessage!.substring(0, 200) +
                                            '...'
                                        : _errorMessage!,
                                    style: const TextStyle(
                                        fontFamily: 'SYMBIOAR+LT'),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () {
                                        _showErrorDetailsDialog(_errorMessage!);
                                      },
                                      child: const Text('عرض التفاصيل'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // عرض نتائج الترجمة
                        Consumer<TranslationController>(
                          builder: (context, translationController, _) {
                            // عرض واجهة التحميل إذا كان التطبيق في حالة التحميل
                            if (translationController.isLoading) {
                              return _buildLoadingCard(translationController);
                            }

                            // عرض واجهة فارغة إذا لم تبدأ الترجمة بعد
                            if (!translationController.hasSourceText &&
                                _errorMessage == null) {
                              return Consumer<ModeController>(
                                builder: (context, modeController, _) {
                                  return _buildEmptyStateCard(modeController);
                                },
                              );
                            }

                            // عرض نتيجة الترجمة (إلا إذا كان هناك خطأ)
                            if (translationController.hasSourceText &&
                                _errorMessage == null) {
                              return _buildTranslationResultCard(
                                  translationController);
                            }

                            // في حالة وجود خطأ ولكن ليس هناك نص مصدر، نعرض رسالة فارغة
                            return const SizedBox.shrink();
                          },
                        ),

                        // مساحة إضافية في نهاية الصفحة
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء قسم اختيار وضع الترجمة - معدل ليظهر مربع بزوايا متناسق مع باقي الصفحة
  Widget _buildModeSelectionCard(ModeController modeController) {
    return Center(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFE3E0F8),
            width: 1,
          ),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ModeSelectionTab(
            currentMode: modeController.currentMode,
            onModeChanged: modeController.setMode,
          ),
        ),
      ),
    );
  }

  // بناء قسم اختيار اللغات
  Widget _buildLanguageSelectionCard(
    LanguageController languageController,
    ModeController modeController,
    TranslationController translationController,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE3E0F8),
          width: 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // محدد اللغات
            LanguageSelector(
              selectedSourceLanguage: languageController.selectedSourceLanguage,
              selectedTargetLanguage: languageController.selectedTargetLanguage,
              onSourceLanguageChanged: languageController.setSourceLanguage,
              onTargetLanguageChanged: languageController.setTargetLanguage,
              onSwapLanguages: languageController.swapLanguages,
              availableLanguages: languageController.availableLanguages,
            ),
            const SizedBox(height: 20),

            // وضع ترجمة النصوص
            if (modeController.isTextMode)
              TextInputField(
                controller: translationController.textController,
                isLoading: translationController.isLoading,
                onTranslate: _handleTranslatePressed,
              ),

            // وضع ترجمة الملفات
            if (modeController.isFileMode)
              FileSelector(
                isLoading: translationController.isLoading,
                fileName: translationController.fileName,
                onSelectFile: () => _handleTranslatePressed(),
              ),
          ],
        ),
      ),
    );
  }

  // بناء قسم التحميل
  Widget _buildLoadingCard(TranslationController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE3E0F8),
          width: 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LoadingView(
          progressValue: controller.progressValue,
          message: controller.progressMessage,
        ),
      ),
    );
  }

  // بناء قسم الحالة الفارغة
  Widget _buildEmptyStateCard(ModeController modeController) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE3E0F8),
          width: 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: EmptyView(
          currentMode: modeController.currentMode,
        ),
      ),
    );
  }

  // بناء قسم نتيجة الترجمة
  Widget _buildTranslationResultCard(TranslationController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE3E0F8),
          width: 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان النتيجة
            const Text(
              'نتيجة الترجمة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF221291),
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),

            // مكون نتيجة الترجمة
            TranslationResultWidget(
              translatedText: controller.translatedText,
              isTranslationSuccessful: controller.isTranslationSuccessful,
              isFileMode: _modeController.isFileMode,
              hasTranslatedFile: controller.translatedFilePath != null,
              onCopy: controller.copyTranslatedText,
              onShare: controller.shareTranslatedText,
              onDownload: _modeController.isFileMode &&
                      controller.translatedFilePath != null
                  ? () {
                      // عرض نافذة تأكيد عند الضغط على زر التنزيل
                      _showTranslationSuccessDialog();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
