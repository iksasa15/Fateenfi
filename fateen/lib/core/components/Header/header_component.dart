import 'package:flutter/material.dart';
import '../../constants/appColor.dart';
import '../../constants/app_dimensions.dart';

class HeaderComponent extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool showWavingHand;
  final List<Color> gradientColors;
  final Color? iconColor;
  final Color? subtitleColor;

  const HeaderComponent({
    Key? key,
    required this.title,
    required this.subtitle,
    this.showWavingHand = true,
    this.gradientColors = const [
      AppColors.primaryDark, // Updated from darkPurple
      AppColors.primaryLight, // Updated from mediumPurple
    ],
    this.iconColor,
    this.subtitleColor,
  }) : super(key: key);

  @override
  State<HeaderComponent> createState() => _HeaderComponentState();
}

class _HeaderComponentState extends State<HeaderComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final actualIconColor = widget.iconColor ??
        AppColors.accent.withOpacity(0.7); // Updated from accentColor
    final actualSubtitleColor =
        widget.subtitleColor ?? AppColors.textHint; // Updated from hintColor

    return Container(
      padding: EdgeInsets.fromLTRB(
          AppDimensions.getSpacing(context, size: SpacingSize.large),
          AppDimensions.getSpacing(context, size: SpacingSize.extraLarge) + 8,
          AppDimensions.getSpacing(context, size: SpacingSize.large),
          AppDimensions.getSpacing(context, size: SpacingSize.medium)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان مع تأثير تدرج لوني
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                widget.gradientColors[0],
                widget.gradientColors.length > 1
                    ? widget.gradientColors[1].withOpacity(0.9)
                    : widget.gradientColors[0].withOpacity(0.7),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ).createShader(bounds),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: AppDimensions.getTitleFontSize(context,
                    small: isSmallScreen),
                fontWeight: FontWeight.bold,
                color: Colors.white, // ستتغير بسبب الماسك
                fontFamily: 'SYMBIOAR+LT',
                letterSpacing: 0.3,
              ),
            ),
          ),
          SizedBox(
              height:
                  AppDimensions.getSpacing(context, size: SpacingSize.small)),
          Row(
            children: [
              // أيقونة ترحيبية متحركة - تظهر فقط إذا كانت showWavingHand = true
              if (widget.showWavingHand)
                AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _waveAnimation.value * 0.2,
                      child: Icon(
                        Icons.waving_hand_rounded,
                        color: actualIconColor,
                        size: AppDimensions.getSubtitleFontSize(context,
                                small: isSmallScreen) +
                            2,
                      ),
                    );
                  },
                ),
              if (widget.showWavingHand)
                SizedBox(
                    width: AppDimensions.getSpacing(context,
                            size: SpacingSize.small) /
                        2),
              Expanded(
                child: Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: AppDimensions.getSubtitleFontSize(context,
                        small: isSmallScreen),
                    color: actualSubtitleColor,
                    fontFamily: 'SYMBIOAR+LT',
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
