import 'package:flutter/material.dart';
import '../constants/bottom_nav_constants.dart';
import '../../../core/constants/appColor.dart';
import '../../../core/constants/app_dimensions.dart';

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
        color: context.colorSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // زيادة ارتفاع شريط التنقل ليناسب العناصر الأكبر
      child: SizedBox(
        height: 60, // زيادة من AppDimensions.extraSmallButtonHeight إلى 60
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
    final Color itemColor = BottomNavConstants.getSectionColor(context, index);

    // لون النص والأيقونة
    final Color textIconColor = isSelected ? itemColor : context.colorTextHint;

    // زيادة حجم الأيقونة
    final double iconSize =
        isSelected ? 24.0 : 22.0; // زيادة حجم الأيقونة بشكل ثابت

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: MediaQuery.of(context).size.width /
            BottomNavConstants.navigationLabels.length,
        padding: EdgeInsets.symmetric(
            horizontal: 4.0), // تقليل الهوامش للسماح بمساحة أكبر للمحتوى
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

            // زيادة المساحة بين الأيقونة والنص
            const SizedBox(height: 4),

            // النص - مع زيادة حجم الخط
            Text(
              BottomNavConstants.navigationLabels[index],
              style: TextStyle(
                color: textIconColor,
                fontSize: 12.0, // زيادة حجم الخط بشكل ثابت
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'SYMBIOAR+LT',
              ),
              textAlign: TextAlign.center,
              overflow:
                  TextOverflow.ellipsis, // منع النص من الانتشار لأكثر من سطر
            ),
          ],
        ),
      ),
    );
  }
}
