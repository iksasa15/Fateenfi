import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String category;
  final Color color;
  final DateTime timestamp;
  final bool isFavorite;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.color,
    required this.timestamp,
    required this.isFavorite,
  });

  // إنشاء نموذج من Map (Firestore)
  factory Note.fromMap(Map<String, dynamic> map, String docId) {
    final Timestamp? timestamp = map['timestamp'] as Timestamp?;

    return Note(
      id: docId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'عام',
      color: Color(map['color'] ?? 0xFFF6F4FF),
      timestamp: timestamp?.toDate() ?? DateTime.now(),
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  // تحويل النموذج إلى Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'color': color.value,
      'isFavorite': isFavorite,
    };
  }

  // إنشاء نسخة جديدة مع تغييرات
  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    Color? color,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      color: color ?? this.color,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
