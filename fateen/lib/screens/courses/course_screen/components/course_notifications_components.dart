// components/course_notifications_components.dart
import 'package:flutter/material.dart';
import '../constants/course_notifications_constants.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class CourseNotificationsComponents {
  // عرض إشعارات معطلة
  static Widget buildDisabledNotificationsView(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.notifications_off_outlined,
            size: 60,
            color: context.colorPrimaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            CourseNotificationsConstants.notificationsDisabledMessage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colorPrimaryDark,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CourseNotificationsConstants.notificationsDisabledHint,
            style: TextStyle(
              fontSize: 14,
              color: context.colorTextSecondary,
              fontFamily: 'SYMBIOAR+LT',
            ),
          ),
        ],
      ),
    );
  }

  // بناء خيار مع مفتاح تبديل
  static Widget buildSwitchOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colorPrimaryDark,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: value ? context.colorSuccess : context.colorTextHint,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
        Switch(
          value: value,
          activeColor: context.colorPrimaryDark,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // بناء رقاقة اختيار
  static Widget buildChoiceChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'SYMBIOAR+LT',
        ),
      ),
      selected: isSelected,
      selectedColor: context.colorPrimaryPale,
      labelStyle: TextStyle(
        color: isSelected ? context.colorPrimaryDark : context.colorTextPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'SYMBIOAR+LT',
      ),
      backgroundColor:
          context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? context.colorPrimaryDark : Colors.transparent,
        ),
      ),
      onSelected: onSelected,
    );
  }

  // بناء زر رئيسي
  static Widget buildPrimaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorPrimaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'SYMBIOAR+LT',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء علامة السحب
  static Widget buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color:
              context.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
