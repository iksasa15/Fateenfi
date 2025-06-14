import 'package:flutter/material.dart';
import '../../../../../core/constants/appColor.dart'; // Updated import
import '../../constants/signup_strings.dart';
import '../../../../../core/constants/app_dimensions.dart';

class SocialSignupComponent extends StatefulWidget {
  const SocialSignupComponent({Key? key}) : super(key: key);

  @override
  State<SocialSignupComponent> createState() => _SocialSignupComponentState();
}

class _SocialSignupComponentState extends State<SocialSignupComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // تتبع حالات التحوم على الأزرار
  final Map<String, bool> _hoverStates = {
    'google': false,
    'facebook': false,
    'apple': false,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateHoverState(String button, bool isHovered) {
    setState(() {
      _hoverStates[button] = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_animation),
        child: Column(
          children: [
            _buildSocialDivider(context),
            _buildSocialButtons(context),
          ],
        ),
      ),
    );
  }

  // فاصل أو سجل دخول باستخدام مع مراعاة حجم الشاشة
  Widget _buildSocialDivider(BuildContext context) {
    // الحصول على حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام والهوامش حسب حجم الشاشة
    final horizontalPadding = isSmallScreen ? 24.0 : 32.0;
    final fontSize = isTablet ? 16.0 : (isSmallScreen ? 12.0 : 14.0);
    final dividerPadding = isSmallScreen ? 12.0 : 16.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade300,
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dividerPadding),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: context.colorPrimaryPale
                    .withOpacity(0.3), // استخدام Extension
                borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
              ),
              child: Text(
                SignupStrings.orLoginWith,
                style: TextStyle(
                  color: context.colorPrimaryLight, // استخدام Extension
                  fontSize: fontSize,
                  fontFamily: 'SYMBIOAR+LT',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade200,
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // أزرار وسائل التواصل الاجتماعي المحسنة
  Widget _buildSocialButtons(BuildContext context) {
    // الحصول على حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // تعديل الأحجام والهوامش حسب حجم الشاشة
    final buttonSize = isTablet
        ? AppDimensions.buttonHeight - 10
        : (isSmallScreen
            ? AppDimensions.smallButtonHeight - 8
            : AppDimensions.buttonHeight - 14);
    final iconSize = isTablet ? 34.0 : (isSmallScreen ? 28.0 : 32.0);
    final spacing = isTablet ? 24.0 : (isSmallScreen ? 15.0 : 20.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEnhancedSocialButton(
            context: context,
            buttonKey: 'google',
            icon: Icons.g_mobiledata_rounded,
            color: context.colorGoogle, // استخدام Extension
            onTap: () {/* تنفيذ تسجيل باستخدام جوجل */},
            size: buttonSize,
            iconSize: iconSize,
            tooltip: "Google",
            isHovered: _hoverStates['google'] ?? false,
            onHover: (value) => _updateHoverState('google', value),
          ),
          SizedBox(width: spacing),
          _buildEnhancedSocialButton(
            context: context,
            buttonKey: 'facebook',
            icon: Icons.facebook_rounded,
            color: context.colorFacebook, // استخدام Extension
            onTap: () {/* تنفيذ تسجيل باستخدام فيسبوك */},
            size: buttonSize,
            iconSize: iconSize,
            tooltip: "Facebook",
            isHovered: _hoverStates['facebook'] ?? false,
            onHover: (value) => _updateHoverState('facebook', value),
          ),
          SizedBox(width: spacing),
          _buildEnhancedSocialButton(
            context: context,
            buttonKey: 'apple',
            icon: Icons.apple_rounded,
            color: context.colorApple, // استخدام Extension
            onTap: () {/* تنفيذ تسجيل باستخدام آبل */},
            size: buttonSize,
            iconSize: iconSize,
            tooltip: "Apple",
            isHovered: _hoverStates['apple'] ?? false,
            onHover: (value) => _updateHoverState('apple', value),
          ),
        ],
      ),
    );
  }

  // زر وسائط اجتماعية محسن بدون تأثير الضباب
  Widget _buildEnhancedSocialButton({
    required BuildContext context,
    required String buttonKey,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double size,
    required double iconSize,
    required String tooltip,
    required bool isHovered,
    required Function(bool) onHover,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: context.colorSurface, // استخدام Extension
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? color.withOpacity(0.2)
                      : context.colorShadowColor, // استخدام Extension
                  blurRadius: isHovered ? 8 : 5,
                  spreadRadius: isHovered ? 2 : 1,
                  offset: isHovered ? const Offset(0, 3) : const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: isHovered
                    ? color.withOpacity(0.3)
                    : context.colorBorder, // استخدام Extension
                width: isHovered ? 1.5 : 1,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isHovered
                    ? color.withOpacity(0.05)
                    : context.colorSurface, // استخدام Extension
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    icon,
                    color: color,
                    size: isHovered ? iconSize * 1.1 : iconSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
