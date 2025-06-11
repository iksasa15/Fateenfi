import 'package:flutter/material.dart';
import '../constants/task_categories_constants.dart';

class TaskCategoryCardWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const TaskCategoryCardWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(TaskCategoriesConstants.cardBorderRadius),
      child: Container(
        padding: EdgeInsets.all(TaskCategoriesConstants.cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(TaskCategoriesConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(TaskCategoriesConstants.shadowOpacity),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(TaskCategoriesConstants.borderOpacity),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: TaskCategoriesConstants.cardIconSize,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color
                        .withOpacity(TaskCategoriesConstants.backgroundOpacity),
                    borderRadius: BorderRadius.circular(
                        TaskCategoriesConstants.badgeBorderRadius),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: TaskCategoriesConstants.fontFamily,
                      fontSize: TaskCategoriesConstants.badgeFontSize,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: TaskCategoriesConstants.fontFamily,
                fontSize: TaskCategoriesConstants.cardTitleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
