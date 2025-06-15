import 'package:flutter/material.dart';
import '../controllers/service_card_controller.dart';
import '../controllers/services_controller.dart';
import '../../../../models/service_item.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';
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
            borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
            side: BorderSide(
              color: context.colorDivider,
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.defaultSpacing),
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
                    borderRadius:
                        BorderRadius.circular(AppDimensions.smallRadius),
                  ),
                  child: Icon(
                    service.icon,
                    color: service.iconColor,
                    size: 26,
                  ),
                ),
                SizedBox(height: AppDimensions.smallSpacing + 4),

                // عنوان الخدمة
                Text(
                  service.title,
                  style: TextStyle(
                    color: context.colorTextPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: AppDimensions.smallBodyFontSize,
                    fontFamily: 'SYMBIOAR+LT',
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // وصف الخدمة (إذا وجد)
                if (service.description != null) ...[
                  SizedBox(height: AppDimensions.smallSpacing / 2),
                  Text(
                    service.description!,
                    style: TextStyle(
                      color: context.colorTextSecondary,
                      fontSize: AppDimensions.smallLabelFontSize - 2,
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
