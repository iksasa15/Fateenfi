import 'package:flutter/material.dart';
import '../controllers/services_controller.dart';
import '../controllers/service_card_controller.dart';
import '../constants/services_constants.dart';
import '../components/service_card_component.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';
class ServicesGridComponent extends StatelessWidget {
  final ServicesController servicesController;
  final ServiceCardController cardController;

  const ServicesGridComponent({
    Key? key,
    required this.servicesController,
    required this.cardController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: AppDimensions.defaultSpacing),
      itemCount: ServicesConstants.services.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.smallSpacing + 4,
        mainAxisSpacing: AppDimensions.smallSpacing + 4,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final service = ServicesConstants.services[index];
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
