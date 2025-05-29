import 'package:flutter/material.dart';
import '../constants/login_colors.dart';

class SkeletonizerComponent extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration shimmerDuration;

  const SkeletonizerComponent({
    Key? key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
    this.shimmerDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<SkeletonizerComponent> createState() => _SkeletonizerComponentState();
}

class _SkeletonizerComponentState extends State<SkeletonizerComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.shimmerDuration,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // إذا لم تكن في حالة تحميل، نعرض المحتوى الفعلي
    if (!widget.isLoading) {
      return widget.child;
    }

    // تعريف الألوان الافتراضية
    final base = widget.baseColor ?? LoginColors.shimmerBase;
    final highlight = widget.highlightColor ?? LoginColors.shimmerHighlight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: _buildSkeletonWrapper(widget.child),
        );
      },
    );
  }

  Widget _buildSkeletonWrapper(Widget widget) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildEnhancedSkeleton(widget),
    );
  }

  // تحويل العناصر إلى هياكل عظمية محسنة
  Widget _buildEnhancedSkeleton(Widget widget) {
    if (widget is Text) {
      final height = (widget.style?.fontSize ?? 14.0) * 1.2;
      final width = _calculateTextWidth(
          widget.data ?? "", widget.style?.fontSize ?? 14.0);

      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(height / 3),
        ),
      );
    } else if (widget is Icon) {
      return Container(
        height: widget.size ?? 24.0,
        width: widget.size ?? 24.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else if (widget is Container) {
      return Container(
        height: widget.constraints?.maxHeight,
        width: widget.constraints?.maxWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    } else if (widget is Image) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    } else if (widget is ElevatedButton || widget is TextButton) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      );
    } else if (widget is TextField || widget is TextFormField) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    // معالجة الأطفال بشكل متكرر
    if (widget is SingleChildScrollView) {
      return SingleChildScrollView(
        child: _buildEnhancedSkeleton(widget.child!),
        physics: widget.physics,
        scrollDirection: widget.scrollDirection,
      );
    } else if (widget is Column) {
      return Column(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: widget.children.map(_buildEnhancedSkeleton).toList(),
      );
    } else if (widget is Row) {
      return Row(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: widget.children.map(_buildEnhancedSkeleton).toList(),
      );
    } else if (widget is Padding) {
      return Padding(
        padding: widget.padding,
        child: _buildEnhancedSkeleton(widget.child!),
      );
    } else if (widget is SizedBox) {
      if (widget.child != null) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: _buildEnhancedSkeleton(widget.child!),
        );
      }
      return widget;
    }

    // العناصر الأخرى
    return Container(
      color: Colors.transparent,
      child: widget,
    );
  }

  // تقدير عرض النص
  double _calculateTextWidth(String text, double fontSize) {
    // تقدير بسيط لعرض النص بناءً على عدد الأحرف
    final characterWidth = fontSize * 0.6;
    return text.length * characterWidth;
  }
}
