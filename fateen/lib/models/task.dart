// lib/models/task.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'course.dart';
import '../screens/tasks/services/notifications_service.dart';

class Task {
  final String id;
  String name;
  String description;
  DateTime dueDate;
  Course? course; // تعديل ليكون متغيراً عادياً (غير نهائي)
  final String? courseId; // معرف الكورس
  DateTime? reminderTime;
  String status;
  List<String> reminders;
  // إضافة بعض الخصائص الجديدة
  String priority; // أولوية المهمة: منخفضة، متوسطة، عالية
  double progress; // نسبة إكمال المهمة من 0 إلى 1
  DateTime? completedDate; // تاريخ إكمال المهمة
  List<String> tags; // مجموعة وسوم للمهمة
  Color? color; // لون مخصص للمهمة
  final String? userId; // معرف المستخدم المالك للمهمة

  // الحصول على مرجع لمجموعة المهام لمستخدم معين
  static CollectionReference tasksCollectionForUser(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');
  }

  // الحصول على مرجع للمهام الخاصة بالمستخدم الحالي
  static Future<CollectionReference> get tasksCollection async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }
    return tasksCollectionForUser(currentUser.uid);
  }

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.dueDate,
    this.course, // جعل الكورس اختياري
    this.courseId, // جعل معرّف الكورس اختياري
    this.reminderTime,
    required this.status,
    this.reminders = const [], // تعديل ليكون اختيارياً مع قيمة افتراضية
    this.priority = 'متوسطة', // القيمة الافتراضية
    this.progress = 0.0, // القيمة الافتراضية
    this.completedDate,
    this.tags = const [], // القيمة الافتراضية
    this.color,
    this.userId,
  }) {
    // التحقق من صحة البيانات عند إنشاء المهمة
    if (id.isEmpty) {
      throw ArgumentError('معرّف المهمة لا يمكن أن يكون فارغاً');
    }
    if (name.isEmpty) {
      throw ArgumentError('اسم المهمة لا يمكن أن يكون فارغاً');
    }
    // التأكد من أن courseId موجود إذا كان هناك course
    if (course != null && (courseId == null || courseId!.isEmpty)) {
      throw ArgumentError('عند تحديد الكورس يجب توفير معرّف الكورس');
    }
    if (status.isEmpty) {
      throw ArgumentError('حالة المهمة لا يمكن أن تكون فارغة');
    }
    if (reminderTime != null && reminderTime!.isBefore(DateTime.now())) {
      throw ArgumentError('وقت التذكير يجب أن يكون في المستقبل');
    }
    // التحقق من صحة نسبة التقدم
    if (progress < 0 || progress > 1) {
      throw ArgumentError('نسبة التقدم يجب أن تكون بين 0 و 1');
    }
    // التأكد من وجود تاريخ إكمال إذا كانت الحالة "مكتملة"
    if (status == 'مكتملة' && completedDate == null) {
      completedDate = DateTime.now(); // تعيين تلقائي لتاريخ الإكمال
    }
    // التحقق من صحة الأولوية
    if (!['منخفضة', 'متوسطة', 'عالية'].contains(priority)) {
      throw ArgumentError(
          'الأولوية يجب أن تكون إحدى القيم: منخفضة، متوسطة، عالية');
    }
  }

  // دوال مطلوبة للتصميم
  String get priorityText {
    switch (priority) {
      case 'عالية':
        return 'أولوية عالية';
      case 'متوسطة':
        return 'أولوية متوسطة';
      case 'منخفضة':
        return 'أولوية منخفضة';
      default:
        return 'أولوية غير محددة';
    }
  }

  String get dueDateFormatted {
    return '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';
  }

  Color get priorityColor {
    switch (priority) {
      case 'عالية':
        return Colors.red;
      case 'متوسطة':
        return Colors.orange;
      case 'منخفضة':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get title => name;

  // إضافة التحويل من وإلى JSON لدعم التخزين المحلي
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'status': status,
      'priority': priority,
      'progress': progress,
      'tags': tags,
      'courseId': courseId,
      'completedDate': completedDate?.toIso8601String(),
      'color': color?.value,
      'userId': userId,
      'reminders': reminders,
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'])
          : null,
      status: json['status'],
      courseId: json['courseId'],
      priority: json['priority'] ?? 'متوسطة',
      progress: json['progress'] ?? 0.0,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      color: json['color'] != null ? Color(json['color']) : null,
      userId: json['userId'],
      reminders: List<String>.from(json['reminders'] ?? []),
    );
  }

  // تحويل الكائن إلى Map لحفظه في قاعدة البيانات
  Map<String, dynamic> toMap() {
    if (id.isEmpty || name.isEmpty || description.isEmpty || status.isEmpty) {
      throw StateError('لا يمكن تحويل المهمة إلى Map: بيانات غير مكتملة');
    }

    Map<String, dynamic> taskMap = {
      'id': id,
      'name': name,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'reminders': reminders,
      'priority': priority,
      'progress': progress,
      'tags': tags,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // إضافة معرّف المستخدم
    if (userId != null) {
      taskMap['userId'] = userId;
    }

    // إضافة معرّف الكورس فقط إذا كان موجودًا
    if (courseId != null && courseId!.isNotEmpty) {
      taskMap['courseId'] = courseId;
    }

    // إضافة وقت التذكير فقط إذا كان موجودًا
    if (reminderTime != null) {
      taskMap['reminderTime'] = Timestamp.fromDate(reminderTime!);
    }

    // إضافة تاريخ الإكمال فقط إذا كان موجودًا
    if (completedDate != null) {
      taskMap['completedDate'] = Timestamp.fromDate(completedDate!);
    }

    // إضافة لون المهمة إذا كان موجودًا
    if (color != null) {
      taskMap['color'] = color!.value;
    }

    return taskMap;
  }

  // إنشاء كائن Task من DocumentSnapshot من Firestore
  static Task fromFirestore(DocumentSnapshot doc, {Course? course}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // التحقق من وجود البيانات الأساسية
    if (!data.containsKey('name') ||
        !data.containsKey('dueDate') ||
        !data.containsKey('status')) {
      throw ArgumentError('بيانات المهمة غير مكتملة');
    }

    // التحقق من تطابق معرّف الكورس إذا كان هناك كورس ومعرّف كورس في البيانات
    String? dataCourseid = data['courseId'] as String?;
    if (course != null && dataCourseid != null && dataCourseid != course.id) {
      throw ArgumentError(
          'معرّف المساق في المهمة لا يتطابق مع معرّف المساق المقدم');
    }

    return Task(
      id: doc.id,
      name: data['name'],
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      course: course, // قد يكون null
      courseId: data['courseId'], // قد يكون null
      reminderTime: data['reminderTime'] != null
          ? (data['reminderTime'] as Timestamp).toDate()
          : null,
      status: data['status'],
      reminders: List<String>.from(data['reminders'] ?? []),
      priority: data['priority'] ?? 'متوسطة',
      progress: (data['progress'] ?? 0.0).toDouble(),
      completedDate: data['completedDate'] != null
          ? (data['completedDate'] as Timestamp).toDate()
          : null,
      tags: List<String>.from(data['tags'] ?? []),
      color: data['color'] != null ? Color(data['color'] as int) : null,
      userId: data['userId'] as String?,
    );
  }

  // حفظ المهمة في Firestore
  Future<void> saveToFirestore() async {
    try {
      String uid = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        throw Exception('معرّف المستخدم غير موجود');
      }

      await tasksCollectionForUser(uid).doc(id).set(toMap());
    } catch (e) {
      throw Exception('فشل في حفظ المهمة: $e');
    }
  }

  // تحديث المهمة في Firestore
  Future<void> updateInFirestore() async {
    try {
      String uid = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        throw Exception('معرّف المستخدم غير موجود');
      }

      Map<String, dynamic> updateData = {
        'name': name,
        'description': description,
        'dueDate': Timestamp.fromDate(dueDate),
        'status': status,
        'reminders': reminders,
        'priority': priority,
        'progress': progress,
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // إضافة معرّف المستخدم
      updateData['userId'] = uid;

      // إضافة معرّف الكورس فقط إذا كان موجودًا
      if (courseId != null && courseId!.isNotEmpty) {
        updateData['courseId'] = courseId;
      }

      // إضافة وقت التذكير فقط إذا كان موجودًا
      if (reminderTime != null) {
        updateData['reminderTime'] = Timestamp.fromDate(reminderTime!);
      } else {
        // حذف حقل reminderTime إذا كان null
        updateData['reminderTime'] = FieldValue.delete();
      }

      // إضافة تاريخ الإكمال فقط إذا كان موجودًا
      if (completedDate != null) {
        updateData['completedDate'] = Timestamp.fromDate(completedDate!);
      } else if (status == 'مكتملة') {
        // إذا تم تغيير الحالة إلى مكتملة ولكن لم يتم تعيين تاريخ الإكمال
        completedDate = DateTime.now();
        updateData['completedDate'] = Timestamp.fromDate(completedDate!);
      } else {
        // حذف حقل completedDate إذا كان null والحالة ليست "مكتملة"
        updateData['completedDate'] = FieldValue.delete();
      }

      // إضافة لون المهمة إذا كان موجودًا
      if (color != null) {
        updateData['color'] = color!.value;
      } else {
        // حذف حقل color إذا كان null
        updateData['color'] = FieldValue.delete();
      }

      await tasksCollectionForUser(uid).doc(id).update(updateData);
    } catch (e) {
      throw Exception('فشل في تحديث المهمة: $e');
    }
  }

  // حذف المهمة من Firestore
  Future<void> deleteFromFirestore() async {
    try {
      String uid = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        throw Exception('معرّف المستخدم غير موجود');
      }

      await tasksCollectionForUser(uid).doc(id).delete();
    } catch (e) {
      throw Exception('فشل في حذف المهمة: $e');
    }
  }

  // الحصول على جميع المهام لمساق معين
  static Future<List<Task>> getTasksForCourse(Course course) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      // الحصول على المستندات المرتبطة بمعرّف المساق المحدد
      QuerySnapshot snapshot = await tasksCollectionForUser(currentUser.uid)
          .where('courseId', isEqualTo: course.id)
          .orderBy('dueDate')
          .get();

      // تحويل كل مستند إلى كائن Task
      List<Task> tasks = [];
      for (var doc in snapshot.docs) {
        tasks.add(fromFirestore(doc, course: course));
      }
      return tasks;
    } catch (e) {
      throw Exception('فشل في الحصول على المهام: $e');
    }
  }

  // الحصول على جميع المهام (مع أو بدون كورس)
  static Future<List<Task>> getAllTasks() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      QuerySnapshot snapshot = await tasksCollectionForUser(currentUser.uid)
          .orderBy('dueDate')
          .get();

      List<Task> tasks = [];
      for (var doc in snapshot.docs) {
        // استعلام إضافي للحصول على الكورس إذا كان مرتبطًا
        String? courseId =
            (doc.data() as Map<String, dynamic>)['courseId'] as String?;

        Course? course;
        if (courseId != null) {
          try {
            DocumentSnapshot courseDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .collection('courses')
                .doc(courseId)
                .get();

            if (courseDoc.exists && courseDoc.data() != null) {
              course = Course.fromMap(
                  courseDoc.data() as Map<String, dynamic>, courseDoc.id);
            }
          } catch (e) {
            print('فشل في الحصول على الكورس للمهمة: $e');
          }
        }

        tasks.add(fromFirestore(doc, course: course));
      }
      return tasks;
    } catch (e) {
      throw Exception('فشل في الحصول على جميع المهام: $e');
    }
  }

  // الحصول على المهام غير المرتبطة بأي كورس
  static Future<List<Task>> getTasksWithoutCourse() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      QuerySnapshot snapshot = await tasksCollectionForUser(currentUser.uid)
          .where('courseId', isNull: true)
          .orderBy('dueDate')
          .get();

      List<Task> tasks = [];
      for (var doc in snapshot.docs) {
        tasks.add(fromFirestore(doc));
      }
      return tasks;
    } catch (e) {
      throw Exception('فشل في الحصول على المهام غير المرتبطة بكورس: $e');
    }
  }

  // الحصول على مهام اليوم
  static Future<List<Task>> getTodayTasks({Course? course}) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      // إنشاء محددات التاريخ (بداية ونهاية اليوم الحالي)
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      Query query = tasksCollectionForUser(currentUser.uid)
          .where('dueDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('status',
              whereIn: ['قيد التنفيذ', 'معلقة']); // استبعاد المكتملة والملغاة

      // إذا تم تحديد كورس، نقوم بتصفية المهام لهذا الكورس فقط
      if (course != null) {
        // تعذر استخدام العديد من شروط where مع حقول مختلفة في Firestore
        // لذلك سنقوم بتصفية النتائج يدويًا بعد الاستعلام
        QuerySnapshot snapshot = await query.get();

        List<Task> tasks = [];
        for (var doc in snapshot.docs) {
          if ((doc.data() as Map<String, dynamic>)['courseId'] == course.id) {
            tasks.add(fromFirestore(doc, course: course));
          }
        }
        return tasks;
      } else {
        QuerySnapshot snapshot = await query.get();

        List<Task> tasks = [];
        for (var doc in snapshot.docs) {
          // استعلام إضافي للحصول على الكورس إذا كان مرتبطًا
          String? courseId =
              (doc.data() as Map<String, dynamic>)['courseId'] as String?;

          Course? taskCourse;
          if (courseId != null) {
            try {
              DocumentSnapshot courseDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('courses')
                  .doc(courseId)
                  .get();

              if (courseDoc.exists && courseDoc.data() != null) {
                taskCourse = Course.fromMap(
                    courseDoc.data() as Map<String, dynamic>, courseDoc.id);
              }
            } catch (e) {
              print('فشل في الحصول على الكورس للمهمة: $e');
            }
          }

          tasks.add(fromFirestore(doc, course: taskCourse));
        }
        return tasks;
      }
    } catch (e) {
      throw Exception('فشل في الحصول على مهام اليوم: $e');
    }
  }

  // الحصول على المهام القادمة (التي لم تكتمل بعد)
  static Future<List<Task>> getUpcomingTasks({Course? course}) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      DateTime now = DateTime.now();
      DateTime startOfTomorrow =
          DateTime(now.year, now.month, now.day + 1, 0, 0, 0);

      Query query = tasksCollectionForUser(currentUser.uid)
          .where('dueDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfTomorrow))
          .where('status', isNotEqualTo: 'مكتملة')
          .where('status', isNotEqualTo: 'ملغاة')
          .orderBy('status')
          .orderBy('dueDate');

      // إذا تم تحديد كورس، نقوم بتصفية المهام لهذا الكورس فقط
      if (course != null) {
        // لا يمكن استخدام where مع courseId هنا بسبب قيود Firestore
        // سنقوم بتصفية النتائج يدويًا
        QuerySnapshot snapshot = await query.get();

        List<Task> tasks = [];
        for (var doc in snapshot.docs) {
          if ((doc.data() as Map<String, dynamic>)['courseId'] == course.id) {
            tasks.add(fromFirestore(doc, course: course));
          }
        }
        return tasks;
      } else {
        QuerySnapshot snapshot = await query.get();

        List<Task> tasks = [];
        for (var doc in snapshot.docs) {
          // استعلام إضافي للحصول على الكورس إذا كان مرتبطًا
          String? courseId =
              (doc.data() as Map<String, dynamic>)['courseId'] as String?;

          Course? taskCourse;
          if (courseId != null) {
            try {
              DocumentSnapshot courseDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('courses')
                  .doc(courseId)
                  .get();

              if (courseDoc.exists && courseDoc.data() != null) {
                taskCourse = Course.fromMap(
                    courseDoc.data() as Map<String, dynamic>, courseDoc.id);
              }
            } catch (e) {
              print('فشل في الحصول على الكورس للمهمة: $e');
            }
          }

          tasks.add(fromFirestore(doc, course: taskCourse));
        }
        return tasks;
      }
    } catch (e) {
      throw Exception('فشل في الحصول على المهام القادمة: $e');
    }
  }

  // الحصول على المهام المتأخرة
  static Future<List<Task>> getOverdueTasks({Course? course}) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      DateTime now = DateTime.now();
      DateTime startOfToday = DateTime(now.year, now.month, now.day, 0, 0, 0);

      Query query = tasksCollectionForUser(currentUser.uid)
          .where('dueDate', isLessThan: Timestamp.fromDate(startOfToday))
          .where('status',
              whereIn: ['قيد التنفيذ', 'معلقة']).orderBy('dueDate');

      // إذا تم تحديد كورس، نقوم بتصفية المهام لهذا الكورس فقط
      if (course != null) {
        // لا يمكن استخدام where مع courseId هنا بسبب قيود Firestore
        // سنقوم بتصفية النتائج يدويًا
        QuerySnapshot snapshot = await query.get();

        List<Task> tasks = [];
        for (var doc in snapshot.docs) {
          if ((doc.data() as Map<String, dynamic>)['courseId'] == course.id) {
            tasks.add(fromFirestore(doc, course: course));
          }
        }
        return tasks;
      } else {
        QuerySnapshot snapshot = await query.get();

        List<Task> tasks = [];
        for (var doc in snapshot.docs) {
          String? courseId =
              (doc.data() as Map<String, dynamic>)['courseId'] as String?;

          Course? taskCourse;
          if (courseId != null) {
            try {
              DocumentSnapshot courseDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('courses')
                  .doc(courseId)
                  .get();

              if (courseDoc.exists && courseDoc.data() != null) {
                taskCourse = Course.fromMap(
                    courseDoc.data() as Map<String, dynamic>, courseDoc.id);
              }
            } catch (e) {
              print('فشل في الحصول على الكورس للمهمة: $e');
            }
          }

          tasks.add(fromFirestore(doc, course: taskCourse));
        }
        return tasks;
      }
    } catch (e) {
      throw Exception('فشل في الحصول على المهام المتأخرة: $e');
    }
  }

  // الحصول على المهام المكتملة
  static Future<List<Task>> getCompletedTasks({Course? course}) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      Query query = tasksCollectionForUser(currentUser.uid)
          .where('status', isEqualTo: 'مكتملة')
          .orderBy('completedDate', descending: true);

      // إذا تم تحديد كورس، نقوم بتصفية المهام لهذا الكورس فقط
      if (course != null) {
        // لا يمكن استخدام where مع courseId هنا بسبب قيود Firestore
        // سنقوم بتصفية النتائج يدويًا
        QuerySnapshot snapshot = await query.get();

        List<Task> tasks = [];
        for (var doc in snapshot.docs) {
          if ((doc.data() as Map<String, dynamic>)['courseId'] == course.id) {
            tasks.add(fromFirestore(doc, course: course));
          }
        }
        return tasks;
      } else {
        QuerySnapshot snapshot = await query.get();

        List<Task> tasks = [];
        for (var doc in snapshot.docs) {
          String? courseId =
              (doc.data() as Map<String, dynamic>)['courseId'] as String?;

          Course? taskCourse;
          if (courseId != null) {
            try {
              DocumentSnapshot courseDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('courses')
                  .doc(courseId)
                  .get();

              if (courseDoc.exists && courseDoc.data() != null) {
                taskCourse = Course.fromMap(
                    courseDoc.data() as Map<String, dynamic>, courseDoc.id);
              }
            } catch (e) {
              print('فشل في الحصول على الكورس للمهمة: $e');
            }
          }

          tasks.add(fromFirestore(doc, course: taskCourse));
        }
        return tasks;
      }
    } catch (e) {
      throw Exception('فشل في الحصول على المهام المكتملة: $e');
    }
  }

  // البحث عن مهام حسب النص
  static Future<List<Task>> searchTasks(String query) async {
    try {
      // Firestore لا يدعم البحث النصي مباشرة، لذلك سنقوم بتحميل جميع المهام ثم تصفيتها
      List<Task> allTasks = await getAllTasks();

      // تحويل النص إلى حروف صغيرة للبحث بدون حساسية لحالة الأحرف
      String lowercaseQuery = query.toLowerCase();

      // تصفية المهام التي تحتوي على النص في الاسم أو الوصف
      return allTasks.where((task) {
        return task.name.toLowerCase().contains(lowercaseQuery) ||
            task.description.toLowerCase().contains(lowercaseQuery) ||
            (task.course?.courseName.toLowerCase().contains(lowercaseQuery) ??
                false) ||
            task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      throw Exception('فشل في البحث عن المهام: $e');
    }
  }

  // إنشاء مهمة جديدة مع معرّف تلقائي
  static Future<Task> createNewTask({
    required String name,
    required String description,
    required DateTime dueDate,
    Course? course, // جعل الكورس اختياري
    DateTime? reminderTime,
    String status = 'قيد التنفيذ',
    List<String> reminders = const [],
    String priority = 'متوسطة',
    double progress = 0.0,
    List<String> tags = const [],
    Color? color,
  }) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      // إنشاء مستند جديد مع معرّف تلقائي
      DocumentReference docRef = tasksCollectionForUser(currentUser.uid).doc();

      // ضبط تاريخ الإكمال إذا كانت الحالة "مكتملة"
      DateTime? completedDate = status == 'مكتملة' ? DateTime.now() : null;

      Task newTask = Task(
        id: docRef.id,
        name: name,
        description: description,
        dueDate: dueDate,
        course: course, // يمكن أن يكون null
        courseId: course?.id, // يمكن أن يكون null
        reminderTime: reminderTime,
        status: status,
        reminders: reminders,
        priority: priority,
        progress: progress,
        completedDate: completedDate,
        tags: tags,
        color: color,
        userId: currentUser.uid, // تخزين معرف المستخدم
      );

      // حفظ المهمة في Firestore
      await newTask.saveToFirestore();

      return newTask;
    } catch (e) {
      throw Exception('فشل في إنشاء مهمة جديدة: $e');
    }
  }

  // تعديل مهمة حالية وتحديثها في Firestore
  Future<Task> updateTask({
    String? newName,
    String? newDescription,
    DateTime? newDueDate,
    DateTime? newReminderTime,
    String? newStatus,
    List<String>? newReminders,
    Course? newCourse,
    String? newPriority,
    double? newProgress,
    List<String>? newTags,
    Color? newColor,
  }) async {
    // التحقق من صحة البيانات الجديدة
    if (newName != null && newName.isEmpty) {
      throw ArgumentError('اسم المهمة لا يمكن أن يكون فارغاً');
    }
    if (newStatus != null && newStatus.isEmpty) {
      throw ArgumentError('حالة المهمة لا يمكن أن تكون فارغة');
    }
    if (newReminderTime != null && newReminderTime.isBefore(DateTime.now())) {
      throw ArgumentError('وقت التذكير يجب أن يكون في المستقبل');
    }
    if (newProgress != null && (newProgress < 0 || newProgress > 1)) {
      throw ArgumentError('نسبة التقدم يجب أن تكون بين 0 و 1');
    }
    if (newPriority != null &&
        !['منخفضة', 'متوسطة', 'عالية'].contains(newPriority)) {
      throw ArgumentError(
          'الأولوية يجب أن تكون إحدى القيم: منخفضة، متوسطة، عالية');
    }

    // تحديث الخصائص المحلية
    if (newName != null) name = newName;
    if (newDescription != null) description = newDescription;
    if (newDueDate != null) dueDate = newDueDate;
    if (newReminderTime != null) reminderTime = newReminderTime;
    if (newStatus != null) {
      status = newStatus;
      // تحديث تاريخ الإكمال إذا تم تغيير الحالة إلى "مكتملة"
      if (newStatus == 'مكتملة' && completedDate == null) {
        completedDate = DateTime.now();
      } else if (newStatus != 'مكتملة') {
        completedDate = null;
      }
    }
    if (newReminders != null) reminders = newReminders;
    if (newPriority != null) priority = newPriority;
    if (newProgress != null) progress = newProgress;
    if (newTags != null) tags = newTags;
    if (newColor != null) color = newColor;
    if (newCourse != null) {
      course = newCourse;
    }

    // التحديث في Firestore
    await updateInFirestore();

    return this;
  }

  // ربط المهمة بكورس معين
  Future<void> assignToCourse(Course course) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      await tasksCollectionForUser(currentUser.uid).doc(id).update({
        'courseId': course.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // تحديث في الكائن المحلي
      this.course = course;
    } catch (e) {
      throw Exception('فشل في ربط المهمة بالكورس: $e');
    }
  }

  // إلغاء ربط المهمة بأي كورس
  Future<void> removeFromCourse() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      await tasksCollectionForUser(currentUser.uid).doc(id).update({
        'courseId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // تحديث في الكائن المحلي
      course = null;
    } catch (e) {
      throw Exception('فشل في إلغاء ربط المهمة بالكورس: $e');
    }
  }

  // تحديث نسبة التقدم مع التحديث في Firestore
  Future<void> updateProgressAndSave(double newProgress) async {
    if (newProgress < 0 || newProgress > 1) {
      throw ArgumentError('نسبة التقدم يجب أن تكون بين 0 و 1');
    }

    progress = newProgress;

    // تغيير الحالة إلى مكتملة تلقائيًا إذا وصلت نسبة التقدم إلى 100%
    if (progress >= 1.0 && status != 'مكتملة') {
      status = 'مكتملة';
      completedDate = DateTime.now();
    }

    await updateInFirestore();
  }

  // إضافة وسم (tag) للمهمة
  Future<void> addTagAndUpdate(String tag) async {
    if (tag.isEmpty) {
      throw ArgumentError('الوسم لا يمكن أن يكون فارغاً');
    }

    if (!tags.contains(tag)) {
      tags.add(tag);
      await updateInFirestore();
    }
  }

  // إزالة وسم (tag) من المهمة
  Future<void> removeTagAndUpdate(String tag) async {
    if (tags.contains(tag)) {
      tags.remove(tag);
      await updateInFirestore();
    }
  }

  // تغيير لون المهمة
  Future<void> setColorAndUpdate(Color newColor) async {
    color = newColor;
    await updateInFirestore();
  }

  // إزالة لون المهمة
  Future<void> clearColorAndUpdate() async {
    color = null;
    await updateInFirestore();
  }

  // إضافة تذكير جديد مع التحديث في Firestore
  Future<void> addReminderAndUpdate(String reminder) async {
    if (reminder.isEmpty) {
      throw ArgumentError('نص التذكير لا يمكن أن يكون فارغاً');
    }
    if (!reminders.contains(reminder)) {
      reminders.add(reminder);
      await updateInFirestore();
    } else {
      throw StateError('التذكير موجود مسبقاً');
    }
  }

  // حذف تذكير مع التحديث في Firestore
  Future<void> removeReminderAndUpdate(String reminder) async {
    if (reminder.isEmpty) {
      throw ArgumentError('نص التذكير لا يمكن أن يكون فارغاً');
    }
    if (!reminders.contains(reminder)) {
      throw StateError('التذكير غير موجود');
    }
    reminders.remove(reminder);
    await updateInFirestore();
  }

  // تعيين وقت التذكير مع التحديث في Firestore
  Future<void> setReminderTimeAndUpdate(DateTime time) async {
    if (time.isBefore(DateTime.now())) {
      throw ArgumentError('وقت التذكير يجب أن يكون في المستقبل');
    }
    reminderTime = time;
    await updateInFirestore();
  }

  // إلغاء وقت التذكير مع التحديث في Firestore
  Future<void> clearReminderTimeAndUpdate() async {
    reminderTime = null;
    await updateInFirestore();
  }

  // تغيير حالة المهمة مع التحديث في Firestore
  Future<void> setStatusAndUpdate(String newStatus) async {
    if (newStatus.isEmpty) {
      throw ArgumentError('حالة المهمة لا يمكن أن تكون فارغة');
    }

    // يمكنك أيضاً إضافة تحقق من قائمة محددة مسبقاً للحالات المسموح بها
    final validStatuses = ['قيد التنفيذ', 'مكتملة', 'معلقة', 'ملغاة'];
    if (!validStatuses.contains(newStatus)) {
      throw ArgumentError(
          'حالة المهمة غير صالحة. الحالات المسموح بها: ${validStatuses.join(', ')}');
    }

    status = newStatus;

    // تحديث تاريخ الإكمال إذا تغيرت الحالة إلى "مكتملة"
    if (newStatus == 'مكتملة') {
      completedDate = DateTime.now();
      progress = 1.0; // اكتمال نسبة التقدم تلقائيًا
    } else if (completedDate != null) {
      completedDate = null; // مسح تاريخ الإكمال إذا تم تغيير الحالة من "مكتملة"
    }

    await updateInFirestore();
  }

  // تغيير أولوية المهمة
  Future<void> setPriorityAndUpdate(String newPriority) async {
    if (!['منخفضة', 'متوسطة', 'عالية'].contains(newPriority)) {
      throw ArgumentError(
          'الأولوية يجب أن تكون إحدى القيم: منخفضة، متوسطة، عالية');
    }

    priority = newPriority;
    await updateInFirestore();
  }

  // التحقق ما إذا كانت المهمة متأخرة
  bool isOverdue() {
    return DateTime.now().isAfter(dueDate) &&
        status != 'مكتملة' &&
        status != 'ملغاة';
  }

  // التحقق ما إذا كانت المهمة قريبة من الموعد النهائي (مثلا، خلال يوم واحد)
  bool isDueSoon({int hoursThreshold = 24}) {
    if (hoursThreshold <= 0) {
      throw ArgumentError('حد الساعات يجب أن يكون أكبر من صفر');
    }

    final difference = dueDate.difference(DateTime.now()).inHours;
    return difference > 0 &&
        difference <= hoursThreshold &&
        status != 'مكتملة' &&
        status != 'ملغاة';
  }

  // التحقق ما إذا كانت المهمة اليوم
  bool isDueToday() {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day &&
        status != 'مكتملة' &&
        status != 'ملغاة';
  }

  // التحقق من إمكانية إكمال المهمة
  bool canComplete() {
    return status != 'مكتملة' && status != 'ملغاة';
  }

  // إكمال المهمة مع التحديث في Firestore
  Future<void> completeAndUpdate() async {
    if (!canComplete()) {
      throw StateError(
          'لا يمكن إكمال هذه المهمة: ${status == 'مكتملة' ? 'المهمة مكتملة بالفعل' : 'المهمة ملغاة'}');
    }

    status = 'مكتملة';
    completedDate = DateTime.now();
    progress = 1.0;

    await updateInFirestore();
  }

  // إلغاء المهمة مع التحديث في Firestore
  Future<void> cancelAndUpdate() async {
    if (status == 'مكتملة' || status == 'ملغاة') {
      throw StateError(
          'لا يمكن إلغاء هذه المهمة: ${status == 'مكتملة' ? 'المهمة مكتملة بالفعل' : 'المهمة ملغاة بالفعل'}');
    }

    status = 'ملغاة';
    await updateInFirestore();
  }

  // التحقق مما إذا كان يمكن تذكير المهمة
  bool canRemind() {
    return reminderTime != null &&
        reminderTime!.isAfter(DateTime.now()) &&
        status != 'مكتملة' &&
        status != 'ملغاة';
  }

  // التحقق مما إذا كانت المهمة مرتبطة بكورس
  bool isAssignedToCourse() {
    return courseId != null && courseId!.isNotEmpty;
  }

  // الحصول على لون المهمة بناءً على الحالة أو لون مخصص
  Color getDisplayColor() {
    // إذا كان هناك لون مخصص، استخدمه
    if (color != null) {
      return color!;
    }

    // وإلا استخدم لونًا بناءً على الحالة
    switch (status) {
      case 'مكتملة':
        return Colors.green;
      case 'قيد التنفيذ':
        return Colors.blue;
      case 'معلقة':
        return Colors.orange;
      case 'ملغاة':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  // الحصول على أيقونة المهمة بناءً على الحالة
  IconData getDisplayIcon() {
    switch (status) {
      case 'مكتملة':
        return Icons.check_circle;
      case 'قيد التنفيذ':
        return Icons.pending_actions;
      case 'معلقة':
        return Icons.pause_circle_outline;
      case 'ملغاة':
        return Icons.cancel_outlined;
      default:
        return Icons.task_alt;
    }
  }

  // الحصول على الأيام المتبقية حتى الموعد النهائي
  int getDaysUntilDue() {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  // الاستماع إلى تغييرات مهمة معينة في الوقت الفعلي
  static Stream<Task> listenToTask(String taskId, {Course? course}) async* {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    yield* tasksCollectionForUser(currentUser.uid)
        .doc(taskId)
        .snapshots()
        .map((doc) => fromFirestore(doc, course: course));
  }

  // الاستماع إلى تغييرات مهام مساق معين في الوقت الفعلي
  static Stream<List<Task>> listenToCourseTasks(Course course) async* {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    yield* tasksCollectionForUser(currentUser.uid)
        .where('courseId', isEqualTo: course.id)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      List<Task> tasks = [];
      for (var doc in snapshot.docs) {
        tasks.add(fromFirestore(doc, course: course));
      }
      return tasks;
    });
  }

  // الاستماع إلى تغييرات جميع المهام في الوقت الفعلي
  static Stream<List<Task>> listenToAllTasks() async* {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    // نحتاج إلى تحميل الكورسات أولاً
    final coursesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('courses')
        .get();

    final courses = coursesSnapshot.docs.map((doc) {
      return Course.fromMap(doc.data(), doc.id);
    }).toList();

    yield* tasksCollectionForUser(currentUser.uid)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      List<Task> tasks = [];
      for (var doc in snapshot.docs) {
        final taskData = doc.data();
        final courseId = taskData != null
            ? (taskData as Map<String, dynamic>)['courseId'] as String?
            : null;

        Course? taskCourse;
        if (courseId != null) {
          taskCourse = courses.firstWhere(
            (c) => c.id == courseId,
          );
        }

        tasks.add(fromFirestore(doc, course: taskCourse));
      }
      return tasks;
    });
  }

  // الاستماع إلى تغييرات المهام غير المرتبطة بكورس في الوقت الفعلي
  static Stream<List<Task>> listenToTasksWithoutCourse() async* {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    yield* tasksCollectionForUser(currentUser.uid)
        .where('courseId', isNull: true)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      List<Task> tasks = [];
      for (var doc in snapshot.docs) {
        tasks.add(fromFirestore(doc));
      }
      return tasks;
    });
  }

  // الحصول على ملخص لإحصائيات المهام
  static Future<Map<String, int>> getTasksStatistics({Course? course}) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      // تحميل المهام المناسبة
      List<Task> tasks;
      if (course != null) {
        tasks = await getTasksForCourse(course);
      } else {
        tasks = await getAllTasks();
      }

      // تاريخ اليوم
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // حساب الإحصائيات
      int totalTasks = tasks.length;
      int completedTasks =
          tasks.where((task) => task.status == 'مكتملة').length;
      int overdueTasks = tasks
          .where((task) =>
              task.dueDate.isBefore(today) &&
              task.status != 'مكتملة' &&
              task.status != 'ملغاة')
          .length;
      int todayTasks = tasks
          .where((task) =>
              task.dueDate.year == today.year &&
              task.dueDate.month == today.month &&
              task.dueDate.day == today.day &&
              task.status != 'مكتملة' &&
              task.status != 'ملغاة')
          .length;
      int upcomingTasks = tasks
          .where((task) =>
              task.dueDate.isAfter(today) &&
              task.status != 'مكتملة' &&
              task.status != 'ملغاة')
          .length;
      int highPriorityTasks = tasks
          .where((task) =>
              task.priority == 'عالية' &&
              task.status != 'مكتملة' &&
              task.status != 'ملغاة')
          .length;

      return {
        'total': totalTasks,
        'completed': completedTasks,
        'overdue': overdueTasks,
        'today': todayTasks,
        'upcoming': upcomingTasks,
        'highPriority': highPriorityTasks,
      };
    } catch (e) {
      print('فشل في الحصول على إحصائيات المهام: $e');
      return {
        'total': 0,
        'completed': 0,
        'overdue': 0,
        'today': 0,
        'upcoming': 0,
        'highPriority': 0,
      };
    }
  }

  // إضافة دوال الإشعارات والتذكيرات

  // دالة لجدولة تذكير للمهمة
  Future<void> scheduleReminder() async {
    if (reminderTime != null) {
      await NotificationsService().scheduleTaskReminder(this);
    }
  }

  // دالة لإلغاء تذكير المهمة
  Future<void> cancelReminder() async {
    await NotificationsService().cancelTaskReminder(id);
  }

  // تحديث تذكير المهمة
  Future<void> updateReminder() async {
    // إلغاء التذكير القديم أولاً
    await cancelReminder();

    // ثم جدولة التذكير الجديد إذا كان مفعلاً
    if (reminderTime != null) {
      await scheduleReminder();
    }
  }
}
