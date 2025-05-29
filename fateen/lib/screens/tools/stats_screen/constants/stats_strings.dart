class StatsStrings {
  // عناوين رئيسية
  static const String pageTitle = 'الإحصائيات';
  static const String loginRequired = 'الرجاء تسجيل الدخول أولاً!';
  static const String goBackBtn = 'العودة';

  // عناوين التبويبات
  static const String summaryTab = 'الملخص';
  static const String chartsTab = 'الرسوم البيانية';
  static const String coursesTab = 'المقررات';

  // عناوين عامة
  static const String overallAverage = 'المتوسط العام';
  static const String fromAllCourses = 'من جميع المقررات والدرجات';
  static const String noCoursesYet = 'لا توجد مقررات!';
  static const String addCoursesToView = 'أضف بعض المقررات لعرض الإحصائيات';
  static const String addCoursesToViewDetails =
      'أضف بعض المقررات لعرض التفاصيل';

  // قسم الإحصائيات
  static const String statsOverview = 'ملخص الإحصائيات';
  static const String courses = 'المقررات';
  static const String grades = 'الدرجات';
  static const String highGrades = 'الدرجات العالية';
  static const String lowGrades = 'الدرجات المنخفضة';

  // قسم النصائح
  static const String tipsTitle = 'نصائح وتوجيهات';
  static const String advancedAnalytics = 'تحليل متقدم بالذكاء الاصطناعي';
  static const String comingSoon = 'سيتم إضافة تحليل ذكاء اصطناعي متقدم قريبًا';

  // فئات توزيع الدرجات
  static const List<String> gradeRanges = [
    'أقل من 60',
    '60 - 69',
    '70 - 79',
    '80 - 89',
    '90 - 100',
  ];

  // قسم الرسوم البيانية
  static const String gradeDistribution = 'توزيع الدرجات';
  static const String courseAverages = 'متوسط درجات المقررات';
  static const String noGradesInRange = 'لا توجد درجات ضمن هذه الشريحة!';
  static const String gradesDetailsInRange = 'تفاصيل درجات:';
  static const String moreGrades = 'درجات أخرى';
  static const String total = 'إجمالي';
  static const String gradeWord = 'درجة';

  // قسم المقررات
  static const String sortCoursesBy = 'ترتيب المقررات حسب:';
  static const String sortByName = 'اسم المقرر';
  static const String sortByAverage = 'المتوسط الأعلى';
  static const String courseAverage = 'متوسط الدرجات:';
  static const String evaluationsCount = 'عدد التقييمات:';
  static const String gradesDetails = 'تفاصيل الدرجات:';
  static const String noGradesAdded = 'لم يتم إضافة درجات لهذا المقرر بعد';

  // إحصائيات المقرر
  static const String highestGrade = 'أعلى درجة';
  static const String lowestGrade = 'أقل درجة';
  static const String avgGrade = 'متوسط الدرجات';
  static const String sumGrade = 'مجموع الدرجات';
  static const String topAndBottom = 'أعلى وأقل درجة:';
  static const String courseDetails = 'تفاصيل مقرر:';

  // قسم أعلى وأقل المقررات
  static const String topAndLowestCourses = 'أعلى وأقل المقررات';
  static const String highestCourse = 'أعلى مقرر';
  static const String lowestCourse = 'أقل مقرر';

  static var courseGradeTotals;

  // رسائل النصائح
  static Map<String, String> getCourseAdvice(double avg) {
    if (avg >= 90) {
      return {
        'title': 'ممتاز!',
        'message': 'استمر في الحفاظ على هذا المستوى العالي.'
      };
    } else if (avg >= 80) {
      return {
        'title': 'جيد جداً',
        'message':
            'أداؤك جيد جدًا. مع قليل من الجهد الإضافي يمكنك الوصول للامتياز.'
      };
    } else if (avg >= 70) {
      return {
        'title': 'جيد',
        'message':
            'مستواك جيد، لكن هناك مجال للتحسين. ركز على مراجعة المواضيع الصعبة.'
      };
    } else if (avg >= 60) {
      return {
        'title': 'مقبول',
        'message':
            'تحتاج إلى تحسين درجاتك. حاول وضع خطة مراجعة مكثفة وطلب المساعدة عند الحاجة.'
      };
    } else {
      return {
        'title': 'ضعيف',
        'message':
            'تحتاج إلى اهتمام عاجل بهذا المقرر. فكر في طلب مساعدة إضافية من الأستاذ أو مرشد أكاديمي.'
      };
    }
  }

  static String getDistributionTip(Map<String, int> distribution) {
    final lowRangeCount = distribution['أقل من 60'] ?? 0;
    final highRangeCount = distribution['90 - 100'] ?? 0;
    final totalGrades = distribution.values.fold(0, (p, c) => p + c);

    if (totalGrades == 0) {
      return 'لم يتم إضافة أي درجات بعد. ابدأ بإضافة بعض الدرجات لعرض التحليل.';
    }

    if (lowRangeCount > 0 && highRangeCount > 0) {
      return 'توجد تفاوتات في درجاتك بين المرتفعة والمنخفضة. '
          'ركّز على تحسين المواد ذات الدرجات المنخفضة.';
    } else if (lowRangeCount > 0) {
      if (lowRangeCount == totalGrades) {
        return 'جميع درجاتك منخفضة. خطط لمراجعة شاملة وطلب مساعدة إضافية.';
      }
      return 'هناك درجات منخفضة تحتاج إلى مزيد من المراجعة والتركيز. '
          'ضع خطة لتحسين نقاط الضعف لديك.';
    } else if (highRangeCount > 0) {
      if (highRangeCount == totalGrades) {
        return 'أداء ممتاز! جميع درجاتك مرتفعة. حافظ على هذا المستوى الرائع.';
      }
      return 'أداؤك جيد بشكل عام. استمر في هذا المستوى وحاول تحسين الدرجات المتوسطة.';
    } else {
      return 'درجاتك متوسطة بشكل عام. استمر في المراجعة واجتهد لرفع المتوسط العام.';
    }
  }
}
