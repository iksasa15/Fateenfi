import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebaseServices/stats_firebase.dart';
import '../constants/stats_constants.dart';

/// وحدة تحكم الإحصائيات تدير حالة البيانات والتفاعل مع Firebase
class StatsController extends ChangeNotifier {
  final StatsFirebaseService _firebaseService = StatsFirebaseService();

  // بيانات المستخدم الحالي
  User? currentUser;

  // حالة التحميل
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // رسالة الخطأ إن وجدت
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // بيانات الإحصائيات
  Map<String, dynamic> _statsData = {};
  Map<String, dynamic> get statsData => _statsData;

  // إضافة مستمعي التغييرات
  StreamSubscription? _tasksSubscription;
  StreamSubscription? _coursesSubscription;

  // بيانات إحصائيات المقررات
  Map<String, dynamic> get coursesStats =>
      _statsData['courses'] ?? StatsConstants.defaultStats['courses'];

  // بيانات إحصائيات المهام
  Map<String, dynamic> get tasksStats =>
      _statsData['tasks'] ?? StatsConstants.defaultStats['tasks'];

  // بيانات إحصائيات الحضور
  Map<String, dynamic> get attendanceStats =>
      _statsData['attendance'] ?? StatsConstants.defaultStats['attendance'];

  // بيانات إحصائيات الاختبارات
  Map<String, dynamic> get examsStats =>
      _statsData['exams'] ?? StatsConstants.defaultStats['exams'];

  /// إنشاء وحدة التحكم
  StatsController() {
    currentUser = FirebaseAuth.instance.currentUser;
  }

  get tasksCount => null;

  get coursesCount => null;

  /// تهيئة البيانات
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // تحميل البيانات من Firebase
      await _loadStatsData();

      // إعداد المستمعين للتغييرات في الوقت الفعلي
      _setupRealTimeListeners();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// إعداد المستمعين للتغييرات في الوقت الفعلي
  void _setupRealTimeListeners() {
    if (currentUser == null) return;

    // إلغاء الاشتراكات السابقة إذا وجدت
    _tasksSubscription?.cancel();
    _coursesSubscription?.cancel();

    // الاستماع للتغييرات في المهام
    _tasksSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .snapshots()
        .listen((_) {
      // عند وجود تغيير، نحدث إحصائيات المهام فقط
      _updateTasksStats();
    }, onError: (error) {
      debugPrint('خطأ في مستمع المهام: $error');
    });

    // الاستماع للتغييرات في المقررات
    _coursesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('courses')
        .snapshots()
        .listen((_) {
      // عند وجود تغيير، نحدث إحصائيات المقررات فقط
      _updateCoursesStats();
    }, onError: (error) {
      debugPrint('خطأ في مستمع المقررات: $error');
    });
  }

  /// تحديث إحصائيات المهام فقط
  Future<void> _updateTasksStats() async {
    try {
      if (currentUser == null) return;

      final tasksData =
          await _firebaseService.fetchTasksStats(currentUser!.uid);

      // تحديث إحصائيات المهام فقط
      _statsData['tasks'] = tasksData;

      // إعلام المستمعين بالتغيير
      notifyListeners();
      debugPrint('تم تحديث إحصائيات المهام تلقائيًا');
    } catch (e) {
      debugPrint('خطأ في تحديث إحصائيات المهام: $e');
    }
  }

  /// تحديث إحصائيات المقررات فقط
  Future<void> _updateCoursesStats() async {
    try {
      if (currentUser == null) return;

      final coursesData =
          await _firebaseService.fetchCoursesStats(currentUser!.uid);

      // تحديث إحصائيات المقررات فقط
      _statsData['courses'] = coursesData;

      // إعلام المستمعين بالتغيير
      notifyListeners();
      debugPrint('تم تحديث إحصائيات المقررات تلقائيًا');
    } catch (e) {
      debugPrint('خطأ في تحديث إحصائيات المقررات: $e');
    }
  }

  /// تحديث البيانات يدويًا
  Future<void> refresh() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // تحميل البيانات من Firebase
      await _loadStatsData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'حدث خطأ أثناء تحديث البيانات: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// تحميل بيانات الإحصائيات
  Future<void> _loadStatsData() async {
    try {
      if (currentUser == null) {
        _errorMessage = 'لم يتم تسجيل الدخول';
        return;
      }

      // تحميل إحصائيات المقررات
      final coursesData =
          await _firebaseService.fetchCoursesStats(currentUser!.uid);

      // تحميل إحصائيات المهام
      final tasksData =
          await _firebaseService.fetchTasksStats(currentUser!.uid);

      // تحميل إحصائيات الحضور
      final attendanceData =
          await _firebaseService.fetchAttendanceStats(currentUser!.uid);

      // تحميل إحصائيات الاختبارات
      final examsData =
          await _firebaseService.fetchExamsStats(currentUser!.uid);

      // تجميع كل البيانات
      _statsData = {
        'courses': coursesData,
        'tasks': tasksData,
        'attendance': attendanceData,
        'exams': examsData,
      };

      debugPrint('تم تحميل جميع البيانات بنجاح');
    } catch (e) {
      debugPrint('حدث خطأ أثناء تحميل البيانات: $e');
      _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
      rethrow;
    }
  }

  /// حساب نسبة المهام المكتملة
  double calculateTasksCompletionRate() {
    final total = tasksStats['total'] ?? 0;
    final completed = tasksStats['completed'] ?? 0;

    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }

  /// حساب معدل الحضور
  double calculateAttendanceRate() {
    final total = attendanceStats['total'] ?? 0;
    final present = attendanceStats['present'] ?? 0;

    if (total == 0) return 0.0;
    return (present / total) * 100;
  }

  /// حساب إجمالي الساعات المعتمدة
  int calculateTotalCreditHours() {
    return coursesStats['creditHours'] ?? 0;
  }

  /// بناء قائمة بيانات بطاقات الإحصائيات
  List<Map<String, dynamic>> buildStatsCardsData({
    required Function(String) onCardTap,
  }) {
    return [
      // بطاقة المقررات
      {
        'icon': StatsConstants.getCardIcon('courses'),
        'title': StatsConstants.coursesTitle,
        'value': '${coursesStats['total'] ?? 0}',
        'subtitle':
            '${calculateTotalCreditHours()} ${StatsConstants.hoursUnit}',
        'color': StatsConstants.kTealAccent,
        'onTap': () => onCardTap('courses'),
      },
      // بطاقة المهام
      {
        'icon': StatsConstants.getCardIcon('tasks'),
        'title': StatsConstants.tasksTitle,
        'value': '${tasksStats['completed'] ?? 0}/${tasksStats['total'] ?? 0}',
        'subtitle':
            '${calculateTasksCompletionRate().toStringAsFixed(1)}% ${StatsConstants.completedTasksText}',
        'color': StatsConstants.kAmberAccent,
        'onTap': () => onCardTap('tasks'),
      },
    ];
  }

  /// بناء قائمة بيانات بطاقات الإحصائيات الإضافية
  List<Map<String, dynamic>> buildAdditionalStatsCardsData({
    required Function(String) onCardTap,
  }) {
    return [
      // بطاقة الحضور
      {
        'icon': StatsConstants.getCardIcon('attendance'),
        'title': StatsConstants.attendanceTitle,
        'value':
            '${attendanceStats['present'] ?? 0}/${attendanceStats['total'] ?? 0}',
        'subtitle':
            '${calculateAttendanceRate().toStringAsFixed(1)}% ${StatsConstants.attendanceRateText}',
        'color': StatsConstants.kGreenAccent,
        'onTap': () => onCardTap('attendance'),
      },
      // بطاقة الاختبارات
      {
        'icon': StatsConstants.getCardIcon('exams'),
        'title': StatsConstants.examsTitle,
        'value': '${examsStats['upcoming'] ?? 0}',
        'subtitle': 'اختبار قادم',
        'color': StatsConstants.kBlueAccent,
        'onTap': () => onCardTap('exams'),
      },
    ];
  }

  @override
  void dispose() {
    // إلغاء الاشتراكات عند التخلص من وحدة التحكم
    _tasksSubscription?.cancel();
    _coursesSubscription?.cancel();
    super.dispose();
  }
}
