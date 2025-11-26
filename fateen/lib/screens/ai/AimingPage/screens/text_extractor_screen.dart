import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/text_extractor_controller.dart';
import '../components/text_extractor_components.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_dimensions.dart';

class TextExtractorScreen extends StatelessWidget {
  final String serverIp;
  final String serverPort;

  const TextExtractorScreen({
    Key? key,
    required this.serverIp,
    required this.serverPort,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TextExtractorController(),
      child: _TextExtractorScreenContent(
        serverIp: serverIp,
        serverPort: serverPort,
      ),
    );
  }
}

class _TextExtractorScreenContent extends StatelessWidget {
  final String serverIp;
  final String serverPort;

  const _TextExtractorScreenContent({
    Key? key,
    required this.serverIp,
    required this.serverPort,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TextExtractorController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.textExtractorTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عرض الصورة المختارة
            ImagePreviewContainer(image: controller.image),

            const SizedBox(height: AppDimensions.paddingLarge),

            // أزرار التحكم
            ControlButtonsRow(
              isLoading: controller.isLoading,
              isAnalyzingImage: controller.isAnalyzingImage,
              onSelectImage: () => controller.getImage(),
              onCaptureImage: () => controller.takePhoto(),
              onExtractText: () => controller.extractText(serverIp, serverPort),
              onAnalyzeImage: () =>
                  controller.analyzeImage(serverIp, serverPort),
            ),

            const SizedBox(height: AppDimensions.paddingLarge),

            // رسالة الخطأ إن وجدت
            ErrorMessageContainer(errorMessage: controller.errorMessage),

            const SizedBox(height: AppDimensions.paddingLarge),

            // مؤشر التحميل
            LoadingIndicator(
              isLoading: controller.isLoading,
              message: 'جاري استخراج النص...',
            ),

            // مؤشر تحليل الصورة
            LoadingIndicator(
              isLoading: controller.isAnalyzingImage,
              message: 'جاري تحليل الصورة باستخدام الذكاء الاصطناعي...',
            ),

            // عرض شرح الصورة
            if (controller.imageAnalysis.isNotEmpty &&
                !controller.isAnalyzingImage)
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingLarge),
                child: ResultContainer(
                  title: AppStrings.imageAnalysis,
                  content: controller.imageAnalysis,
                  titleColor: AppColors.secondaryColor,
                  containerColor: AppColors.lightPurple,
                  borderColor: AppColors.secondaryColor,
                  isPlayingAudio: controller.isPlayingAudio,
                  onCopy: () {
                    Clipboard.setData(
                        ClipboardData(text: controller.imageAnalysis));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.copyImageAnalysisSuccess),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  onSpeak: () {
                    if (controller.isPlayingAudio) {
                      controller.stopAudio();
                    } else {
                      controller.convertTextToSpeech(
                        controller.imageAnalysis,
                        serverIp,
                        serverPort,
                      );
                    }
                  },
                ),
              ),

            // عرض النص المستخرج
            if (controller.extractedText.isNotEmpty && !controller.isLoading)
              ResultContainer(
                title: AppStrings.extractedText,
                content: controller.extractedText,
                titleColor: AppColors.primaryColor,
                containerColor: AppColors.lightBlue,
                borderColor: AppColors.primaryColor,
                isPlayingAudio: controller.isPlayingAudio,
                onCopy: () {
                  Clipboard.setData(
                      ClipboardData(text: controller.extractedText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.copySuccess),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onSpeak: () {
                  if (controller.isPlayingAudio) {
                    controller.stopAudio();
                  } else {
                    controller.convertTextToSpeech(
                      controller.extractedText,
                      serverIp,
                      serverPort,
                    );
                  }
                },
              ),

            // إذا تم استخراج النص، نعرض زر تحليل النص
            if (controller.extractedText.isNotEmpty && !controller.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingMedium),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: controller.isAnalyzing
                        ? null
                        : () => controller.analyzeText(serverIp, serverPort),
                    icon: const Icon(Icons.psychology),
                    label: const Text(AppStrings.analyzeTextText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                    ),
                  ),
                ),
              ),

            // مؤشر تحليل النص
            LoadingIndicator(
              isLoading: controller.isAnalyzing,
              message: 'جاري تحليل النص باستخدام الذكاء الاصطناعي...',
            ),

            // عرض نتائج التحليل
            if (controller.analyzedText.isNotEmpty && !controller.isAnalyzing)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.paddingLarge),
                child: ResultContainer(
                  title: AppStrings.analyzedText,
                  content: controller.analyzedText,
                  titleColor: AppColors.accentColor,
                  containerColor: AppColors.lightGreen,
                  borderColor: AppColors.accentColor,
                  isPlayingAudio: controller.isPlayingAudio,
                  onCopy: () {
                    Clipboard.setData(
                        ClipboardData(text: controller.analyzedText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.copyAnalysisSuccess),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  onSpeak: () {
                    if (controller.isPlayingAudio) {
                      controller.stopAudio();
                    } else {
                      controller.convertTextToSpeech(
                        controller.analyzedText,
                        serverIp,
                        serverPort,
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
