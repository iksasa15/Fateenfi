import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/next_lecture_constants.dart';
import '../services/firebaseServices/next_lecture_firebase.dart';

/// وحدة تحكم للمحاضرة القادمة
class NextLectureController extends ChangeNotifier {
  // خدمة Firebase
  final NextLectureFirebase _firebase = NextLectureFirebase();

  // حالة التحميل
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  // قائمة المقررات
  List<Map<String, dynamic>> coursesData = [];

  // بيانات المحاضرة القادمة
  Map<String, dynamic>? nextLectureMap;

  // مؤقت لتحديث الوقت كل ثانية
  Timer? _timer;

  // متغيرات للتتبع
  StreamSubscription? _coursesSubscription;
  int? _initialDiffSeconds;
  String? _initialLectureName;

  /// إنشاء وحدة التحكم
  NextLectureController() {
    // لا نقوم بأي تهيئة في البناء، يجب استدعاء دالة initialize
  }

  /// تهيئة البيانات
  Future<void> initialize() async {
    try {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      notifyListeners();

      // تحديث أيام المحاضرات أولاً
      await _firebase.updateCourseDays();

      // تحميل المقررات
      await _fetchCoursesFromFirestore();

      // الاستماع للتغييرات في المقررات
      _listenToCoursesChanges();

      // بدء المؤقت للمحاضرة القادمة
      _startTimerForLecture();

      isLoading = false;

      // تشخيص المحاضرات للكشف عن المشكلات
      diagnoseLectures();

      notifyListeners();
    } catch (e) {
      isLoading = false;
      hasError = true;
      errorMessage = NextLectureConstants.errorLoadingLectures;
      notifyListeners();
      debugPrint('خطأ في تهيئة وحدة تحكم المحاضرة القادمة: $e');
    }
  }

  /// تحديث البيانات
  Future<void> refresh() async {
    try {
      // لا نعدل حالة التحميل لأن التحديث قد يكون جزءاً من عملية أخرى
      hasError = false;
      errorMessage = '';

      // إعادة تحميل المقررات
      await _fetchCoursesFromFirestore();

      // تحديث المحاضرة القادمة
      _updateNextLectureMap();

      // تشغيل التشخيص بعد التحديث
      diagnoseLectures();

      notifyListeners();
    } catch (e) {
      hasError = true;
      errorMessage = NextLectureConstants.errorLoadingLectures;
      notifyListeners();
      debugPrint('خطأ في تحديث بيانات المحاضرة القادمة: $e');
    }
  }

  /// جلب المقررات من Firestore
  Future<void> _fetchCoursesFromFirestore() async {
    try {
      final loadedCourses = await _firebase.fetchCourses();

      if (loadedCourses.isEmpty) {
        debugPrint('تنبيه: لم يتم العثور على أي مقررات للمستخدم الحالي');
      } else {
        debugPrint('تم تحميل ${loadedCourses.length} مقرر بنجاح');

        // التحقق من بنية بيانات المقررات
        int validCourses = 0;
        for (var course in loadedCourses) {
          final hasCourseName =
              course[NextLectureConstants.courseNameField] != null;
          final hasLectureTime =
              course[NextLectureConstants.lectureTimeField] != null;
          final hasLectureDay = course['lectureDay'] != null ||
              course[NextLectureConstants.dayOfWeekField] != null;

          if (hasCourseName && hasLectureTime && hasLectureDay) {
            validCourses++;
            debugPrint(
                'مقرر صالح: ${course[NextLectureConstants.courseNameField]}');
          } else {
            debugPrint(
                'مقرر غير مكتمل: ${course[NextLectureConstants.courseNameField] ?? 'اسم غير معروف'}, '
                'وقت المحاضرة: ${course[NextLectureConstants.lectureTimeField] ?? 'غير محدد'}, '
                'يوم المحاضرة: ${course['lectureDay'] ?? course[NextLectureConstants.dayOfWeekField] ?? 'غير محدد'}');
          }
        }

        debugPrint(
            'عدد المقررات الصالحة: $validCourses من أصل ${loadedCourses.length}');
      }

      coursesData = loadedCourses;
    } catch (e) {
      debugPrint('خطأ في جلب المقررات: $e');
      throw e;
    }
  }

  /// الاستماع للتغييرات في المقررات
  void _listenToCoursesChanges() {
    try {
      // إلغاء الاشتراك السابق إن وجد
      _coursesSubscription?.cancel();

      // بدء الاستماع للتغييرات
      _coursesSubscription =
          _firebase.listenToCourses().listen((updatedCourses) {
        if (updatedCourses.isEmpty) {
          debugPrint('تم استلام تحديث: لا توجد مقررات');
        } else {
          debugPrint('تم استلام تحديث: ${updatedCourses.length} مقرر');
        }

        coursesData = updatedCourses;

        // تحديث المحاضرة القادمة
        _updateNextLectureMap();
        notifyListeners();
      }, onError: (error) {
        debugPrint('خطأ في مستمع المقررات: $error');
      });
    } catch (e) {
      debugPrint('خطأ في إعداد مستمع المقررات: $e');
    }
  }

  /// بدء مؤقت كل ثانية لإعادة حساب المحاضرة القادمة
  void _startTimerForLecture() {
    _updateNextLectureMap();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateNextLectureMap();
      notifyListeners();
    });
  }

  /// نحسب أقرب محاضرة ونحدّث المتغيرات
  void _updateNextLectureMap() {
    final newMap = _getNextLectureData();
    if (newMap == null) {
      // لا توجد محاضرة قادمة
      nextLectureMap = null;
      // إعادة تعيين القيم
      _initialDiffSeconds = null;
      _initialLectureName = null;
      return;
    }

    final newCourseName =
        newMap[NextLectureConstants.courseNameField] as String;
    final newDiffSeconds = newMap['diffSeconds'] as int;

    // إذا المحاضرة تغيّرت (اسمها مختلف) => نخزّن diffSeconds لأول مرة
    if (_initialLectureName == null || _initialLectureName != newCourseName) {
      _initialDiffSeconds = newDiffSeconds;
      _initialLectureName = newCourseName;
    }

    nextLectureMap = newMap;
    debugPrint(
        'تم تحديث المحاضرة القادمة: $newCourseName، متبقي $newDiffSeconds ثانية');
  }

  /// إيجاد أقرب محاضرة من الآن بغض النظر عن المدة
  Map<String, dynamic>? _getNextLectureData() {
    if (coursesData.isEmpty) {
      debugPrint('لا توجد مقررات لعرض المحاضرة القادمة');
      return null; // لا نقوم بإنشاء محاضرة افتراضية
    }

    final now = DateTime.now();
    DateTime? closest;
    Map<String, dynamic>? chosenCourse;

    for (var course in coursesData) {
      // محاولة الحصول على يوم المحاضرة (إما كاسم يوم أو كرقم)
      var lectureDay = -1;

      // التحقق من وجود حقل lectureDay (النص)
      final lectureDayStr = course['lectureDay'] as String?;
      if (lectureDayStr != null && lectureDayStr.isNotEmpty) {
        lectureDay = _getDayOfWeekFromName(lectureDayStr);
      }
      // التحقق من وجود حقل dayOfWeek (الرقم)
      else if (course[NextLectureConstants.dayOfWeekField] != null) {
        try {
          final dayValue = course[NextLectureConstants.dayOfWeekField];
          if (dayValue is int) {
            lectureDay = dayValue;
          } else if (dayValue is String) {
            lectureDay = int.tryParse(dayValue) ?? -1;
          }
        } catch (e) {
          debugPrint('خطأ في تحويل يوم الأسبوع: $e');
        }
      }

      // التحقق من صحة يوم المحاضرة - استخدام يوم افتراضي إذا لم يكن صالحًا
      if (lectureDay < 1 || lectureDay > 7) {
        // إضافة يوم افتراضي - استخدم اليوم التالي من اليوم الحالي
        final today = now.weekday;
        lectureDay = today >= 7 ? 1 : today + 1;

        debugPrint(
            'استخدام يوم افتراضي للمحاضرة: $lectureDay للمقرر: ${course[NextLectureConstants.courseNameField]}');
      }

      // تحقق من وقت المحاضرة
      final lectureTimeStr =
          course[NextLectureConstants.lectureTimeField] as String?;
      if (lectureTimeStr == null || lectureTimeStr.isEmpty) {
        // استخدام وقت افتراضي إذا لم يكن هناك وقت للمحاضرة
        course[NextLectureConstants.lectureTimeField] = '14:30';
        debugPrint(
            'استخدام وقت افتراضي للمحاضرة: 14:30 للمقرر: ${course[NextLectureConstants.courseNameField]}');
      }

      // تحليل وقت المحاضرة
      int hour = 14; // وقت افتراضي
      int minute = 30; // وقت افتراضي

      // محاولة تحليل التنسيق 00:00
      if (lectureTimeStr != null && lectureTimeStr.contains(':')) {
        final split = lectureTimeStr.split(':');
        if (split.length == 2) {
          hour = int.tryParse(split[0].trim()) ?? hour;
          minute = int.tryParse(split[1].trim()) ?? minute;
          debugPrint('تحليل وقت المحاضرة بصيغة HH:MM: $hour:$minute');
        }
      }
      // محاولة تحليل تنسيقات أخرى محتملة
      else if (lectureTimeStr != null && lectureTimeStr.isNotEmpty) {
        try {
          // محاولة تحليل عدة صيغ محتملة
          if (lectureTimeStr.contains('.')) {
            // صيغة عشرية مثل 14.30
            final timeValue = double.tryParse(lectureTimeStr);
            if (timeValue != null) {
              hour = timeValue.toInt();
              minute = ((timeValue - hour) * 60).toInt();
              debugPrint('تحليل وقت المحاضرة بصيغة عشرية: $hour:$minute');
            }
          } else {
            // صيغة مثل 1430 تعني 14:30
            if (lectureTimeStr.length == 4) {
              hour = int.tryParse(lectureTimeStr.substring(0, 2)) ?? hour;
              minute = int.tryParse(lectureTimeStr.substring(2, 4)) ?? minute;
              debugPrint('تحليل وقت المحاضرة بصيغة HHMM: $hour:$minute');
            } else {
              // محاولة التحويل المباشر إلى رقم
              final timeValue = double.tryParse(lectureTimeStr);
              if (timeValue != null) {
                hour = timeValue.toInt();
                minute = 0;
                debugPrint('تحليل وقت المحاضرة كرقم: $hour:$minute');
              }
            }
          }
        } catch (e) {
          debugPrint('خطأ في تحليل وقت المحاضرة: $e');
        }
      }

      // حساب التاريخ الفعلي للمحاضرة القادمة
      var lectureDateTime =
          _getNextDateForWeekday(now, lectureDay, hour, minute);

      // التحقق من أن المحاضرة في المستقبل
      final diffSeconds = lectureDateTime.difference(now).inSeconds;
      if (diffSeconds <= 0) {
        debugPrint(
            'المحاضرة في الماضي للمقرر: ${course[NextLectureConstants.courseNameField]}');
        continue;
      }

      // إضافة بيانات تصحيح
      debugPrint(
          'محاضرة محتملة: ${course[NextLectureConstants.courseNameField]}, يوم: $lectureDay, وقت: $hour:$minute, تبقى: $diffSeconds ثانية (${(diffSeconds / 3600).toStringAsFixed(1)} ساعة)');

      if (closest == null || lectureDateTime.isBefore(closest)) {
        closest = lectureDateTime;
        chosenCourse = course;
      }
    }

    // إذا لم نجد محاضرة مناسبة، نرجع null
    if (closest == null) {
      debugPrint('لم يتم العثور على محاضرات قادمة');
      return null;
    }

    // فارق الثواني
    final diffSeconds = closest.difference(now).inSeconds;

    // إنشاء بيانات المحاضرة القادمة
    final result = {
      NextLectureConstants.courseNameField:
          chosenCourse?[NextLectureConstants.courseNameField] ??
              'مقرر غير معروف',
      NextLectureConstants.classroomField:
          chosenCourse?[NextLectureConstants.classroomField] ??
              'قاعة غير معروفة',
      'diffSeconds': diffSeconds,
      'lectureDay': chosenCourse?['lectureDay'] ?? '',
      'lectureDate': closest.toString(),
    };

    debugPrint(
        'تم اختيار المحاضرة القادمة: ${result[NextLectureConstants.courseNameField]}, الوقت المتبقي: $diffSeconds ثانية (${(diffSeconds / 3600).toStringAsFixed(1)} ساعة)');
    return result;
  }

  /// تحويل اسم اليوم إلى رقم اليوم في الأسبوع (1=الاثنين، 7=الأحد)
  int _getDayOfWeekFromName(String dayName) {
    final Map<String, int> daysMap = {
      'الاثنين': 1,
      'الثلاثاء': 2,
      'الأربعاء': 3,
      'الخميس': 4,
      'الجمعة': 5,
      'السبت': 6,
      'الأحد': 7,
    };

    // محاولة تحليل النص مع مراعاة التشكيل والمسافات
    String normalizedDayName = dayName.trim();
    // إزالة أل التعريف إذا وجدت
    if (normalizedDayName.startsWith('ال')) {
      normalizedDayName = normalizedDayName.substring(2);
    }

    // البحث أولاً عن التطابق المباشر
    int? result = daysMap[normalizedDayName];

    // إذا لم يتم العثور، نحاول البحث بطريقة أكثر مرونة
    if (result == null) {
      for (var entry in daysMap.entries) {
        if (normalizedDayName.contains(entry.key)) {
          result = entry.value;
          break;
        }
      }
    }

    // إذا لم يتم العثور، نتحقق من أرقام الأيام مباشرة
    if (result == null) {
      result = int.tryParse(normalizedDayName) ?? -1;
    }

    debugPrint('تحويل اسم اليوم: $dayName => ${result ?? -1}');
    return result ?? -1;
  }

  /// الحصول على التاريخ التالي ليوم معين في الأسبوع
  DateTime _getNextDateForWeekday(
      DateTime now, int targetWeekday, int hour, int minute) {
    // تشخيص متغيرات الإدخال
    debugPrint('حساب موعد المحاضرة:');
    debugPrint('الوقت الحالي: $now');
    debugPrint('اليوم المستهدف: $targetWeekday، الساعة: $hour:$minute');

    // في نظامنا وفي Dart: 1=الاثنين، 7=الأحد
    // لذا لا نحتاج لتحويل رقم اليوم

    debugPrint('اليوم المستهدف: $targetWeekday، اليوم الحالي: ${now.weekday}');

    // حساب عدد الأيام للوصول إلى اليوم المستهدف
    int daysUntil;

    if (targetWeekday == now.weekday) {
      // نفس اليوم، نتحقق من الوقت
      final lectureTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (now.isAfter(lectureTime)) {
        // إذا انتهت المحاضرة اليوم، ننتظر للأسبوع القادم
        daysUntil = 7;
        debugPrint('المحاضرة في نفس اليوم لكن انتهت، إضافة 7 أيام');
      } else {
        // المحاضرة اليوم ولم تبدأ بعد
        daysUntil = 0;
        debugPrint('المحاضرة اليوم ولم تبدأ بعد، daysUntil = 0');
      }
    } else {
      // يوم مختلف، نحسب الفرق
      daysUntil = targetWeekday - now.weekday;

      // تصحيح إذا كان اليوم المستهدف قبل اليوم الحالي في الأسبوع
      if (daysUntil < 0) {
        daysUntil += 7;
        debugPrint('اليوم المستهدف قبل اليوم الحالي، إضافة 7 أيام: $daysUntil');
      } else {
        debugPrint('اليوم المستهدف بعد اليوم الحالي بـ $daysUntil يوم');
      }
    }

    // إنشاء تاريخ المحاضرة
    final lectureDate = DateTime(
      now.year,
      now.month,
      now.day + daysUntil,
      hour,
      minute,
    );

    debugPrint('تاريخ المحاضرة المحسوب: $lectureDate');
    return lectureDate;
  }

  /// تنسيق وقت المحاضرة القادمة (للعرض كنص)
  String formatNextLectureTime(int diffSeconds) {
    final days = diffSeconds ~/ 86400; // 86400 ثانية في اليوم
    final hours = (diffSeconds % 86400) ~/ 3600;
    final minutes = (diffSeconds % 3600) ~/ 60;

    if (days > 0) {
      if (hours > 0) {
        return '${NextLectureConstants.startsInText} $days ${_getDayUnit(days)} ${NextLectureConstants.andText} $hours ${_getHourUnit(hours)}';
      } else {
        return '${NextLectureConstants.startsInText} $days ${_getDayUnit(days)}';
      }
    } else if (hours > 0) {
      if (minutes > 0) {
        return '${NextLectureConstants.startsInText} $hours ${_getHourUnit(hours)} ${NextLectureConstants.andText} $minutes ${_getMinuteUnit(minutes)}';
      } else {
        return '${NextLectureConstants.startsInText} $hours ${_getHourUnit(hours)}';
      }
    } else {
      return '${NextLectureConstants.startsInText} $minutes ${_getMinuteUnit(minutes)}';
    }
  }

  // وحدات الوقت بالتذكير والتأنيث المناسب
  String _getDayUnit(int count) {
    if (count == 1) return 'يوم';
    if (count == 2) return 'يومين';
    if (count >= 3 && count <= 10) return 'أيام';
    return 'يوماً';
  }

  String _getHourUnit(int count) {
    if (count == 1) return 'ساعة';
    if (count == 2) return 'ساعتين';
    if (count >= 3 && count <= 10) return 'ساعات';
    return 'ساعة';
  }

  String _getMinuteUnit(int count) {
    if (count == 1) return 'دقيقة';
    if (count == 2) return 'دقيقتين';
    if (count >= 3 && count <= 10) return 'دقائق';
    return 'دقيقة';
  }

  /// دالة تشخيص متقدمة لكشف مشكلات المحاضرات
  void diagnoseLectures() {
    final now = DateTime.now();

    debugPrint('=== تشخيص المحاضرات ===');
    debugPrint('الوقت الحالي: $now');
    debugPrint('عدد المقررات: ${coursesData.length}');

    for (var course in coursesData) {
      final courseName = course[NextLectureConstants.courseNameField];
      final lectureTimeStr = course[NextLectureConstants.lectureTimeField];
      final lectureDayStr = course['lectureDay'];
      final dayOfWeek = course[NextLectureConstants.dayOfWeekField];

      debugPrint('\nمقرر: $courseName');
      debugPrint('وقت المحاضرة: $lectureTimeStr');
      debugPrint('يوم المحاضرة (نص): $lectureDayStr');
      debugPrint('يوم المحاضرة (رقم): $dayOfWeek');

      // محاولة حساب موعد المحاضرة القادمة لهذا المقرر
      try {
        int lectureDay = -1;

        if (lectureDayStr != null && lectureDayStr.isNotEmpty) {
          lectureDay = _getDayOfWeekFromName(lectureDayStr);
          debugPrint(
              'تم تحويل يوم المحاضرة من النص: $lectureDayStr => $lectureDay');
        } else if (dayOfWeek != null) {
          if (dayOfWeek is int) {
            lectureDay = dayOfWeek;
          } else if (dayOfWeek is String) {
            lectureDay = int.tryParse(dayOfWeek) ?? -1;
          }
          debugPrint('تم استخدام رقم يوم المحاضرة: $lectureDay');
        }

        if (lectureDay < 1 || lectureDay > 7) {
          debugPrint('❌ يوم المحاضرة غير صالح: $lectureDay');
          continue;
        }

        // تحليل وقت المحاضرة
        int hour = -1;
        int minute = -1;

        if (lectureTimeStr != null && lectureTimeStr.isNotEmpty) {
          if (lectureTimeStr.contains(':')) {
            final split = lectureTimeStr.split(':');
            if (split.length == 2) {
              hour = int.tryParse(split[0].trim()) ?? -1;
              minute = int.tryParse(split[1].trim()) ?? -1;
              debugPrint('تم تحليل الوقت كـ $hour:$minute');
            }
          } else if (lectureTimeStr.contains('.')) {
            final timeValue = double.tryParse(lectureTimeStr);
            if (timeValue != null) {
              hour = timeValue.toInt();
              minute = ((timeValue - hour) * 60).toInt();
              debugPrint('تم تحليل الوقت العشري كـ $hour:$minute');
            }
          } else if (lectureTimeStr.length == 4) {
            hour = int.tryParse(lectureTimeStr.substring(0, 2)) ?? -1;
            minute = int.tryParse(lectureTimeStr.substring(2, 4)) ?? -1;
            debugPrint('تم تحليل الوقت كـ $hour:$minute من HHMM');
          } else {
            final timeValue = double.tryParse(lectureTimeStr);
            if (timeValue != null) {
              hour = timeValue.toInt();
              minute = 0;
              debugPrint('تم تحليل الوقت كساعة فقط: $hour:00');
            }
          }
        }

        if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
          debugPrint('❌ وقت المحاضرة غير صالح: $hour:$minute');
          continue;
        }

        // حساب موعد المحاضرة القادمة
        final lectureDateTime =
            _getNextDateForWeekday(now, lectureDay, hour, minute);
        final diffSeconds = lectureDateTime.difference(now).inSeconds;

        debugPrint('موعد المحاضرة القادمة: $lectureDateTime');
        debugPrint(
            'الوقت المتبقي: $diffSeconds ثانية (${(diffSeconds / 3600).toStringAsFixed(1)} ساعة)');

        if (diffSeconds <= 0) {
          debugPrint('❌ المحاضرة في الماضي');
        } else {
          debugPrint('✅ محاضرة محتملة لتكون المحاضرة القادمة');
        }
      } catch (e) {
        debugPrint('❌ خطأ في حساب موعد المحاضرة: $e');
      }
    }

    debugPrint('\n=== نتيجة التشخيص ===');
    if (nextLectureMap != null) {
      debugPrint(
          'تم العثور على محاضرة قادمة: ${nextLectureMap![NextLectureConstants.courseNameField]}');
      debugPrint(
          'الوقت المتبقي: ${nextLectureMap!['diffSeconds']} ثانية (${(nextLectureMap!['diffSeconds'] / 3600).toStringAsFixed(1)} ساعة)');
      debugPrint('تاريخ المحاضرة: ${nextLectureMap!['lectureDate']}');
    } else {
      debugPrint('لم يتم العثور على محاضرة قادمة');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _coursesSubscription?.cancel();
    super.dispose();
  }
}
