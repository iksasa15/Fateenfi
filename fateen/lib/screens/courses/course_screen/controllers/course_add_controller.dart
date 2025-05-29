// controllers/course_add_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/course.dart';

class CourseAddController extends ChangeNotifier {
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool isLoading = false;

  // Create new course
  Future<bool> addNewCourse(Course course) async {
    try {
      isLoading = true;
      notifyListeners();

      await course.saveToFirestore(currentUser);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('حدث خطأ أثناء إضافة المقرر: $e');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Validate course data
  Map<String, String?> validateCourseData(String name, String creditHoursStr,
      List<String> selectedDays, String? selectedTimeString) {
    Map<String, String?> errors = {
      'nameError': null,
      'creditError': null,
      'daysError': null,
      'timeError': null,
    };

    // التحقق من اسم المادة
    if (name.trim().isEmpty) {
      errors['nameError'] = 'اسم المقرر لا يجب أن يكون فارغًا';
    }

    // التحقق من عدد الساعات
    if (creditHoursStr.trim().isEmpty) {
      errors['creditError'] = 'يجب إدخال عدد الساعات';
    } else {
      final creditHours = int.tryParse(creditHoursStr.trim());
      if (creditHours == null || creditHours <= 0) {
        errors['creditError'] = 'عدد الساعات يجب أن يكون رقمًا موجَبًا';
      }
    }

    // التحقق من اختيار أيام المحاضرة
    if (selectedDays.isEmpty) {
      errors['daysError'] = 'يجب اختيار يوم واحد على الأقل للمحاضرة';
    }

    // التحقق من تحديد وقت المحاضرة
    if (selectedTimeString == null || selectedTimeString.isEmpty) {
      errors['timeError'] = 'يجب تحديد وقت المحاضرة';
    }

    return errors;
  }
}
