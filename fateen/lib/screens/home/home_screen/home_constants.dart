import 'package:flutter/material.dart';

/// ثوابت الصفحة الرئيسية
class HomeConstants {
  // الألوان الرئيسية
  static const Color kDarkPurple = Color(0xFF221291);
  static const Color kMediumPurple = Color(0xFF6C63FF);
  static const Color kLightPurple = Color(0xFFF6F4FF);
  static const Color kAccentColor = Color(0xFFFF6B6B);

  // تعريف لون الخلفية الموحد مع صفحة تسجيل الدخول
  static const Color kBackgroundColor = Color(0xFFFDFDFF);

  // ألوان إضافية لجعل الصفحة أكثر حيوية
  static const Color kTealAccent = Color(0xFF4ECDC4); // لون فيروزي للتباين
  static const Color kAmberAccent = Color(0xFFFFD166); // لون أصفر ذهبي
  static const Color kGreenAccent = Color(0xFF06D6A0); // لون أخضر زاهي
  static const Color kSalmonAccent = Color(0xFFFF9F9F); // وردي فاتح

  // العناوين المستخدمة في التطبيق
  static const String appTitle = 'الرئيسية';
  static const String statisticsTitle = 'الإحصائيات';
  static const String nextLectureTitle = 'المحاضرة القادمة';
  static const String tasksNeedAttentionTitle = 'مهام تحتاج اهتمامك';
  static const String quickToolsTitle = 'أدوات سريعة';
  static const String todayTasksTitle = 'مهام اليوم';
  static const String overdueTasksTitle = 'مهام متأخرة';
  static const String todayReminderTitle = 'تذكير اليوم';
  static const String customizeButtonText = 'تخصيص';
  static const String addToolText = 'إضافة أداة';
  static const String wishText = 'نتمنى لك يوماً سعيداً!';

  // نصوص أخرى
  static const String coursesTitle = 'المواد';
  static const String tasksTitle = 'المهام';
  static const String hoursUnit = 'ساعة';
  static const String completedTasksText = 'مكتملة';

  // أسماء أيام الأسبوع بالعربية
  static const Map<int, String> arabicDays = {
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
    7: 'الأحد',
  };

  // أسماء الشهور بالعربية
  static const Map<int, String> arabicMonths = {
    1: 'يناير',
    2: 'فبراير',
    3: 'مارس',
    4: 'أبريل',
    5: 'مايو',
    6: 'يونيو',
    7: 'يوليو',
    8: 'أغسطس',
    9: 'سبتمبر',
    10: 'أكتوبر',
    11: 'نوفمبر',
    12: 'ديسمبر',
  };

  // رسائل تحفيزية
  static const List<String> motivationalMessages = [
    "استمر في التقدم! أنت تحقق إنجازات رائعة كل يوم.",
    "المذاكرة بانتظام تجعل الأمور أسهل وأكثر متعة.",
    "تذكر أخذ فترات راحة قصيرة لتحافظ على تركيزك.",
    "النجاح ليس صدفة، بل نتيجة العمل الجاد والمثابرة.",
    "كل يوم هو فرصة جديدة للتعلم وتحقيق أهدافك.",
  ];

  // تنسيق التاريخ والوقت
  static String getMorningOrEveningGreeting(String name) {
    // طباعة للتحقق من البيانات المستلمة
    debugPrint('getMorningOrEveningGreeting - اسم المستخدم المستلم: "$name"');

    final hourNow = DateTime.now().hour;
    final greeting =
        (hourNow >= 5 && hourNow < 18) ? 'صباح الخير' : 'مساء الخير';

    // التحقق من اسم المستخدم وإزالة الحالات الخاصة
    String displayName = name;
    if (name == 'مستخدم' || name.isEmpty || name == 'null') {
      // إذا كان الاسم هو القيمة الافتراضية أو فارغاً، استخدم تحية بدون اسم
      return greeting;
    } else {
      // تأكد من أن الاسم لا يحتوي على كلمة "مستخدم"
      if (name.contains('مستخدم')) {
        displayName = name.replaceAll('مستخدم', '').trim();
        if (displayName.isEmpty) {
          return greeting;
        }
      }

      // استخدم تحية مع الاسم
      return '$greeting $displayName';
    }
  }
}

/// قائمة الخدمات المتاحة
class AvailableServices {
  static Map<String, Map<String, dynamic>> getServices(BuildContext context) {
    return {
      'حاسبة GPA': {
        'icon': Icons.calculate_outlined,
        'color': HomeConstants.kTealAccent,
        'route': '/gpa_calculator',
      },
      'الملاحظات': {
        'icon': Icons.note_alt_outlined,
        'color': HomeConstants.kAmberAccent,
        'route': '/notes',
      },
      'الذكاء الاصطناعي': {
        'icon': Icons.smart_toy_outlined,
        'color': const Color(0xFF6A5ACD),
        'route': '/ai_assistant',
      },
      'السبورة التفاعلية': {
        'icon': Icons.edit_note,
        'color': HomeConstants.kGreenAccent,
        'route': '/whiteboard',
      },
      'تقنية بومودورو': {
        'icon': Icons.timer_outlined,
        'color': HomeConstants.kAccentColor,
        'route': '/pomodoro',
      },
      'الترجمة': {
        'icon': Icons.translate_outlined,
        'color': const Color(0xFF29B6F6),
        'route': '/translator',
      },
      'الإحصائيات': {
        'icon': Icons.bar_chart_outlined,
        'color': const Color(0xFFFF7043),
        'route': '/statistics',
      },
    };
  }

  // الحصول على الخدمات الافتراضية
  static List<String> getDefaultQuickTools() {
    return ['الذكاء الاصطناعي', 'الإحصائيات'];
  }
}

/// ثوابت التبويبات
class TabsConstants {
  static const List<BottomNavigationBarItem> navigationItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded),
      label: 'الرئيسية',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_rounded),
      label: 'الجدول',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book_rounded),
      label: 'المقررات',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.checklist_rtl_rounded),
      label: 'المهام',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.support_agent_rounded),
      label: 'الخدمات',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_rounded),
      label: 'الإعدادات',
    ),
  ];

  // نصوص رسائل الخطأ
  static const String signOutErrorMessage =
      'حدث خطأ أثناء تسجيل الخروج. حاول مرة أخرى.';
  static const String loadingErrorMessage =
      'حدث خطأ أثناء تحميل البيانات. حاول مرة أخرى.';

  // قيم SharedPreferences
  static const String prefUserIdKey = 'logged_user_id';
  static const String prefUserNameKey = 'user_name';
  static const String prefUserMajorKey = 'user_major';
  static const String prefQuickToolsKey = 'favorite_services';

  // قيم Firebase
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String tasksCollection = 'tasks';
  static const String nameField = 'name';
  static const String majorField = 'major';

  static var navigationLabels;

  static var navigationIcons;
}

/// ثوابت تنسيق المقررات والمحاضرات
class CourseConstants {
  // القيم الزمنية
  static const int maxLectureAdvanceSeconds = 18000; // 5 ساعات بالثواني

  // نصوص المحاضرات
  static const String lectureStartsIn = 'تبدأ خلال';
  static const String hourText = 'ساعة';
  static const String minuteText = 'دقيقة';
  static const String andText = 'و';

  // قيم حقول المقررات
  static const String courseIdField = 'id';
  static const String courseNameField = 'courseName';
  static const String creditHoursField = 'creditHours';
  static const String lectureTimeField = 'lectureTime';
  static const String classroomField = 'classroom';
  static const String dayOfWeekField = 'dayOfWeek';
}
