import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task.dart';
import 'app_file.dart';

class Course {
  String id;
  String courseName;
  int creditHours;
  List<String> days;
  String classroom;
  String? lectureTime;

  Map<String, double> grades;
  Map<String, double> maxGrades;

  List<Task> tasks;
  List<String> reminders;
  List<AppFile> files;

  Course({
    required this.id,
    required this.courseName,
    required this.creditHours,
    required this.days,
    required this.classroom,
    this.lectureTime,
    Map<String, double>? grades,
    Map<String, double>? maxGrades,
    List<Task>? tasks,
    List<String>? reminders,
    List<AppFile>? files,
  })  : grades = grades ?? {},
        maxGrades = maxGrades ?? {},
        tasks = tasks ?? [],
        reminders = reminders ?? [],
        files = files ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'creditHours': creditHours,
      'days': days,
      'classroom': classroom,
      'lectureTime': lectureTime,
      'grades': grades,
      'maxGrades': maxGrades,
      'reminders': reminders,
      'files': files.map((f) => f.toMap()).toList(),
    };
  }

  static Course fromJson(Map<String, dynamic> json) {
    print("DEBUG: fromJson called with grades: ${json['grades']}");

    Map<String, double> extractedGrades = {};
    Map<String, double> extractedMaxGrades = {};

    if (json['grades'] != null) {
      final oldGrades = Map<String, dynamic>.from(json['grades']);
      final oldMaxGrades = json['maxGrades'] != null
          ? Map<String, dynamic>.from(json['maxGrades'])
          : <String, double>{};

      oldGrades.forEach((key, value) {
        print("DEBUG: Processing grade $key: $value (${value.runtimeType})");

        double gradeValue = 0.0;
        if (value is int) {
          gradeValue = value.toDouble();
        } else if (value is double) {
          gradeValue = value;
        } else if (value is String) {
          gradeValue = double.tryParse(value) ?? 0.0;
        }

        double maxGrade = 100.0;
        if (oldMaxGrades.containsKey(key)) {
          var maxValue = oldMaxGrades[key];
          if (maxValue is int) {
            maxGrade = maxValue.toDouble();
          } else if (maxValue is double) {
            maxGrade = maxValue;
          } else if (maxValue is String) {
            maxGrade = double.tryParse(maxValue) ?? 100.0;
          }
        }

        if (maxGrade == 20.0 && gradeValue < 10.0 && gradeValue > 0) {
          print(
              "DEBUG: Possible scaling issue detected for $key: $gradeValue/20.0");
          gradeValue = gradeValue * 5;
          print("DEBUG: Fixed grade to: $gradeValue/20.0");
        }

        extractedGrades[key] = gradeValue;
        extractedMaxGrades[key] = maxGrade;

        print(
            "DEBUG: Final extracted grade for $key: ${extractedGrades[key]}/${extractedMaxGrades[key]}");
      });
    }

    return Course(
      id: json['id'],
      courseName: json['courseName'] ?? '',
      creditHours: json['creditHours'] ?? 0,
      days: List<String>.from(json['days'] ?? []),
      classroom: json['classroom'] ?? '',
      lectureTime: json['lectureTime'],
      grades: extractedGrades,
      maxGrades: extractedMaxGrades,
      reminders: List<String>.from(json['reminders'] ?? []),
      files: (json['files'] as List<dynamic>?)
              ?.map((fileMap) => AppFile.fromMap(fileMap))
              .toList() ??
          [],
    );
  }

  void viewCourseDetails() {
    print("🔹 تفاصيل المقرر:");
    print("📌 الاسم: $courseName");
    print("📚 عدد الساعات: $creditHours");
    print("📅 أيام المحاضرة: ${days.join('، ')}");
    print("🏫 القاعة: $classroom");
    if (lectureTime != null) {
      print("⏰ وقت المحاضرة: $lectureTime");
    }
  }

  void modifyCourseDetails(
    String newName,
    int newCreditHours,
    List<String> newDays,
    String newClassroom,
    String? newLectureTime,
  ) {
    if (newName.isEmpty) {
      throw Exception("اسم المقرر لا يجب أن يكون فارغًا!");
    }
    if (newCreditHours < 0) {
      throw Exception("عدد الساعات يجب أن لا يكون سالبًا!");
    }
    courseName = newName;
    creditHours = newCreditHours;
    days = newDays;
    classroom = newClassroom;
    lectureTime = newLectureTime;
    print("✏ تم تعديل تفاصيل المقرر: $courseName");
  }

  void createGrade(String assignment, double actualGrade,
      [double maxGrade = 100.0]) {
    print(
        "DEBUG: createGrade called with actualGrade=$actualGrade, maxGrade=$maxGrade");

    if (assignment.isEmpty) {
      throw Exception("اسم التقييم فارغ!");
    }

    if (actualGrade < 0) {
      throw Exception("الدرجة يجب أن تكون موجبة (أو صفر) وليست سالبة.");
    }

    if (actualGrade > maxGrade) {
      throw Exception("لا يمكن أن تتجاوز الدرجة $maxGrade.");
    }

    grades[assignment] = actualGrade;
    maxGrades[assignment] = maxGrade;

    print(
        "DEBUG: Grade stored directly: grades[$assignment]=${grades[assignment]}, maxGrades[$assignment]=${maxGrades[assignment]}");
    print("📊 تمت إضافة درجة '$actualGrade / $maxGrade' لـ '$assignment'");
  }

  void editGrade(
      String oldAssignmentName, String newAssignmentName, double actualGrade,
      [double maxGrade = 100.0]) {
    print(
        "DEBUG: editGrade called with actualGrade=$actualGrade, maxGrade=$maxGrade");

    if (newAssignmentName.isEmpty) {
      throw Exception("اسم التقييم جديد فارغ!");
    }

    if (actualGrade < 0) {
      throw Exception("الدرجة يجب أن تكون موجبة (أو صفر) وليست سالبة.");
    }

    if (actualGrade > maxGrade) {
      throw Exception("لا يمكن أن تتجاوز الدرجة $maxGrade.");
    }

    if (oldAssignmentName != newAssignmentName &&
        grades.containsKey(oldAssignmentName)) {
      grades.remove(oldAssignmentName);
      maxGrades.remove(oldAssignmentName);
    }

    grades[newAssignmentName] = actualGrade;
    maxGrades[newAssignmentName] = maxGrade;

    print(
        "DEBUG: Grade updated directly: grades[$newAssignmentName]=${grades[newAssignmentName]}, maxGrades[$newAssignmentName]=${maxGrades[newAssignmentName]}");
    print(
        "✏ تم تعديل/إضافة تقييم: $newAssignmentName بدرجة $actualGrade / $maxGrade");
  }

  void deleteGrade(String assignmentName) {
    grades.remove(assignmentName);
    maxGrades.remove(assignmentName);
    print("DEBUG: Grade removed: $assignmentName");
  }

  double getActualGrade(String assignment) {
    double result = grades[assignment] ?? 0.0;
    print("DEBUG: getActualGrade for $assignment = $result");
    return result;
  }

  double getMaxGrade(String assignment) {
    double result = maxGrades[assignment] ?? 100.0;
    print("DEBUG: getMaxGrade for $assignment = $result");
    return result;
  }

  double getGradePercentage(String assignment) {
    double actual = getActualGrade(assignment);
    double max = getMaxGrade(assignment);
    double percentage = max > 0 ? (actual / max) * 100 : 0.0;
    print("DEBUG: getGradePercentage for $assignment = $percentage%");
    return percentage;
  }

  void addFile(AppFile file) {
    files.add(file);
    print("📂 تمت إضافة ملف `${file.fileName}` إلى `$courseName`");
  }

  void removeFile(AppFile file) {
    files.remove(file);
    print("🗑 تمت إزالة ملف `${file.fileName}` من `$courseName`");
  }

  void uploadAndAddFile(AppFile file) {
    file.upload();
    addFile(file);
  }

  void deleteFile(AppFile file) {
    removeFile(file);
    file.deleteFile();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseName': courseName,
      'creditHours': creditHours,
      'days': days,
      'classroom': classroom,
      'lectureTime': lectureTime,
      'grades': grades,
      'maxGrades': maxGrades,
      'reminders': reminders,
      'files': files.map((f) => f.toMap()).toList(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map, String docId) {
    print("DEBUG: fromMap called with grades: ${map['grades']}");

    Map<String, double> extractedGrades = {};
    Map<String, double> extractedMaxGrades = {};

    if (map['grades'] != null) {
      final grades = Map<String, dynamic>.from(map['grades']);
      final maxGrades = map['maxGrades'] != null
          ? Map<String, dynamic>.from(map['maxGrades'])
          : <String, double>{};

      grades.forEach((key, value) {
        print("DEBUG: Processing grade $key: $value (${value.runtimeType})");

        double gradeValue = 0.0;
        if (value is int) {
          gradeValue = value.toDouble();
        } else if (value is double) {
          gradeValue = value;
        } else if (value is String) {
          gradeValue = double.tryParse(value) ?? 0.0;
        }

        double maxGrade = 100.0;
        if (maxGrades.containsKey(key)) {
          var maxValue = maxGrades[key];
          if (maxValue is int) {
            maxGrade = maxValue.toDouble();
          } else if (maxValue is double) {
            maxGrade = maxValue;
          } else if (maxValue is String) {
            maxGrade = double.tryParse(maxValue) ?? 100.0;
          }
        }

        if (maxGrade == 20.0 && gradeValue < 10.0 && gradeValue > 0) {
          print(
              "DEBUG: Possible scaling issue detected for $key: $gradeValue/20.0");
          gradeValue = gradeValue * 5;
          print("DEBUG: Fixed grade to: $gradeValue/20.0");
        }

        extractedGrades[key] = gradeValue;
        extractedMaxGrades[key] = maxGrade;

        print(
            "DEBUG: Final extracted grade for $key: ${extractedGrades[key]}/${extractedMaxGrades[key]}");
      });
    }

    return Course(
      id: map['id'] ?? docId,
      courseName: map['courseName'] ?? '',
      creditHours: map['creditHours'] ?? 0,
      days: List<String>.from(map['days'] ?? []),
      classroom: map['classroom'] ?? '',
      lectureTime: map['lectureTime'],
      grades: extractedGrades,
      maxGrades: extractedMaxGrades,
      reminders: List<String>.from(map['reminders'] ?? []),
      files: (map['files'] as List<dynamic>?)
              ?.map((fileMap) => AppFile.fromMap(fileMap))
              .toList() ??
          [],
    );
  }

  get name => null;

  bool? get isNotEmpty => null;

  get totalGrades => null;

  Future<void> saveToFirestore(User? currentUser) async {
    if (currentUser == null) return;
    final userId = currentUser.uid;

    print("DEBUG: Saving course to Firestore with grades: $grades");
    print("DEBUG: and maxGrades: $maxGrades");

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(id);

    await docRef.set(toMap(), SetOptions(merge: true));
    print("✅ تم حفظ المقرر '$courseName' في فايرستور.");
  }

  Future<void> deleteFromFirestore(User? currentUser) async {
    if (currentUser == null) return;
    final userId = currentUser.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(id)
        .delete();

    print("🗑 تم حذف المقرر '$courseName' من فايرستور.");
  }

  Map<String, dynamic> toGPAFormat() {
    String grade = 'A'; // قيمة افتراضية

    print("DEBUG: toGPAFormat لمقرر $courseName");

    if (grades.isNotEmpty) {
      // فقط جمع الدرجات الفعلية
      double totalScore = 0.0;

      grades.forEach((assignment, actual) {
        print("DEBUG: التقييم: $assignment, الدرجة: $actual");
        totalScore += actual;
      });

      print("DEBUG: مجموع الدرجات الفعلية: $totalScore");

      // تحديد التقدير بناءً على مجموع الدرجات حسب الشروط المحددة
      if (totalScore >= 95)
        grade = 'A+';
      else if (totalScore >= 90)
        grade = 'A';
      else if (totalScore >= 85)
        grade = 'B+';
      else if (totalScore >= 80)
        grade = 'B';
      else if (totalScore >= 75)
        grade = 'C+';
      else if (totalScore >= 70)
        grade = 'C';
      else if (totalScore >= 65)
        grade = 'D+';
      else if (totalScore >= 60)
        grade = 'D';
      else
        grade = 'F';

      print("DEBUG: التقدير النهائي: $grade");
    } else {
      print("DEBUG: لا توجد درجات، استخدام التقدير الافتراضي: $grade");
    }

    return {
      'courseName': courseName,
      'creditHours': creditHours.toString(),
      'grade': grade,
    };
  }

  double calculateAverage() {
    if (grades.isEmpty) return 0.0;
    double total = grades.values.fold(0.0, (sum, grade) => sum + grade);
    return total / grades.length;
  }
}
