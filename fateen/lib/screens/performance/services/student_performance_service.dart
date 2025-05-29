import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/performance_config.dart';
import '../../../models/student_performance_model.dart';
import '../../../models/student.dart';
import '../../../models/course.dart';
import '../../../models/task.dart';

/// خدمة تحليل وإدارة أداء الطالب الأكاديمي
/// توفر واجهات للتفاعل مع خادم التحليل وقاعدة البيانات
class StudentPerformanceService {
  //===========================================================================
  // 1. إعدادات الخادم وإدارة الاتصال
  //===========================================================================

  /// عنوان الخادم الافتراضي
  static String _serverAddress = "http://192.168.0.172";

  /// منفذ الخادم الافتراضي
  static int _serverPort = 8000;

  /// تعيين عنوان وبوابة الخادم
  /// يقوم بتحديث عنوان خادم API
  static void setServerAddress(String address, int port) {
    _serverAddress = address;
    _serverPort = port;
    // تحديث عنوان API في كلاس التكوين
    PerformanceConfig.API_SERVER = "http://$_serverAddress:$_serverPort";
  }

  /// الحصول على معلومات الخادم الحالي
  /// يرجع عنوان الخادم والمنفذ كنص
  static String getServerInfo() => "$_serverAddress:$_serverPort";

  /// اختبار الاتصال بواجهة API
  /// يتحقق من أن الخادم يعمل ومفتاح API تم تعيينه
  static Future<bool> checkApiConnection() async {
    try {
      print(
          "Testing API connection to: ${PerformanceConfig.TEST_API_ENDPOINT}");
      final response = await http
          .get(Uri.parse(PerformanceConfig.TEST_API_ENDPOINT))
          .timeout(const Duration(seconds: 5));

      print("API test response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'working' && data['key_set'] == true;
      }
      return false;
    } catch (e) {
      print("API connection test failed: $e");
      return false;
    }
  }

  //===========================================================================
  // 2. وظائف مساعدة لمعالجة البيانات
  //===========================================================================

  /// تحويل Timestamps في أي كائن إلى تنسيق قابل للتسلسل
  static dynamic _convertTimestampsToString(dynamic object) {
    if (object is Timestamp) {
      return object.toDate().toIso8601String();
    } else if (object is Map) {
      return Map.fromEntries(object.entries
          .map((e) => MapEntry(e.key, _convertTimestampsToString(e.value))));
    } else if (object is List) {
      return object.map((e) => _convertTimestampsToString(e)).toList();
    }
    return object;
  }

  /// التحقق من صحة رابط يوتيوب
  static bool isValidYoutubeUrl(String url) {
    if (url.isEmpty) return false;

    // تحقق من أن الرابط يبدأ بنطاق YouTube
    bool hasYouTubeDomain =
        url.contains('youtube.com/watch') || url.contains('youtu.be/');

    // تحقق من وجود معرف الفيديو
    String? videoId = extractYoutubeVideoId(url);

    return hasYouTubeDomain && videoId != null && videoId.isNotEmpty;
  }

  /// استخراج معرف فيديو يوتيوب بشكل دقيق
  static String? extractYoutubeVideoId(String url) {
    if (url.isEmpty) return null;

    try {
      // نمط روابط watch?v=
      RegExp regExp1 = RegExp(r'youtube\.com/watch\?v=([^&\n?#]+)');
      // نمط روابط youtu.be
      RegExp regExp2 = RegExp(r'youtu\.be/([^&\n?#]+)');

      Match? match = regExp1.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        String videoId = match.group(1)!;
        // التحقق من أن المعرف بالطول الصحيح (عادة 11 حرفًا)
        if (videoId.length == 11) return videoId;
      }

      match = regExp2.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        String videoId = match.group(1)!;
        if (videoId.length == 11) return videoId;
      }

      return null;
    } catch (e) {
      print("Error extracting YouTube video ID: $e");
      return null;
    }
  }

  /// الحصول على صورة مصغرة لفيديو يوتيوب
  static String _getYoutubeThumbnail(String url) {
    final videoId = extractYoutubeVideoId(url);
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/0.jpg';
    }
    return '';
  }

  /// الحصول على رابط يوتيوب افتراضي بناءً على المادة
  static String _getFallbackYoutubeUrlForSubject(String subject) {
    // تنظيف النص للمقارنة
    final subjectLower = subject.trim().toLowerCase();

    if (subjectLower.contains('رياضيات') || subjectLower.contains('math')) {
      return 'https://www.youtube.com/watch?v=pTnEG_WGd2Q'; // شرح التكامل للمبتدئين
    } else if (subjectLower.contains('تكامل') ||
        subjectLower.contains('calculus')) {
      return 'https://www.youtube.com/watch?v=WUvTyaaNkzM'; // أساسيات حساب التفاضل والتكامل
    } else if (subjectLower.contains('فيزياء') ||
        subjectLower.contains('physics')) {
      return 'https://www.youtube.com/watch?v=5GJe_SwlvxE'; // أساسيات الميكانيكا
    } else if (subjectLower.contains('برمجة') ||
        subjectLower.contains('programming')) {
      return 'https://www.youtube.com/watch?v=rfscVS0vtbw'; // أساسيات البرمجة
    } else {
      // روابط عامة للمذاكرة الفعالة
      final general = [
        'https://www.youtube.com/watch?v=Z-zNHHpXoMM', // مهارات المذاكرة الفعالة
        'https://www.youtube.com/watch?v=VfBP88TcVg8', // تقنيات إدارة الوقت
      ];
      return general[DateTime.now().millisecondsSinceEpoch % general.length];
    }
  }

  /// التحقق من صحة خطة الدراسة
  static bool _isValidStudyPlan(StudyPlan plan) {
    // التحقق من وجود الجلسات
    if (plan.sessions.isEmpty) {
      return false;
    }

    // التحقق من صحة كل جلسة
    for (var session in plan.sessions) {
      // التحقق من وجود اليوم
      if (session.day.isEmpty) {
        return false;
      }

      // التحقق من وجود وقت الجلسة
      if (session.timeSlot.isEmpty) {
        return false;
      }

      // التحقق من وجود المادة
      if (session.subject.isEmpty) {
        return false;
      }

      // التحقق من وجود تركيز للدراسة
      if (session.focus.isEmpty) {
        return false;
      }

      // التحقق من مدة الجلسة
      if (session.durationMinutes <= 0) {
        return false;
      }
    }

    return true;
  }

  /// حساب المعدل التراكمي من المقررات
  static double calculateGPA(List<Course> courses) {
    if (courses.isEmpty) return 0.0;

    double totalPoints = 0.0;
    int totalCreditHours = 0;

    for (var course in courses) {
      double courseAverage = 0.0;
      if (course.grades.isNotEmpty) {
        double totalGrades = 0.0;
        for (var grade in course.grades.values) {
          totalGrades += grade;
        }
        courseAverage = totalGrades / course.grades.length;
      }

      // تحويل المتوسط إلى نقاط
      double points = convertGradeToPoints(courseAverage);

      totalPoints += points * course.creditHours;
      totalCreditHours += course.creditHours;
    }

    if (totalCreditHours == 0) return 0.0;

    return totalPoints / totalCreditHours;
  }

  /// تحويل الدرجة إلى نقاط (نظام GPA)
  static double convertGradeToPoints(double grade) {
    if (grade >= 95)
      return 4.0; // A+
    else if (grade >= 90)
      return 4.0; // A
    else if (grade >= 85)
      return 3.7; // B+
    else if (grade >= 80)
      return 3.3; // B
    else if (grade >= 75)
      return 3.0; // C+
    else if (grade >= 70)
      return 2.7; // C
    else if (grade >= 65)
      return 2.3; // D+
    else if (grade >= 60)
      return 2.0; // D
    else
      return 0.0; // F
  }

  //===========================================================================
  // 3. التفاعل مع Firebase (قراءة وكتابة البيانات)
  //===========================================================================

  /// الحصول على كائن الطالب الحالي
  static Future<Student?> getCurrentStudent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return await Student.getStudent(user.uid);
  }

  /// الحصول على قائمة مقررات الطالب من Firestore
  static Future<List<Course>> getStudentCourses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .get();

      return snapshot.docs
          .map((doc) =>
              Course.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error fetching courses: $e");
      return [];
    }
  }

  /// حفظ عادات الدراسة في Firestore
  static Future<void> saveStudyHabits(StudentHabits habits) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('performance')
          .doc('study_habits')
          .set(habits.toJson());
    } catch (e) {
      print("Error saving study habits: $e");
    }
  }

  /// الحصول على عادات الدراسة المحفوظة من Firestore
  static Future<StudentHabits?> getSavedStudyHabits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('performance')
          .doc('study_habits')
          .get();

      if (doc.exists && doc.data() != null) {
        return StudentHabits.fromJson(doc.data()!);
      }

      return null;
    } catch (e) {
      print("Error fetching study habits: $e");
      return null;
    }
  }

  /// حفظ تحليل الأداء في Firestore
  static Future<void> savePerformanceAnalysis(
      PerformanceAnalysis analysis) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('performance')
          .doc('analysis')
          .set(analysis.toJson());
    } catch (e) {
      print("Error saving analysis: $e");
    }
  }

  /// الحصول على تحليل الأداء المحفوظ من Firestore
  static Future<PerformanceAnalysis?> getSavedPerformanceAnalysis() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('performance')
          .doc('analysis')
          .get();

      if (doc.exists && doc.data() != null) {
        return PerformanceAnalysis.fromJson(doc.data()!);
      }

      return null;
    } catch (e) {
      print("Error fetching analysis: $e");
      return null;
    }
  }

  //===========================================================================
  // 4. إدارة الخطط الدراسية
  //===========================================================================

  /// توليد خطة دراسية محددة تعمل في حالات الفشل
  static StudyPlan _generateFixedStudyPlan(List<Course> courses) {
    // تاريخ اليوم
    DateTime now = DateTime.now();

    // تحديد أيام الأسبوع
    List<String> days = [
      "السبت",
      "الأحد",
      "الاثنين",
      "الثلاثاء",
      "الأربعاء",
      "الخميس",
      "الجمعة"
    ];

    // تحويل يوم الأسبوع إلى النظام العربي
    int todayIndex = (now.weekday + 1) % 7;

    // إنشاء الجلسات
    List<StudySession> sessions = [];

    // إضافة جلسة لكل مقرر (حتى 5 مقررات)
    int coursesToUse = math.min(5, courses.length);
    for (int i = 0; i < coursesToUse; i++) {
      Course course = courses[i];

      // تخطي أيام الجمعة
      int dayIndex = (todayIndex + i) % 7;
      if (dayIndex == 6) {
        dayIndex = (dayIndex + 1) % 7;
      }

      // استخدام ملف من ملفات المقرر إذا وجد
      String focusContent = "مراجعة عامة للمادة";
      if (course.files.isNotEmpty) {
        final fileName = course.files[i % course.files.length].fileName;
        focusContent = "دراسة $fileName";
      }

      // اختيار وقت ملائم
      String timeSlot;
      switch (i % 5) {
        case 0:
          timeSlot = "16:00 - 18:00";
          break;
        case 1:
          timeSlot = "18:30 - 20:30";
          break;
        case 2:
          timeSlot = "15:00 - 17:00";
          break;
        case 3:
          timeSlot = "19:00 - 21:00";
          break;
        default:
          timeSlot = "17:30 - 19:30";
          break;
      }

      // إنشاء الجلسة
      sessions.add(StudySession(
        day: days[dayIndex],
        timeSlot: timeSlot,
        subject: course.courseName,
        focus: focusContent,
        durationMinutes: 120,
      ));
    }

    // إذا لم تكن هناك مقررات، قم بإنشاء جلسات محددة
    if (sessions.isEmpty) {
      sessions = [
        StudySession(
          day: "السبت",
          timeSlot: "16:00 - 18:00",
          subject: "مقرر 1",
          focus: "مراجعة عامة",
          durationMinutes: 120,
        ),
        StudySession(
          day: "الأحد",
          timeSlot: "18:00 - 20:00",
          subject: "مقرر 2",
          focus: "حل تمارين",
          durationMinutes: 120,
        ),
        StudySession(
          day: "الاثنين",
          timeSlot: "17:00 - 19:00",
          subject: "مقرر 3",
          focus: "مراجعة ملخصات",
          durationMinutes: 120,
        ),
        StudySession(
          day: "الثلاثاء",
          timeSlot: "19:00 - 21:00",
          subject: "مقرر 1",
          focus: "تحضير للاختبار",
          durationMinutes: 120,
        ),
        StudySession(
          day: "الأربعاء",
          timeSlot: "16:00 - 18:00",
          subject: "مقرر 2",
          focus: "مراجعة شاملة",
          durationMinutes: 120,
        ),
      ];
    }

    // إضافة تاريخ اليوم إلى وصف الخطة
    String currentDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    return StudyPlan(
      title: "خطة دراسية مخصصة للأسبوع الحالي",
      description: "خطة مقترحة تبدأ من $currentDate بناءً على ملفاتك الدراسية",
      sessions: sessions,
      tips: [
        "حدد أهدافاً واضحة ومحددة لكل جلسة دراسية",
        "قسم المواد الكبيرة إلى أجزاء صغيرة يمكن إدارتها",
        "استخدم تقنية بومودورو: 25 دقيقة دراسة و5 دقائق راحة",
        "راجع المواد بانتظام لترسيخ المعلومات",
        "نظم مكان دراستك للحد من المشتتات"
      ],
    );
  }

  /// توليد خطة دراسية مخصصة من الخادم الخارجي
  ///
  /// يرسل طلب إلى خادم Python للحصول على خطة دراسية مخصصة
  /// بناءً على المقررات وعادات الدراسة
  static Future<StudyPlan> generateStudyPlan(
    List<Course> courses,
    StudentHabits habits,
  ) async {
    try {
      // جمع وتنظيم ملفات المقررات للإرسال
      List<Map<String, dynamic>> coursesWithFiles = courses
          .map((c) => {
                'id': c.id,
                'courseName': c.courseName,
                'creditHours': c.creditHours,
                'grades': c.grades,
                'days': c.days,
                'lectureTime': c.lectureTime,
                'files': c.files
                    .map((f) => {
                          'fileName': f.fileName,
                          'fileType': f.fileType,
                          'fileSize': f.fileSize,
                        })
                    .toList(),
              })
          .toList();

      // بناء هيكل البيانات للطلب
      final Map<String, dynamic> requestData = {
        "courses": coursesWithFiles,
        "habits": {
          'sleepHours': habits.sleepHours,
          'studyHoursDaily': habits.studyHoursDaily,
          'studyHoursWeekly': habits.studyHoursWeekly,
          'understandingLevel': habits.understandingLevel,
          'distractionLevel': habits.distractionLevel,
          'hasHealthIssues': habits.hasHealthIssues,
          'learningStyle': habits.learningStyle,
          'additionalNotes': habits.additionalNotes,
        },
        // إضافة تاريخ اليوم الحالي
        "current_date": DateTime.now().toIso8601String().split('T')[0],
      };

      print("Sending request to generate study plan:");
      print("URL: ${PerformanceConfig.GENERATE_STUDY_PLAN_ENDPOINT}");
      print("Courses count: ${courses.length}");
      print(
          "Total files: ${courses.fold(0, (sum, course) => sum + course.files.length)}");
      print("Habits: ${habits.toJson()}");
      print("Current date: ${requestData['current_date']}");

      // محاولة الاتصال بخادم Python
      final response = await http
          .post(
            Uri.parse(PerformanceConfig.GENERATE_STUDY_PLAN_ENDPOINT),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(requestData),
          )
          .timeout(Duration(seconds: PerformanceConfig.API_TIMEOUT_SECONDS));

      print("Study plan response status code: ${response.statusCode}");
      if (response.body.isNotEmpty) {
        print(
            "Study plan response preview: ${response.body.substring(0, math.min(200, response.body.length))}...");
      } else {
        print("Study plan response body is empty");
      }

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(utf8.decode(response.bodyBytes));

        // التحقق من وجود الحقول المطلوبة
        if (responseJson == null ||
            responseJson['sessions'] == null ||
            !(responseJson['sessions'] is List)) {
          print("Error: Invalid response format. Missing required fields.");
          print("Response received: $responseJson");
          throw Exception('تنسيق استجابة غير صالح');
        }

        StudyPlan plan = StudyPlan(
          title: responseJson['title'] ?? 'خطة دراسية جديدة',
          description: responseJson['description'] ?? 'خطة دراسية مخصصة جديدة',
          sessions: (responseJson['sessions'] as List)
              .map<StudySession>((s) => StudySession(
                    day: s['day'] ?? '',
                    timeSlot: s['timeSlot'] ?? '',
                    subject: s['subject'] ?? '',
                    focus: s['focus'] ?? '',
                    durationMinutes: s['durationMinutes'] ?? 120,
                  ))
              .toList(),
          tips: List<String>.from(responseJson['tips'] ?? []),
        );

        print("Generated study plan successfully:");
        print("Title: ${plan.title}");
        print("Number of sessions: ${plan.sessions.length}");
        print("Number of tips: ${plan.tips.length}");

        // التحقق من صحة الخطة
        if (!_isValidStudyPlan(plan)) {
          print("Generated study plan is invalid, using a fixed study plan");
          return _generateFixedStudyPlan(courses);
        }

        return plan;
      } else {
        throw Exception('فشل في توليد خطة الدراسة: ${response.statusCode}');
      }
    } catch (e) {
      print("Error generating study plan: $e");

      // في حالة الفشل، أرجع خطة دراسية ثابتة ومحددة بأيام وملفات
      return _generateFixedStudyPlan(courses);
    }
  }

  //===========================================================================
  // 5. تحليل الأداء الأكاديمي
  //===========================================================================

  /// بناء كائن التحليل من بيانات JSON المستلمة من الخادم
  static PerformanceAnalysis _buildAnalysisFromJson(Map<String, dynamic> json) {
    try {
      print("Building analysis from JSON data");

      // التعامل مع نقاط القوة والضعف - التأكد من أنها غير فارغة
      List<String> strengths = json['strengths'] != null
          ? List<String>.from(json['strengths'])
          : ["تحليل نقاط القوة غير متاح حالياً."];

      List<String> weaknesses = json['weaknesses'] != null
          ? List<String>.from(json['weaknesses'])
          : ["تحليل نقاط الضعف غير متاح حالياً."];

      // في حالة استجابة خطأ محددة، استبدلها
      if (strengths.length == 1 &&
          strengths[0].contains("تحليل الأداء غير متاح")) {
        strengths = ["لم يتم التعرف على نقاط قوة محددة."];
      }

      if (weaknesses.length == 1 &&
          weaknesses[0].contains("تعذر تحليل نقاط الضعف")) {
        weaknesses = ["لم يتم التعرف على نقاط ضعف محددة."];
      }

      // قراءة الخطة الدراسية
      StudyPlan studyPlan;
      if (json['studyPlan'] != null) {
        studyPlan = StudyPlan(
          title: json['studyPlan']?['title'] ?? 'خطة دراسية مخصصة',
          description: json['studyPlan']?['description'] ??
              'خطة مخصصة بناءً على أدائك وعاداتك الدراسية',
          sessions: (json['studyPlan']?['sessions'] as List? ?? [])
              .map<StudySession>((s) => StudySession(
                    day: s['day'] ?? '',
                    timeSlot: s['timeSlot'] ?? '',
                    subject: s['subject'] ?? '',
                    focus: s['focus'] ?? '',
                    durationMinutes: s['durationMinutes'] ?? 120,
                  ))
              .toList(),
          tips: List<String>.from(json['studyPlan']?['tips'] ?? []),
        );
      } else {
        // خطة دراسية افتراضية إذا لم تكن موجودة
        studyPlan = StudyPlan(
          title: 'خطة دراسية مخصصة',
          description: 'خطة مخصصة بناءً على أدائك وعاداتك الدراسية',
          sessions: [],
          tips: ["قم بتنظيم وقتك بشكل فعال"],
        );
      }

      // قراءة الموارد التعليمية
      List<LearningResource> resources = [];
      if (json['resources'] != null) {
        try {
          resources = (json['resources'] as List)
              .map<LearningResource>((r) => LearningResource(
                    title: r['title'] ?? '',
                    description: r['description'] ?? '',
                    type: r['type'] ?? 'article',
                    url: r['url'] ?? '', // السماح بروابط فارغة
                    thumbnailUrl: r['thumbnailUrl'] ?? '',
                    durationMinutes: r['durationMinutes'] ?? 30,
                    subject: r['subject'] ?? '',
                  ))
              .toList();

          // التأكد من صحة الروابط للفيديوهات
          for (var i = 0; i < resources.length; i++) {
            if (resources[i].type.toLowerCase() == 'video' &&
                (resources[i].url.isEmpty ||
                    !isValidYoutubeUrl(resources[i].url))) {
              print("Resource $i has invalid YouTube URL: ${resources[i].url}");
              // تعيين رابط يوتيوب افتراضي مناسب للمادة
              String fallbackUrl =
                  _getFallbackYoutubeUrlForSubject(resources[i].subject);
              resources[i] = LearningResource(
                title: resources[i].title,
                description: resources[i].description,
                type: resources[i].type,
                url: fallbackUrl,
                thumbnailUrl: _getYoutubeThumbnail(fallbackUrl),
                durationMinutes: resources[i].durationMinutes,
                subject: resources[i].subject,
              );
            }
          }
        } catch (e) {
          print("Error parsing resources: $e");
        }
      }

      if (resources.isEmpty) {
        // إذا كانت الموارد فارغة، استخدم الموارد الافتراضية
        print("Resources list is empty, using some default resources");
        resources = _getFallbackResources(['عام']);
      }

      print(
          "Analysis built with: ${strengths.length} strengths, ${weaknesses.length} weaknesses, ${resources.length} resources");

      // بناء كائن التحليل الكامل
      return PerformanceAnalysis(
        strengths: strengths,
        weaknesses: weaknesses,
        correlations: List<String>.from(json['correlations'] ?? []),
        studyPatterns: List<String>.from(json['studyPatterns'] ?? []),
        studyPlan: studyPlan,
        resources: resources,
        calculatedGPA: json['calculatedGPA'] ?? 0.0,
      );
    } catch (e) {
      print("Error building analysis from JSON: $e");
      // في حالة الفشل، إرجاع تحليل افتراضي بسيط
      return PerformanceAnalysis(
        strengths: ["تحليل نقاط القوة غير متاح حالياً."],
        weaknesses: ["تعذر تحليل نقاط الضعف."],
        correlations: ["لم يتم العثور على علاقات."],
        studyPatterns: ["تعذر تحليل أنماط الدراسة."],
        studyPlan: StudyPlan(
          title: "خطة دراسية",
          description: "خطة دراسية بسيطة",
          sessions: [],
          tips: ["قم بتنظيم وقتك بشكل فعال"],
        ),
        resources: _getFallbackResources(['عام']),
        calculatedGPA: 0.0,
      );
    }
  }

  /// تحليل أداء الطالب بناءً على درجاته وعادات الدراسة
  ///
  /// يقوم بإرسال بيانات الطالب والمقررات وعادات الدراسة إلى خادم API
  /// للحصول على تحليل شامل للأداء وتوصيات التحسين
  static Future<PerformanceAnalysis> analyzePerformance(
    List<Course> courses,
    StudentHabits habits,
    Student? student,
  ) async {
    try {
      // طباعة رسالة تصحيح مفصلة
      print("=== STARTING PERFORMANCE ANALYSIS ===");
      print("Courses: ${courses.length}");
      print("Habits: ${habits.toJson()}");
      print("Student: ${student?.toMap()}");

      // بناء هيكل البيانات لإرساله إلى الخادم - تحسين التعامل مع البيانات
      final Map<String, dynamic> requestData = {
        "courses": courses
            .map((c) => {
                  'id': c.id,
                  'courseName': c.courseName,
                  'creditHours': c.creditHours,
                  'grades': c.grades,
                  'maxGrades': c.maxGrades,
                  'files': c.files
                      .map((f) => {
                            'fileName': f.fileName,
                            'fileType': f.fileType,
                            'fileSize': f.fileSize,
                            'uploadDate': f.uploadDate?.toIso8601String(),
                          })
                      .toList(),
                  'tasks': c.tasks.map((t) => t.toMap()).toList(),
                  'days': c.days,
                  'lectureTime': c.lectureTime,
                  'classroom': c.classroom,
                })
            .toList(),
        "habits": habits.toJson(), // استخدام دالة toJson مباشرة
        "student":
            student == null ? {} : _convertTimestampsToString(student.toMap()),
      };

      print(
          "Sending request to: ${PerformanceConfig.ANALYZE_PERFORMANCE_ENDPOINT}");
      print(
          "Request data sample: ${jsonEncode(requestData).substring(0, math.min(200, jsonEncode(requestData).length))}...");

      // محاولة الاتصال بالخادم Python مع تمديد timeout
      final response = await http
          .post(
            Uri.parse(PerformanceConfig.ANALYZE_PERFORMANCE_ENDPOINT),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(requestData),
          )
          .timeout(Duration(seconds: PerformanceConfig.API_TIMEOUT_SECONDS));

      print("Response status code: ${response.statusCode}");

      // تسجيل المزيد من التفاصيل حول استجابة الخادم
      if (response.body.isNotEmpty) {
        print(
            "Response preview: ${response.body.substring(0, math.min(200, response.body.length))}...");
        try {
          final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
          print("Successfully parsed response JSON");
          print("Strengths count: ${responseJson['strengths']?.length ?? 0}");
          print("Weaknesses count: ${responseJson['weaknesses']?.length ?? 0}");
          print("Resources count: ${responseJson['resources']?.length ?? 0}");

          // بناء كائن التحليل
          PerformanceAnalysis analysis = _buildAnalysisFromJson(responseJson);

          // التحقق من صحة الخطة الدراسية
          if (!_isValidStudyPlan(analysis.studyPlan)) {
            print("Invalid study plan received, replacing with a fixed one");
            analysis = PerformanceAnalysis(
              strengths: analysis.strengths,
              weaknesses: analysis.weaknesses,
              correlations: analysis.correlations,
              studyPatterns: analysis.studyPatterns,
              studyPlan: _generateFixedStudyPlan(courses), // خطة دراسية ثابتة
              resources: analysis.resources,
              calculatedGPA: analysis.calculatedGPA,
            );
          }

          // حفظ التحليل
          await savePerformanceAnalysis(analysis);
          print("Analysis saved successfully");

          return analysis;
        } catch (parseError) {
          print("Error parsing response: $parseError");
          throw Exception('فشل في تحليل استجابة الخادم: $parseError');
        }
      } else {
        print("Response body is empty");
        throw Exception('استجابة الخادم فارغة');
      }
    } catch (e) {
      print("Error in analyzePerformance: $e");

      // استخدام تحليل محلي بديل مع خطة دراسية محددة
      print("Generating fallback analysis with fixed study plan");

      PerformanceAnalysis analysis =
          generateFallbackAnalysis(courses, habits, student);

      // التأكد من وجود خطة دراسية صالحة
      if (!_isValidStudyPlan(analysis.studyPlan)) {
        analysis = PerformanceAnalysis(
          strengths: analysis.strengths,
          weaknesses: analysis.weaknesses,
          correlations: analysis.correlations,
          studyPatterns: analysis.studyPatterns,
          studyPlan: _generateFixedStudyPlan(courses), // استخدام خطة ثابتة
          resources: analysis.resources,
          calculatedGPA: analysis.calculatedGPA,
        );
      }

      // حفظ التحليل المحدث
      await savePerformanceAnalysis(analysis);

      return analysis;
    }
  }

  /// توليد تحليل احتياطي في حالة الفشل في الاتصال بالخادم
  static PerformanceAnalysis generateFallbackAnalysis(
    List<Course> courses,
    StudentHabits habits,
    Student? student,
  ) {
    print("Generating fallback analysis");

    // حساب المعدل التراكمي
    double gpa = calculateGPA(courses);

    // إنشاء قوائم للتحليل
    List<String> strengths = [];
    List<String> weaknesses = [];
    List<String> correlations = [];
    List<String> studyPatterns = [];

    // تحليل أساسي لنقاط القوة والضعف بناءً على الدرجات
    for (var course in courses) {
      double average = 0.0;
      if (course.grades.isNotEmpty) {
        double total = 0.0;
        for (var grade in course.grades.values) {
          total += grade;
        }
        average = total / course.grades.length;

        if (average >= 85) {
          strengths.add(
              'أداء ممتاز في مادة ${course.courseName} بمتوسط ${average.toStringAsFixed(1)}%.');
        } else if (average <= 70) {
          weaknesses.add(
              'تحتاج إلى تحسين في مادة ${course.courseName} حيث أن متوسط درجاتك ${average.toStringAsFixed(1)}%.');
        }
      }
    }

    // تحليل أساسي لعادات الدراسة
    if (habits.sleepHours < 7) {
      weaknesses.add(
          'متوسط ساعات النوم اليومية (${habits.sleepHours} ساعات) أقل من المعدل الطبيعي (7-8 ساعات).');
      correlations.add(
          'قلة النوم (${habits.sleepHours} ساعات) قد تؤثر سلباً على التركيز والاستيعاب.');
    } else {
      strengths.add(
          'متوسط ساعات النوم اليومية (${habits.sleepHours} ساعات) ضمن المعدل الطبيعي.');
    }

    if (habits.studyHoursDaily < 3) {
      weaknesses.add(
          'متوسط ساعات المذاكرة اليومية (${habits.studyHoursDaily} ساعات) قد لا تكون كافية للتحصيل الجيد.');
      correlations.add(
          'قلة وقت المذاكرة (${habits.studyHoursDaily} ساعات يومياً) قد تؤثر على فهم المواد وإتقانها.');
    } else {
      strengths.add(
          'متوسط ساعات المذاكرة اليومية (${habits.studyHoursDaily} ساعات) جيدة.');
    }

    // تحليل أنماط الدراسة
    studyPatterns
        .add('أسلوب التعلم المفضل لديك هو الأسلوب ${habits.learningStyle}.');

    // إذا لم تكن هناك نقاط قوة أو ضعف كافية، أضف بعضها العامة
    if (strengths.length < 5) {
      strengths.addAll([
        'لديك القدرة على تحديد نقاط الضعف لديك والعمل على تحسينها.',
        'تظهر اهتماماً بتحسين أدائك الدراسي من خلال استخدام أدوات التحليل.',
        'لديك فرصة لتطوير مهاراتك الدراسية بناءً على تحليل أدائك الحالي.',
        'مستواك الحالي يمكن تحسينه بسهولة باتباع خطة دراسية منظمة.',
        'لديك قدرة كامنة على تحقيق نتائج أفضل بتوجيه جهودك بشكل صحيح.',
      ].take(5 - strengths.length));
    }

    if (weaknesses.length < 5) {
      weaknesses.addAll([
        'قد تحتاج إلى تحسين مهارات إدارة الوقت لتحقيق توازن أفضل بين المواد.',
        'يمكنك الاستفادة من تقنيات دراسة متنوعة تناسب أسلوب تعلمك.',
        'قد تحتاج إلى زيادة التركيز على المواد التي تعاني فيها من صعوبات.',
        'قد تستفيد من جدولة وقت المذاكرة بشكل أكثر فعالية.',
        'يمكنك تحسين نظام تدوين الملاحظات للمساعدة في المراجعة.',
      ].take(5 - weaknesses.length));
    }

    if (correlations.length < 4) {
      correlations.addAll([
        'هناك علاقة بين أسلوب تعلمك وفعالية الدراسة في المواد المختلفة.',
        'يمكن أن يؤثر توزيع ساعات المذاكرة على مستوى الاستيعاب والتذكر.',
        'التوازن بين الراحة والدراسة يؤثر على القدرة على التركيز لفترات طويلة.',
        'تنويع أساليب الدراسة يمكن أن يحسن الفهم ويقلل من الملل.',
      ].take(4 - correlations.length));
    }

    if (studyPatterns.length < 4) {
      studyPatterns.addAll([
        'تميل إلى الدراسة بناءً على الأولويات والمواعيد النهائية.',
        'قد تستفيد من تقسيم المهام الكبيرة إلى أجزاء أصغر يمكن إدارتها.',
        'يمكنك تحسين تنظيم وقت الدراسة بناءً على مستويات الطاقة اليومية.',
        'تركيز جهودك بناءً على تحليل نقاط القوة والضعف يمكن أن يعزز فعالية الدراسة.',
      ].take(4 - studyPatterns.length));
    }

    // إنشاء خطة دراسية مخصصة وثابتة
    StudyPlan studyPlan = _generateFixedStudyPlan(courses);

// إنشاء موارد فارغة (تلبية لما يطلبه العميل)
    List<LearningResource> resources = [];

    return PerformanceAnalysis(
      strengths: strengths,
      weaknesses: weaknesses,
      correlations: correlations,
      studyPatterns: studyPatterns,
      studyPlan: studyPlan,
      resources: resources,
      calculatedGPA: gpa,
    );
  }

  //===========================================================================
  // 6. إدارة الموارد التعليمية
  //===========================================================================

  /// دالة مساعدة لتوفير موارد احتياطية عند فشل الحصول على موارد
  static List<LearningResource> _getFallbackResources(
      List<String> courseNames) {
    // لا نرجع موارد افتراضية حسب المتطلبات الجديدة
    return [];
  }

  /// الحصول على موارد تعليمية مناسبة من الخادم
  ///
  /// يقوم بإرسال نقاط الضعف وأسلوب التعلم وأسماء المقررات
  /// للحصول على موارد تعليمية مناسبة (فيديوهات ومقالات)
  static Future<List<LearningResource>> getLearningResources(
    List<String> weaknesses,
    String learningStyle,
    List<String> courseNames,
  ) async {
    try {
      // إذا كانت قائمة نقاط الضعف فارغة، استخدم قائمة افتراضية
      if (weaknesses.isEmpty) {
        weaknesses = [
          "صعوبة في فهم بعض المفاهيم الأساسية",
          "حاجة إلى تحسين مهارات حل المشكلات"
        ];
      }

      // بناء هيكل البيانات للطلب
      final Map<String, dynamic> requestData = {
        "weaknesses": weaknesses,
        "learningStyle": learningStyle,
        "courses": courseNames,
      };

      print("===== GETTING LEARNING RESOURCES =====");
      print("URL: ${PerformanceConfig.LEARNING_RESOURCES_ENDPOINT}");
      print("Weaknesses count: ${weaknesses.length}");
      print("Learning style: $learningStyle");
      print("Courses: $courseNames");
      print("Request data: ${jsonEncode(requestData)}");

      // اختبار الاتصال أولاً
      bool isConnected = await checkApiConnection();
      if (!isConnected) {
        print("API connection failed, returning empty resources list");
        return [];
      }

      // محاولة الاتصال بخادم Python
      final response = await http
          .post(
            Uri.parse(PerformanceConfig.LEARNING_RESOURCES_ENDPOINT),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(requestData),
          )
          .timeout(Duration(seconds: PerformanceConfig.API_TIMEOUT_SECONDS));

      print("Learning resources response status code: ${response.statusCode}");
      if (response.body.isNotEmpty) {
        print(
            "Response preview: ${response.body.substring(0, math.min(200, response.body.length))}...");

        // تحليل الاستجابة بشكل أكثر قوة
        try {
          final responseData = jsonDecode(utf8.decode(response.bodyBytes));

          List<dynamic> resourcesJson = [];
          if (responseData is List) {
            resourcesJson = responseData;
          } else if (responseData is Map &&
              responseData.containsKey('resources')) {
            resourcesJson = responseData['resources'] as List;
          } else {
            print("Unexpected response format: $responseData");
            return [];
          }

          print("Parsed ${resourcesJson.length} resources from response");

          if (resourcesJson.isEmpty) {
            print("No resources received from server, returning empty list");
            return [];
          }

          List<LearningResource> resources = resourcesJson
              .map<LearningResource>((r) => LearningResource(
                    title: r['title'] ?? 'مورد تعليمي',
                    description: r['description'] ?? 'وصف المورد التعليمي',
                    type: r['type'] ?? 'article',
                    url: r['url'] ?? '',
                    thumbnailUrl: r['thumbnailUrl'] ?? '',
                    durationMinutes: r['durationMinutes'] ?? 30,
                    subject: r['subject'] ?? courseNames.first ?? 'عام',
                  ))
              .toList();

          print("Created ${resources.length} learning resource objects");

          // التأكد من وجود روابط صالحة للفيديوهات
          for (var i = 0; i < resources.length; i++) {
            if (resources[i].type.toLowerCase() == 'video' &&
                (resources[i].url.isEmpty ||
                    !isValidYoutubeUrl(resources[i].url))) {
              print("Resource $i has invalid YouTube URL: ${resources[i].url}");
              // نحذف الموارد ذات الروابط غير الصالحة
              continue;
            }
          }

          // تصفية الموارد للحصول فقط على الصالحة
          resources = resources
              .where((resource) =>
                  resource.type.toLowerCase() != 'video' ||
                  (resource.type.toLowerCase() == 'video' &&
                      isValidYoutubeUrl(resource.url)))
              .toList();

          return resources;
        } catch (e) {
          print("Error parsing resources: $e");
          return [];
        }
      } else {
        print("Response body is empty, returning empty list");
        return [];
      }
    } catch (e) {
      print("Error getting learning resources: $e");
      return [];
    }
  }

  /// الحصول على موارد تعليمية مخصصة لمقررات محددة
  ///
  /// يستهدف هذه الدالة الحصول على موارد أكثر تخصصاً لمقررات معينة
  /// بناءً على أسلوب التعلم المفضل
  static Future<List<LearningResource>> getSpecificCourseResources(
      List<String> courseNames, String learningStyle) async {
    try {
      // بناء بيانات الطلب
      final Map<String, dynamic> requestData = {
        "courses": courseNames,
        "learningStyle": learningStyle,
        // إضافة معلومات إضافية للحصول على موارد أكثر تخصيصًا
        "resourceType": "educational_videos"
      };

      print("Requesting specific course resources:");
      print("URL: ${PerformanceConfig.LEARNING_RESOURCES_ENDPOINT}");
      print("Courses: $courseNames");
      print("Learning style: $learningStyle");

      // التحقق من الاتصال أولاً
      bool isConnected = await checkApiConnection();
      if (!isConnected) {
        print("API connection failed, returning empty resources list");
        return [];
      }

      // إرسال الطلب إلى واجهة API
      final response = await http
          .post(
            Uri.parse(PerformanceConfig.LEARNING_RESOURCES_ENDPOINT),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(requestData),
          )
          .timeout(Duration(seconds: PerformanceConfig.API_TIMEOUT_SECONDS));

      print("Learning resources response status code: ${response.statusCode}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        print("Resource response received successfully");

        final resources = jsonDecode(utf8.decode(response.bodyBytes));

        if (resources is List && resources.isNotEmpty) {
          return resources
              .map<LearningResource>((r) => LearningResource(
                    title: r['title'] ?? 'مورد تعليمي',
                    description: r['description'] ?? 'وصف المورد التعليمي',
                    type: r['type'] ?? 'video',
                    url: r['url'] ?? '',
                    thumbnailUrl: r['thumbnailUrl'] ?? '',
                    durationMinutes: r['durationMinutes'] ?? 30,
                    subject: r['subject'] ??
                        (courseNames.isNotEmpty ? courseNames.first : 'عام'),
                  ))
              .toList();
        }
      }

      // في حالة عدم توفر موارد أو حدوث خطأ، نرجع قائمة فارغة
      return [];
    } catch (e) {
      print("Error getting specific course resources: $e");
      return [];
    }
  }
}
