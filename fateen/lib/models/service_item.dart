import 'package:flutter/material.dart';

/// نموذج بيانات لكل خدمة مع لون للأيقونة
class ServiceItem {
  final String title;
  final String? description;
  final IconData icon;
  final Color iconColor;
  final Widget destination;

  ServiceItem({
    required this.title,
    this.description,
    required this.icon,
    required this.iconColor,
    required this.destination,
  });
}
