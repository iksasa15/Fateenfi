import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Student {
  //=================== الخصائص والمتغيرات ===================
  String? userId;
  String? name;
  String? username; // اسم المستخدم
  String? universityName; // اسم الجامعة
  String? major;
  String? email;
  bool? emailVerified;
  Timestamp? createdAt;
  Timestamp? lastLoginAt;

  //=================== المُنشئ (Constructor) ===================
  Student({
    this.userId,
    this.name,
    this.username, // اسم المستخدم
    this.universityName, // اسم الجامعة
    this.major,
    this.email,
    this.emailVerified,
    this.createdAt,
    this.lastLoginAt,
  });

  //=================== دوال تحويل البيانات ===================
  // تحويل بيانات الطالب إلى Map لحفظها في Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'username': username, // اسم المستخدم
      'universityName': universityName, // اسم الجامعة
      'major': major,
      'email': email,
      'emailVerified': emailVerified ?? false,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'lastLoginAt': lastLoginAt ?? FieldValue.serverTimestamp(),
    };
  }

  // إنشاء كائن Student من Map
  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      userId: id,
      name: map['name'],
      username: map['username'], // اسم المستخدم
      universityName: map['universityName'], // اسم الجامعة
      major: map['major'],
      email: map['email'],
      emailVerified: map['emailVerified'] ?? false,
      createdAt: map['createdAt'],
      lastLoginAt: map['lastLoginAt'],
    );
  }

  //=================== دوال التحقق من صحة البيانات ===================
  // التحقق من صحة الاسم
  static bool isValidName(String name) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(name);
  }

  // التحقق من صحة اسم المستخدم
  static bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_\u0600-\u06FF]+$').hasMatch(username);
  }

  // التحقق من صحة اسم الجامعة
  static bool isValidUniversityName(String universityName) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(universityName);
  }

  // التحقق من صحة التخصص
  static bool isValidMajor(String major) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(major);
  }

  // التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // التحقق من صحة كلمة المرور
  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  //=================== دوال البريد الإلكتروني والتحقق ===================
  // دالة إعادة إرسال بريد التحقق - المستخدمة فقط في VerificationController
  static Future<String?> resendVerificationEmail(String email) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return "❌ يجب تسجيل الدخول أولاً لإعادة إرسال بريد التحقق.";
      }

      if (user.email != email) {
        return "❌ البريد الإلكتروني غير مطابق للحساب الحالي.";
      }

      await user.reload();

      if (user.emailVerified) {
        return "✅ البريد الإلكتروني مفعل بالفعل.";
      }

      await user.sendEmailVerification();
      return null; // نجاح
    } catch (e) {
      return "❌ حدث خطأ: $e";
    }
  }

  // دالة جلب بيانات الطالب - مستخدمة في StudentPerformanceService
  static Future<Student?> getStudent(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return Student.fromMap(data, userId);
      }
      return null;
    } catch (e) {
      print("خطأ في جلب بيانات الطالب: $e");
      return null;
    }
  }
}
