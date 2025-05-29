import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  String text;
  bool isUser;
  int timestamp;
  String? fileAttachment;
  String? fileType;
  String? imageUrl;

  ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.fileAttachment,
    this.fileType,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp,
      'fileAttachment': fileAttachment,
      'fileType': fileType,
      'imageUrl': imageUrl,
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      fileAttachment: json['fileAttachment'],
      fileType: json['fileType'],
      imageUrl: json['imageUrl'],
    );
  }
}
