// components/page_navigation_component.dart

import 'package:flutter/material.dart';
import '../constants/whiteboard_colors.dart';

class PageNavigationComponent extends StatelessWidget {
  final int currentPageIndex;
  final int pageCount;
  final Function() onPreviousPage;
  final Function() onNextPage;
  final Function() onAddNewPage;
  final Function() onShowPageSelector;

  const PageNavigationComponent({
    Key? key,
    required this.currentPageIndex,
    required this.pageCount,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onAddNewPage,
    required this.onShowPageSelector,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : WhiteboardColors.kLightPurple,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: WhiteboardColors.kShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // زر الصفحة السابقة
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
              size: 18,
            ),
            onPressed: currentPageIndex > 0 ? onPreviousPage : null,
            tooltip: 'الصفحة السابقة',
          ),

          // رقم الصفحة الحالية
          Expanded(
            child: GestureDetector(
              onTap: onShowPageSelector,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'صفحة ${currentPageIndex + 1} من $pageCount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white
                            : WhiteboardColors.kDarkPurple,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDarkMode
                          ? WhiteboardColors.kMediumPurple
                          : WhiteboardColors.kDarkPurple,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // زر إضافة صفحة جديدة
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
              size: 22,
            ),
            onPressed: onAddNewPage,
            tooltip: 'إضافة صفحة جديدة',
          ),

          // زر الصفحة التالية
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode
                  ? WhiteboardColors.kMediumPurple
                  : WhiteboardColors.kDarkPurple,
              size: 18,
            ),
            onPressed:
                currentPageIndex < pageCount - 1 ? onNextPage : onAddNewPage,
            tooltip: 'الصفحة التالية',
          ),
        ],
      ),
    );
  }
}
