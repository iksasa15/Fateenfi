class PomodoroDurations {
  // خيارات مدة جلسة التركيز
  static const List<int> sessionDurations = [
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    55,
    60
  ];

  // خيارات مدة الاستراحة القصيرة
  static const List<int> breakDurations = [5, 10, 15, 20];

  // خيارات مدة الاستراحة الطويلة
  static const List<int> longBreakDurations = [15, 20, 25, 30];

  // خيارات عدد الجلسات قبل الاستراحة الطويلة
  static const List<int> sessionsOptions = [2, 3, 4, 5, 6];

  // الحدود
  static const int maxCustomDuration = 180; // أقصى مدة مسموح بها (دقائق)
  static const int minCustomDuration = 1; // أدنى مدة مسموح بها (دقائق)

  // مدة رسوم متحركة
  static const int timerAnimationDuration = 500; // بالمللي ثانية
  static const int pulseAnimationDuration = 1500; // بالمللي ثانية
  static const int delayedStartDuration = 3; // بالثواني
}
