import 'package:flutter/material.dart';
import 'controllers/services_controller.dart';
import 'controllers/service_card_controller.dart';
import 'constants/services_constants.dart';
import 'components/services_header_component_new.dart';
import 'components/services_grid_component.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  // المتحكمات
  late ServicesController _servicesController;
  late ServiceCardController _cardController;

  @override
  void initState() {
    super.initState();

    // تهيئة المتحكمات
    _servicesController = ServicesController();
    _servicesController.initAnimation(this);
    _cardController = ServiceCardController();
  }

  @override
  void dispose() {
    _servicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // هيدر الصفحة
            ServicesHeaderComponent.buildHeader(context),

            // خط فاصل
            ServicesHeaderComponent.buildDivider(),

            // محتوى الصفحة
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ServicesGridComponent(
                    servicesController: _servicesController,
                    cardController: _cardController,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
