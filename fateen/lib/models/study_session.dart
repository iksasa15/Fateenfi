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

  // تحويل إلى Map للتخزين
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'timeSlot': timeSlot,
      'subject': subject,
      'focus': focus,
      'durationMinutes': durationMinutes,
    };
  }

  // إنشاء من Map للاسترجاع
  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      day: json['day'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      subject: json['subject'] ?? '',
      focus: json['focus'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 120,
    );
  }

  // نسخة معدلة
  StudySession copyWith({
    String? day,
    String? timeSlot,
    String? subject,
    String? focus,
    int? durationMinutes,
  }) {
    return StudySession(
      day: day ?? this.day,
      timeSlot: timeSlot ?? this.timeSlot,
      subject: subject ?? this.subject,
      focus: focus ?? this.focus,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}
