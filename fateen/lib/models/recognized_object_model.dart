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
      name: json['name'] ?? 'عنصر غير معروف',
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : 0.0,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'confidence': confidence,
        'description': description,
      };
}
