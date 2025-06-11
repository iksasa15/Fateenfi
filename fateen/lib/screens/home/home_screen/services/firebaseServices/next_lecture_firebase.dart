import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/next_lecture_constants.dart';

/// خدمة التعامل مع Firebase للمحاضرات
class NextLectureFirebase {
  // مراجع Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// جلب المقررات من Firebase
  Future<List<Map<String, dynamic>>> fetchCourses() async {
    if (currentUser == null) {
      debugPrint('لا يوجد مستخدم مسجل دخول لجلب المقررات');
      return [];
    }

    try {
      final userId = currentUser!.uid;
      debugPrint('جلب المقررات للمستخدم: $userId');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('لم يتم العثور على مقررات للمستخدم $userId');
        return [];
      }

      final loadedCourses = snapshot.docs.map((doc) {
        final data = doc.data();

        // طباعة بيانات المقرر كاملة للتشخيص
        debugPrint('بيانات المقرر الخام: ${doc.id} => $data');

        // استخدام courseName بدلاً من name للتوافق مع كلاس Course
        final name = data[NextLectureConstants.courseNameField] ??
            data[NextLectureConstants.courseOldNameField] ??
            'مقرر بدون اسم';

        // التحقق من وجود يوم المحاضرة (lectureDay) - أولوية أولى
        String? lectureDay;
        if (data.containsKey('lectureDay') && data['lectureDay'] != null) {
          lectureDay = data['lectureDay'].toString();
        }

        // التحقق من وجود رقم يوم الأسبوع (dayOfWeek) - أولوية ثانية
        dynamic dayOfWeek;
        if (data.containsKey(NextLectureConstants.dayOfWeekField) &&
            data[NextLectureConstants.dayOfWeekField] != null) {
          dayOfWeek = data[NextLectureConstants.dayOfWeekField];
        }

        // إنشاء كائن المقرر مع معالجة حقول الوقت والقاعة
        return {
          NextLectureConstants.idField: doc.id,
          NextLectureConstants.courseNameField: name,
          NextLectureConstants.lectureTimeField:
              data[NextLectureConstants.lectureTimeField]?.toString() ?? '',
          NextLectureConstants.classroomField:
              data[NextLectureConstants.classroomField]?.toString() ?? '',
          NextLectureConstants.dayOfWeekField: dayOfWeek,
          'lectureDay': lectureDay,
        };
      }).toList();

      debugPrint('تم جلب ${loadedCourses.length} مقرر بنجاح من Firebase');

      // تشخيص المقررات التي تم تحميلها
      for (var course in loadedCourses) {
        debugPrint(
            'تم تحميل المقرر: ${course[NextLectureConstants.courseNameField]}, '
            'يوم: ${course['lectureDay'] ?? course[NextLectureConstants.dayOfWeekField] ?? 'غير محدد'}, '
            'وقت: ${course[NextLectureConstants.lectureTimeField]}, '
            'قاعة: ${course[NextLectureConstants.classroomField]}');
      }

      return loadedCourses;
    } catch (e) {
      debugPrint('حدث خطأ أثناء جلب المقررات من Firebase: $e');
      throw e;
    }
  }

  /// الاستماع للتغييرات في المقررات
  Stream<List<Map<String, dynamic>>> listenToCourses() {
    if (currentUser == null) {
      debugPrint('لا يوجد مستخدم مسجل دخول للاستماع للتغييرات في المقررات');
      return Stream.value([]);
    }

    try {
      final userId = currentUser!.uid;
      debugPrint('بدء الاستماع للتغييرات في مقررات المستخدم: $userId');

      return _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .snapshots()
          .map((snapshot) {
        final courses = snapshot.docs.map((doc) {
          final data = doc.data();

          // استخدام courseName بدلاً من name للتوافق
          final name = data[NextLectureConstants.courseNameField] ??
              data[NextLectureConstants.courseOldNameField] ??
              'مقرر بدون اسم';

          // التحقق من وجود يوم المحاضرة (lectureDay) - أولوية أولى
          String? lectureDay;
          if (data.containsKey('lectureDay') && data['lectureDay'] != null) {
            lectureDay = data['lectureDay'].toString();
          }

          // التحقق من وجود رقم يوم الأسبوع (dayOfWeek) - أولوية ثانية
          dynamic dayOfWeek;
          if (data.containsKey(NextLectureConstants.dayOfWeekField) &&
              data[NextLectureConstants.dayOfWeekField] != null) {
            dayOfWeek = data[NextLectureConstants.dayOfWeekField];
          }

          return {
            NextLectureConstants.idField: doc.id,
            NextLectureConstants.courseNameField: name,
            NextLectureConstants.lectureTimeField:
                data[NextLectureConstants.lectureTimeField]?.toString() ?? '',
            NextLectureConstants.classroomField:
                data[NextLectureConstants.classroomField]?.toString() ?? '',
            NextLectureConstants.dayOfWeekField: dayOfWeek,
            'lectureDay': lectureDay,
          };
        }).toList();

        debugPrint('تم استلام تحديث: ${courses.length} مقرر من Firebase');
        return courses;
      });
    } catch (e) {
      debugPrint('خطأ في إنشاء مستمع المقررات: $e');
      return Stream.value([]);
    }
  }
}
