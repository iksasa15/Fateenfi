import 'package:flutter/material.dart';
import '../controllers/service_card_controller.dart';
import '../controllers/services_controller.dart';
import '../../../../models/service_item.dart';

class ServiceCardComponent extends StatelessWidget {
  final ServiceItem service;
  final bool isPressed;
  final ServicesController servicesController;
  final ServiceCardController cardController;

  const ServiceCardComponent({
    Key? key,
    required this.service,
    required this.isPressed,
    required this.servicesController,
    required this.cardController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => cardController.navigateToService(context, service),
      onTapDown: (_) => servicesController.onCardPressed(service.title),
      onTapUp: (_) => servicesController.onCardReleased(),
      onTapCancel: () => servicesController.onCardReleased(),
      child: AnimatedBuilder(
        animation: servicesController.scaleAnimation!,
        builder: (context, child) {
          final scale =
              isPressed ? servicesController.scaleAnimation!.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade100,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // أيقونة الخدمة
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: service.iconColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    service.icon,
                    color: service.iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),

                // عنوان الخدمة
                Text(
                  service.title,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // وصف الخدمة (إذا وجد)
                if (service.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.description!,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontFamily: 'SYMBIOAR+LT',
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
