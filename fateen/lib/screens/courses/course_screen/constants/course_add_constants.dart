// constants/course_add_constants.dart

class CourseAddConstants {
  // العناوين الرئيسية
  final String addCourseTitle = "إضافة مقرر جديد";
  final String editCourseTitle = "تعديل المقرر";

  // تسميات الحقول
  final String courseNameLabel = "اسم المقرر";
  final String creditHoursLabel = "عدد الساعات";
  final String classroomLabel = "رقم القاعة";
  final String daysLabel = "أيام المحاضرة";
  final String timeLabel = "وقت المحاضرة";

  // تلميحات وأزرار
  final String selectDaysHint = "اختر الأيام";
  final String selectTimeHint = "اختر الوقت";
  final String addButton = "إضافة المقرر";
  final String updateButton = "حفظ التعديلات";

  // رسائل التحقق
  final String nameRequired = "اسم المقرر مطلوب";
  final String creditRequired = "عدد الساعات مطلوب";
  final String creditInvalid = "عدد الساعات يجب أن يكون رقمًا صحيحًا";

  // رسائل النجاح والفشل
  final String addSuccess = "تم إضافة المقرر بنجاح";
  final String addError = "حدث خطأ أثناء إضافة المقرر";
  final String updateSuccess = "تم تحديث المقرر بنجاح";
  final String updateError = "حدث خطأ أثناء تحديث المقرر";
}
