// lib/screens/notes/components/note_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/note_model.dart';
import '../constants/notes_colors.dart';
import '../constants/notes_icons.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isGridView;

  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    this.isGridView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isGridView ? _buildGridCard(context) : _buildListCard(context);
  }

  // بناء بطاقة في عرض القائمة
  Widget _buildListCard(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final categoryColor =
        NotesColors.categoryColors[note.category] ?? NotesColors.kMediumPurple;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // أيقونة الفئة
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        NotesIcons.getCategoryIcon(note.category),
                        color: categoryColor,
                        size: 24,
                      ),
                      if (note.isFavorite)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: NotesColors.kBorderColor, width: 1),
                            ),
                            child: const Icon(
                              NotesIcons.favorite,
                              color: Colors.amber,
                              size: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // تفاصيل الملاحظة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // التصنيف
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              note.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: categoryColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'SYMBIOAR+LT',
                              ),
                            ),
                          ),

                          const Spacer(),

                          // التاريخ
                          Text(
                            formatter.format(note.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // العنوان
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF4338CA),
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // المحتوى المختصر
                      Text(
                        note.content,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // سهم للانتقال
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    NotesIcons.forward,
                    color: Color(0xFF4338CA),
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء بطاقة في عرض الشبكة
  Widget _buildGridCard(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final categoryColor =
        NotesColors.categoryColors[note.category] ?? NotesColors.kMediumPurple;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة - رمز الفئة
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      NotesIcons.getCategoryIcon(note.category),
                      color: categoryColor,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  if (note.isFavorite)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        NotesIcons.favorite,
                        color: Colors.amber,
                        size: 14,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // عنوان الملاحظة
              Text(
                note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF4338CA),
                  fontFamily: 'SYMBIOAR+LT',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // محتوى الملاحظة
              Expanded(
                child: Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.5,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // تذييل البطاقة - التاريخ والتصنيف
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // التصنيف
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      note.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: categoryColor,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SYMBIOAR+LT',
                      ),
                    ),
                  ),

                  const Spacer(),

                  // التاريخ
                  Text(
                    formatter.format(note.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontFamily: 'SYMBIOAR+LT',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
