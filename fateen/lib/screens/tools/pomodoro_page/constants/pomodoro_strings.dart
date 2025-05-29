class PomodoroStrings {
  // عناوين الشاشة
  static const String appTitle = 'وقت المذاكرة';
  static const String resetTimerTitle = 'إعادة ضبط المؤقت';
  static const String resetTimerContent =
      'هل أنت متأكد من رغبتك في إعادة ضبط المؤقت وحذف التقدم؟';
  static const String resetTimerCancel = 'إلغاء';
  static const String resetTimerConfirm = 'إعادة ضبط';
  static const String resetTimerSuccess = 'تم إعادة ضبط المؤقت';

  // حالات المؤقت
  static const String statusReady = 'جاهز للبدء';
  static const String statusFocus = 'وقت التركيز';
  static const String statusShortBreak = 'استراحة قصيرة';
  static const String statusLongBreak = 'استراحة طويلة';
  static const String remainingTime = 'متبقي';
  static const String readyStatus = 'جاهز';

  // معلومات التنقل
  static const String nextFocusSession = 'جلسة التركيز التالية:';
  static const String nextBreakSession = 'الاستراحة التالية:';
  static const String minutesUnit = 'دقيقة';
  static const String longBreakLabel = 'طويلة';
  static const String shortBreakLabel = 'قصيرة';

  // أزرار التحكم
  static const String startButton = 'بدء';
  static const String pauseButton = 'إيقاف';
  static const String resetButton = 'إعادة ضبط';

  // الإعدادات
  static const String settingsTitle = 'الإعدادات';
  static const String settingsFocusDuration = 'مدة جلسة التركيز:';
  static const String settingsShortBreakDuration = 'مدة الاستراحة القصيرة:';
  static const String settingsLongBreakDuration = 'مدة الاستراحة الطويلة:';
  static const String settingsSessionsCount = 'جلسات قبل الاستراحة الطويلة:';
  static const String customOption = 'مخصص';
  static const String minutesSuffix = 'دقيقة';

  // حوار الإعدادات
  static const String settingsAutoStartBreaks = 'بدء فترات الاستراحة تلقائيًا';
  static const String settingsAutoStartBreaksDesc =
      'بدء مؤقت الاستراحة تلقائيًا بعد انتهاء جلسة التركيز';
  static const String settingsAutoStartSessions = 'بدء جلسات التركيز تلقائيًا';
  static const String settingsAutoStartSessionsDesc =
      'بدء مؤقت التركيز تلقائيًا بعد انتهاء فترة الاستراحة';
  static const String settingsEnableSounds = 'تفعيل الأصوات';
  static const String settingsEnableSoundsDesc =
      'تشغيل صوت تنبيه عند انتهاء المؤقت';
  static const String settingsEnableVibration = 'تفعيل الاهتزاز';
  static const String settingsEnableVibrationDesc =
      'اهتزاز الجهاز عند انتهاء المؤقت';
  static const String settingsShowNotifications = 'عرض الإشعارات';
  static const String settingsShowNotificationsDesc =
      'عرض إشعار عند انتهاء المؤقت';
  static const String settingsSaveButton = 'حفظ';
  static const String settingsCancelButton = 'إلغاء';

  // حوار الوقت المخصص
  static const String customFocusTimeTitle = 'تحديد مدة جلسة التركيز';
  static const String customShortBreakTimeTitle = 'تحديد مدة الاستراحة القصيرة';
  static const String customLongBreakTimeTitle = 'تحديد مدة الاستراحة الطويلة';
  static const String customTimeInstructions = 'أدخل عدد الدقائق (1-180)';
  static const String customTimeHint = 'عدد الدقائق...';
  static const String customTimeConfirm = 'تأكيد';
  static const String customTimeCancel = 'إلغاء';
  static const String customTimeError = 'يرجى إدخال قيمة بين 1 و 180 دقيقة';
  static const String customTimeNumberError = 'يرجى إدخال رقم صحيح';

  // الإحصائيات
  static const String statsTitle = 'إحصائيات الجلسة';
  static const String statsFocusTime = 'وقت التركيز';
  static const String statsShortBreaks = 'استراحات قصيرة';
  static const String statsLongBreaks = 'استراحات طويلة';
  static const String statsCurrentProgress = 'تقدم الدورة الحالية:';
  static const String statsCompletedLabel = 'اكتمل';
  static const String statsFromLabel = 'من أصل';
  static const String statsSessionsLabel = 'جلسة في هذه الدورة';

  // إشعارات المؤقت
  static const String beginBreakMessage = 'بدأت فترة $statusShortBreak!';
  static const String beginLongBreakMessage = 'بدأت فترة $statusLongBreak!';
  static const String beginFocusMessage =
      'انتهت فترة الاستراحة. لنبدأ التركيز من جديد!';
  static const String startButtonLabel = 'بدء';

  // القيم الافتراضية
  static const String defaultSessionsValue = "4";
  static const String defaultFocusDuration = "25";
  static const String defaultShortBreakDuration = "5";
  static const String defaultLongBreakDuration = "15";
}
