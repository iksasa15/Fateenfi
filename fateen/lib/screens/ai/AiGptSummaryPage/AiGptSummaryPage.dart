import 'package:flutter/material.dart';
import 'controllers/ai_summary_controller.dart';
import 'components/ai_summary_header_component.dart';
import 'components/ai_summary_input_component.dart';
import '../AiGptSummaryPage/components/ai_summary_display_component.dart';
import 'constants/ai_summary_colors.dart';
import 'constants/ai_summary_strings.dart';
import 'constants/ai_summary_dimensions.dart';

class AiGptSummaryPage extends StatefulWidget {
  const AiGptSummaryPage({Key? key}) : super(key: key);

  @override
  State<AiGptSummaryPage> createState() => _AiGptSummaryPageState();
}

class _AiGptSummaryPageState extends State<AiGptSummaryPage>
    with TickerProviderStateMixin {
  late AiSummaryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AiSummaryController(vsync: this);
    _controller.initializeAnimations();
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
              AiSummaryHeaderComponent(
                controller: _controller,
                title: AiSummaryStrings.pageTitle,
                onBackPressed: () => Navigator.pop(context),
                onResetPressed:
                    _controller.summary.isNotEmpty && !_controller.isLoading
                        ? () => _controller.resetContent(fullReset: true)
                        : null,
              ),

              // المحتوى الرئيسي
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // محتوى الصفحة الرئيسي
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              // إظهار نموذج الإدخال عندما لا يوجد ملخص
                              if (_controller.summary.isEmpty ||
                                  _controller.isLoading) {
                                // عرض مؤشر التحميل أثناء التوليد
                                if (_controller.isLoading &&
                                    _controller.summary.isEmpty) {
                                  return _buildLoadingComponent();
                                } else {
                                  // عرض نموذج الإدخال
                                  return AiSummaryInputComponent(
                                    controller: _controller,
                                    isLoading: _controller.isLoading,
                                    onGeneratePressed: () =>
                                        _controller.generateSummary(context),
                                  );
                                }
                              }
                              // عرض الملخص إذا كان موجوداً
                              else {
                                return AiSummaryDisplayComponent(
                                  controller: _controller,
                                  fadeAnimation: _controller.fadeAnimation,
                                  slideAnimation: _controller.slideAnimation,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
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
                      Icons.auto_awesome,
                      color: Color(0xFF4338CA),
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // رسالة التحميل
              Text(
                AiSummaryStrings.generatingSummaryText,
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
                AiSummaryStrings.waitMomentText,
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
