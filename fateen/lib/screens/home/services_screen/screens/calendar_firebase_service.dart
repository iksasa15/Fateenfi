// firebase/calendar_firebase_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CountdownModel {
  final int id;
  final String title;
  final DateTime targetDate;
  final bool hasNotification;

  CountdownModel({
    required this.id,
    required this.title,
    required this.targetDate,
    this.hasNotification = false,
  });

  // حساب عدد الأيام المتبقية
  int get daysLeft {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }

  // تحويل النموذج إلى Map لتخزينه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetDate': Timestamp.fromDate(targetDate),
      'hasNotification': hasNotification,
    };
  }

  // إنشاء نموذج من Map مستخرج من Firestore
  factory CountdownModel.fromMap(Map<String, dynamic> map) {
    return CountdownModel(
      id: map['id'],
      title: map['title'],
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      hasNotification: map['hasNotification'] ?? false,
    );
  }

  // إنشاء نسخة معدلة من النموذج
  CountdownModel copyWith({
    int? id,
    String? title,
    DateTime? targetDate,
    bool? hasNotification,
  }) {
    return CountdownModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      hasNotification: hasNotification ?? this.hasNotification,
    );
  }
}

class CalendarFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // التحقق من تسجيل دخول المستخدم
  bool get isUserLoggedIn => _auth.currentUser != null;

  // الحصول على معرف المستخدم الحالي
  String? get userId => _auth.currentUser?.uid;

  // مرجع لمجموعة المواعيد في Firestore
  CollectionReference<Map<String, dynamic>> get _countdownsCollection {
    if (!isUserLoggedIn) {
      throw Exception('المستخدم غير مسجل دخول');
    }
    return _firestore.collection('users').doc(userId).collection('countdowns');
  }

  // الحصول على المواعيد كـ Stream
  Stream<List<CountdownModel>> getCountdownsStream() {
    if (!isUserLoggedIn) {
      return Stream.value([]);
    }

    return _countdownsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CountdownModel.fromMap(doc.data());
      }).toList();
    });
  }

  // إضافة موعد جديد
  Future<void> addCountdown(CountdownModel countdown) async {
    if (!isUserLoggedIn) {
      throw Exception('المستخدم غير مسجل دخول');
    }

    await _countdownsCollection
        .doc(countdown.id.toString())
        .set(countdown.toMap());
  }

  // تحديث موعد
  Future<void> updateCountdown(CountdownModel countdown) async {
    if (!isUserLoggedIn) {
      throw Exception('المستخدم غير مسجل دخول');
    }

    await _countdownsCollection
        .doc(countdown.id.toString())
        .update(countdown.toMap());
  }

  // حذف موعد
  Future<void> deleteCountdown(int id) async {
    if (!isUserLoggedIn) {
      throw Exception('المستخدم غير مسجل دخول');
    }

    await _countdownsCollection.doc(id.toString()).delete();
  }

  // الحصول على المواعيد مرة واحدة
  Future<List<CountdownModel>> getCountdowns() async {
    if (!isUserLoggedIn) {
      return [];
    }

    final snapshot = await _countdownsCollection.get();
    return snapshot.docs.map((doc) {
      return CountdownModel.fromMap(doc.data());
    }).toList();
  }
}
