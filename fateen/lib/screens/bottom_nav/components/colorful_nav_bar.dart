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
    // لون القسم الحالي
    final Color currentSectionColor =
        BottomNavConstants.sectionColors[selectedIndex];

    // تحديد ارتفاع الشريط المناسب للجهاز
    final barHeight = BottomNavConstants.getBarHeight(context);

    return Container(
      height: barHeight,
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
              height: 2,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(BottomNavConstants.navigationLabels.length,
                (index) {
              return _buildNavItem(context, index);
            }),
          ),
        ],
      ),
    );
  }

  /// بناء عنصر التنقل
  Widget _buildNavItem(BuildContext context, int index) {
    // تحديد ما إذا كان هذا العنصر مختاراً
    final bool isSelected = index == selectedIndex;

    // لون العنصر الحالي
    final Color itemColor = BottomNavConstants.sectionColors[index];

    // لون النص والأيقونة (لون القسم إذا كان نشطاً، رمادي إذا لم يكن)
    final Color textIconColor = isSelected ? itemColor : Colors.grey.shade500;

    // حجم الأيقونة
    final double iconSize = isSelected
        ? BottomNavConstants.activeIconSize
        : BottomNavConstants.inactiveIconSize;

    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: BottomNavConstants.verticalPadding),

            // الأيقونة
            Icon(
              BottomNavConstants.navigationIcons[index],
              color: textIconColor,
              size: iconSize,
            ),

            const SizedBox(height: BottomNavConstants.labelTopPadding),

            // النص
            Text(
              BottomNavConstants.navigationLabels[index],
              style: TextStyle(
                color: textIconColor,
                fontSize: BottomNavConstants.labelFontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),

            // شريط المؤشر
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(
                  top: BottomNavConstants.indicatorTopMargin),
              height: BottomNavConstants.indicatorHeight,
              width: isSelected ? BottomNavConstants.indicatorWidth : 0,
              decoration: BoxDecoration(
                color: itemColor,
                borderRadius:
                    BorderRadius.circular(BottomNavConstants.indicatorRadius),
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

            const SizedBox(height: BottomNavConstants.verticalPadding),
          ],
        ),
      ),
    );
  }
}
