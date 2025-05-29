import 'study_session.dart';

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

  // تحويل إلى Map للتخزين
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'tips': tips,
    };
  }

  // إنشاء من Map للاسترجاع
  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    List<StudySession> sessions = [];
    if (json['sessions'] != null) {
      sessions = (json['sessions'] as List)
          .map((item) => StudySession.fromJson(item))
          .toList();
    }

    List<String> tips = [];
    if (json['tips'] != null) {
      tips = List<String>.from(json['tips']);
    }

    return StudyPlan(
      title: json['title'] ?? 'خطة دراسية',
      description: json['description'] ?? 'خطة دراسية مخصصة',
      sessions: sessions,
      tips: tips,
    );
  }

  // نسخة معدلة
  StudyPlan copyWith({
    String? title,
    String? description,
    List<StudySession>? sessions,
    List<String>? tips,
  }) {
    return StudyPlan(
      title: title ?? this.title,
      description: description ?? this.description,
      sessions: sessions ?? this.sessions,
      tips: tips ?? this.tips,
    );
  }

  // الحصول على جلسات يوم معين
  List<StudySession> getSessionsForDay(String day) {
    return sessions.where((session) => session.day == day).toList();
  }

  // حساب إجمالي ساعات الدراسة الأسبوعية
  int get totalWeeklyMinutes {
    return sessions.fold(0, (sum, session) => sum + session.durationMinutes);
  }

  // الحصول على خطة فارغة
  factory StudyPlan.empty() {
    return StudyPlan(
      title: 'خطة دراسية جديدة',
      description: 'لم يتم إنشاء خطة دراسية بعد',
      sessions: [],
      tips: [],
    );
  }
}
