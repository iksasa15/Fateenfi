import 'package:fateen/models/service_item.dart';
import 'package:flutter/material.dart';
import '../controllers/services_controller.dart';
import '../controllers/service_card_controller.dart';
import '../components/service_card_component.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

class ServicesGridComponent extends StatelessWidget {
  final ServicesController servicesController;
  final ServiceCardController cardController;
  final List<ServiceItem> services;

  const ServicesGridComponent({
    Key? key,
    required this.servicesController,
    required this.cardController,
    required this.services,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: AppDimensions.defaultSpacing),
      itemCount: services.length, // استخدام القائمة المفلترة
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.smallSpacing + 4,
        mainAxisSpacing: AppDimensions.smallSpacing + 4,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final service = services[index]; // استخدام القائمة المفلترة
        final isPressed =
            servicesController.currentPressedCard == service.title;

        return ServiceCardComponent(
          service: service,
          isPressed: isPressed,
          servicesController: servicesController,
          cardController: cardController,
        );
      },
    );
  }
}
