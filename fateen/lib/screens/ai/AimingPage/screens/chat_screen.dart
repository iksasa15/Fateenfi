import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_controller.dart';
import '../components/chat_components.dart';
import '../constants/app_strings.dart';
import '../constants/app_dimensions.dart';

class ChatScreen extends StatelessWidget {
  final String serverIp;
  final String serverPort;

  const ChatScreen({Key? key, required this.serverIp, required this.serverPort})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatController(),
      child: _ChatScreenContent(
        serverIp: serverIp,
        serverPort: serverPort,
      ),
    );
  }
}

class _ChatScreenContent extends StatelessWidget {
  final String serverIp;
  final String serverPort;

  const _ChatScreenContent(
      {Key? key, required this.serverIp, required this.serverPort})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ChatController>(context);

    return Scaffold(
      appBar:
          AppBar(title: const Text(AppStrings.chatTitle), centerTitle: true),
      body: Column(
        children: [
          // عرض رسائل الخطأ
          if (controller.errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              color: Colors.red[100],
              width: double.infinity,
              child: Text(
                controller.errorMessage,
                style: TextStyle(color: Colors.red[800]),
              ),
            ),

          // عرض المحادثة
          Expanded(
            child: controller.messages.isEmpty
                ? const Center(
                    child: Text(
                      AppStrings.emptyChat,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return ChatBubble(
                        message: message,
                        onSpeakPressed: !message.isUser
                            ? () => controller.speakBotMessage(
                                message.text, serverIp, serverPort)
                            : null,
                      );
                    },
                  ),
          ),

          // مؤشر التحميل
          LoadingMessageIndicator(isLoading: controller.isLoading),

          // حقل إدخال الرسالة
          ChatInputBar(
            controller: controller.textController,
            isListening: controller.isListening,
            onSendPressed: () => controller.sendMessage(serverIp, serverPort),
            onListeningToggle: () {
              if (controller.isListening) {
                controller.stopListening();
              } else {
                if (!controller.speechEnabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('التعرف على الصوت غير متاح على هذا الجهاز'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                controller.startListening();
              }
            },
          ),
        ],
      ),
    );
  }
}
