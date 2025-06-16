// lib/screens/notes/components/note_list.dart

import 'package:flutter/material.dart';
import '../../../../models/note_model.dart';
import '../constants/notes_strings.dart';
import '../../../../core/constants/appColor.dart'; // Add this import
import '../../../../core/constants/app_dimensions.dart'; // Add this import
 // Add this import
import 'note_card.dart';

class NotesList extends StatelessWidget {
  final List<Note> notes;
  final bool isSearching;
  final Function(Note) onNoteTap;
  final Function(Note) onNoteLongPress;

  const NotesList({
    Key? key,
    required this.notes,
    this.isSearching = false,
    required this.onNoteTap,
    required this.onNoteLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تقسيم الملاحظات إلى مفضلة وعادية
    final favoriteNotes = notes.where((note) => note.isFavorite).toList();
    final regularNotes = notes.where((note) => !note.isFavorite).toList();

    final hasFavorites = favoriteNotes.isNotEmpty;
    final hasRegular = regularNotes.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عرض المفضلة أولاً
          if (hasFavorites && !isSearching) ...[
            Text(
              NotesStrings.favoriteNotes,
              style: TextStyle(
                fontSize: AppDimensions.subtitleFontSize,
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            SizedBox(height: AppDimensions.smallSpacing),
            ...favoriteNotes.map((note) => NoteCard(
                  note: note,
                  onTap: () => onNoteTap(note),
                  onLongPress: () => onNoteLongPress(note),
                )),
          ],

          // المسافة بين المفضلة والعادية
          if (hasFavorites && hasRegular && !isSearching)
            SizedBox(height: AppDimensions.sectionPadding),

          // عنوان للملاحظات العادية
          if (hasRegular && (hasFavorites || isSearching)) ...[
            if (!isSearching)
              Text(
                NotesStrings.allNotes,
                style: TextStyle(
                  fontSize: AppDimensions.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: context.colorPrimaryDark,
                  fontFamily: 'SYMBIOAR+LT',
                ),
              ),
            if (!isSearching) SizedBox(height: AppDimensions.smallSpacing),
          ],

          // عرض الملاحظات العادية
          if (hasRegular) ...[
            ...regularNotes.map((note) => NoteCard(
                  note: note,
                  onTap: () => onNoteTap(note),
                  onLongPress: () => onNoteLongPress(note),
                )),
          ],

          // إضافة مساحة في النهاية للتمرير
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
