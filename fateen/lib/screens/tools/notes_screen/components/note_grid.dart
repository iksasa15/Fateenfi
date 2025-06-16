// lib/screens/notes/components/note_grid.dart

import 'package:flutter/material.dart';
import '../../../../models/note_model.dart';
import '../constants/notes_strings.dart';
import '../../../../core/constants/appColor.dart'; // Add this import
import '../../../../core/constants/app_dimensions.dart'; // Add this import
// Add this import
import 'note_card.dart';

class NotesGrid extends StatelessWidget {
  final List<Note> notes;
  final bool isSearching;
  final Function(Note) onNoteTap;
  final Function(Note) onNoteLongPress;

  const NotesGrid({
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85,
              ),
              itemCount: favoriteNotes.length,
              itemBuilder: (context, index) {
                return NoteCard(
                  note: favoriteNotes[index],
                  onTap: () => onNoteTap(favoriteNotes[index]),
                  onLongPress: () => onNoteLongPress(favoriteNotes[index]),
                  isGridView: true,
                );
              },
            ),
          ],

          // عنوان للملاحظات الأخرى
          if (hasFavorites && hasRegular && !isSearching) ...[
            SizedBox(height: AppDimensions.largeSpacing),
            Text(
              NotesStrings.allNotes,
              style: TextStyle(
                fontSize: AppDimensions.subtitleFontSize,
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            SizedBox(height: AppDimensions.smallSpacing),
          ],

          // عرض الملاحظات العادية
          if (hasRegular)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85,
              ),
              itemCount: regularNotes.length,
              itemBuilder: (context, index) {
                return NoteCard(
                  note: regularNotes[index],
                  onTap: () => onNoteTap(regularNotes[index]),
                  onLongPress: () => onNoteLongPress(regularNotes[index]),
                  isGridView: true,
                );
              },
            ),

          // إضافة مساحة في النهاية للتمرير
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
