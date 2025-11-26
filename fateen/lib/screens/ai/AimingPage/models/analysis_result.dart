class AnalysisResult {
  final String originalText;
  final String analysis;
  final DateTime timestamp;

  AnalysisResult({
    required this.originalText,
    required this.analysis,
    required this.timestamp,
  });

  // Factory constructor to create an AnalysisResult from JSON
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      originalText: json['originalText'] as String,
      analysis: json['analysis'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // Convert an AnalysisResult instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'originalText': originalText,
      'analysis': analysis,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
