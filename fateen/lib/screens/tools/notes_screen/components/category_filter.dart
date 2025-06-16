// lib/screens/notes/components/category_filter.dart

import 'package:flutter/material.dart';
import '../constants/notes_colors.dart';
import '../constants/notes_strings.dart';
import '../constants/notes_icons.dart';
import '../../../../core/constants/appColor.dart'; // Add this import
import '../../../../core/constants/app_dimensions.dart'; // Add this import

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategorySelected;
  final Function() onFilterCleared;

  const CategoryFilter({
    Key? key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    required this.onFilterCleared,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: AppDimensions.defaultSpacing,
          bottom: AppDimensions.smallSpacing),
      padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.smallSpacing,
          vertical: AppDimensions.smallSpacing),
      decoration: BoxDecoration(
        color: context.colorPrimaryPale,
        borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
        border: Border.all(
          color: context.colorPrimaryExtraLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
              border: Border.all(
                color: context.colorPrimaryExtraLight,
                width: 1,
              ),
            ),
            child: Icon(
              NotesIcons.filter,
              color: _getCategoryColor(context, selectedCategory),
              size: 16,
            ),
          ),
          SizedBox(width: AppDimensions.smallSpacing),
          Text(
            '${NotesStrings.filterByCategory}$selectedCategory',
            style: TextStyle(
              color: context.colorPrimaryDark,
              fontWeight: FontWeight.w500,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onFilterCleared,
            style: TextButton.styleFrom(
              padding:
                  EdgeInsets.symmetric(horizontal: AppDimensions.smallSpacing),
              minimumSize: const Size(0, 0),
              foregroundColor: context.colorPrimaryLight,
            ),
            child: const Text(
              NotesStrings.clearFilter,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // الحصول على لون الفئة
  Color _getCategoryColor(BuildContext context, String category) {
    return NotesColors.categoryColors[category] ?? context.colorMediumPurple;
  }
}
