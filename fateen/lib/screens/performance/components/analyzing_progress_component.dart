import 'package:flutter/material.dart';
import 'package:universal_html/js.dart';
import 'dart:math';
import '../constants/performance_colors.dart';

/// مكون إظهار تقدم التحليل
/// يعرض رسومات متحركة ومؤشر تقدم أثناء تحليل بيانات الطالب
class AnalyzingProgressComponent extends StatelessWidget {
  /// رسالة تصف حالة التقدم الحالية
  final String progressMessage;

  const AnalyzingProgressComponent({
    Key? key,
    required this.progressMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildProgressCard(context),
    );
  }

  /// بناء بطاقة مؤشر التقدم الرئيسية
  Widget _buildProgressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // أيقونة متحركة للتفكير
          _buildThinkingIconContainer(),

          const SizedBox(height: 24),

          // رسالة التقدم
          Text(
            progressMessage,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // شريط التقدم
          LinearProgressIndicator(
            backgroundColor: Colors.grey,
            valueColor:
                AlwaysStoppedAnimation<Color>(PerformanceColors.primary),
          ),

          const SizedBox(height: 16),

          // رسالة مدة الانتظار
          const Text(
            "قد تستغرق العملية بضع دقائق...",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ],
      ),
    );
  }

  /// بناء حاوية أيقونة التفكير المتحركة
  Widget _buildThinkingIconContainer() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: PerformanceColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildThinkingAnimation(),
      ),
    );
  }

  /// بناء الرسوم المتحركة للتفكير (الدماغ مع الدوائر المتحركة)
  Widget _buildThinkingAnimation() {
    return Stack(
      children: [
        // أيقونة الدماغ المركزية
        Center(
          child: Icon(
            Icons.psychology,
            color: PerformanceColors.primary,
            size: 40,
          ),
        ),

        // دوائر متحركة حول الدماغ
        _buildRotatingCircles(),
      ],
    );
  }

  /// بناء الدوائر المتحركة حول أيقونة الدماغ
  Widget _buildRotatingCircles() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 6.28, // دوران كامل (2π)
          child: CustomPaint(
            painter: CirclesPainter(
              PerformanceColors.primary,
              value,
            ),
            size: const Size(50, 50),
          ),
        );
      },
      // إعادة تشغيل الرسوم المتحركة باستمرار
      onEnd: () {
        (context as Element).markNeedsBuild();
      },
    );
  }
}

/// رسام مخصص للدوائر المتحركة حول أيقونة الدماغ
class CirclesPainter extends CustomPainter {
  /// لون الدوائر
  final Color color;

  /// نسبة التقدم للرسوم المتحركة (0.0 إلى 1.0)
  final double progress;

  CirclesPainter(this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // رسم 3 دوائر حول المركز
    for (int i = 0; i < 3; i++) {
      // حساب موقع كل دائرة باستخدام الدالة الدائرية
      final offset = 2 * pi * (i / 3) + progress * 2 * pi;
      final x = center.dx + radius * cos(offset);
      final y = center.dy + radius * sin(offset);

      // تحديد خصائص الرسم لكل دائرة
      final paint = Paint()
        ..color = color
            .withOpacity(0.6 - (i * 0.15)) // جعل الدوائر متتالية أكثر شفافية
        ..style = PaintingStyle.fill;

      // رسم الدائرة بحجم متناقص تدريجيًا
      canvas.drawCircle(Offset(x, y), 4 - i * 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // إعادة الرسم مع كل تغيير في قيمة التقدم
    return true;
  }
}
