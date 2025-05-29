// lib/screens/tasks/constants/tasks_strings.dart

class TasksStrings {
  // عناوين الصفحة
  static const String title = 'المهام';
  static const String courseTasks = 'مهام مادة';
  static const String subtitle = 'إدارة وتنظيم جميع مهامك في مكان واحد';
  static const String searchHint = 'ابحث في المهام...';

  // فلاتر المهام
  static const String allTasks = 'الكل';
  static const String todayTasks = 'اليوم';
  static const String upcomingTasks = 'القادمة';
  static const String overdueTasks = 'المتأخرة';
  static const String completedTasks = 'المكتملة';
  static const String filterBy = 'تصفية حسب: ';
  static const String clearFilter = 'مسح';
  static const String searchResults = 'نتائج البحث: ';
  static const String taskCountSuffix = ' مهمة';
  static const String chooseFilter = 'اختر الفلتر';

  // أقسام الصفحة
  static const String urgentTasks = 'المهام العاجلة';
  static const String importantTasks = 'المهام المهمة';

  // حالة عدم وجود مهام
  static const String noTasks = 'لا توجد مهام';
  static const String noMatchingTasks = 'لا توجد مهام مطابقة';
  static const String tryDifferentSearch = 'جرب بحثًا مختلفًا أو تصفية أخرى';
  static const String startAddingTasks =
      'ابدأ بإضافة مهامك وحدد مواعيد التسليم والأولويات لتنظيم يومك بشكل أفضل';
  static const String noCourseTasksMessage = 'لا توجد مهام لهذه المادة بعد';
  static const String addFirstCourseTask = 'أضف أول مهمة لهذه المادة';

  // محرر المهام
  static const String addTask = 'إضافة مهمة';
  static const String editTask = 'تعديل المهمة';
  static const String taskTitle = 'عنوان المهمة';
  static const String enterTaskTitle = 'أدخل عنوان المهمة';
  static const String taskDescription = 'وصف المهمة';
  static const String taskDescriptionHint = 'اكتب وصف المهمة هنا...';
  static const String dueDate = 'تاريخ التسليم';
  static const String dueTime = 'وقت التسليم';
  static const String priority = 'الأولوية';
  static const String status = 'الحالة';
  static const String course = 'المادة الدراسية';
  static const String selectCourse = 'اختر المادة';
  static const String noCourse = 'بدون مادة';
  static const String reminder = 'تذكير';
  static const String reminderTime = 'وقت التذكير';
  static const String enableReminder = 'تفعيل التذكير';
  static const String tags = 'الوسوم';
  static const String addTag = 'إضافة وسم';
  static const String newTag = 'وسم جديد';
  static const String cancel = 'إلغاء';
  static const String add = 'إضافة';
  static const String save = 'حفظ';
  static const String saving = 'جارٍ الحفظ...';
  static const String wordCount = ' كلمة، ';
  static const String charCount = ' حرف';

  // أولويات المهام
  static const String highPriority = 'عالية';
  static const String mediumPriority = 'متوسطة';
  static const String lowPriority = 'منخفضة';

  // حالات المهام
  static const String statusInProgress = 'قيد التنفيذ';
  static const String statusCompleted = 'مكتملة';

  // رسائل الخطأ والنجاح
  static const String emptyTitleError = 'يرجى إدخال عنوان للمهمة';
  static const String saveSuccess = 'تم حفظ المهمة بنجاح';
  static const String saveError = 'حدث خطأ أثناء حفظ المهمة';
  static const String deleteSuccess = 'تم حذف المهمة بنجاح';
  static const String deleteError = 'فشل في حذف المهمة';
  static const String markCompleteSuccess = 'تم إكمال المهمة بنجاح';
  static const String markCompleteError = 'فشل في تحديث حالة المهمة';

  // خيارات المهمة
  static const String deleteTask = 'حذف المهمة';
  static const String deleteConfirmation = 'هل أنت متأكد من حذف هذه المهمة؟';
  static const String editTaskOption = 'تعديل المهمة';
  static const String markAsCompleteOption = 'تحديد كمكتملة';
  static const String markAsIncompleteOption = 'إلغاء الإكمال';
  static const String duplicateTask = 'نسخ المهمة';
  static const String copyTitle = ' (نسخة)';
}
