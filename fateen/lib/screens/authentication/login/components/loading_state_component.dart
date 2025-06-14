import 'package:flutter/material.dart';
import '../../../../core/constants/appColor.dart';

class LoadingStateComponent extends StatefulWidget {
  const LoadingStateComponent({Key? key}) : super(key: key);

  @override
  State<LoadingStateComponent> createState() => _LoadingStateComponentState();
}

class _LoadingStateComponentState extends State<LoadingStateComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _pulseAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                context.colorShimmerBase,
                context.colorShimmerHighlight,
                context.colorShimmerBase,
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: _buildEnhancedPlaceholders(context),
        );
      },
    );
  }

  Widget _buildEnhancedPlaceholders(BuildContext context) {
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ضبط القيم بناءً على حجم الشاشة
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = screenWidth * 0.06; // 6% من عرض الشاشة
    final verticalPadding = screenHeight * 0.0375; // 3.75% من ارتفاع الشاشة

    return Column(
      children: [
        // محاكاة الهيدر مع تصميم محسن
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // محاكاة العنوان الرئيسي
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: screenWidth * 0.5, // 50% من عرض الشاشة
                      height: screenHeight * 0.04, // 4% من ارتفاع الشاشة
                      margin: EdgeInsets.only(
                          bottom:
                              screenHeight * 0.015), // 1.5% من ارتفاع الشاشة
                      decoration: BoxDecoration(
                        color: context.colorSurface,
                        borderRadius: BorderRadius.circular(
                            screenWidth * 0.044), // 4.4% من عرض الشاشة
                      ),
                    ),
                  );
                },
              ),
              // محاكاة العنوان الفرعي مع إيقونة
              Row(
                children: [
                  Container(
                    width: screenWidth * 0.067, // 6.7% من عرض الشاشة
                    height: screenWidth * 0.067, // نفس العرض للحفاظ على النسب
                    margin: EdgeInsets.only(
                        right: screenWidth * 0.022), // 2.2% من عرض الشاشة
                    decoration: BoxDecoration(
                      color: context.colorSurface,
                      borderRadius: BorderRadius.circular(
                          screenWidth * 0.033), // 3.3% من عرض الشاشة
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.333, // 33.3% من عرض الشاشة
                    height: screenHeight * 0.025, // 2.5% من ارتفاع الشاشة
                    decoration: BoxDecoration(
                      color: context.colorSurface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(
                          screenWidth * 0.028), // 2.8% من عرض الشاشة
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // محاكاة المحتوى الرئيسي مع تجاويف وتأثيرات حديثة
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            screenHeight * 0.0125, // 1.25% من ارتفاع الشاشة
            horizontalPadding,
            screenHeight * 0.0375, // 3.75% من ارتفاع الشاشة
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // محاكاة حقل البريد الإلكتروني
              _buildInputFieldPlaceholder(context),
              SizedBox(height: screenHeight * 0.02), // 2% من ارتفاع الشاشة

              // محاكاة حقل كلمة المرور
              _buildInputFieldPlaceholder(context),
              SizedBox(height: screenHeight * 0.02),

              // محاكاة رابط نسيت كلمة المرور
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: screenWidth * 0.417, // 41.7% من عرض الشاشة
                  height: screenHeight * 0.03, // 3% من ارتفاع الشاشة
                  margin: EdgeInsets.only(
                    top: screenHeight * 0.01, // 1% من ارتفاع الشاشة
                    bottom: screenHeight * 0.04, // 4% من ارتفاع الشاشة
                  ),
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.033), // 3.3% من عرض الشاشة
                  ),
                ),
              ),

              // محاكاة زر تسجيل الدخول
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    height: isSmallScreen
                        ? screenHeight * 0.065
                        : screenHeight * 0.075, // 6.5% أو 7.5% من ارتفاع الشاشة
                    margin: EdgeInsets.only(
                        bottom: screenHeight * 0.04), // 4% من ارتفاع الشاشة
                    decoration: BoxDecoration(
                      color: context.colorSurface,
                      borderRadius: BorderRadius.circular(
                          screenWidth * 0.044), // 4.4% من عرض الشاشة
                      boxShadow: [
                        BoxShadow(
                          color: context.isDarkMode
                              ? context.colorShadowColor
                              : Colors.grey.shade100,
                          blurRadius: 10 * _pulseAnimation.value,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // محاكاة فاصل أو سجل دخول باستخدام
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.025), // 2.5% من ارتفاع الشاشة
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: context.colorSurface,
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.444, // 44.4% من عرض الشاشة
                      height: screenHeight * 0.0375, // 3.75% من ارتفاع الشاشة
                      margin: EdgeInsets.symmetric(
                          horizontal:
                              screenWidth * 0.044), // 4.4% من عرض الشاشة
                      decoration: BoxDecoration(
                        color: context.colorSurface,
                        borderRadius: BorderRadius.circular(
                            screenWidth * 0.042), // 4.2% من عرض الشاشة
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: context.colorSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // محاكاة أزرار وسائل التواصل الاجتماعي
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButtonPlaceholder(context),
                  SizedBox(width: screenWidth * 0.056), // 5.6% من عرض الشاشة
                  _buildSocialButtonPlaceholder(context),
                  SizedBox(width: screenWidth * 0.056),
                  _buildSocialButtonPlaceholder(context),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // بناء عنصر محاكاة لحقل الإدخال
  Widget _buildInputFieldPlaceholder(BuildContext context) {
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.075, // 7.5% من ارتفاع الشاشة
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius:
            BorderRadius.circular(screenWidth * 0.044), // 4.4% من عرض الشاشة
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? context.colorShadowColor
                : Colors.grey.shade50,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // محاكاة الأيقونة
          Container(
            width: screenWidth * 0.139, // 13.9% من عرض الشاشة
            padding: EdgeInsets.all(screenWidth * 0.033), // 3.3% من عرض الشاشة
            child: Container(
              decoration: BoxDecoration(
                color: context.colorSurface,
                borderRadius: BorderRadius.circular(
                    screenWidth * 0.033), // 3.3% من عرض الشاشة
              ),
            ),
          ),
          // محاكاة حقل النص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.222, // 22.2% من عرض الشاشة
                  height: screenHeight * 0.015, // 1.5% من ارتفاع الشاشة
                  margin: EdgeInsets.only(
                      bottom: screenHeight * 0.0075), // 0.75% من ارتفاع الشاشة
                  decoration: BoxDecoration(
                    color: context.colorSurface,
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.017), // 1.7% من عرض الشاشة
                  ),
                ),
                Container(
                  width: screenWidth * 0.333, // 33.3% من عرض الشاشة
                  height: screenHeight * 0.02, // 2% من ارتفاع الشاشة
                  decoration: BoxDecoration(
                    color: context.colorSurface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.022), // 2.2% من عرض الشاشة
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء عنصر محاكاة لزر وسائل التواصل الاجتماعي
  Widget _buildSocialButtonPlaceholder(BuildContext context) {
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // حساب الحجم كنسبة من عرض الشاشة
    final buttonSize = isSmallScreen
        ? screenWidth * 0.128 // 12.8% من عرض الشاشة
        : screenWidth * 0.15; // 15% من عرض الشاشة

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(
                screenWidth * 0.044), // 4.4% من عرض الشاشة
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode
                    ? context.colorShadowColor
                    : Colors.grey.shade100,
                blurRadius: 5 * _pulseAnimation.value,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}