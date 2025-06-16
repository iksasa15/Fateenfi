import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class CountdownTimer extends StatefulWidget {
  final int initialSeconds;
  final double? fontSize;
  final bool showIcon;
  final Color? customColor;

  const CountdownTimer({
    Key? key,
    required this.initialSeconds,
    this.fontSize,
    this.showIcon = true,
    this.customColor,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحديث العداد عند تغيير قيمة initialSeconds
    if (widget.initialSeconds != oldWidget.initialSeconds) {
      _remainingSeconds = widget.initialSeconds;
    }
  }

  void _startTimer() {
    // إلغاء المؤقت السابق إن وجد
    _timer?.cancel();

    // بدء مؤقت جديد
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تنسيق الوقت المتبقي
    String formattedTime = _formatRemainingTime(_remainingSeconds);
    Color timeColor =
        widget.customColor ?? _getTimeColor(context, _remainingSeconds);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showIcon) ...[
          Icon(
            Icons.access_time_rounded,
            size: widget.fontSize != null
                ? widget.fontSize! * 1.2
                : AppDimensions.getIconSize(context,
                    size: IconSize.small, small: true),
            color: timeColor,
          ),
          SizedBox(width: 4),
        ],
        Text(
          formattedTime,
          style: TextStyle(
            fontFamily: 'SYMBIOAR+LT',
            fontSize: widget.fontSize ??
                AppDimensions.getLabelFontSize(context) * 0.9,
            fontWeight: FontWeight.bold,
            color: timeColor,
          ),
        ),
      ],
    );
  }

  String _formatRemainingTime(int seconds) {
    if (seconds < 60) {
      return "$seconds ث";
    }

    int minutes = seconds ~/ 60;
    if (minutes < 60) {
      return "$minutes د";
    }

    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return "$hours س";
    }

    // تحسين العرض لتكون أكثر وضوحاً
    return "$hours:${remainingMinutes.toString().padLeft(2, '0')}";
  }

  Color _getTimeColor(BuildContext context, int seconds) {
    if (seconds < 900) {
      // أقل من 15 دقيقة - استخدام لون الخطأ من AppColors
      return context.colorError;
    } else if (seconds < 1800) {
      // أقل من 30 دقيقة - استخدام لون التحذير من AppColors
      return context.colorWarning;
    } else {
      // أكثر من 30 دقيقة - استخدام لون النجاح من AppColors
      return context.colorSuccess;
    }
  }
}
