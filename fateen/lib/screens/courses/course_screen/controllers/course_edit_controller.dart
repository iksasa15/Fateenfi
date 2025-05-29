import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/course.dart';

class CourseEditController extends ChangeNotifier {
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool isLoading = false; // تمت إضافة متغير isLoading لتتبع حالة العملية

  // تعديل مقرر
  Future<bool> updateCourse(Course course) async {
    try {
      isLoading = true; // تحديث حالة التحميل عند بدء العملية
      notifyListeners();

      await course.saveToFirestore(currentUser);

      isLoading = false; // إعادة تعيين حالة التحميل بعد النجاح
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('حدث خطأ أثناء تعديل المقرر: $e');
      isLoading = false; // إعادة تعيين حالة التحميل في حالة الخطأ
      notifyListeners();
      return false;
    }
  }

  // التحقق من صحة بيانات المقرر - تم تحديثها لتشمل الأيام والوقت
  Map<String, String?> validateCourseData(String name, String creditHoursStr,
      List<String> selectedDays, String? selectedTimeString) {
    Map<String, String?> errors = {
      'nameError': null,
      'creditError': null,
      'daysError': null,
      'timeError': null,
    };

    // التحقق من اسم المقرر
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

  // الدالة القديمة محتفظ بها للتوافق الخلفي
  Map<String, String?> validateBasicCourseData(
      String name, String creditHoursStr) {
    Map<String, String?> errors = {
      'nameError': null,
      'creditError': null,
    };

    if (name.trim().isEmpty) {
      errors['nameError'] = 'اسم المقرر لا يجب أن يكون فارغًا';
    }

    if (creditHoursStr.trim().isEmpty) {
      errors['creditError'] = 'يجب إدخال عدد الساعات';
      return errors;
    }

    final creditHours = int.tryParse(creditHoursStr.trim());
    if (creditHours == null || creditHours <= 0) {
      errors['creditError'] = 'عدد الساعات يجب أن يكون رقمًا موجَبًا';
    }

    return errors;
  }
}
