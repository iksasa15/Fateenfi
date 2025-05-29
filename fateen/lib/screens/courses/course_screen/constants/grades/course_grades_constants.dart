class CourseGradesConstants {
  // ثوابت النصوص
  static const String gradesTabTitle = 'درجات المقرر';
  static const String noGradesMessage = 'لا توجد درجات مسجّلة بعد';
  static const String addGradesHint = 'قم بإضافة درجات لهذا المقرر';
  static const String addGradeButton = 'إضافة درجة';
  static const String addGradeTitle = 'إضافة درجة جديدة';
  static const String editGradeTitle = 'تعديل الدرجة';
  static const String assignmentTypeLabel = 'نوع التقييم';
  static const String assignmentNameLabel = 'اسم التقييم';
  static const String gradeLabel = 'الدرجة المحصلة';
  static const String maxGradeLabel = 'الدرجة الكاملة';
  static const String cancelButton = 'إلغاء';
  static const String saveButton = 'حفظ';
  static const String deleteButton = 'حذف';
  static const String deleteConfirmTitle = 'تأكيد الحذف';
  static const String deleteConfirmMessage = 'هل أنت متأكد من حذف درجة "%s"؟';
  static const String deleteSuccessMessage = 'تم حذف الدرجة بنجاح';

  // رسائل الخطأ
  static const String assignmentEmptyError =
      'نوع التقييم لا يجب أن يكون فارغًا';
  static const String assignmentDuplicateError =
      'هذا التقييم موجود بالفعل، الرجاء اختيار نوع آخر';
  static const String gradeValueError =
      'الدرجة يجب أن تكون رقمًا موجَبًا أو صفر';
  static const String maxGradeError =
      'الدرجة الكاملة يجب أن تكون رقمًا موجَبًا';
  static const String gradeExceedsMaxError =
      'الدرجة المحصلة لا يمكن أن تتجاوز الدرجة الكاملة';
  static const String addGradeSuccess = 'تم إضافة الدرجة بنجاح';
  static const String editGradeSuccess = 'تم تعديل الدرجة بنجاح';
  static const String generalError =
      'حدث خطأ أثناء العملية، الرجاء المحاولة مرة أخرى';

  // رسائل التحميل
  static const String loadingMessage = 'جارٍ التحميل...';
  static const String savingMessage = 'جارٍ الحفظ...';
  static const String deletingMessage = 'جارٍ الحذف...';

  // تمت إزالة ثابت اسم التقييم المخصص
  // بدلاً من ذلك سنستخدم ثابت نوع التقييم للحفاظ على الاتساق

  // تلميح إدخال التقييم المخصص
  static const String customAssignmentHint = 'أدخل نوع التقييم المخصص';
}
