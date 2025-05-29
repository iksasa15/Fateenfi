import 'package:flutter/material.dart';

class NotesIcons {
  // الأيقونات المستخدمة في الفئات
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'برمجة':
        return Icons.code;
      case 'رياضيات':
        return Icons.functions;
      case 'مشاريع':
        return Icons.work_outline;
      case 'شبكات':
        return Icons.wifi;
      case 'عام':
      default:
        return Icons.note_alt_outlined;
    }
  }

  // أيقونات أخرى
  static const IconData add = Icons.add;
  static const IconData back = Icons.arrow_back_ios;
  static const IconData search = Icons.search;
  static const IconData clear = Icons.clear;
  static const IconData listView = Icons.view_list;
  static const IconData gridView = Icons.grid_view;
  static const IconData filter = Icons.filter_list;
  static const IconData favorite = Icons.star;
  static const IconData notFavorite = Icons.star_border;
  static const IconData edit = Icons.edit_outlined;
  static const IconData copy = Icons.copy_outlined;
  static const IconData share = Icons.share_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData check = Icons.check;
  static const IconData addCircle = Icons.add_circle_outline;
  static const IconData save = Icons.save_outlined;
  static const IconData editNote = Icons.edit_note;
  static const IconData forward = Icons.arrow_forward_ios;
  static const IconData category = Icons.category_outlined;
  static const IconData allInclusive = Icons.all_inclusive;
}
