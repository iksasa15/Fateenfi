// lib/features/task_editor/constants/editor_strings.dart

class EditorStrings {
  // Editor titles
  static const String addTask = "إضافة مهمة";
  static const String editTask = "تعديل المهمة";
  static const String editorDescription =
      "قم بإدخال تفاصيل المهمة وحدد المواعيد والأولويات";

  // Field labels
  static const String taskTitle = "عنوان المهمة";
  static const String enterTaskTitle = "أدخل عنوان المهمة";
  static const String taskDescription = "وصف المهمة";
  static const String taskDescriptionHint = "اكتب وصف المهمة هنا...";
  static const String dueDate = "تاريخ التسليم";
  static const String dueTime = "وقت التسليم";
  static const String priority = "الأولوية";
  static const String course = "المادة الدراسية";
  static const String selectCourse = "اختر المادة";
  static const String noCourse = "بدون مادة";
  static const String reminder = "تذكير";
  static const String reminderTime = "وقت التذكير";
  static const String enableReminder = "تفعيل التذكير";
  static const String tags = "الوسوم";
  static const String addTag = "إضافة وسم";
  static const String newTag = "وسم جديد";

  // Counters
  static const String wordCount = " كلمة، ";
  static const String charCount = " حرف";

  // Buttons
  static const String save = "حفظ";
  static const String add = "إضافة";
  static const String cancel = "إلغاء";
  static const String saving = "جارٍ الحفظ...";

  // Priorities
  static const String highPriority = "عالية";
  static const String mediumPriority = "متوسطة";
  static const String lowPriority = "منخفضة";

  // Task statuses
  static const String statusInProgress = "قيد التنفيذ";
  static const String statusCompleted = "مكتملة";

  // Messages
  static const String emptyTitleError = "يرجى إدخال عنوان للمهمة";
  static const String saveSuccess = "تم حفظ المهمة بنجاح";
  static const String saveError = "حدث خطأ أثناء حفظ المهمة";
}
