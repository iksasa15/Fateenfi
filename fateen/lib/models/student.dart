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
      'username': username,
      'usernameSearchable':
          username?.toLowerCase(), // إضافة حقل للبحث غير الحساس لحالة الأحرف
      'universityName': universityName, // اسم الجامعة
      'major': major,
      'email': email?.toLowerCase(), // تأكيد حفظ البريد بأحرف صغيرة
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
    return name.isNotEmpty &&
        RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(name) &&
        name.length >= 3;
  }

  // التحقق من صحة اسم المستخدم - تحسين الشروط
  static bool isValidUsername(String username) {
    // يجب أن يبدأ بحرف، ويحتوي فقط على حروف وأرقام إنجليزية، وأكثر من 4 أحرف
    return username.length >= 4 &&
        RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{3,}$').hasMatch(username);
  }

  // رسائل الخطأ لاسم المستخدم
  static String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'الرجاء إدخال اسم المستخدم';
    }

    if (username.length < 4) {
      return 'يجب أن يكون اسم المستخدم أكثر من 4 أحرف';
    }

    if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
      return 'يجب أن يبدأ اسم المستخدم بحرف';
    }

    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{3,}$').hasMatch(username)) {
      return 'اسم المستخدم يجب أن يحتوي فقط على حروف إنجليزية وأرقام وشرطة سفلية';
    }

    return null;
  }

  // التحقق من صحة اسم الجامعة
  static bool isValidUniversityName(String universityName) {
    return universityName.isNotEmpty &&
        RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(universityName) &&
        universityName.length >= 2;
  }

  // رسائل الخطأ لاسم الجامعة
  static String? validateUniversityName(String universityName) {
    if (universityName.isEmpty) {
      return 'الرجاء إدخال اسم الجامعة';
    }

    if (universityName.length < 2) {
      return 'اسم الجامعة قصير جداً';
    }

    if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(universityName)) {
      return 'اسم الجامعة يجب أن يحتوي على حروف فقط';
    }

    return null;
  }

  // التحقق من صحة التخصص
  static bool isValidMajor(String major) {
    return major.isNotEmpty &&
        RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(major) &&
        major.length >= 2;
  }

  // رسائل الخطأ للتخصص
  static String? validateMajor(String major) {
    if (major.isEmpty) {
      return 'الرجاء إدخال التخصص';
    }

    if (major.length < 2) {
      return 'التخصص قصير جداً';
    }

    if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(major)) {
      return 'التخصص يجب أن يحتوي على حروف فقط';
    }

    return null;
  }

  // التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // رسائل الخطأ للبريد الإلكتروني
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }

    if (!isValidEmail(email)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  // التحقق من صحة كلمة المرور
  static bool isValidPassword(String password) {
    // التحقق من عدم وجود حروف عربية
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(password)) {
      return false; // لا تقبل الحروف العربية
    }

    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  // رسائل الخطأ لكلمة المرور
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }

    // التحقق من عدم وجود حروف عربية
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حروف إنجليزية فقط وليس عربية';
    }

    if (password.length < 8) {
      return 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل';
    }

    return null;
  }

  // فحص قوة كلمة المرور وإعطاء درجة (0.0 - 1.0)
  static double calculatePasswordStrength(String password) {
    double strength = 0.0;

    // طول كلمة المرور
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;

    // تنوع الأحرف
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'\d').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.2;

    // الحد الأقصى هو 1.0
    return strength > 1.0 ? 1.0 : strength;
  }

  // الحصول على نص وصفي لقوة كلمة المرور
  static String getPasswordStrengthText(String password) {
    double strength = calculatePasswordStrength(password);

    if (strength < 0.3) return 'ضعيفة';
    if (strength < 0.6) return 'متوسطة';
    if (strength < 0.8) return 'جيدة';
    return 'قوية';
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

  // التحقق من فرادة اسم المستخدم
  static Future<bool> isUsernameUnique(String username) async {
    try {
      // تحويل اسم المستخدم إلى أحرف صغيرة للبحث غير الحساس لحالة الأحرف
      final String lowercaseUsername = username.trim().toLowerCase();

      // البحث باستخدام حقل usernameSearchable للبحث غير الحساس لحالة الأحرف
      final QuerySnapshot resultSearchable = await FirebaseFirestore.instance
          .collection('users')
          .where('usernameSearchable', isEqualTo: lowercaseUsername)
          .limit(1)
          .get();

      if (resultSearchable.docs.isNotEmpty) {
        return false; // اسم المستخدم موجود
      }

      // البحث التقليدي في حقل username (للتوافق مع البيانات القديمة)
      final QuerySnapshot resultFallback = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return resultFallback.docs.isEmpty;
    } catch (e) {
      print("خطأ في التحقق من فرادة اسم المستخدم: $e");
      return false;
    }
  }

  // التحقق من وجود البريد الإلكتروني - تم تحديث هذه الدالة للتحقق من كل من Firebase Auth و Firestore
  static Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      // تحويل البريد إلى أحرف صغيرة وإزالة المسافات
      email = email.trim().toLowerCase();

      // التحقق من Firebase Auth أولاً
      final methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        return true; // البريد موجود في Firebase Auth
      }

      // التحقق من Firestore - للتأكد من عدم وجود بريد مكرر
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return result.docs.isNotEmpty; // إعادة نتيجة التحقق من Firestore
    } catch (e) {
      print("خطأ في التحقق من البريد الإلكتروني: $e");
      return true; // نفترض وجود البريد في حالة الخطأ (للأمان)
    }
  }

  static Future<bool> isUsernameExists(String username) async {
    try {
      // تحويل اسم المستخدم إلى أحرف صغيرة للبحث غير الحساس لحالة الأحرف
      final String lowercaseUsername = username.trim().toLowerCase();

      // البحث باستخدام حقل usernameSearchable إذا كان موجودًا
      final QuerySnapshot resultSearchable = await FirebaseFirestore.instance
          .collection('users')
          .where('usernameSearchable', isEqualTo: lowercaseUsername)
          .limit(1)
          .get();

      if (resultSearchable.docs.isNotEmpty) {
        return true; // اسم المستخدم موجود
      }

      // البحث التقليدي في حقل username (للتوافق مع البيانات القديمة)
      final QuerySnapshot resultFallback = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return resultFallback.docs.isNotEmpty;
    } catch (e) {
      print("خطأ في التحقق من وجود اسم المستخدم: $e");
      return false;
    }
  }
}
