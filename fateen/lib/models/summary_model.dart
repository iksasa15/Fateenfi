class SummaryModel {
  final String title;
  final String mainIdea;
  final List<String> keyPoints;
  final String conclusion;

  SummaryModel({
    required this.title,
    required this.mainIdea,
    required this.keyPoints,
    required this.conclusion,
  });

  // إنشاء ملخص فارغ
  factory SummaryModel.empty() {
    return SummaryModel(
      title: "",
      mainIdea: "",
      keyPoints: [],
      conclusion: "",
    );
  }

  // تحويل من JSON
  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      title: json['title'] ?? '',
      mainIdea: json['main_idea'] ?? '',
      keyPoints: List<String>.from(json['key_points'] ?? []),
      conclusion: json['conclusion'] ?? '',
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'main_idea': mainIdea,
      'key_points': keyPoints,
      'conclusion': conclusion,
    };
  }

  // التحقق من كون الملخص فارغًا
  bool get isEmpty =>
      title.isEmpty &&
      mainIdea.isEmpty &&
      keyPoints.isEmpty &&
      conclusion.isEmpty;

  // عكس التحقق من كون الملخص فارغًا
  bool get isNotEmpty => !isEmpty;
}
