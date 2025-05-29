import 'package:flutter/material.dart';
import '../../../../models/ai_service_model.dart';
import 'ai_service_card_component.dart';
import 'package:animate_do/animate_do.dart';

class AiServiceCardListComponent extends StatelessWidget {
  final List<AiServiceModel> servicesList;

  const AiServiceCardListComponent({
    Key? key,
    required this.servicesList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: servicesList.length,
        itemBuilder: (context, index) {
          return AiServiceCardComponent(
            service: servicesList[index],
          );
        },
      ),
    );
  }
}
