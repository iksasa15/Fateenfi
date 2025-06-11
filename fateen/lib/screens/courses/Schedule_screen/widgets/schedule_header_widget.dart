import 'package:flutter/material.dart';
import '../constants/schedule_header_constants.dart';
import '../controllers/schedule_view_controller.dart';

class ScheduleHeaderWidget extends StatelessWidget {
  final ScheduleViewController controller;
  final Function(bool)? onViewModeChanged;

  const ScheduleHeaderWidget({
    Key? key,
    required this.controller,
    this.onViewModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام دالة قياس حجم الشاشة
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 400;

    final double titleSize =
        isSmallScreen ? 20.0 : (isMediumScreen ? 22.0 : 24.0);
    final double iconSize =
        isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 22.0);
    final double buttonSize =
        isSmallScreen ? 38.0 : (isMediumScreen ? 42.0 : 46.0);
    final double horizontalPadding = screenSize.width * 0.04;
    final double verticalPadding = screenSize.height * 0.02;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // عنوان صفحة الجدول الدراسي
          Text(
            ScheduleHeaderConstants.screenTitle,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: ScheduleHeaderConstants.kTextColor,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),

          // زر تبديل نوع العرض (يومي/أسبوعي)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  controller.toggleViewMode();
                  if (onViewModeChanged != null) {
                    onViewModeChanged!(controller.showCalendarView);
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    controller.showCalendarView
                        ? Icons.view_list_rounded
                        : Icons.calendar_view_week_rounded,
                    key: ValueKey(controller.showCalendarView),
                    color: ScheduleHeaderConstants.kDarkPurple,
                    size: iconSize,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
