import 'chat_message_model.dart';

class ChatSessionModel {
  String? id;
  String title;
  int timestamp;
  String topic;
  List<ChatMessageModel> messages;

  ChatSessionModel({
    this.id,
    required this.title,
    required this.timestamp,
    required this.topic,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'timestamp': timestamp,
      'topic': topic,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> messagesJson = json['messages'] ?? [];

    return ChatSessionModel(
      id: json['id'],
      title: json['title'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      topic: json['topic'] ?? 'general',
      messages: messagesJson
          .map((messageJson) => ChatMessageModel.fromJson(messageJson))
          .toList(),
    );
  }

  // إنشاء جلسة محادثة جديدة فارغة
  factory ChatSessionModel.createNew() {
    return ChatSessionModel(
      title: '',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      topic: 'general',
      messages: [],
    );
  }
}
