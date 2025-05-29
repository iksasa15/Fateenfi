import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/drawing_file_model.dart';
import '../../../../models/drawn_line_model.dart';
import '../../../../models/sticker_model.dart';

class FirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // حفظ بيانات الرسمة في Firestore
  Future<bool> saveDrawingToFirebase({
    required String fileId,
    required String fileName,
    required DateTime creationDate,
    required List<DrawnLine> lines,
    required List<Sticker> stickers,
    required Uint8List imageData,
  }) async {
    try {
      // أولاً: رفع الصورة المصغرة إلى Firebase Storage
      final storageRef = _storage.ref().child('drawings/$fileId/thumbnail.png');
      final uploadTask = storageRef.putData(imageData);
      final snapshot = await uploadTask;
      final thumbnailUrl = await snapshot.ref.getDownloadURL();

      // ثانياً: حفظ بيانات الرسمة في Firestore
      final drawingData = {
        'id': fileId,
        'name': fileName,
        'creationDate': creationDate.toIso8601String(),
        'lastModified': DateTime.now().toIso8601String(),
        'thumbnailUrl': thumbnailUrl,
        'lines': lines.map((line) => line.toJson()).toList(),
        'stickers': stickers.map((sticker) => sticker.toJson()).toList(),
      };

      await _firestore.collection('drawings').doc(fileId).set(drawingData);

      return true;
    } catch (e) {
      print('خطأ في حفظ الرسمة على Firebase: $e');
      return false;
    }
  }

  // استرجاع الرسمات من Firestore
  Future<List<DrawingFile>> getDrawingsFromFirebase() async {
    try {
      final snapshot = await _firestore.collection('drawings').get();
      final List<DrawingFile> drawingFiles = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        drawingFiles.add(DrawingFile(
          id: data['id'],
          name: data['name'],
          creationDate: DateTime.parse(data['creationDate']),
          lastModified: DateTime.parse(data['lastModified']),
          thumbnailPath:
              data['thumbnailUrl'], // استخدام URL بدلاً من المسار المحلي
          filePath: '', // في حالة Firebase، لا نستخدم مسار ملف محلي
        ));
      }

      return drawingFiles;
    } catch (e) {
      print('خطأ في استرجاع الرسمات من Firebase: $e');
      return [];
    }
  }

  // استرجاع بيانات رسمة محددة من Firestore
  Future<Map<String, dynamic>?> getDrawingDataFromFirebase(
      String fileId) async {
    try {
      final doc = await _firestore.collection('drawings').doc(fileId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;

      List<DrawnLine> lines = (data['lines'] as List)
          .map((lineData) => DrawnLine.fromJson(lineData))
          .toList();

      List<Sticker> stickers = (data['stickers'] as List)
          .map((stickerData) => Sticker.fromJson(stickerData))
          .toList();

      return {
        'lines': lines,
        'stickers': stickers,
        'fileInfo': DrawingFile(
          id: data['id'],
          name: data['name'],
          creationDate: DateTime.parse(data['creationDate']),
          lastModified: DateTime.parse(data['lastModified']),
          thumbnailPath: data['thumbnailUrl'],
          filePath: '',
        ),
      };
    } catch (e) {
      print('خطأ في استرجاع بيانات الرسمة من Firebase: $e');
      return null;
    }
  }

  // حذف رسمة من Firebase
  Future<bool> deleteDrawingFromFirebase(String fileId) async {
    try {
      // حذف الصورة المصغرة من Storage
      await _storage.ref().child('drawings/$fileId/thumbnail.png').delete();

      // حذف بيانات الرسمة من Firestore
      await _firestore.collection('drawings').doc(fileId).delete();

      return true;
    } catch (e) {
      print('خطأ في حذف الرسمة من Firebase: $e');
      return false;
    }
  }
}
