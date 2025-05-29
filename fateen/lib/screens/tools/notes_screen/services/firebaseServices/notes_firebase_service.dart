import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../models/note_model.dart';
import '../../constants/notes_strings.dart';

class NotesFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // الحصول على الـ User الحالي
  User? get currentUser => _auth.currentUser;

  // الحصول على مرجع مجموعة الملاحظات
  CollectionReference<Map<String, dynamic>> get notesCollection {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('notes');
  }

  // الحصول على مجموعة الفئات
  DocumentReference<Map<String, dynamic>> get categoriesDoc {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('categories')
        .doc('user_categories');
  }

  // إنشاء Stream لمراقبة تغيرات الملاحظات
  Stream<List<Note>> getNotesStream() {
    if (currentUser == null) {
      return Stream.value([]); // إرجاع قائمة فارغة بدل البيانات التجريبية
    }

    return notesCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Note.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // جلب الفئات المخزنة
  Future<List<String>> getCategories() async {
    if (currentUser == null) {
      return ['عام'];
    }

    try {
      final doc = await categoriesDoc.get();
      if (doc.exists && doc.data() != null) {
        final List<dynamic> data = doc.data()?['categories'] ?? [];
        return data.map((category) => category.toString()).toList();
      }
      return [NotesStrings.defaultCategory];
    } catch (e) {
      print('Error loading categories: $e');
      return [NotesStrings.defaultCategory];
    }
  }

  // حفظ فئة جديدة
  Future<void> saveCategory(String category) async {
    if (currentUser == null || category.isEmpty) return;

    try {
      final doc = await categoriesDoc.get();

      if (doc.exists && doc.data() != null) {
        List<dynamic> currentCategories = doc.data()?['categories'] ?? [];
        if (!currentCategories.contains(category)) {
          currentCategories.add(category);
          await categoriesDoc.update({'categories': currentCategories});
        }
      } else {
        await categoriesDoc.set({
          'categories': [category]
        });
      }
    } catch (e) {
      print('Error saving category: $e');
      throw Exception('فشل في حفظ الفئة: $e');
    }
  }

  // إضافة ملاحظة جديدة
  Future<void> addNote(Map<String, dynamic> data) async {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    data['timestamp'] = FieldValue.serverTimestamp();
    await notesCollection.add(data);
  }

  // تحديث ملاحظة موجودة
  Future<void> updateNote(String noteId, Map<String, dynamic> data) async {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    data['timestamp'] = FieldValue.serverTimestamp();
    await notesCollection.doc(noteId).update(data);
  }

  // تبديل حالة المفضلة
  Future<void> toggleFavorite(String noteId, bool isFavorite) async {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    await notesCollection.doc(noteId).update({
      'isFavorite': !isFavorite,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // حذف ملاحظة
  Future<void> deleteNote(String noteId) async {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    await notesCollection.doc(noteId).delete();
  }

  // نسخ ملاحظة
  Future<void> duplicateNote(Note note) async {
    if (currentUser == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    final data = note.toMap();
    data['title'] = '${note.title}${NotesStrings.copyTitle}';
    data['isFavorite'] = false;
    data['timestamp'] = FieldValue.serverTimestamp();

    await notesCollection.add(data);
  }
}
