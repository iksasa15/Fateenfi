import 'package:flutter/material.dart';
import '../constants/task_categories_constants.dart';
import '../../../../core/constants/appColor.dart'; // استيراد ملف الألوان
import '../../../../core/constants/app_dimensions.dart'; // استيراد ملف الأبعاد

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
      borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
          boxShadow: [
            BoxShadow(
              color: context.colorShadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
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
                  size:
                      AppDimensions.getIconSize(context, size: IconSize.small, small: true),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.getSpacing(context,
                        size: SpacingSize.small),
                    vertical: AppDimensions.getSpacing(context,
                            size: SpacingSize.small) /
                        2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius / 2),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: TaskCategoriesConstants.fontFamily,
                      fontSize:
                          AppDimensions.getLabelFontSize(context, small: true),
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
                height:
                    AppDimensions.getSpacing(context, size: SpacingSize.small)),
            Text(
              title,
              style: TextStyle(
                fontFamily: TaskCategoriesConstants.fontFamily,
                fontSize: AppDimensions.getBodyFontSize(context),
                fontWeight: FontWeight.bold,
                color: context.colorTextPrimary,
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
