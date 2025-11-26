import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_dimensions.dart';

class ImagePreviewContainer extends StatelessWidget {
  final File? image;

  const ImagePreviewContainer({Key? key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.imagePreviewHeight,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(color: Colors.grey),
      ),
      child: image == null
          ? const Center(child: Text(AppStrings.noImageSelected))
          : ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusLarge),
              child: Image.file(image!, fit: BoxFit.contain),
            ),
    );
  }
}

class ControlButtonsRow extends StatelessWidget {
  final bool isLoading;
  final bool isAnalyzingImage;
  final VoidCallback onSelectImage;
  final VoidCallback onCaptureImage;
  final VoidCallback onExtractText;
  final VoidCallback onAnalyzeImage;

  const ControlButtonsRow({
    Key? key,
    required this.isLoading,
    required this.isAnalyzingImage,
    required this.onSelectImage,
    required this.onCaptureImage,
    required this.onExtractText,
    required this.onAnalyzeImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: onSelectImage,
          icon: const Icon(Icons.image),
          label: const Text(AppStrings.selectImageText),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onCaptureImage,
          icon: const Icon(Icons.camera_alt),
          label: const Text(AppStrings.captureImageText),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            backgroundColor: Colors.teal,
          ),
        ),
        ElevatedButton.icon(
          onPressed: isLoading ? null : onExtractText,
          icon: const Icon(Icons.text_fields),
          label: const Text(AppStrings.extractTextText),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: isAnalyzingImage ? null : onAnalyzeImage,
          icon: const Icon(Icons.image_search),
          label: const Text(AppStrings.analyzeImageText),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            backgroundColor: Colors.purple,
          ),
        ),
      ],
    );
  }
}

class ErrorMessageContainer extends StatelessWidget {
  final String errorMessage;

  const ErrorMessageContainer({Key? key, required this.errorMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.lightRed,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: AppColors.errorColor),
      ),
      child: Text(
        errorMessage,
        style: TextStyle(color: Colors.red[800]),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final String message;

  const LoadingIndicator(
      {Key? key, required this.isLoading, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}

class ResultContainer extends StatelessWidget {
  final String title;
  final String content;
  final Color titleColor;
  final Color containerColor;
  final Color borderColor;
  final bool isPlayingAudio;
  final VoidCallback onCopy;
  final VoidCallback onSpeak;

  const ResultContainer({
    Key? key,
    required this.title,
    required this.content,
    required this.titleColor,
    required this.containerColor,
    required this.borderColor,
    required this.isPlayingAudio,
    required this.onCopy,
    required this.onSpeak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: AppDimensions.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            IconButton(
              icon: Icon(
                isPlayingAudio ? Icons.stop : Icons.volume_up,
                color: titleColor,
              ),
              onPressed: onSpeak,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: AppDimensions.fontSizeMedium),
            textDirection: TextDirection.rtl,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy),
            label: const Text(AppStrings.copyText),
            style: ElevatedButton.styleFrom(
              backgroundColor: borderColor,
            ),
          ),
        ),
      ],
    );
  }
}
