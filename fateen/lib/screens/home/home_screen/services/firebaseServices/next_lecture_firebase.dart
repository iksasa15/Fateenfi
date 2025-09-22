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
        } else if (lectureDay != null) {
          // تحويل اسم اليوم إلى رقم
          dayOfWeek = _getDayNumberFromName(lectureDay);
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
          } else if (lectureDay != null) {
            // تحويل اسم اليوم إلى رقم
            dayOfWeek = _getDayNumberFromName(lectureDay);
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

  /// تحديث أيام المحاضرات للمقررات التي لا تحتوي على أيام محاضرات
  Future<void> updateCourseDays() async {
    if (currentUser == null) {
      debugPrint('لا يوجد مستخدم مسجل دخول لتحديث أيام المحاضرات');
      return;
    }

    try {
      final userId = currentUser!.uid;
      final courseCollection =
          _firestore.collection('users').doc(userId).collection('courses');

      final snapshot = await courseCollection.get();
      int updatedCount = 0;

      // تحديث كل مقرر ليحتوي على يوم محاضرة
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final courseName =
            data[NextLectureConstants.courseNameField] ?? 'مقرر غير معروف';

        // التحقق من وجود يوم محاضرة
        final hasLectureDay = data.containsKey('lectureDay') &&
            data['lectureDay'] != null &&
            data['lectureDay'] != '';
        final hasDayOfWeek =
            data.containsKey(NextLectureConstants.dayOfWeekField) &&
                data[NextLectureConstants.dayOfWeekField] != null;

        if (!hasLectureDay && !hasDayOfWeek) {
          // تعيين يوم افتراضي (يوم مختلف لكل مقرر)
          final defaultDay =
              (updatedCount % 5) + 1; // توزيع على أيام الأسبوع (1-5)
          final dayName = _getDayNameFromNumber(defaultDay);

          // تحديث المقرر
          await courseCollection.doc(doc.id).update({
            NextLectureConstants.dayOfWeekField: defaultDay,
            'lectureDay': dayName
          });

          debugPrint(
              'تم تحديث مقرر: $courseName، يوم المحاضرة: $dayName ($defaultDay)');
          updatedCount++;
        } else if (hasLectureDay && !hasDayOfWeek) {
          // إذا كان لدينا فقط اسم اليوم، نضيف رقم اليوم
          final dayName = data['lectureDay'].toString();
          final dayNumber = _getDayNumberFromName(dayName);

          if (dayNumber != null) {
            await courseCollection
                .doc(doc.id)
                .update({NextLectureConstants.dayOfWeekField: dayNumber});
            debugPrint('تم إضافة رقم اليوم $dayNumber للمقرر: $courseName');
          }
        } else if (!hasLectureDay && hasDayOfWeek) {
          // إذا كان لدينا فقط رقم اليوم، نضيف اسم اليوم
          final dayNumber = data[NextLectureConstants.dayOfWeekField];
          final dayName = _getDayNameFromNumber(dayNumber);

          await courseCollection.doc(doc.id).update({'lectureDay': dayName});
          debugPrint('تم إضافة اسم اليوم $dayName للمقرر: $courseName');
        }

        // أيضًا تحقق من وقت المحاضرة وأضفه إذا كان غير موجود
        final hasLectureTime =
            data.containsKey(NextLectureConstants.lectureTimeField) &&
                data[NextLectureConstants.lectureTimeField] != null &&
                data[NextLectureConstants.lectureTimeField] != '';

        if (!hasLectureTime) {
          // توزيع أوقات المحاضرات بين 9 صباحًا و3 مساءً
          final hours = [9, 10, 11, 12, 14, 15];
          final defaultHour = hours[updatedCount % hours.length];
          final defaultTime = '$defaultHour:30';

          // تحديث المقرر بإضافة وقت المحاضرة
          await courseCollection
              .doc(doc.id)
              .update({NextLectureConstants.lectureTimeField: defaultTime});

          debugPrint('تم تحديث مقرر: $courseName، وقت المحاضرة: $defaultTime');
        }

        // أيضًا تحقق من القاعة وأضفها إذا كانت غير موجودة
        final hasClassroom =
            data.containsKey(NextLectureConstants.classroomField) &&
                data[NextLectureConstants.classroomField] != null &&
                data[NextLectureConstants.classroomField] != '';

        if (!hasClassroom) {
          // إضافة قاعة افتراضية
          final defaultClassroom = 'قاعة ${100 + (updatedCount % 20)}';

          // تحديث المقرر بإضافة القاعة
          await courseCollection
              .doc(doc.id)
              .update({NextLectureConstants.classroomField: defaultClassroom});

          debugPrint('تم تحديث مقرر: $courseName، القاعة: $defaultClassroom');
        }
      }

      debugPrint(
          'تم تحديث أيام المحاضرات وبيانات إضافية لـ $updatedCount مقرر');
    } catch (e) {
      debugPrint('خطأ في تحديث أيام المحاضرات: $e');
    }
  }

  /// تحويل رقم اليوم إلى اسمه
  String _getDayNameFromNumber(int number) {
    final Map<int, String> days = {
      1: 'الاثنين',
      2: 'الثلاثاء',
      3: 'الأربعاء',
      4: 'الخميس',
      5: 'الجمعة',
      6: 'السبت',
      7: 'الأحد',
    };
    return days[number] ?? 'غير معروف';
  }

  /// تحويل اسم اليوم إلى رقمه (مطابق لـ DateTime.weekday)
  int? _getDayNumberFromName(String dayName) {
    final Map<String, int> days = {
      'الاثنين': 1,
      'الثلاثاء': 2,
      'الأربعاء': 3,
      'الخميس': 4,
      'الجمعة': 5,
      'السبت': 6,
      'الأحد': 7,
    };
    return days[dayName];
  }

  /// الحصول على المحاضرة التالية بناءً على اليوم الحالي
  Future<Map<String, dynamic>?> getNextLecture() async {
    try {
      final courses = await fetchCourses();
      if (courses.isEmpty) {
        debugPrint('لا توجد مقررات متاحة للبحث عن المحاضرة التالية');
        return null;
      }

      // الحصول على اليوم الحالي (1 = الاثنين، 7 = الأحد)
      final now = DateTime.now();
      final currentDayOfWeek = now.weekday;
      final currentHour = now.hour;
      final currentMinute = now.minute;

      debugPrint(
          'اليوم الحالي: ${_getDayNameFromNumber(currentDayOfWeek)}, الساعة: $currentHour:$currentMinute');

      // تحويل الوقت الحالي إلى دقائق منذ بداية اليوم
      final currentTimeInMinutes = currentHour * 60 + currentMinute;

      // ترتيب المقررات حسب اليوم والوقت
      List<Map<String, dynamic>> validCourses = [];

      for (var course in courses) {
        final courseName = course[NextLectureConstants.courseNameField];
        dynamic dayOfWeekValue = course[NextLectureConstants.dayOfWeekField];
        int? dayOfWeek;

        // التأكد من أن لدينا رقم يوم صحيح
        if (dayOfWeekValue is int) {
          dayOfWeek = dayOfWeekValue;
        } else if (dayOfWeekValue is String && dayOfWeekValue.isNotEmpty) {
          dayOfWeek = int.tryParse(dayOfWeekValue);
        } else if (course['lectureDay'] != null) {
          dayOfWeek = _getDayNumberFromName(course['lectureDay'].toString());
        }

        if (dayOfWeek == null) {
          debugPrint('لا يمكن تحديد يوم المحاضرة للمقرر: $courseName');
          continue;
        }

        // تحويل وقت المحاضرة إلى دقائق
        String lectureTimeStr =
            course[NextLectureConstants.lectureTimeField] ?? '';
        int? lectureTimeInMinutes = _parseTimeToMinutes(lectureTimeStr);

        if (lectureTimeInMinutes == null) {
          debugPrint('لا يمكن تحويل وقت المحاضرة للمقرر: $courseName');
          continue;
        }

        // تخزين المعلومات المحسوبة مع المقرر
        course['_dayOfWeekNumber'] = dayOfWeek;
        course['_lectureTimeInMinutes'] = lectureTimeInMinutes;

        validCourses.add(course);
      }

      // تصنيف المقررات إلى مقررات اليوم الحالي والأيام المستقبلية
      List<Map<String, dynamic>> todayCourses = [];
      List<Map<String, dynamic>> futureCourses = [];

      for (var course in validCourses) {
        final courseDay = course['_dayOfWeekNumber'] as int;
        final courseTime = course['_lectureTimeInMinutes'] as int;

        if (courseDay == currentDayOfWeek) {
          if (courseTime > currentTimeInMinutes) {
            // محاضرة اليوم ولم تبدأ بعد
            todayCourses.add(course);
          }
        } else if ((courseDay > currentDayOfWeek) ||
            (courseDay < currentDayOfWeek)) {
          // لمراعاة أيام الأسبوع القادم
          futureCourses.add(course);
        }
      }

      // ترتيب محاضرات اليوم حسب الوقت
      todayCourses.sort((a, b) {
        final aTime = a['_lectureTimeInMinutes'] as int;
        final bTime = b['_lectureTimeInMinutes'] as int;
        return aTime.compareTo(bTime);
      });

      // ترتيب المحاضرات المستقبلية حسب اليوم ثم الوقت
      futureCourses.sort((a, b) {
        final aDayOfWeek = a['_dayOfWeekNumber'] as int;
        final bDayOfWeek = b['_dayOfWeekNumber'] as int;

        // حساب الأيام المتبقية من اليوم الحالي
        int aDaysFromNow = (aDayOfWeek - currentDayOfWeek + 7) % 7;
        if (aDaysFromNow == 0)
          aDaysFromNow = 7; // إذا كانت النتيجة 0، فهذا يعني 7 أيام

        int bDaysFromNow = (bDayOfWeek - currentDayOfWeek + 7) % 7;
        if (bDaysFromNow == 0) bDaysFromNow = 7;

        // مقارنة الأيام أولاً
        final dayComparison = aDaysFromNow.compareTo(bDaysFromNow);
        if (dayComparison != 0) return dayComparison;

        // إذا كان نفس اليوم، قارن الوقت
        final aTime = a['_lectureTimeInMinutes'] as int;
        final bTime = b['_lectureTimeInMinutes'] as int;
        return aTime.compareTo(bTime);
      });

      // البحث عن المحاضرة التالية
      Map<String, dynamic>? nextLecture;

      if (todayCourses.isNotEmpty) {
        // المحاضرة التالية هي أول محاضرة في اليوم الحالي
        nextLecture = todayCourses.first;
        debugPrint(
            'المحاضرة التالية هي محاضرة اليوم: ${nextLecture[NextLectureConstants.courseNameField]}');
      } else if (futureCourses.isNotEmpty) {
        // المحاضرة التالية هي أول محاضرة في الأيام القادمة
        nextLecture = futureCourses.first;
        debugPrint(
            'المحاضرة التالية هي في يوم آخر: ${nextLecture[NextLectureConstants.courseNameField]}');
      }

      return nextLecture;
    } catch (e) {
      debugPrint('خطأ في الحصول على المحاضرة التالية: $e');
      return null;
    }
  }

  /// تحويل سلسلة الوقت (مثل "10:30") إلى عدد الدقائق منذ بداية اليوم
  int? _parseTimeToMinutes(String timeStr) {
    if (timeStr.isEmpty) return null;

    // دعم صيغ مختلفة (10:30، 10.30، 10,30، 10-30)
    timeStr =
        timeStr.replaceAll('.', ':').replaceAll(',', ':').replaceAll('-', ':');

    final parts = timeStr.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return hour * 60 + minute;
  }
}
