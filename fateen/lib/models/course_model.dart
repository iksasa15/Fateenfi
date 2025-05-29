import 'app_file.dart';
import 'task.dart';

class Course {
  final String id;
  final String courseName;
  final Map<String, double> grades;
  final Map<String, double> maxGrades;

  // إضافة الحقول المفقودة
  final int creditHours;
  final List<String> days;
  final String classroom;
  final String? lectureTime;
  final List<String> reminders;
  final List<AppFile> files;
  final List<Task> tasks;

  // getter لـ totalGrades
  double get totalGrades {
    if (grades.isEmpty) return 0.0;
    return grades.values.fold(0.0, (sum, grade) => sum + grade);
  }

  Course({
    required this.id,
    required this.courseName,
    required this.grades,
    Map<String, double>? maxGrades,
    required this.creditHours,
    required this.days,
    required this.classroom,
    this.lectureTime,
    List<String>? reminders,
    List<AppFile>? files,
    List<Task>? tasks,
  })  : maxGrades = maxGrades ?? {},
        reminders = reminders ?? [],
        files = files ?? [],
        tasks = tasks ?? [];

  factory Course.fromMap(Map<String, dynamic> data, String docId) {
    // معالجة الدرجات
    final gradesData = data['grades'] as Map? ?? {};
    final maxGradesData = data['maxGrades'] as Map? ?? {};

    final Map<String, double> parsedGrades = gradesData.map((k, v) {
      if (v is int) {
        return MapEntry(k as String, v.toDouble());
      } else if (v is double) {
        return MapEntry(k as String, v);
      } else if (v is String) {
        return MapEntry(k as String, double.tryParse(v) ?? 0.0);
      } else {
        return MapEntry(k as String, 0.0);
      }
    });

    final Map<String, double> parsedMaxGrades = maxGradesData.map((k, v) {
      if (v is int) {
        return MapEntry(k as String, v.toDouble());
      } else if (v is double) {
        return MapEntry(k as String, v);
      } else if (v is String) {
        return MapEntry(k as String, double.tryParse(v) ?? 100.0);
      } else {
        return MapEntry(k as String, 100.0);
      }
    });

    // معالجة الملفات
    List<AppFile> parsedFiles = [];
    if (data['files'] != null && data['files'] is List) {
      parsedFiles = (data['files'] as List)
          .map((fileData) => AppFile.fromMap(fileData))
          .toList();
    }

    // معالجة المهام
    List<Task> parsedTasks = [];
    if (data['tasks'] != null && data['tasks'] is List) {
      parsedTasks = (data['tasks'] as List)
          .map((taskData) => Task.fromJson(taskData))
          .toList();
    }

    return Course(
      id: data['id'] ?? docId,
      courseName: data['courseName'] ?? '',
      grades: parsedGrades,
      maxGrades: parsedMaxGrades,
      creditHours: data['creditHours'] ?? 3,
      days: List<String>.from(data['days'] ?? []),
      classroom: data['classroom'] ?? '',
      lectureTime: data['lectureTime'],
      reminders: List<String>.from(data['reminders'] ?? []),
      files: parsedFiles,
      tasks: parsedTasks,
    );
  }

  // حساب متوسط درجات المقرر
  double calculateAverage() {
    if (grades.isEmpty) return 0.0;
    double sum = 0.0;
    grades.forEach((_, gradeValue) => sum += gradeValue);
    return sum / grades.length;
  }

  // حساب مجموع درجات المقرر
  double calculateSum() {
    return grades.values.fold(0.0, (prev, curr) => prev + curr);
  }

  // حساب أعلى درجة في المقرر
  double calculateMax() {
    if (grades.isEmpty) return 0.0;
    return grades.values.reduce((a, b) => a > b ? a : b);
  }

  // حساب أدنى درجة في المقرر
  double calculateMin() {
    if (grades.isEmpty) return 0.0;
    return grades.values.reduce((a, b) => a < b ? a : b);
  }
}

// امتداد لترتيب القائمة
extension ListSorted<T> on List<T> {
  List<T> sorted(int Function(T a, T b) compare) {
    final List<T> copy = List.of(this);
    copy.sort(compare);
    return copy;
  }
}
