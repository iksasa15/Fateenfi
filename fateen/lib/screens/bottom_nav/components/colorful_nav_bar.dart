import 'package:flutter/material.dart';
import '../constants/bottom_nav_constants.dart';

/// شريط التنقل السفلي الملون
class ColorfulNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const ColorfulNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة
    final Size screenSize = MediaQuery.of(context).size;

    // لون القسم الحالي
    final Color currentSectionColor =
        BottomNavConstants.sectionColors[selectedIndex];

    // تحديد ارتفاع الشريط المناسب للجهاز
    final barHeight = BottomNavConstants.getBarHeight(context);

    // الحصول على الهامش السفلي المناسب للشريط
    final padding = BottomNavConstants.getNavBarPadding(context);

    return Container(
      height: barHeight + padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // خط علوي ملون يتغير حسب القسم
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenSize.height * 0.0025, // 0.25% من ارتفاع الشاشة
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentSectionColor.withOpacity(0.7),
                    currentSectionColor.withOpacity(0.3),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          // عناصر التنقل
          Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                  BottomNavConstants.navigationLabels.length, (index) {
                return _buildNavItem(context, index);
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء عنصر التنقل
  Widget _buildNavItem(BuildContext context, int index) {
    // الحصول على أبعاد الشاشة
    final Size screenSize = MediaQuery.of(context).size;

    // تحديد ما إذا كان هذا العنصر مختاراً
    final bool isSelected = index == selectedIndex;

    // لون العنصر الحالي
    final Color itemColor = BottomNavConstants.sectionColors[index];

    // لون النص والأيقونة (لون القسم إذا كان نشطاً، رمادي إذا لم يكن)
    final Color textIconColor = isSelected ? itemColor : Colors.grey.shade500;

    // حجم الأيقونة
    final double iconSize = isSelected
        ? BottomNavConstants.getActiveIconSize(context)
        : BottomNavConstants.getInactiveIconSize(context);

    // هل الشاشة صغيرة؟
    final bool isSmallScreen = screenSize.width < 360;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemTapped(index),
          splashColor: itemColor.withOpacity(0.1),
          highlightColor: itemColor.withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: BottomNavConstants.getVerticalPadding(context)),

              // الأيقونة
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  BottomNavConstants.navigationIcons[index],
                  color: textIconColor,
                  size: iconSize,
                ),
              ),

              SizedBox(height: BottomNavConstants.getLabelTopPadding(context)),

              // النص
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: textIconColor,
                  fontSize: BottomNavConstants.getLabelFontSize(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                child: Text(
                  BottomNavConstants.navigationLabels[index],
                ),
              ),

              // شريط المؤشر
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuart,
                margin: EdgeInsets.only(
                    top: BottomNavConstants.getIndicatorTopMargin(context)),
                height: BottomNavConstants.getIndicatorHeight(context),
                width: isSelected
                    ? BottomNavConstants.getIndicatorWidth(context)
                    : 0,
                decoration: BoxDecoration(
                  color: itemColor,
                  borderRadius: BorderRadius.circular(
                      BottomNavConstants.getIndicatorRadius(context)),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: itemColor.withOpacity(0.5),
                            blurRadius: 3,
                            spreadRadius: -1,
                            offset: const Offset(0, 0),
                          )
                        ]
                      : null,
                ),
              ),

              SizedBox(height: BottomNavConstants.getVerticalPadding(context)),
            ],
          ),
        ),
      ),
    );
  }
}
