// lib/screens/notes/components/note_options_menu.dart

import 'package:flutter/material.dart';
import '../../../../models/note_model.dart';
import '../constants/notes_colors.dart';
import '../constants/notes_strings.dart';
import '../constants/notes_icons.dart';

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
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        _buildOptionItem(
          NotesStrings.editNoteOption,
          NotesIcons.edit,
          NotesColors.kMediumPurple,
          onEdit,
        ),
        _buildOptionItem(
          note.isFavorite
              ? NotesStrings.removeFromFavorites
              : NotesStrings.addToFavorites,
          note.isFavorite ? NotesIcons.favorite : NotesIcons.notFavorite,
          Colors.amber,
          onToggleFavorite,
        ),
        _buildOptionItem(
          NotesStrings.duplicateNote,
          NotesIcons.copy,
          Colors.blue,
          onDuplicate,
        ),
        _buildOptionItem(
          NotesStrings.share,
          NotesIcons.share,
          Colors.green,
          onShare,
        ),
        const Divider(),
        _buildOptionItem(
          NotesStrings.deleteNote,
          NotesIcons.delete,
          NotesColors.kAccentColor,
          onDelete,
          isDestructive: true,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOptionItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: isDestructive
                    ? NotesColors.kAccentColor
                    : Colors.grey.shade800,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
