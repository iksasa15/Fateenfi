class RecognizedObjectModel {
  final String name;
  final double confidence;
  final String? description;

  RecognizedObjectModel({
    required this.name,
    required this.confidence,
    this.description,
  });

  factory RecognizedObjectModel.fromJson(Map<String, dynamic> json) {
    return RecognizedObjectModel(
      name: json['name'] ?? 'غير معروف',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
      'description': description,
    };
  }
}
