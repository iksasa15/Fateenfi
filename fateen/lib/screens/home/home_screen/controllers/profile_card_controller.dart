import 'package:fateen/screens/home/home_screen/services/firebaseServices/profile_card_service.dart';
import 'package:flutter/material.dart';
import '../constants/profile_card_constants.dart';
import '../services/firebaseServices/profileFirebase.dart';

class ProfileCardController extends ChangeNotifier {
  String _userName = ProfileCardConstants.defaultUserName;
  String _userMajor = ProfileCardConstants.defaultUserMajor;
  bool _isLoading = true;
  String? _errorMessage;

  final ProfileCardService _service = ProfileCardService();

  // الحصول على قيم المستخدم
  String get userName => _userName;
  String get userMajor => _userMajor;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // تهيئة البيانات
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // الحصول على البيانات من Firebase
      final userData = await _service.getUserData();

      _userName = userData['name'] ?? ProfileCardConstants.defaultUserName;
      _userMajor = userData['major'] ?? ProfileCardConstants.defaultUserMajor;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تعيين بيانات المستخدم مباشرة (يمكن استخدامها للاختبار أو التحديثات المحلية)
  void setUserData(String name, String major) {
    _userName = name;
    _userMajor = major;
    notifyListeners();
  }

  // الحصول على التحية المناسبة للوقت
  String getTimeBasedGreeting() {
    final DateTime now = DateTime.now();
    final int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return ProfileCardConstants.morningGreeting;
    } else {
      return ProfileCardConstants.eveningGreeting;
    }
  }

  // الحصول على التاريخ المنسق بالعربية
  String getFormattedDate() {
    final DateTime now = DateTime.now();

    final String dayName = ProfileCardConstants.arabicDays[now.weekday % 7];
    final String monthName = ProfileCardConstants.arabicMonths[now.month - 1];

    return '$dayName، ${now.day} $monthName ${now.year}';
  }

  // تحديث البيانات
  Future<void> refresh() async {
    await initialize();
  }

  @override
  void dispose() {
    // تنظيف الموارد إذا لزم الأمر
    super.dispose();
  }
}
