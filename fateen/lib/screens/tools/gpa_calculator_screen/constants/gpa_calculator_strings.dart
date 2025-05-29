class GPACalculatorStrings {
  // عناوين الصفحة
  static const String title = 'حاسبة المعدل GPA';
  static const String subTitle =
      'أدخل المقررات وعدد الساعات والتقديرات لحساب المعدل';

  // أزرار وأقسام
  static const String calculateGPA = 'حساب المعدل';
  static const String addCourse = 'إضافة مقرر';
  static const String currentTermCourses = 'مقررات الفصل الحالي';
  static const String previousGPA = 'المعدل التراكمي السابق';
  static const String previousGPASubtitle =
      'اختياري - أدخل المعدل السابق والساعات المنجزة';
  static const String gradesTable = 'جدول التقديرات والنقاط';

  // حقول الإدخال
  static const String courseName = 'اسم المقرر';
  static const String creditHours = 'الساعات';
  static const String grade = 'التقدير';
  static const String cumulativeGPA = 'المعدل التراكمي';
  static const String completedHours = 'الساعات المنجزة';
  static const String gpaSystem = 'نظام المعدل';
  static const String gpaSystem5 = 'نظام 5.0';
  static const String gpaSystem4 = 'نظام 4.0';

  // رسائل
  static const String minCourseMessage = 'يجب أن يكون هناك مقرر واحد على الأقل';

  // مربع حوار النتائج
  static const String resultTitle = 'نتائج حساب المعدل';
  static const String termGPA = 'معدل الفصل';
  static const String cumulativeGPAResult = 'المعدل التراكمي';
  static const String registeredHours = 'الساعات المسجلة:';
  static const String earnedPoints = 'النقاط المكتسبة:';
  static const String gradeLabel = 'التقدير:';
  static const String ok = 'حسناً';

  // أسماء الحقول
  static const String courseNameHint = 'اسم المقرر';
  static const String creditHoursHint = 'عدد';

  // تعليمات التحقق من الصحة
  static const String requiredField = 'مطلوب';

  // زر استيراد المقررات
  static const String importCourses = "استيراد موادي";
  static const String importingCourses = "جاري استيراد المقررات...";
  static const String importSuccess = "تم استيراد %d مقرر بنجاح";
  static const String importError = "حدث خطأ أثناء استيراد المقررات:";
}
