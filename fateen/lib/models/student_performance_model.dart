import '../models/course.dart';
import '../models/student.dart';

class PerformanceData {
  final Student student;
  final List<Course> courses;
  final StudentHabits habits;
  final PerformanceAnalysis? analysis;

  PerformanceData({
    required this.student,
    required this.courses,
    required this.habits,
    this.analysis,
  });
}

class StudentHabits {
  final int sleepHours;
  final int studyHoursDaily;
  final int studyHoursWeekly;
  final int understandingLevel; // 1-5
  final int distractionLevel; // 1-5
  final bool hasHealthIssues;
  final String learningStyle; // visual, auditory, kinesthetic
  final String additionalNotes;

  StudentHabits({
    required this.sleepHours,
    required this.studyHoursDaily,
    required this.studyHoursWeekly,
    required this.understandingLevel,
    required this.distractionLevel,
    required this.hasHealthIssues,
    required this.learningStyle,
    this.additionalNotes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'sleepHours': sleepHours,
      'studyHoursDaily': studyHoursDaily,
      'studyHoursWeekly': studyHoursWeekly,
      'understandingLevel': understandingLevel,
      'distractionLevel': distractionLevel,
      'hasHealthIssues': hasHealthIssues,
      'learningStyle': learningStyle,
      'additionalNotes': additionalNotes,
    };
  }

  factory StudentHabits.fromJson(Map<String, dynamic> json) {
    return StudentHabits(
      sleepHours: json['sleepHours'] ?? 7,
      studyHoursDaily: json['studyHoursDaily'] ?? 2,
      studyHoursWeekly: json['studyHoursWeekly'] ?? 10,
      understandingLevel: json['understandingLevel'] ?? 3,
      distractionLevel: json['distractionLevel'] ?? 3,
      hasHealthIssues: json['hasHealthIssues'] ?? false,
      learningStyle: json['learningStyle'] ?? 'visual',
      additionalNotes: json['additionalNotes'] ?? '',
    );
  }
}

class PerformanceAnalysis {
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> correlations;
  final List<String> studyPatterns;
  final StudyPlan studyPlan;
  final List<LearningResource> resources;
  final double? calculatedGPA;

  PerformanceAnalysis({
    required this.strengths,
    required this.weaknesses,
    required this.correlations,
    required this.studyPatterns,
    required this.studyPlan,
    required this.resources,
    this.calculatedGPA,
  });

  factory PerformanceAnalysis.fromJson(Map<String, dynamic> json) {
    return PerformanceAnalysis(
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      correlations: List<String>.from(json['correlations'] ?? []),
      studyPatterns: List<String>.from(json['studyPatterns'] ?? []),
      studyPlan: StudyPlan.fromJson(json['studyPlan'] ?? {}),
      resources: (json['resources'] as List<dynamic>?)
              ?.map((resource) => LearningResource.fromJson(resource))
              .toList() ??
          [],
      calculatedGPA: json['calculatedGPA'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strengths': strengths,
      'weaknesses': weaknesses,
      'correlations': correlations,
      'studyPatterns': studyPatterns,
      'studyPlan': studyPlan.toJson(),
      'resources': resources.map((resource) => resource.toJson()).toList(),
      'calculatedGPA': calculatedGPA,
    };
  }
}

class StudyPlan {
  final String title;
  final String description;
  final List<StudySession> sessions;
  final List<String> tips;

  StudyPlan({
    required this.title,
    required this.description,
    required this.sessions,
    required this.tips,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((session) => StudySession.fromJson(session))
              .toList() ??
          [],
      tips: List<String>.from(json['tips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'tips': tips,
    };
  }
}

class StudySession {
  final String day;
  final String timeSlot;
  final String subject;
  final String focus;
  final int durationMinutes;

  StudySession({
    required this.day,
    required this.timeSlot,
    required this.subject,
    required this.focus,
    required this.durationMinutes,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      day: json['day'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      subject: json['subject'] ?? '',
      focus: json['focus'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'timeSlot': timeSlot,
      'subject': subject,
      'focus': focus,
      'durationMinutes': durationMinutes,
    };
  }
}

class LearningResource {
  final String title;
  final String description;
  final String type; // video, article, exercise, quiz
  final String url;
  final String thumbnailUrl;
  final int durationMinutes;
  final String subject;

  LearningResource({
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    required this.thumbnailUrl,
    required this.durationMinutes,
    required this.subject,
  });

  factory LearningResource.fromJson(Map<String, dynamic> json) {
    return LearningResource(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'video',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 10,
      subject: json['subject'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'durationMinutes': durationMinutes,
      'subject': subject,
    };
  }
}
