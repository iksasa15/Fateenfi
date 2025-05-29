class DrawingFile {
  final String id;
  final String name;
  final DateTime creationDate;
  final DateTime lastModified;
  final String? thumbnailPath;
  final String filePath;

  DrawingFile({
    required this.id,
    required this.name,
    required this.creationDate,
    required this.lastModified,
    this.thumbnailPath,
    required this.filePath,
  });

  /// تحويل ملف الرسم إلى map للتخزين
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creationDate': creationDate.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'thumbnailPath': thumbnailPath,
      'filePath': filePath,
    };
  }

  /// إنشاء ملف رسم من map
  factory DrawingFile.fromJson(Map<String, dynamic> json) {
    return DrawingFile(
      id: json['id'] as String,
      name: json['name'] as String,
      creationDate: DateTime.parse(json['creationDate'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      thumbnailPath: json['thumbnailPath'] as String?,
      filePath: json['filePath'] as String,
    );
  }
}
