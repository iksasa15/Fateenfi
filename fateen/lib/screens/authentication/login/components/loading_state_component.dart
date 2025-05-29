import 'package:flutter/material.dart';
import '../constants/login_colors.dart';
import '../constants/login_dimensions.dart';

class LoadingStateComponent extends StatefulWidget {
  const LoadingStateComponent({Key? key}) : super(key: key);

  @override
  State<LoadingStateComponent> createState() => _LoadingStateComponentState();
}

class _LoadingStateComponentState extends State<LoadingStateComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                LoginColors.shimmerBase,
                LoginColors.shimmerHighlight,
                LoginColors.shimmerBase,
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
    return Column(
      children: [
        // محاكاة الهيدر مع تصميم محسن
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // محاكاة العنوان الرئيسي
              Container(
                width: 180,
                height: 32,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              // محاكاة العنوان الفرعي مع إيقونة
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // محاكاة المحتوى الرئيسي مع تجاويف وتأثيرات حديثة
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // محاكاة حقل البريد الإلكتروني
              _buildInputFieldPlaceholder(),
              const SizedBox(height: 16),

              // محاكاة حقل كلمة المرور
              _buildInputFieldPlaceholder(),
              const SizedBox(height: 16),

              // محاكاة رابط نسيت كلمة المرور
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 150,
                  height: 24,
                  margin: const EdgeInsets.only(top: 8, bottom: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(LoginDimensions.mediumRadius),
                  ),
                ),
              ),

              // محاكاة زر تسجيل الدخول
              Container(
                width: double.infinity,
                height: LoginDimensions.defaultButtonHeight,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              // محاكاة فاصل أو سجل دخول باستخدام
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      width: 160,
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // محاكاة أزرار وسائل التواصل الاجتماعي
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButtonPlaceholder(),
                  const SizedBox(width: 20),
                  _buildSocialButtonPlaceholder(),
                  const SizedBox(width: 20),
                  _buildSocialButtonPlaceholder(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // بناء عنصر محاكاة لحقل الإدخال
  Widget _buildInputFieldPlaceholder() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade50,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // محاكاة الأيقونة
          Container(
            width: 50,
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  width: 80,
                  height: 12,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
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
  Widget _buildSocialButtonPlaceholder() {
    return Container(
      width: LoginDimensions.socialButtonSize,
      height: LoginDimensions.socialButtonSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
