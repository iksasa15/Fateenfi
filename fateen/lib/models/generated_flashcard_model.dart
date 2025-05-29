// generated_flashcard_model.dart
class GeneratedFlashcardModel {
  final String front; // الوجه الأمامي للبطاقة (السؤال/العنوان)
  final String back; // الوجه الخلفي للبطاقة (الجواب/الشرح)
  bool isKnown; // هل البطاقة معروفة للمستخدم

  GeneratedFlashcardModel({
    required this.front,
    required this.back,
    this.isKnown = false,
  });

  // تحويل من JSON
  factory GeneratedFlashcardModel.fromJson(Map<String, dynamic> json) {
    return GeneratedFlashcardModel(
      front: json['front'] ?? '',
      back: json['back'] ?? '',
      isKnown: json['isKnown'] ?? false,
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'front': front,
      'back': back,
      'isKnown': isKnown,
    };
  }
}
