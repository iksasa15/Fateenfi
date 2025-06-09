import 'package:flutter/material.dart';
import '../constants/bottom_nav_constants.dart';

/// شريط التنقل السفلي العصري
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
    // حساب منطقة الأمان للأجهزة مثل iPhone X
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        height: 42,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(BottomNavConstants.navigationLabels.length,
              (index) {
            return _buildNavItem(context, index);
          }),
        ),
      ),
    );
  }

  /// بناء عنصر التنقل
  Widget _buildNavItem(BuildContext context, int index) {
    // تحديد ما إذا كان هذا العنصر مختاراً
    final bool isSelected = index == selectedIndex;

    // لون العنصر الحالي
    final Color itemColor = BottomNavConstants.sectionColors[index];

    // لون النص والأيقونة
    final Color textIconColor = isSelected ? itemColor : Colors.grey.shade500;

    // حجم الأيقونة معدل ليناسب المساحة المتاحة
    final double iconSize = isSelected ? 24.0 : 22.0;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: MediaQuery.of(context).size.width /
            BottomNavConstants.navigationLabels.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // استخدام LayoutBuilder للتأكد من أن العناصر تناسب الارتفاع المتاح
            return IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الأيقونة
                  Icon(
                    BottomNavConstants.navigationIcons[index],
                    color: textIconColor,
                    size: iconSize,
                  ),

                  // مسافة صغيرة للغاية
                  SizedBox(height: constraints.maxHeight * 0.05),

                  // النص - باستخدام FittedBox لضمان ملاءمته للمساحة
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      BottomNavConstants.navigationLabels[index],
                      style: TextStyle(
                        color: textIconColor,
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
