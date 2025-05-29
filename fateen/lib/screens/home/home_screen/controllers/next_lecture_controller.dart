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

      // تحميل المقررات
      await _fetchCoursesFromFirestore();

      // الاستماع للتغييرات في المقررات
      _listenToCoursesChanges();

      // بدء المؤقت للمحاضرة القادمة
      _startTimerForLecture();

      isLoading = false;
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
      coursesData = loadedCourses;
      debugPrint('تم تحميل ${coursesData.length} مقرر');
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
        coursesData = updatedCourses;
        debugPrint('تم تحديث بيانات المقررات: ${coursesData.length} مقرر');

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
      // لا توجد محاضرة قادمة (أو تبعد أكثر من 5 ساعات)
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
  }

  /// إيجاد أقرب محاضرة من الآن إن كانت أقل من 5 ساعات
  Map<String, dynamic>? _getNextLectureData() {
    if (coursesData.isEmpty) return null;

    final now = DateTime.now();
    DateTime? closest;
    Map<String, dynamic>? chosenCourse;

    for (var course in coursesData) {
      // التحقق من يوم المحاضرة
      final lectureDayStr = course['lectureDay'] ?? '';
      if (lectureDayStr.isEmpty) continue;

      // تحويل اسم اليوم إلى رقم يوم الأسبوع (1=الاثنين إلى 7=الأحد)
      final lectureWeekday = _getDayOfWeekFromName(lectureDayStr);
      if (lectureWeekday == -1) continue;

      // تحقق من وقت المحاضرة
      final lectureTimeStr = course[NextLectureConstants.lectureTimeField];
      if (lectureTimeStr == null || lectureTimeStr.isEmpty) {
        continue;
      }

      final split = lectureTimeStr.split(':');
      if (split.length != 2) continue;

      final hour = int.tryParse(split[0]) ?? -1;
      final minute = int.tryParse(split[1]) ?? -1;
      if (hour < 0 || minute < 0) continue;

      // حساب التاريخ الفعلي للمحاضرة القادمة
      var lectureDateTime =
          _getNextDateForWeekday(now, lectureWeekday, hour, minute);

      if (closest == null || lectureDateTime.isBefore(closest)) {
        closest = lectureDateTime;
        chosenCourse = course;
      }
    }

    if (closest == null) return null;

    // فارق الثواني
    final diffSeconds = closest.difference(now).inSeconds;
    // لو المحاضرة تبعد أكثر من 7 أيام => null (أسبوع كامل)
    if (diffSeconds > 7 * 24 * 3600) {
      return null;
    }

    return {
      NextLectureConstants.courseNameField:
          chosenCourse?[NextLectureConstants.courseNameField] ?? '',
      NextLectureConstants.classroomField:
          chosenCourse?[NextLectureConstants.classroomField] ?? '',
      'diffSeconds': diffSeconds,
      'lectureDay': chosenCourse?['lectureDay'] ?? '',
      'lectureDate': closest.toString(),
    };
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
    return daysMap[dayName] ?? -1;
  }

  /// الحصول على التاريخ التالي ليوم معين في الأسبوع
  DateTime _getNextDateForWeekday(
      DateTime now, int targetWeekday, int hour, int minute) {
    // تحويل رقم اليوم الأسبوعي من نظامنا (1-7) إلى نظام Dart (1-7 لكن الأحد=7 في نظامنا و1 في Dart)
    int dartWeekday = targetWeekday == 7 ? 1 : targetWeekday + 1;

    // حساب عدد الأيام للوصول إلى اليوم المستهدف
    int daysUntil = dartWeekday - now.weekday;
    if (daysUntil < 0) {
      daysUntil += 7; // إذا اليوم المستهدف قبل اليوم الحالي، نضيف أسبوع
    } else if (daysUntil == 0) {
      // إذا نفس اليوم والوقت، نتحقق من الوقت
      if (now.hour > hour || (now.hour == hour && now.minute >= minute)) {
        daysUntil = 7; // المحاضرة التالية في الأسبوع المقبل
      }
    }

    // إنشاء تاريخ المحاضرة
    return DateTime(
      now.year,
      now.month,
      now.day + daysUntil,
      hour,
      minute,
    );
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

  @override
  void dispose() {
    _timer?.cancel();
    _coursesSubscription?.cancel();
    super.dispose();
  }
}
