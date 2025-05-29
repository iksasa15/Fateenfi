// lib/screens/notes/components/empty_notes_state.dart

import 'package:flutter/material.dart';
import '../constants/notes_colors.dart';
import '../constants/notes_strings.dart';
import '../constants/notes_icons.dart';

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
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFiltering
                  ? Icons.search_off_rounded
                  : NotesIcons.getCategoryIcon(''),
              size: 80,
              color: const Color(0xFF4338CA),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isFiltering ? NotesStrings.noMatchingNotes : NotesStrings.noNotes,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4338CA),
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isFiltering
                ? NotesStrings.tryDifferentSearch
                : NotesStrings.startAddingNotes,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontFamily: 'SYMBIOAR+LT',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
