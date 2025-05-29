// lib/models/app_file.dart
import 'dart:developer' as developer;

class AppFile {
  // الخصائص
  String id;
  String fileName;
  int fileSize; // الحجم بالكيلوبايت (KB)
  String fileType; // مثل "PDF" أو "DOCX"
  String? filePath; // مسار الملف على الجهاز (اختياري)

  // **المُنشئ**
  AppFile({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    this.filePath,
    DateTime? createdAt,
  });

  // **دالة رفع الملف**
  void upload() {
    // بإمكانك تخصيص هذه الدالة لرفع الملف إلى Firebase Storage أو غيره
    developer.log("📂 تم رفع الملف: $fileName ($fileType) بحجم $fileSize KB");
  }

  // **دالة عرض تفاصيل الملف**
  void viewDetailsInConsole() {
    // لعرض التفاصيل في الـConsole
    developer.log("📄 تفاصيل الملف:");
    developer.log("- 📌 الاسم: $fileName");
    developer.log("- 💾 الحجم: $fileSize KB");
    developer.log("- 📑 النوع: $fileType");
    developer.log("- 📂 المسار: ${filePath ?? 'غير متوفر'}");
  }

  // **دالة حذف الملف**
  void deleteFile() {
    // بإمكانك تخصيص هذه الدالة لحذف الملف من التخزين السحابي إن وجد
    developer.log("🗑 تم حذف الملف: $fileName");
  }

  // ----------- دوال اختيارية للتعامل مع فايرستور -----------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
      'filePath': filePath,
    };
  }

  factory AppFile.fromMap(Map<String, dynamic> map) {
    return AppFile(
      id: map['id'] ?? '',
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      fileType: map['fileType'] ?? 'UNKNOWN',
      filePath: map['filePath'],
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  get uploadDate => null;
}
