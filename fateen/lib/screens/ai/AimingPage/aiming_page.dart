import 'package:flutter/material.dart';
import 'controllers/aiming_controller.dart';
import 'components/aiming_header_component.dart';
import 'components/aiming_input_component.dart';
import 'components/aiming_result_component.dart';
import 'constants/aiming_colors.dart';
import 'constants/aiming_strings.dart';
import 'constants/aiming_dimensions.dart';

class AimingPage extends StatefulWidget {
  const AimingPage({Key? key}) : super(key: key);

  @override
  State<AimingPage> createState() => _AimingPageState();
}

class _AimingPageState extends State<AimingPage> with TickerProviderStateMixin {
  late AimingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AimingController(vsync: this);
    _controller.initializeAnimations();
    _controller.checkServerStatus();
    // تم حذف استدعاء فتح الكاميرا تلقائيًا
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFF),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // هيدر الصفحة
              AimingHeaderComponent(
                controller: _controller,
                title: AimingStrings.pageTitle,
                onBackPressed: () => Navigator.pop(context),
                onResetPressed: _controller.recognizedObjects.isNotEmpty &&
                        !_controller.isLoading
                    ? () => _controller.resetContent()
                    : null,
              ),

              // المحتوى الرئيسي
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      // إذا كانت هناك نتائج للتعرف على الصورة
                      if (_controller.recognizedObjects.isNotEmpty &&
                          !_controller.isLoading) {
                        return AimingResultComponent(
                          controller: _controller,
                          fadeAnimation: _controller.fadeAnimation,
                          slideAnimation: _controller.slideAnimation,
                        );
                      }

                      // عرض مؤشر التحميل أثناء معالجة الصورة
                      if (_controller.isLoading) {
                        return _buildLoadingComponent();
                      }

                      // عرض نموذج إدخال الصورة
                      return AimingInputComponent(
                        controller: _controller,
                        isLoading: _controller.isLoading,
                        onImageProcessPressed: () =>
                            _controller.processImage(context),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // مكون التحميل
  Widget _buildLoadingComponent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE3E0F8),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة التحميل
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF5F3FF),
                  border: Border.all(
                    color: const Color(0xFFE3E0F8),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller.loadingController,
                        curve: Curves.linear,
                      ),
                    ),
                    child: const Icon(
                      Icons.image_search,
                      color: Color(0xFF4338CA),
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // رسالة التحميل
              Text(
                AimingStrings.processingImageText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // رسالة انتظار
              Text(
                AimingStrings.waitMomentText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontFamily: 'SYMBIOAR+LT',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // مؤشر خطي
              LinearProgressIndicator(
                backgroundColor: const Color(0xFFF5F3FF),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
