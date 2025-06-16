// lib/screens/notes/components/note_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/note_model.dart';
import '../constants/notes_colors.dart';
import '../constants/notes_icons.dart';
import '../../../../core/constants/appColor.dart'; // Add this import
import '../../../../core/constants/app_dimensions.dart'; // Add this import

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
        NotesColors.categoryColors[note.category] ?? context.colorMediumPurple;

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.smallSpacing),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        boxShadow: [
          BoxShadow(
            color: context.colorShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: EdgeInsets.all(AppDimensions.defaultSpacing),
            child: Row(
              children: [
                // أيقونة الفئة
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.mediumRadius),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        NotesIcons.getCategoryIcon(note.category),
                        color: categoryColor,
                        size: AppDimensions.iconSize,
                      ),
                      if (note.isFavorite)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: context.colorBorder, width: 1),
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
                SizedBox(width: AppDimensions.defaultSpacing),

                // تفاصيل الملاحظة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // التصنيف
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.smallSpacing,
                                vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.smallRadius),
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
                              color: context.colorTextSecondary,
                              fontFamily: 'SYMBIOAR+LT',
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppDimensions.smallSpacing),

                      // العنوان
                      Text(
                        note.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppDimensions.subtitleFontSize,
                          color: context.colorPrimaryDark,
                          fontFamily: 'SYMBIOAR+LT',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4),

                      // المحتوى المختصر
                      Text(
                        note.content,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colorTextSecondary,
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
                    color: context.colorPrimaryPale,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    NotesIcons.forward,
                    color: context.colorPrimaryDark,
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
        NotesColors.categoryColors[note.category] ?? context.colorMediumPurple;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
        child: Container(
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(AppDimensions.largeRadius),
            boxShadow: [
              BoxShadow(
                color: context.colorShadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(AppDimensions.defaultSpacing),
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
                      borderRadius:
                          BorderRadius.circular(AppDimensions.smallRadius),
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
                      padding: EdgeInsets.all(4),
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

              SizedBox(height: AppDimensions.smallSpacing),

              // عنوان الملاحظة
              Text(
                note.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: context.colorPrimaryDark,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: AppDimensions.smallSpacing),

              // محتوى الملاحظة
              Expanded(
                child: Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colorTextSecondary,
                    height: 1.5,
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // تذييل البطاقة - التاريخ والتصنيف
              SizedBox(height: AppDimensions.smallSpacing),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // التصنيف
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.smallSpacing, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.smallRadius),
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
                      color: context.colorTextSecondary,
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
