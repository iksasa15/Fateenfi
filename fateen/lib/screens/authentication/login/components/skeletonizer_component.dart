import 'package:flutter/material.dart';
import '../../shared/constants/auth_colors.dart';

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

    // استخدام MediaQuery للحصول على حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;

    // تعريف الألوان الافتراضية
    final base = widget.baseColor ?? AuthColors.shimmerBase;
    final highlight = widget.highlightColor ?? AuthColors.shimmerHighlight;

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
          child: _buildSkeletonWrapper(widget.child, screenWidth),
        );
      },
    );
  }

  Widget _buildSkeletonWrapper(Widget widget, double screenWidth) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(screenWidth * 0.04), // 4% من عرض الشاشة
      ),
      child: _buildEnhancedSkeleton(widget, screenWidth),
    );
  }

  // تحويل العناصر إلى هياكل عظمية محسنة
  Widget _buildEnhancedSkeleton(Widget widget, double screenWidth) {
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
        height: widget.size ?? screenWidth * 0.067, // ~6.7% من عرض الشاشة
        width: widget.size ?? screenWidth * 0.067,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(screenWidth * 0.022), // ~2.2% من عرض الشاشة
        ),
      );
    } else if (widget is Container) {
      return Container(
        height: widget.constraints?.maxHeight,
        width: widget.constraints?.maxWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(screenWidth * 0.033), // ~3.3% من عرض الشاشة
        ),
      );
    } else if (widget is Image) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.033),
        ),
      );
    } else if (widget is ElevatedButton || widget is TextButton) {
      return Container(
        height: screenWidth * 0.156, // ~15.6% من عرض الشاشة
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(screenWidth * 0.044), // ~4.4% من عرض الشاشة
        ),
      );
    } else if (widget is TextField || widget is TextFormField) {
      return Container(
        height: screenWidth * 0.167, // ~16.7% من عرض الشاشة
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.044),
        ),
      );
    }

    // معالجة الأطفال بشكل متكرر
    if (widget is SingleChildScrollView) {
      return SingleChildScrollView(
        child: _buildEnhancedSkeleton(widget.child!, screenWidth),
        physics: widget.physics,
        scrollDirection: widget.scrollDirection,
      );
    } else if (widget is Column) {
      return Column(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: widget.children
            .map((child) => _buildEnhancedSkeleton(child, screenWidth))
            .toList(),
      );
    } else if (widget is Row) {
      return Row(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: widget.children
            .map((child) => _buildEnhancedSkeleton(child, screenWidth))
            .toList(),
      );
    } else if (widget is Padding) {
      return Padding(
        padding: widget.padding,
        child: _buildEnhancedSkeleton(widget.child!, screenWidth),
      );
    } else if (widget is SizedBox) {
      if (widget.child != null) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: _buildEnhancedSkeleton(widget.child!, screenWidth),
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
