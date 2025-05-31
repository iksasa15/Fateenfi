import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/constants/auth_colors.dart';
import '../constants/login_strings.dart';

class SocialLoginComponent extends StatefulWidget {
  const SocialLoginComponent({Key? key}) : super(key: key);

  @override
  State<SocialLoginComponent> createState() => _SocialLoginComponentState();
}

class _SocialLoginComponentState extends State<SocialLoginComponent>
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
      duration: const Duration(milliseconds: 600),
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
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ضبط القيم بناءً على حجم الشاشة
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // حساب الأبعاد كنسبة من حجم الشاشة
    final horizontalPadding = screenWidth * 0.06; // 6% من عرض الشاشة
    final verticalMargin = screenHeight * 0.025; // 2.5% من ارتفاع الشاشة
    final fontSize = isTablet
        ? screenWidth * 0.027
        : (isSmallScreen
            ? screenWidth * 0.033
            : screenWidth * 0.039); // نسبة من عرض الشاشة
    final dividerPadding = isSmallScreen
        ? screenWidth * 0.033
        : screenWidth * 0.044; // نسبة من عرض الشاشة

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalMargin),
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
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.008, // 0.8% من ارتفاع الشاشة
                horizontal: screenWidth * 0.033, // 3.3% من عرض الشاشة
              ),
              decoration: BoxDecoration(
                color: AuthColors.lightPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(
                    screenWidth * 0.03), // 3% من عرض الشاشة
              ),
              child: Text(
                LoginStrings.orLoginWith,
                style: TextStyle(
                  color: AuthColors.mediumPurple,
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
    // استخدام MediaQuery للحصول على أبعاد الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ضبط القيم بناءً على حجم الشاشة
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // حساب الأبعاد كنسبة من حجم الشاشة
    final buttonSize = isTablet
        ? screenWidth * 0.093
        : (isSmallScreen
            ? screenWidth * 0.128
            : screenWidth * 0.144); // نسبة من عرض الشاشة
    final iconSize = isTablet
        ? screenWidth * 0.057
        : (isSmallScreen
            ? screenWidth * 0.078
            : screenWidth * 0.089); // نسبة من عرض الشاشة
    final spacing = isTablet
        ? screenWidth * 0.04
        : (isSmallScreen
            ? screenWidth * 0.042
            : screenWidth * 0.056); // نسبة من عرض الشاشة

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: screenHeight * 0.015), // 1.5% من ارتفاع الشاشة
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEnhancedSocialButton(
            context: context,
            buttonKey: 'google',
            icon: Icons.g_mobiledata_rounded,
            color: AuthColors.googleColor,
            onTap: () {
              HapticFeedback.mediumImpact();
              /* تنفيذ تسجيل الدخول بواسطة جوجل */
            },
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
            color: AuthColors.facebookColor,
            onTap: () {
              HapticFeedback.mediumImpact();
              /* تنفيذ تسجيل الدخول بواسطة فيسبوك */
            },
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
            color: AuthColors.appleColor,
            onTap: () {
              HapticFeedback.mediumImpact();
              /* تنفيذ تسجيل الدخول بواسطة آبل */
            },
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
    // استخدام MediaQuery للحصول على حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;

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
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(screenWidth * 0.04), // 4% من عرض الشاشة
              boxShadow: [
                BoxShadow(
                  color:
                      isHovered ? color.withOpacity(0.2) : Colors.grey.shade200,
                  blurRadius: isHovered ? 8 : 5,
                  spreadRadius: isHovered ? 2 : 1,
                  offset: isHovered ? const Offset(0, 3) : const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color:
                    isHovered ? color.withOpacity(0.3) : Colors.grey.shade200,
                width: isHovered ? 1.5 : 1,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isHovered ? color.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.all(screenWidth * 0.022), // 2.2% من عرض الشاشة
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
