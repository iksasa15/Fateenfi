import 'package:flutter/material.dart';
import 'constants/pomodoro_colors.dart';
import 'constants/pomodoro_strings.dart';
import 'controllers/pomodoro_controller.dart';
import 'components/timer/timer_circle.dart';
import 'components/timer/control_buttons.dart';
import 'components/timer/session_indicators.dart';
import 'components/timer/status_label.dart';
import 'components/settings/time_settings.dart';
import 'components/settings/settings_dialog.dart';
import 'components/settings/custom_time_dialog.dart';
import 'components/stats/stats_card.dart';
import 'components/pomodoro_header_component.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with TickerProviderStateMixin {
  // متحكم الحالة للميزة بالكامل
  late PomodoroController _controller;

  @override
  void initState() {
    super.initState();
    // تهيئة متحكم البوموردورو
    _controller = PomodoroController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تعيين اتجاه النص للصفحة بالكامل
      child: Scaffold(
        backgroundColor:
            const Color(0xFFFDFDFF), // لون خلفية متوافق مع صفحة المقررات
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // استخدام مكون الهيدر الجديد
                  PomodoroHeaderComponent(
                    onSettingsPressed: _showSettingsDialog,
                  ),

                  // محتوى الصفحة
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10), // تقليل الحشو أكثر لمنع تجاوز الحدود
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // قسم المؤقت
                          _buildTimerSection(),
                          const SizedBox(height: 14), // تقليل المسافة

                          // قسم الإعدادات
                          TimeSettings(
                            controller: _controller,
                            isDarkMode: false,
                            onCustomTimeRequested: _showCustomTimeDialog,
                          ),
                          const SizedBox(height: 14), // تقليل المسافة

                          // قسم الإحصائيات
                          StatsCard(
                            controller: _controller,
                            isDarkMode: false,
                          ),
                          const SizedBox(
                              height:
                                  14), // تقليل المسافة لمنع تجاوز الحدود السفلية
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // تمت إزالة الزر العائم (FloatingActionButton) تمامًا
      ),
    );
  }

  // بناء قسم المؤقت مع تحسينات لتجنب تجاوز الحدود
  Widget _buildTimerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14), // تقليل الحشو أكثر
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF5F3FF), // لون حدود متوافق مع صفحة المقررات
          width: 1, // تقليل سمك الحدود
        ),
      ),
      child: Column(
        children: [
          // مؤشرات الدورة
          SessionIndicators(controller: _controller),
          const SizedBox(height: 6), // تقليل المسافة أكثر

          // حالة المؤقت
          StatusLabel(
            controller: _controller,
            isDarkMode: false,
          ),
          const SizedBox(height: 12), // تقليل المسافة أكثر

          // المؤقت الدائري - يحتاج تعديل لكي لا يتأثر باتجاه النص
          Directionality(
            textDirection:
                TextDirection.ltr, // إعادة تعيين اتجاه النص للمؤقت الدائري
            child: Container(
              // تحديد حجم للحاوية لمنع تجاوز الحدود
              height: MediaQuery.of(context).size.width * 0.5,
              width: MediaQuery.of(context).size.width * 0.5,
              child: TimerCircle(
                controller: _controller,
                isDarkMode: false,
                pulseAnimation: _controller.pulseAnimation,
              ),
            ),
          ),
          const SizedBox(height: 16), // تقليل المسافة أكثر

          // أزرار التحكم - ضمان أن تظهر بشكل صحيح مع اتجاه النص
          Directionality(
            textDirection: TextDirection.ltr, // إعادة تعيين اتجاه النص للأزرار
            child: ControlButtons(
              controller: _controller,
              onResetPressed: _showResetConfirmation,
              isDarkMode: false,
            ),
          ),

          // تمت إزالة زر التشغيل/الإيقاف الإضافي

          // عدد الجلسات المكتملة - تعديل لتناسب مع الشاشة
          if (_controller.completedSessions > 0) ...[
            const SizedBox(height: 14), // تقليل المسافة أكثر
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompletionInfo(
                  icon: Icons.check_circle_outline,
                  title: PomodoroStrings.statsSessionsLabel.split(' ')[0],
                  value: _controller.completedSessions.toString(),
                  color: PomodoroColors.kGreenColor,
                ),
                Container(
                  height: 16, // تقليل ارتفاع الخط الفاصل أكثر
                  width: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(
                      horizontal: 6), // تقليل الهوامش أكثر
                ),
                _buildCompletionInfo(
                  icon: Icons.repeat,
                  title: PomodoroStrings.statsFromLabel.split(' ')[1],
                  value: _controller.currentCycle.toString(),
                  color: PomodoroColors.kMediumPurple,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // بناء معلومات الإكمال - تم تحسين الأحجام لمنع تجاوز الحدود
  Widget _buildCompletionInfo({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 14, // تصغير حجم الأيقونة أكثر
            ),
            const SizedBox(width: 3), // تقليل المسافة أكثر
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11, // تصغير حجم الخط أكثر
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
        const SizedBox(height: 2), // تقليل المسافة أكثر
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF221291), // لون متوافق مع صفحة المقررات
            fontWeight: FontWeight.bold,
            fontSize: 13, // تصغير حجم الخط أكثر
            fontFamily: 'SYMBIOAR+LT',
          ),
        ),
      ],
    );
  }

  // عرض حوار الإعدادات - تم تعديله لدعم RTL
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl, // ضمان اتجاه النص في الحوار
        child: SettingsDialog(controller: _controller),
      ),
    );
  }

  // عرض حوار الوقت المخصص - تم تعديله لدعم RTL
  void _showCustomTimeDialog(bool isSession, {bool isLongBreak = false}) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl, // ضمان اتجاه النص في الحوار
        child: CustomTimeDialog(
          controller: _controller,
          isSession: isSession,
          isLongBreak: isLongBreak,
        ),
      ),
    );
  }

  // عرض حوار تأكيد إعادة الضبط - تم تعديله لدعم RTL
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl, // ضمان اتجاه النص في الحوار
        child: AlertDialog(
          title: const Text(
            PomodoroStrings.resetTimerTitle,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontWeight: FontWeight.bold,
              color: Color(0xFF221291), // لون متوافق مع صفحة المقررات
              fontSize: 14, // تصغير حجم الخط
            ),
          ),
          content: const Text(
            PomodoroStrings.resetTimerContent,
            style: TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: 12, // تصغير حجم الخط
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                PomodoroStrings.resetTimerCancel,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: 12, // تصغير حجم الخط
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _controller.resetTimer();
                _showSuccessSnackBar(PomodoroStrings.resetTimerSuccess);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF4338CA), // لون متوافق مع صفحة المقررات
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                PomodoroStrings.resetTimerConfirm,
                style: TextStyle(
                  fontFamily: 'SYMBIOAR+LT',
                  fontSize: 12, // تصغير حجم الخط
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عرض رسالة نجاح - تم تعديلها لدعم RTL
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl, // ضمان اتجاه النص في الإشعار
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'SYMBIOAR+LT',
              fontSize: 12, // تصغير حجم الخط
            ),
          ),
        ),
        backgroundColor: const Color(0xFF4338CA), // لون متوافق مع صفحة المقررات
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6), // تقليل الهوامش أكثر
      ),
    );
  }

  // عرض رسالة عند انتهاء المؤقت - تم تعديلها لدعم RTL
  void showCompletionSnackBar() {
    if (!_controller.showNotifications) return;

    final message = _controller.getCompletionMessage();
    final backgroundColor = _controller.isBreakTime
        ? const Color(0xFF221291) // لون متوافق مع صفحة المقررات
        : PomodoroColors.kAccentColor;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl, // ضمان اتجاه النص في الإشعار
          child: Row(
            children: [
              Icon(
                _controller.isBreakTime ? Icons.free_breakfast : Icons.work,
                color: Colors.white,
                size: 14, // تصغير حجم الأيقونة أكثر
              ),
              const SizedBox(width: 6), // تقليل المسافة أكثر
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11, // تصغير حجم الخط أكثر
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6), // تقليل الهوامش أكثر
        duration: const Duration(seconds: 4),
        action: _controller.isBreakTime && !_controller.autoStartBreaks
            ? SnackBarAction(
                label: PomodoroStrings.startButtonLabel,
                textColor: Colors.white,
                onPressed: _controller.startTimer,
              )
            : null,
      ),
    );
  }
}
