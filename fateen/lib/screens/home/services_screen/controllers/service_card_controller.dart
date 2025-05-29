import 'package:flutter/material.dart';
import '../../../../models/service_item.dart';

class ServiceCardController {
  // انتقال إلى الشاشة المستهدفة
  void navigateToService(BuildContext context, ServiceItem service) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => service.destination),
    );
  }
}
