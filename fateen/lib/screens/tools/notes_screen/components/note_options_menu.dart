// lib/screens/notes/components/note_options_menu.dart

import 'package:flutter/material.dart';
import '../../../../models/note_model.dart';
import '../constants/notes_colors.dart';
import '../constants/notes_strings.dart';
import '../constants/notes_icons.dart';
import '../../../../core/constants/appColor.dart'; // Add this import
import '../../../../core/constants/app_dimensions.dart'; // Add this import

class TaskOptionsMenu extends StatelessWidget {
  final Note note;
  final Function() onEdit;
  final Function() onToggleFavorite;
  final Function() onDuplicate;
  final Function() onShare;
  final Function() onDelete;

  const TaskOptionsMenu({
    Key? key,
    required this.note,
    required this.onEdit,
    required this.onToggleFavorite,
    required this.onDuplicate,
    required this.onShare,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: context.colorBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        _buildOptionItem(
          context,
          NotesStrings.editNoteOption,
          NotesIcons.edit,
          context.colorMediumPurple,
          onEdit,
        ),
        _buildOptionItem(
          context,
          note.isFavorite
              ? NotesStrings.removeFromFavorites
              : NotesStrings.addToFavorites,
          note.isFavorite ? NotesIcons.favorite : NotesIcons.notFavorite,
          Colors.amber,
          onToggleFavorite,
        ),
        _buildOptionItem(
          context,
          NotesStrings.duplicateNote,
          NotesIcons.copy,
          Colors.blue,
          onDuplicate,
        ),
        _buildOptionItem(
          context,
          NotesStrings.share,
          NotesIcons.share,
          Colors.green,
          onShare,
        ),
        Divider(color: context.colorDivider),
        _buildOptionItem(
          context,
          NotesStrings.deleteNote,
          NotesIcons.delete,
          context.colorAccent,
          onDelete,
          isDestructive: true,
        ),
        SizedBox(height: AppDimensions.sectionPadding),
      ],
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.sectionPadding,
            vertical: AppDimensions.smallSpacing),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
              ),
              child: Icon(
                icon,
                color: color,
                size: AppDimensions.smallIconSize,
              ),
            ),
            SizedBox(width: AppDimensions.defaultSpacing),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: AppDimensions.subtitleFontSize,
                color: isDestructive
                    ? context.colorAccent
                    : context.colorTextPrimary,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
