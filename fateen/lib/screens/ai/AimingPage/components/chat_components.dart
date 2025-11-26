import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onSpeakPressed;

  const ChatBubble({Key? key, required this.message, this.onSpeakPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall,
            horizontal: AppDimensions.paddingSmall),
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width *
              AppDimensions.chatBubbleMaxWidth,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.userBubbleColor : AppColors.botBubbleColor,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textPrimaryColor,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.time),
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeSmall,
                    color:
                        isUser ? Colors.white70 : AppColors.textSecondaryColor,
                  ),
                ),
                if (!isUser && onSpeakPressed != null)
                  IconButton(
                    icon: Icon(
                      Icons.volume_up,
                      size: AppDimensions.iconSizeSmall,
                      color: isUser ? Colors.white70 : AppColors.primaryColor,
                    ),
                    onPressed: onSpeakPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'استماع للرد',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onSendPressed;
  final VoidCallback onListeningToggle;

  const ChatInputBar({
    Key? key,
    required this.controller,
    required this.isListening,
    required this.onSendPressed,
    required this.onListeningToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingXS),
      child: Row(
        children: [
          // زر الميكروفون
          IconButton(
            onPressed: onListeningToggle,
            icon: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: isListening ? Colors.red : null,
            ),
            tooltip: isListening ? 'إيقاف التسجيل' : 'تسجيل صوتي',
          ),

          // حقل إدخال النص
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSendPressed(),
            ),
          ),

          // زر إرسال الرسالة
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primaryColor),
            onPressed: onSendPressed,
            tooltip: 'إرسال',
          ),
        ],
      ),
    );
  }
}

class LoadingMessageIndicator extends StatelessWidget {
  final bool isLoading;

  const LoadingMessageIndicator({
    Key? key,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.all(AppDimensions.paddingSmall),
      child: LinearProgressIndicator(),
    );
  }
}
