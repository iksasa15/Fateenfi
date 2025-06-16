// lib/screens/notes/components/empty_notes_state.dart

import 'package:flutter/material.dart';
import '../constants/notes_colors.dart';
import '../constants/notes_strings.dart';
import '../constants/notes_icons.dart';
import '../../../../core/constants/appColor.dart'; // Add this import
import '../../../../core/constants/app_dimensions.dart'; // Add this import

class EmptyNotesState extends StatelessWidget {
  final bool isFiltering;
  final VoidCallback onAddNote;

  const EmptyNotesState({
    Key? key,
    this.isFiltering = false,
    required this.onAddNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الرمز في المنتصف
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: context.colorPrimaryPale,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFiltering
                  ? Icons.search_off_rounded
                  : NotesIcons.getCategoryIcon(''),
              size: AppDimensions.largeIconSize,
              color: context.colorPrimaryDark,
            ),
          ),
          SizedBox(height: AppDimensions.largeSpacing),
          Text(
            isFiltering ? NotesStrings.noMatchingNotes : NotesStrings.noNotes,
            style: TextStyle(
              fontSize: AppDimensions.smallTitleFontSize,
              fontWeight: FontWeight.bold,
              color: context.colorPrimaryDark,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          SizedBox(height: AppDimensions.smallSpacing),
          Text(
            isFiltering
                ? NotesStrings.tryDifferentSearch
                : NotesStrings.startAddingNotes,
            style: TextStyle(
              fontSize: AppDimensions.subtitleFontSize,
              color: context.colorTextSecondary,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
