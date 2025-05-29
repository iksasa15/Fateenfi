import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'components/ai_header_component.dart';
import 'components/ai_description_component.dart';
import 'components/ai_service_card_list_component.dart';
import 'controllers/ai_gpt_main_controller.dart';

class AiGptMainScreen extends StatefulWidget {
  const AiGptMainScreen({Key? key}) : super(key: key);

  @override
  _AiGptMainScreenState createState() => _AiGptMainScreenState();
}

class _AiGptMainScreenState extends State<AiGptMainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AiGptMainController();

    return Directionality(
      textDirection: TextDirection.rtl, // ضبط اتجاه النص من اليمين إلى اليسار
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFF),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // هيدر الصفحة
                const AiHeaderComponent(),

                // خط فاصل تحت الهيدر
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                ),

                // المحتوى الرئيسي
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 16),

                      // نص توضيحي
                      const AiDescriptionComponent(),
                      const SizedBox(height: 16),

                      // قائمة الخدمات
                      AiServiceCardListComponent(
                        servicesList: controller.getServicesList(context),
                      ),

                      // مساحة في الأسفل للتمرير بسهولة
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
