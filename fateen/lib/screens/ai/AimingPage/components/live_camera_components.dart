import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_dimensions.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController? controller;
  final bool isAnalyzing;
  final bool autoSpeak;
  final bool isSingleAnalyzing;

  const CameraPreviewWidget({
    Key? key,
    required this.controller,
    required this.isAnalyzing,
    required this.autoSpeak,
    required this.isSingleAnalyzing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // عرض الكاميرا
        CameraPreview(controller!),

        // مؤشر التحليل
        if (isAnalyzing)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusXL),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: AppDimensions.paddingSmall),
                  Text(
                    AppStrings.continuousAnalysis,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

        // مؤشر الصوت التلقائي
        if (autoSpeak)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusXL),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 15,
                  ),
                  SizedBox(width: AppDimensions.paddingSmall),
                  Text(
                    AppStrings.autoAudioOn,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

        // مؤشر التقاط صورة واحدة
        if (isSingleAnalyzing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppStrings.analyzing,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppDimensions.fontSizeMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AnalysisResultPanel extends StatelessWidget {
  final String analysisResult;
  final bool isPlayingAudio;
  final bool autoSpeak;
  final Function() onCopy;
  final Function() onSpeak;
  final Function() onAutoSpeakToggle;

  const AnalysisResultPanel({
    Key? key,
    required this.analysisResult,
    required this.isPlayingAudio,
    required this.autoSpeak,
    required this.onCopy,
    required this.onSpeak,
    required this.onAutoSpeakToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان نتيجة التحليل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.analysisResult,
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر التحدث التلقائي
                  if (analysisResult.isNotEmpty && !isPlayingAudio)
                    IconButton(
                      icon: Icon(
                        autoSpeak
                            ? Icons.record_voice_over
                            : Icons.voice_over_off,
                        color: autoSpeak ? Colors.green : Colors.grey,
                      ),
                      onPressed: onAutoSpeakToggle,
                      tooltip: autoSpeak
                          ? 'إيقاف الشرح الصوتي التلقائي'
                          : 'تفعيل الشرح الصوتي التلقائي',
                    ),

                  // زر نسخ النتيجة
                  if (analysisResult.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: AppColors.secondaryColor,
                      ),
                      onPressed: onCopy,
                    ),

                  // زر الاستماع للنتيجة
                  if (analysisResult.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        isPlayingAudio ? Icons.stop : Icons.volume_up,
                        color: AppColors.secondaryColor,
                      ),
                      onPressed: onSpeak,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          // محتوى التحليل
          Expanded(
            child: SingleChildScrollView(
              child: analysisResult.isEmpty
                  ? const Center(
                      child: Text(
                        AppStrings.captureHint,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingMedium),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium),
                        border: Border.all(color: AppColors.secondaryColor),
                      ),
                      child: Text(
                        analysisResult,
                        style: const TextStyle(
                            fontSize: AppDimensions.fontSizeMedium),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorMessageBanner extends StatelessWidget {
  final String errorMessage;

  const ErrorMessageBanner({Key? key, required this.errorMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      width: double.infinity,
      color: Colors.red[100],
      child: Text(
        errorMessage,
        style: TextStyle(color: Colors.red[800]),
      ),
    );
  }
}
