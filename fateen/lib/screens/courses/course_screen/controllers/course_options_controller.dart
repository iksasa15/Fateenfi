import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../models/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../course_screen/screens/course_files_screen.dart';
import '../../course_screen/screens/course_grades_screen.dart';
import '../../course_screen/screens/course_notifications_screen.dart';

class CourseOptionsController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _isDeleting = false;

  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set isDeleting(bool value) {
    _isDeleting = value;
    notifyListeners();
  }

  // دالة حذف المقرر
  Future<bool> deleteCourse(String courseId) async {
    isDeleting = true;
    try {
      // الحصول على معرّف المستخدم الحالي
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        isDeleting = false;
        return false;
      }

      // حذف المقرر من مجموعة مقررات المستخدم
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('courses')
          .doc(courseId)
          .delete();

      isDeleting = false;
      return true;
    } catch (e) {
      debugPrint('Error deleting course: $e');
      isDeleting = false;
      return false;
    }
  }

  // دالة جدولة إشعار للمقرر
  Future<bool> scheduleNotification(
      Course course, String notificationTime) async {
    isLoading = true;
    try {
      // الحصول على معرّف المستخدم الحالي
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        isLoading = false;
        return false;
      }

      // هنا ستكون المنطق لحفظ إعدادات الإشعار في قاعدة البيانات
      final notificationData = {
        'courseId': course.id,
        'notificationTime': notificationTime,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .add(notificationData);

      isLoading = false;
      return true;
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      isLoading = false;
      return false;
    }
  }

  // الانتقال إلى صفحة الملفات
  void navigateToFiles(
      BuildContext context, Course course, VoidCallback onCourseUpdated) {
    if (context.mounted) {
      // استخدام showDialog لعرض نافذة ملفات المقرر
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return CourseFilesScreen(
            course: course,
            onFilesUpdated: onCourseUpdated,
          );
        },
      );
    }
  }

  // الانتقال إلى صفحة الدرجات
  void navigateToGrades(
      BuildContext context, Course course, VoidCallback onCourseUpdated) {
    if (context.mounted) {
      // استخدام showDialog لعرض نافذة درجات المقرر
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return CourseGradesScreen(
            course: course,
            onGradesUpdated: onCourseUpdated,
          );
        },
      );
    }
  }

  // الانتقال إلى صفحة الإشعارات
  void navigateToNotifications(
      BuildContext context, Course course, VoidCallback onCourseUpdated) {
    if (context.mounted) {
      // استخدام showDialog لعرض نافذة إشعارات المقرر
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return CourseNotificationsScreen(
            course: course,
            onNotificationsUpdated: onCourseUpdated,
          );
        },
      );
    }
  }

  // التحقق من وجود المقرر
  Future<bool> courseExists(String courseId) async {
    try {
      // الحصول على معرّف المستخدم الحالي
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      // التحقق من وجود المقرر
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('courses')
          .doc(courseId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking if course exists: $e');
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
