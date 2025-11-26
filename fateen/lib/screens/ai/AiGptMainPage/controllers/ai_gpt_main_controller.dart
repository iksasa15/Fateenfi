import 'package:flutter/material.dart';
import '../../../../models/ai_service_model.dart';
import '../constants/ai_services_constants.dart';
import '../../AiGptQuestionsPage/ai_gpt_questions_screen.dart';
import '../../AiGptSummaryPage/AiGptSummaryPage.dart';
import '../../AiGptFlashcardsPage/AiGptFlashcardsPage.dart';
import '../../AiConceptExplainerPage/AiConceptExplainerPage.dart';
import '../../AimingPage/screens/home_screen.dart'; // استيراد صفحة التعرف على الصور

class AiGptMainController {
  List<AiServiceModel> getServicesList(BuildContext context) {
    return [
      // إنشاء أسئلة
      AiServiceModel(
        title: AiServicesConstants.questionsTitle,
        description: AiServicesConstants.questionsDescription,
        iconColor: AiServicesConstants.questionsColor,
        icon: Icons.question_answer_outlined,
        onTap: () => _navigateToPage(context, const AiGptQuestionsScreen()),
      ),

      // تلخيص المحتوى
      AiServiceModel(
        title: AiServicesConstants.summaryTitle,
        description: AiServicesConstants.summaryDescription,
        iconColor: AiServicesConstants.summaryColor,
        icon: Icons.summarize_outlined,
        onTap: () => _navigateToPage(context, const AiGptSummaryPage()),
      ),

      // بطاقات تعليمية
      AiServiceModel(
        title: AiServicesConstants.flashcardsTitle,
        description: AiServicesConstants.flashcardsDescription,
        iconColor: AiServicesConstants.flashcardsColor,
        icon: Icons.style_outlined,
        onTap: () => _navigateToPage(context, const AiGptFlashcardsPage()),
      ),

      // شرح المفاهيم
      AiServiceModel(
        title: AiServicesConstants.conceptsTitle,
        description: AiServicesConstants.conceptsDescription,
        iconColor: AiServicesConstants.conceptsColor,
        icon: Icons.lightbulb_outline,
        onTap: () => _navigateToPage(context, const AiConceptExplainerPage()),
      ),

      // التعرف على الصور (خدمة جديدة)
      AiServiceModel(
        title: AiServicesConstants.imageRecognitionTitle,
        description: AiServicesConstants.imageRecognitionDescription,
        iconColor: AiServicesConstants.imageRecognitionColor,
        icon: Icons.image_search,
        onTap: () => _navigateToPage(context, const HomeScreen()),
      ),
    ];
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
