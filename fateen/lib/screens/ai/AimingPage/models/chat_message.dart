class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});

  // Factory constructor to create a ChatMessage from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      time: DateTime.parse(json['time'] as String),
    );
  }

  // Convert a ChatMessage instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'time': time.toIso8601String(),
    };
  }
}
