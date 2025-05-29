import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/pomodoro_strings.dart';
import '../constants/pomodoro_durations.dart';
import 'sound_controller.dart';

enum TimerState { ready, running, paused }

enum TimerType { focus, shortBreak, longBreak }

class PomodoroController extends ChangeNotifier {
  // المتحكمات الأخرى
  final SoundController _soundController = SoundController();

  // حالة المؤقت
  TimerState _timerState = TimerState.ready;
  TimerType _timerType = TimerType.focus;

  // إعدادات المؤقت
  int _sessionDuration = 25;
  int _breakDuration = 5;
  int _longBreakDuration = 15;
  int _secondsRemaining = 25 * 60;
  int _completedSessions = 0;
  int _sessionsUntilLongBreak = 4;
  int _currentCycle = 1;

  // إعدادات إضافية
  bool _autoStartBreaks = true;
  bool _autoStartSessions = false;
  bool _enableSounds = true;
  bool _enableVibration = true;
  bool _showNotifications = true;

  // المؤقت
  Timer? _timer;

  // القيم المختارة في الإعدادات
  String _selectedSessionValue = PomodoroStrings.defaultFocusDuration;
  String _selectedBreakValue = PomodoroStrings.defaultShortBreakDuration;
  String _selectedLongBreakValue = PomodoroStrings.defaultLongBreakDuration;
  String _selectedSessionsValue = PomodoroStrings.defaultSessionsValue;

  // متحكمات الرسوم المتحركة
  late final AnimationController timerAnimationController;
  late final AnimationController pulseAnimationController;
  late final Animation<double> pulseAnimation;

  // متغيرات عرض
  String _statusMessage = PomodoroStrings.statusReady;
  String _nextSessionInfo =
      "${PomodoroStrings.nextFocusSession} 25 ${PomodoroStrings.minutesUnit}";
  bool _timerJustEnded = false;
  List<bool> _cycleIndicators = [true, false, false, false];

  // المتحكمات الرسومية لازمة للبناء
  PomodoroController({
    required TickerProvider vsync,
  }) {
    // تهيئة متحكمات الرسوم المتحركة
    timerAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(
          milliseconds: PomodoroDurations.timerAnimationDuration),
    );

    pulseAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(
          milliseconds: PomodoroDurations.pulseAnimationDuration),
    );

    pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // تهيئة المتحكمات
    timerAnimationController.forward();
    _updateTimerInfo();
    _soundController.preloadSound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    timerAnimationController.dispose();
    pulseAnimationController.dispose();
    _soundController.dispose();
    super.dispose();
  }

  // الحصول على الحالة الحالية
  TimerState get timerState => _timerState;
  TimerType get timerType => _timerType;
  int get sessionDuration => _sessionDuration;
  int get breakDuration => _breakDuration;
  int get longBreakDuration => _longBreakDuration;
  int get secondsRemaining => _secondsRemaining;
  int get completedSessions => _completedSessions;
  int get sessionsUntilLongBreak => _sessionsUntilLongBreak;
  int get currentCycle => _currentCycle;
  String get statusMessage => _statusMessage;
  String get nextSessionInfo => _nextSessionInfo;
  List<bool> get cycleIndicators => _cycleIndicators;

  // الإعدادات
  bool get autoStartBreaks => _autoStartBreaks;
  bool get autoStartSessions => _autoStartSessions;
  bool get enableSounds => _enableSounds;
  bool get enableVibration => _enableVibration;
  bool get showNotifications => _showNotifications;

  // القيم المختارة
  String get selectedSessionValue => _selectedSessionValue;
  String get selectedBreakValue => _selectedBreakValue;
  String get selectedLongBreakValue => _selectedLongBreakValue;
  String get selectedSessionsValue => _selectedSessionsValue;

  // طرق مساعدة
  bool get isTimerRunning => _timerState == TimerState.running;
  bool get isBreakTime => _timerType != TimerType.focus;
  bool get isLongBreak => _timerType == TimerType.longBreak;

  // قيمة التقدم (0.0 إلى 1.0)
  double get progressValue {
    final totalSeconds = _getTotalSeconds();
    if (totalSeconds == 0) return 0;
    return _secondsRemaining / totalSeconds;
  }

  // الحصول على إجمالي ثواني المؤقت الحالي
  int _getTotalSeconds() {
    switch (_timerType) {
      case TimerType.focus:
        return _sessionDuration * 60;
      case TimerType.shortBreak:
        return _breakDuration * 60;
      case TimerType.longBreak:
        return _longBreakDuration * 60;
    }
  }

  // تنسيق الوقت بالدقائق والثواني
  String formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // تحديث معلومات المؤقت للعرض
  void _updateTimerInfo() {
    if (_timerState == TimerState.running) {
      _statusMessage = _getStatusMessage();
    } else {
      _statusMessage = PomodoroStrings.statusReady;
    }

    // تحديث معلومات الجلسة التالية
    if (_timerType != TimerType.focus) {
      _nextSessionInfo =
          "${PomodoroStrings.nextFocusSession} $_sessionDuration ${PomodoroStrings.minutesUnit}";
    } else {
      final nextBreakIsSoon =
          (_completedSessions + 1) % _sessionsUntilLongBreak == 0;
      final nextBreakDuration =
          nextBreakIsSoon ? _longBreakDuration : _breakDuration;
      final breakType = nextBreakIsSoon
          ? PomodoroStrings.longBreakLabel
          : PomodoroStrings.shortBreakLabel;
      _nextSessionInfo =
          "${PomodoroStrings.nextBreakSession} $nextBreakDuration ${PomodoroStrings.minutesUnit} ($breakType)";
    }

    // تحديث مؤشرات الدورة
    _updateCycleIndicators();

    notifyListeners();
  }

  // الحصول على رسالة الحالة
  String _getStatusMessage() {
    switch (_timerType) {
      case TimerType.focus:
        return PomodoroStrings.statusFocus;
      case TimerType.shortBreak:
        return PomodoroStrings.statusShortBreak;
      case TimerType.longBreak:
        return PomodoroStrings.statusLongBreak;
    }
  }

  // تحديث مؤشرات الدورة الحالية
  void _updateCycleIndicators() {
    final currentPosition = _completedSessions % _sessionsUntilLongBreak;
    _cycleIndicators = List.generate(
        _sessionsUntilLongBreak, (index) => index <= currentPosition);
  }

  // بدء المؤقت
  void startTimer() {
    if (_timerState != TimerState.running) {
      _timerState = TimerState.running;
      notifyListeners();

      // تشغيل الرسوم المتحركة للنبض
      pulseAnimationController.repeat(reverse: true);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          notifyListeners();
        } else {
          // إنهاء المؤقت الحالي
          stopTimer();

          // تعيين علامة انتهاء المؤقت
          _timerJustEnded = true;

          // تشغيل صوت التنبيه واهتزاز إذا كان مفعلاً
          _playAlerts();

          // تغيير الوضع بين وقت التركيز والاستراحة
          if (_timerType != TimerType.focus) {
            // انتهاء الاستراحة، بدء جلسة جديدة
            _timerType = TimerType.focus;
            _secondsRemaining = _sessionDuration * 60;

            // البدء تلقائيًا إذا كان الخيار مفعلاً
            if (_autoStartSessions) {
              _delayedStart();
            }
          } else {
            // انتهاء الجلسة، بدء الاستراحة
            _completedSessions++;

            // تحديد نوع الاستراحة (طويلة أو قصيرة)
            final needLongBreak =
                _completedSessions % _sessionsUntilLongBreak == 0;
            _timerType =
                needLongBreak ? TimerType.longBreak : TimerType.shortBreak;

            if (needLongBreak) {
              _secondsRemaining = _longBreakDuration * 60;
              _currentCycle++;
            } else {
              _secondsRemaining = _breakDuration * 60;
            }

            // البدء تلقائيًا إذا كان الخيار مفعلاً
            if (_autoStartBreaks) {
              _delayedStart();
            }
          }

          // تنفيذ رسوم متحركة للتايمر
          timerAnimationController.reset();
          timerAnimationController.forward();

          // تحديث معلومات المؤقت
          _updateTimerInfo();
        }
      });

      // تحديث معلومات المؤقت
      _updateTimerInfo();
    }
  }

  // بدء المؤقت بعد تأخير قصير
  void _delayedStart() {
    Future.delayed(
        const Duration(seconds: PomodoroDurations.delayedStartDuration), () {
      if (_timerState != TimerState.running) {
        startTimer();
      }
    });
  }

  // تشغيل التنبيهات (صوت واهتزاز)
  void _playAlerts() {
    if (_enableSounds && _timerJustEnded) {
      _soundController.playAlertSound();
      _timerJustEnded = false;
    }

    if (_enableVibration) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.mediumImpact();
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        HapticFeedback.mediumImpact();
      });
    }
  }

  // إيقاف المؤقت
  void stopTimer() {
    _timerState = TimerState.paused;
    _timer?.cancel();

    // إيقاف النبض
    pulseAnimationController.stop();
    pulseAnimationController.reset();

    notifyListeners();

    // تحديث معلومات المؤقت
    _updateTimerInfo();
  }

  // إعادة ضبط المؤقت بعد التأكيد
  void resetTimer() {
    stopTimer();

    _timerState = TimerState.ready;
    _timerType = TimerType.focus;
    _secondsRemaining = _sessionDuration * 60;
    _completedSessions = 0;
    _currentCycle = 1;

    // تنفيذ رسوم متحركة للتايمر
    timerAnimationController.reset();
    timerAnimationController.forward();

    // تحديث معلومات المؤقت
    _updateTimerInfo();
  }

  // تغيير إعدادات المؤقت
  void updateSessionDuration(String value) {
    _sessionDuration = int.parse(value);
    _selectedSessionValue = value;
    if (_timerType == TimerType.focus) {
      _secondsRemaining = _sessionDuration * 60;
    }
    _updateTimerInfo();
  }

  // تحديث مدة جلسة التركيز بقيمة مخصصة
  void updateSessionDurationWithCustomValue(int customValue) {
    _sessionDuration = customValue;
    _selectedSessionValue = customValue.toString();
    if (_timerType == TimerType.focus) {
      _secondsRemaining = _sessionDuration * 60;
    }
    _updateTimerInfo();
  }

  void updateBreakDuration(String value) {
    _breakDuration = int.parse(value);
    _selectedBreakValue = value;
    if (_timerType == TimerType.shortBreak) {
      _secondsRemaining = _breakDuration * 60;
    }
    _updateTimerInfo();
  }

  // تحديث مدة الاستراحة القصيرة بقيمة مخصصة
  void updateBreakDurationWithCustomValue(int customValue) {
    _breakDuration = customValue;
    _selectedBreakValue = customValue.toString();
    if (_timerType == TimerType.shortBreak) {
      _secondsRemaining = _breakDuration * 60;
    }
    _updateTimerInfo();
  }

  void updateLongBreakDuration(String value) {
    _longBreakDuration = int.parse(value);
    _selectedLongBreakValue = value;
    if (_timerType == TimerType.longBreak) {
      _secondsRemaining = _longBreakDuration * 60;
    }
    _updateTimerInfo();
  }

  // تحديث مدة الاستراحة الطويلة بقيمة مخصصة
  void updateLongBreakDurationWithCustomValue(int customValue) {
    _longBreakDuration = customValue;
    _selectedLongBreakValue = customValue.toString();
    if (_timerType == TimerType.longBreak) {
      _secondsRemaining = _longBreakDuration * 60;
    }
    _updateTimerInfo();
  }

  // تغيير عدد الجلسات قبل الاستراحة الطويلة
  void updateSessionsUntilLongBreak(String value) {
    _sessionsUntilLongBreak = int.parse(value);
    _selectedSessionsValue = value;
    _updateCycleIndicators();
    _updateTimerInfo();
  }

  // تحديث الإعدادات الإضافية
  void updateSettings({
    bool? autoStartBreaks,
    bool? autoStartSessions,
    bool? enableSounds,
    bool? enableVibration,
    bool? showNotifications,
  }) {
    if (autoStartBreaks != null) _autoStartBreaks = autoStartBreaks;
    if (autoStartSessions != null) _autoStartSessions = autoStartSessions;
    if (enableSounds != null) _enableSounds = enableSounds;
    if (enableVibration != null) _enableVibration = enableVibration;
    if (showNotifications != null) _showNotifications = showNotifications;
    notifyListeners();
  }

  // الحصول على رسالة الإشعار عند انتهاء المؤقت
  String getCompletionMessage() {
    if (_timerType == TimerType.focus) {
      return PomodoroStrings.beginFocusMessage;
    } else {
      return _timerType == TimerType.longBreak
          ? PomodoroStrings.beginLongBreakMessage
          : PomodoroStrings.beginBreakMessage;
    }
  }
}
