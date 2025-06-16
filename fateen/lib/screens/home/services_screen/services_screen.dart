import 'package:fateen/models/service_item.dart';
import 'package:flutter/material.dart';
import 'controllers/services_controller.dart';
import 'controllers/service_card_controller.dart';
import 'constants/services_constants.dart';
import 'components/services_header_component_new.dart';
import 'components/services_grid_component.dart';
import '../../../../core/constants/appColor.dart';
import '../../../../core/constants/app_dimensions.dart';

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

  // قائمة الخدمات المفلترة
  List<ServiceItem> filteredServices = [];

  @override
  void initState() {
    super.initState();

    // تهيئة المتحكمات
    _servicesController = ServicesController();
    _servicesController.initAnimation(this);
    _cardController = ServiceCardController();

    // تخصيص الخدمات المعروضة - حاسبة المعدل ووقت المذاكرة والملاحظات فقط
    filteredServices = ServicesConstants.services.where((service) {
      return service.title == "حاسبة GPA" ||
          service.title == "وقت المذاكرة" ||
          service.title == "الملاحظات";
    }).toList();
  }

  @override
  void dispose() {
    _servicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorBackground,
      body: SafeArea(
        child: Column(
          children: [
            // هيدر الصفحة
            ServicesHeaderComponent.buildHeader(context),

            // محتوى الصفحة
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.sectionPadding),
                  child: ServicesGridComponent(
                    servicesController: _servicesController,
                    cardController: _cardController,
                    services: filteredServices,
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
