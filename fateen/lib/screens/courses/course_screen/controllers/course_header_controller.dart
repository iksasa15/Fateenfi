// controllers/course_header_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/course_header_constants.dart';

class CourseHeaderController extends ChangeNotifier {
  String _screenTitle = CourseHeaderConstants.screenTitle;
  String _screenSubtitle = CourseHeaderConstants.screenSubtitle;
  String? _displayName;
  bool _isLoading = true;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  String get screenTitle => _screenTitle;
  String get screenSubtitle => _screenSubtitle;
  String? get displayName => _displayName;
  bool get isLoading => _isLoading;

  CourseHeaderController() {
    init();
  }

  void init() async {
    await fetchDisplayName();
    notifyListeners();
  }

  // جلب اسم المستخدم
  Future<void> fetchDisplayName() async {
    if (_currentUser == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // جلب البيانات من Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        _displayName = userDoc.data()?['name'] ?? 'مستخدم';
        _isLoading = false;
        // تخصيص العنوان الفرعي إذا وجد اسم المستخدم
        if (_displayName != null &&
            _displayName!.isNotEmpty &&
            _displayName != 'مستخدم') {
          _screenSubtitle = CourseHeaderConstants.welcomeFormat
              .replaceFirst('%s', _displayName!);
        }
      }

      // جلب البيانات من التخزين المحلي كاحتياط
      final prefs = await SharedPreferences.getInstance();
      if (_displayName == null || _displayName == 'مستخدم') {
        _displayName = prefs.getString('user_name') ?? 'مستخدم';
        if (_displayName != 'مستخدم') {
          _screenSubtitle = CourseHeaderConstants.welcomeFormat
              .replaceFirst('%s', _displayName!);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ أثناء جلب اسم المستخدم: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // إمكانية تعديل العنوان حسب الحاجة
  void updateTitle(String newTitle) {
    _screenTitle = newTitle;
    notifyListeners();
  }

  // إمكانية تعديل الوصف حسب الحاجة
  void updateSubtitle(String newSubtitle) {
    _screenSubtitle = newSubtitle;
    notifyListeners();
  }
}
