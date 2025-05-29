import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Student {
  String? userId;
  String? name;
  String? major;
  String? email;
  bool? emailVerified;
  Timestamp? createdAt;
  Timestamp? lastLoginAt;

  Student({
    this.userId,
    this.name,
    this.major,
    this.email,
    this.emailVerified,
    this.createdAt,
    this.lastLoginAt,
  });

  // تحويل بيانات الطالب إلى Map لحفظها في Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
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
      major: map['major'],
      email: map['email'],
      emailVerified: map['emailVerified'] ?? false,
      createdAt: map['createdAt'],
      lastLoginAt: map['lastLoginAt'],
    );
  }

  // 🔹 التحقق من صحة الاسم (يجب أن يكون نصًا بدون أرقام)
  static bool isValidName(String name) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(name);
  }

  // 🔹 التحقق من صحة التخصص (يجب أن يكون نصًا بدون أرقام)
  static bool isValidMajor(String major) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(major);
  }

  // 🔹 التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // 🔹 التحقق من صحة كلمة المرور
  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) && // يحتوي على حرف كبير
        RegExp(r'[a-z]').hasMatch(password) && // يحتوي على حرف صغير
        RegExp(r'\d').hasMatch(password) && // يحتوي على رقم
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]')
            .hasMatch(password); // يحتوي على رمز خاص
  }

  // 🔹 دالة تسجيل طالب جديد
  static Future<String?> registerStudent({
    required String name,
    required String major,
    required String email,
    required String password,
  }) async {
    if (!isValidName(name)) {
      return "❌ الاسم يجب أن يحتوي على أحرف فقط بدون أرقام.";
    }

    if (!isValidMajor(major)) {
      return "❌ التخصص يجب أن يحتوي على أحرف فقط بدون أرقام.";
    }

    if (!isValidEmail(email)) {
      return "❌ يرجى إدخال بريد إلكتروني صحيح.";
    }

    if (!isValidPassword(password)) {
      return "❌ يجب أن تحتوي كلمة المرور على 8 خانات على الأقل، وحرف كبير، وحرف صغير، ورقم، ورمز خاص.";
    }

    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // التحقق من وجود البريد الإلكتروني مسبقًا
      final methods = await auth.fetchSignInMethodsForEmail(email.trim());
      if (methods.isNotEmpty) {
        return "❌ البريد الإلكتروني مستخدم بالفعل. يرجى تسجيل الدخول أو استخدام بريد إلكتروني آخر.";
      }

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String userId = userCredential.user!.uid;

      // تعيين اسم المستخدم
      await userCredential.user!.updateDisplayName(name);

      Student student = Student(
        userId: userId,
        name: name,
        major: major,
        email: email,
        emailVerified: false,
        createdAt: Timestamp.now(),
        lastLoginAt: Timestamp.now(),
      );

      await firestore.collection('users').doc(userId).set(student.toMap());

      // إرسال بريد التحقق
      await sendVerificationEmail();

      return null; // نجاح
    } on FirebaseAuthException catch (e) {
      // معالجة أخطاء Firebase الشائعة
      switch (e.code) {
        case 'email-already-in-use':
          return "❌ البريد الإلكتروني مستخدم بالفعل.";
        case 'invalid-email':
          return "❌ البريد الإلكتروني غير صالح.";
        case 'weak-password':
          return "❌ كلمة المرور ضعيفة جداً.";
        case 'operation-not-allowed':
          return "❌ تسجيل المستخدمين معطل حالياً.";
        case 'network-request-failed':
          return "❌ يرجى التحقق من اتصالك بالإنترنت.";
        case 'too-many-requests':
          return "❌ تم تجاوز عدد المحاولات، يرجى المحاولة لاحقاً.";
        default:
          return "❌ حدث خطأ: ${e.message}";
      }
    } catch (e) {
      return "❌ حدث خطأ غير متوقع: $e";
    }
  }

  // 🔹 دالة تسجيل الدخول
  static Future<String?> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // تحديث آخر تسجيل دخول
      await firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return null; // نجاح
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "❌ البريد الإلكتروني غير مسجل.";
        case 'wrong-password':
          return "❌ كلمة المرور غير صحيحة.";
        case 'user-disabled':
          return "❌ تم تعطيل هذا الحساب.";
        case 'too-many-requests':
          return "❌ تم تجاوز عدد المحاولات، يرجى المحاولة لاحقاً.";
        case 'network-request-failed':
          return "❌ يرجى التحقق من اتصالك بالإنترنت.";
        default:
          return "❌ حدث خطأ في تسجيل الدخول: ${e.message}";
      }
    } catch (e) {
      return "❌ حدث خطأ غير متوقع: $e";
    }
  }

  // 🔹 دالة تحديث بيانات الطالب
  static Future<String?> updateStudent({
    required String userId,
    required String newName,
    required String newMajor,
    required String newEmail,
  }) async {
    if (!isValidName(newName)) {
      return "❌ الاسم يجب أن يحتوي على أحرف فقط بدون أرقام.";
    }

    if (!isValidMajor(newMajor)) {
      return "❌ التخصص يجب أن يحتوي على أحرف فقط بدون أرقام.";
    }

    if (!isValidEmail(newEmail)) {
      return "❌ يرجى إدخال بريد إلكتروني صحيح.";
    }

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      FirebaseAuth auth = FirebaseAuth.instance;
      User? currentUser = auth.currentUser;

      // تحقق مما إذا كان المستخدم يريد تغيير البريد الإلكتروني
      if (currentUser != null && currentUser.email != newEmail) {
        // تحديث البريد الإلكتروني في Firebase Auth
        await currentUser.updateEmail(newEmail);
        // إعادة إرسال بريد التحقق للبريد الجديد
        await currentUser.sendEmailVerification();
      }

      // تحديث اسم العرض
      if (currentUser != null && currentUser.displayName != newName) {
        await currentUser.updateDisplayName(newName);
      }

      await firestore.collection('users').doc(userId).update({
        'name': newName,
        'major': newMajor,
        'email': newEmail,
        'emailVerified': currentUser?.emailVerified ?? false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null; // نجاح التحديث
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          return "❌ تحتاج إلى إعادة تسجيل الدخول لتحديث البريد الإلكتروني.";
        case 'email-already-in-use':
          return "❌ البريد الإلكتروني الجديد مستخدم بالفعل.";
        default:
          return "❌ حدث خطأ: ${e.message}";
      }
    } catch (e) {
      return "❌ حدث خطأ غير متوقع: $e";
    }
  }

  // 🔹 دالة جلب بيانات الطالب
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

  // 🔹 دالة التحقق من حالة التحقق من البريد الإلكتروني - معدلة
  static Future<bool> isEmailVerified() async {
    try {
      // تسجيل الخروج أولاً للتأكد من تحديث الجلسة
      await FirebaseAuth.instance.signOut();

      // محاولة إعادة تسجيل الدخول (يجب توفير البريد وكلمة المرور)
      if (_lastEmail != null && _lastPassword != null) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _lastEmail!,
          password: _lastPassword!,
        );
      } else {
        // إذا لم تكن المعلومات متوفرة، لا يمكننا التحقق
        debugPrint("لا يمكن التحقق: البيانات غير متوفرة");
        return false;
      }

      // إعادة تحميل بيانات المستخدم من السيرفر
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        // التحقق من حالة البريد الإلكتروني بعد إعادة التحميل
        bool verified =
            FirebaseAuth.instance.currentUser?.emailVerified ?? false;

        // تحديث حالة التحقق في Firestore إذا كانت صحيحة
        if (verified) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'emailVerified': true,
          });
        }

        debugPrint("نتيجة التحقق من البريد: $verified");
        return verified;
      }

      debugPrint("لا يمكن التحقق: المستخدم غير موجود");
      return false;
    } catch (e) {
      debugPrint("خطأ في التحقق من حالة البريد الإلكتروني: $e");
      return false;
    }
  }

  // تخزين مؤقت للبريد وكلمة المرور للتحقق لاحقاً
  static String? _lastEmail;
  static String? _lastPassword;

  // طريقة جديدة للتحقق من البريد مع معلومات الدخول
  static Future<bool> checkEmailVerificationWithCredentials(
      {required String email, required String password}) async {
    try {
      // تخزين البيانات للاستخدام لاحقاً
      _lastEmail = email;
      _lastPassword = password;

      // تسجيل الخروج
      await FirebaseAuth.instance.signOut();

      // إعادة تسجيل الدخول
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // إعادة تحميل المستخدم من السيرفر
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        bool verified =
            FirebaseAuth.instance.currentUser?.emailVerified ?? false;

        // تحديث في Firestore
        if (verified) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'emailVerified': true,
          });
        }

        return verified;
      }

      return false;
    } catch (e) {
      debugPrint("خطأ في التحقق المعزز من البريد: $e");
      return false;
    }
  }

  // 🔹 دالة إرسال بريد التحقق
  static Future<String?> sendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.emailVerified) {
          return "✅ البريد الإلكتروني مفعل بالفعل.";
        }

        await user.sendEmailVerification();
        return null; // نجاح
      }
      return "❌ يجب تسجيل الدخول أولاً.";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'too-many-requests':
          return "❌ تم إرسال الكثير من الطلبات، يرجى المحاولة لاحقاً.";
        default:
          return "❌ حدث خطأ: ${e.message}";
      }
    } catch (e) {
      return "❌ حدث خطأ غير متوقع: $e";
    }
  }

  // 🔹 دالة إعادة إرسال بريد التحقق
  static Future<String?> resendVerificationEmail(String email) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // إذا كان المستخدم غير مسجل دخول، نحاول تسجيل الدخول أولاً
      if (user == null) {
        return "❌ يجب تسجيل الدخول أولاً لإعادة إرسال بريد التحقق.";
      }

      // التحقق من أن البريد المطلوب هو نفسه الحالي
      if (user.email != email) {
        return "❌ البريد الإلكتروني غير مطابق للحساب الحالي.";
      }

      // إعادة تحميل بيانات المستخدم من السيرفر
      await user.reload();

      // التحقق إذا كان البريد مفعل بالفعل
      if (user.emailVerified) {
        return "✅ البريد الإلكتروني مفعل بالفعل.";
      }

      // إرسال بريد التحقق
      await user.sendEmailVerification();
      return null; // نجاح
    } catch (e) {
      return "❌ حدث خطأ: $e";
    }
  }

  // 🔹 دالة تسجيل الخروج
  static Future<String?> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return null; // نجاح
    } catch (e) {
      return "❌ حدث خطأ أثناء تسجيل الخروج: $e";
    }
  }

  // 🔹 دالة تغيير كلمة المرور
  static Future<String?> changePassword(String newPassword) async {
    if (!isValidPassword(newPassword)) {
      return "❌ يجب أن تحتوي كلمة المرور الجديدة على 8 خانات على الأقل، وحرف كبير، وحرف صغير، ورقم، ورمز خاص.";
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        return null; // نجاح
      }
      return "❌ يجب تسجيل الدخول أولاً.";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          return "❌ تحتاج إلى إعادة تسجيل الدخول لتغيير كلمة المرور.";
        default:
          return "❌ حدث خطأ: ${e.message}";
      }
    } catch (e) {
      return "❌ حدث خطأ غير متوقع: $e";
    }
  }

  // 🔹 دالة إرسال رسالة إعادة تعيين كلمة المرور
  static Future<String?> resetPassword(String email) async {
    if (!isValidEmail(email)) {
      return "❌ يرجى إدخال بريد إلكتروني صحيح.";
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null; // نجاح
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "❌ لا يوجد حساب مرتبط بهذا البريد الإلكتروني.";
        default:
          return "❌ حدث خطأ: ${e.message}";
      }
    } catch (e) {
      return "❌ حدث خطأ غير متوقع: $e";
    }
  }
}
