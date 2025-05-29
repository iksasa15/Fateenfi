import 'package:flutter/material.dart';
import 'controllers/ai_flashcards_controller.dart';
import 'components/ai_flashcards_header_component.dart';
import 'components/ai_flashcards_input_component.dart';
import 'components/ai_flashcards_display_component.dart';
import 'constants/ai_flashcards_colors.dart';
import 'constants/ai_flashcards_strings.dart';
import 'constants/ai_flashcards_dimensions.dart';

class AiGptFlashcardsPage extends StatefulWidget {
  const AiGptFlashcardsPage({Key? key}) : super(key: key);

  @override
  State<AiGptFlashcardsPage> createState() => _AiGptFlashcardsPageState();
}

class _AiGptFlashcardsPageState extends State<AiGptFlashcardsPage>
    with TickerProviderStateMixin {
  late AiFlashcardsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AiFlashcardsController(vsync: this);
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
              AiFlashcardsHeaderComponent(
                controller: _controller,
                title: AiFlashcardsStrings.pageTitle,
                onBackPressed: () => Navigator.pop(context),
                onResetPressed:
                    _controller.flashcards.isNotEmpty && !_controller.isLoading
                        ? () => _controller.resetContent(fullReset: true)
                        : null,
              ),

              // محتوى الصفحة الرئيسي
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _controller.formKey,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        // إظهار نموذج الإدخال عندما لا توجد بطاقات
                        if (_controller.flashcards.isEmpty ||
                            _controller.isLoading) {
                          // عرض مؤشر التحميل أثناء التوليد
                          if (_controller.isLoading &&
                              _controller.flashcards.isEmpty) {
                            return _buildLoadingComponent();
                          } else {
                            // عرض نموذج الإدخال
                            return AiFlashcardsInputComponent(
                              controller: _controller,
                              isLoading: _controller.isLoading,
                              onGeneratePressed: () =>
                                  _controller.generateFlashcards(context),
                            );
                          }
                        }
                        // عرض البطاقات إذا كانت موجودة
                        else {
                          return AiFlashcardsDisplayComponent(
                            controller: _controller,
                            fadeAnimation: _controller.fadeAnimation,
                            slideAnimation: _controller.slideAnimation,
                          );
                        }
                      },
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
                      Icons.star,
                      color: Color(0xFF4338CA),
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // نص التحميل
              Text(
                _controller.generatedFlashcardsCount > 0
                    ? AiFlashcardsStrings.generatingFlashcardCountText
                        .replaceFirst(
                            '%d', '${_controller.generatedFlashcardsCount + 1}')
                        .replaceFirst(
                            '%d', '${_controller.totalFlashcardsToGenerate}')
                    : AiFlashcardsStrings.generatingFlashcardsText,
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
                AiFlashcardsStrings.waitMomentText,
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
