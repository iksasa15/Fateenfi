import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/bottom_nav/components/colorful_nav_bar.dart';
import '../screens/bottom_nav/controllers/bottom_nav_controller.dart';

/// شاشة التنقل بين الصفحات مع شريط التنقل السفلي
class BottomNavScreen extends StatefulWidget {
  final List<Widget> pages;
  final PageStorageBucket storageBucket;

  const BottomNavScreen({
    Key? key,
    required this.pages,
    required this.storageBucket,
  }) : super(key: key);

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  late BottomNavController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BottomNavController();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<BottomNavController>(
        builder: (context, controller, _) {
          return Scaffold(
            body: PageStorage(
              bucket: widget.storageBucket,
              child: IndexedStack(
                index: controller.selectedIndex,
                children: widget.pages,
              ),
            ),
            bottomNavigationBar: ColorfulNavBar(
              selectedIndex: controller.selectedIndex,
              onItemTapped: (index) => controller.changeIndex(index),
            ),
          );
        },
      ),
    );
  }
}
